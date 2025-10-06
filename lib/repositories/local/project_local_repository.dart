import 'dart:convert';

import 'package:catatan_kaki/database/app_database.dart';
import 'package:catatan_kaki/models/project.dart' as domain;
import 'package:drift/drift.dart';

class ProjectLocalRepository {
  ProjectLocalRepository(this._db);

  final AppDatabase _db;

  domain.Project _mapDataToModel(Project data) {
    return domain.Project(
      id: data.id,
      userId: data.userId,
      title: data.title,
      description: data.description,
      longDescription: data.longDescription,
      category: data.category,
      environment: data.environment,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      notesCount: data.notesCount,
      todosCount: data.todosCount,
      revisionsCount: data.revisionsCount,
      completedTodosCount: data.completedTodosCount,
    );
  }

  ProjectsCompanion _mapModelToCompanion(domain.Project model) {
    return ProjectsCompanion(
      id: Value(model.id),
      userId: Value(model.userId),
      title: Value(model.title),
      description: Value(model.description),
      longDescription: Value(model.longDescription),
      category: Value(model.category),
      environment: Value(model.environment),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
      notesCount: Value(model.notesCount),
      todosCount: Value(model.todosCount),
      revisionsCount: Value(model.revisionsCount),
      completedTodosCount: Value(model.completedTodosCount),
    );
  }

  Stream<List<domain.Project>> watchAllProjects() {
    return _db.select(_db.projects).watch().map((rows) {
      return rows.map(_mapDataToModel).toList();
    });
  }

  Future<void> insertOrUpdateProject(domain.Project project) async {
    final existing = await getProjectById(project.id);
    final operation = existing == null ? 'create' : 'update';

    await _db.transaction(() async {
      final companion = _mapModelToCompanion(project);
      await _db.into(_db.projects).insertOnConflictUpdate(companion);

      await _db.into(_db.syncQueue).insert(
            SyncQueueCompanion.insert(
              entityType: 'project',
              entityId: project.id,
              operation: operation,
              payload: jsonEncode(project.toJson()),
            ),
          );
    });
  }

  Future<void> insertOrUpdateProjects(List<domain.Project> remoteProjects) async {
    if (remoteProjects.isEmpty) return;

    final remoteIds = remoteProjects.map((p) => p.id).toList();
    final existingLocals = await (_db.select(_db.projects)..where((tbl) => tbl.id.isIn(remoteIds))).get();
    final localMap = {for (var p in existingLocals) p.id: p};

    final companionsToUpsert = <ProjectsCompanion>[];

    for (final remote in remoteProjects) {
      final local = localMap[remote.id];
      if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
        companionsToUpsert.add(_mapModelToCompanion(remote));
      }
    }

    if (companionsToUpsert.isNotEmpty) {
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(_db.projects, companionsToUpsert);
      });
    }
  }

  Future<void> deleteProject(String id) async {
    await _db.transaction(() async {
      await (_db.delete(_db.projects)..where((tbl) => tbl.id.equals(id))).go();

      await _db.into(_db.syncQueue).insert(
            SyncQueueCompanion.insert(
              entityType: 'project',
              entityId: id,
              operation: 'delete',
              payload: jsonEncode({'id': id}),
            ),
          );
    });
  }

  Future<domain.Project?> getProjectById(String id) {
    return (_db.select(_db.projects)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull()
        .then((data) => data != null ? _mapDataToModel(data) : null);
  }

  Stream<domain.Project?> watchProjectById(String id) {
    return (_db.select(_db.projects)..where((tbl) => tbl.id.equals(id)))
        .watchSingleOrNull()
        .map((data) => data != null ? _mapDataToModel(data) : null);
  }

  Future<void> deleteAll() {
    return _db.delete(_db.projects).go();
  }
}
