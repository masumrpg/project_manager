import 'dart:convert';

import 'package:catatan_kaki/database/app_database.dart';
import 'package:catatan_kaki/models/enums/sync_status.dart';
import 'package:catatan_kaki/models/note.dart';
import 'package:catatan_kaki/models/project.dart';
import 'package:catatan_kaki/models/revision.dart';
import 'package:catatan_kaki/models/todo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

class SyncService {
  SyncService(this._ref);

  final Ref _ref;

  Future<void> syncProjects() async {
    final syncStatusNotifier = _ref.read(syncStatusProvider.notifier);
    final metadataRepo = _ref.read(syncMetadataRepositoryProvider);

    syncStatusNotifier.state = SyncStatus.syncing;

    try {
      await _pushLocalChanges();
      await _pullRemoteChanges();

      await metadataRepo.setLastSyncTimestamp(DateTime.now());
      syncStatusNotifier.state = SyncStatus.success;
    } catch (e) {
      syncStatusNotifier.state = SyncStatus.error;
      _ref.read(syncErrorProvider.notifier).state = e.toString();
      print('Sync failed: $e');
      rethrow;
    }
  }

  Future<void> _pullRemoteChanges() async {
    final remoteRepo = _ref.read(projectRepositoryProvider);
    final projectLocalRepo = _ref.read(projectLocalRepositoryProvider);
    final noteLocalRepo = _ref.read(noteLocalRepositoryProvider);
    final revisionLocalRepo = _ref.read(revisionLocalRepositoryProvider);
    final todoLocalRepo = _ref.read(todoLocalRepositoryProvider);

    try {
      // 1. Pull all projects
      final remoteProjects = await remoteRepo.getAllProjects();
      await projectLocalRepo.insertOrUpdateProjects(remoteProjects);

      // 2. For each project, pull its children
      for (final project in remoteProjects) {
        final detailedProject = await remoteRepo.getProjectById(project.id);
        if (detailedProject != null) {
          if (detailedProject.notes.isNotEmpty) {
            await noteLocalRepo.insertOrUpdateNotes(detailedProject.notes);
          }
          if (detailedProject.revisions.isNotEmpty) {
            await revisionLocalRepo.insertOrUpdateRevisions(detailedProject.revisions);
          }
          if (detailedProject.todos.isNotEmpty) {
            await todoLocalRepo.insertOrUpdateTodos(detailedProject.todos);
          }
        }
      }
    } catch (e) {
      print('Sync pull failed: $e');
      rethrow;
    }
  }

  Future<void> _pushLocalChanges() async {
    final db = _ref.read(appDatabaseProvider);
    final remoteRepo = _ref.read(projectRepositoryProvider);
    final queueItems = await (db.select(db.syncQueue)..where((tbl) => tbl.attempts < 5)).get();

    for (final item in queueItems) {
      try {
        final payload = jsonDecode(item.payload);

        if (item.entityType == 'project') {
          if (item.operation == 'create') {
            final project = Project.fromJson(payload);
            await remoteRepo.createProject(project);
          } else if (item.operation == 'update') {
            final project = Project.fromJson(payload);
            await remoteRepo.updateProject(project);
          } else if (item.operation == 'delete') {
            final id = payload['id'] as String;
            await remoteRepo.deleteProject(id);
          }
        } else if (item.entityType == 'note') {
          if (item.operation == 'create') {
            final note = Note.fromJson(payload);
            await remoteRepo.addNoteToProject(note.projectId, note);
          } else if (item.operation == 'update') {
            final note = Note.fromJson(payload);
            await remoteRepo.updateNote(note.projectId, note);
          } else if (item.operation == 'delete') {
            final projectId = payload['projectId'] as String;
            final noteId = payload['id'] as String;
            await remoteRepo.removeNoteFromProject(projectId, noteId);
          }
        } else if (item.entityType == 'revision') {
          if (item.operation == 'create') {
            final revision = Revision.fromJson(payload);
            await remoteRepo.addRevisionToProject(revision.projectId, revision);
          } else if (item.operation == 'update') {
            final revision = Revision.fromJson(payload);
            await remoteRepo.updateRevision(revision.projectId, revision);
          } else if (item.operation == 'delete') {
            final projectId = payload['projectId'] as String;
            final revisionId = payload['id'] as String;
            await remoteRepo.removeRevisionFromProject(projectId, revisionId);
          }
        } else if (item.entityType == 'todo') {
          if (item.operation == 'create') {
            final todo = Todo.fromJson(payload);
            await remoteRepo.addTodoToProject(todo.projectId, todo);
          } else if (item.operation == 'update') {
            final todo = Todo.fromJson(payload);
            await remoteRepo.updateTodo(todo.projectId, todo);
          } else if (item.operation == 'delete') {
            final projectId = payload['projectId'] as String;
            final todoId = payload['id'] as String;
            await remoteRepo.removeTodoFromProject(projectId, todoId);
          }
        }

        // If successful, delete from queue
        await (db.delete(db.syncQueue)..where((tbl) => tbl.id.equals(item.id))).go();
      } catch (e) {
        print('Failed to sync item ${item.id}: $e');
        // Increment attempt counter
        await (db.update(db.syncQueue)..where((tbl) => tbl.id.equals(item.id)))
            .write(SyncQueueCompanion(attempts: Value(item.attempts + 1)));
      }
    }
  }
}