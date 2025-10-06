import 'dart:convert';

import 'package:catatan_kaki/database/app_database.dart';
import 'package:catatan_kaki/models/note.dart' as domain;
import 'package:drift/drift.dart';

class NoteLocalRepository {
  NoteLocalRepository(this._db);

  final AppDatabase _db;

  domain.Note _mapDataToModel(Note data) {
    return domain.Note(
      id: data.id,
      projectId: data.projectId,
      title: data.title,
      description: data.description,
      content: data.content,
      status: data.status,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  NotesCompanion _mapModelToCompanion(domain.Note model) {
    return NotesCompanion(
      id: Value(model.id),
      projectId: Value(model.projectId),
      title: Value(model.title),
      description: Value(model.description),
      content: Value(model.content),
      status: Value(model.status),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  Stream<List<domain.Note>> watchNotesForProject(String projectId) {
    final query = _db.select(_db.notes)
      ..where((tbl) => tbl.projectId.equals(projectId));
    return query.watch().map((rows) => rows.map(_mapDataToModel).toList());
  }

  Future<void> insertOrUpdateNote(domain.Note note) async {
    final existing = await (_db.select(_db.notes)..where((tbl) => tbl.id.equals(note.id))).getSingleOrNull();
    final operation = existing == null ? 'create' : 'update';

    await _db.transaction(() async {
      final companion = _mapModelToCompanion(note);
      await _db.into(_db.notes).insertOnConflictUpdate(companion);

      await _db.into(_db.syncQueue).insert(
            SyncQueueCompanion.insert(
              entityType: 'note',
              entityId: note.id,
              operation: operation,
              payload: jsonEncode(note.toJson()),
            ),
          );
    });
  }

  Future<void> deleteNote(String noteId) async {
    final note = await (_db.select(_db.notes)..where((tbl) => tbl.id.equals(noteId))).getSingleOrNull();
    if (note == null) return;

    await _db.transaction(() async {
      await (_db.delete(_db.notes)..where((tbl) => tbl.id.equals(noteId))).go();

      await _db.into(_db.syncQueue).insert(
            SyncQueueCompanion.insert(
              entityType: 'note',
              entityId: noteId,
              operation: 'delete',
              payload: jsonEncode({'id': noteId, 'projectId': note.projectId}),
            ),
          );
    });
  }

  Future<void> insertOrUpdateNotes(List<domain.Note> remoteNotes) async {
    if (remoteNotes.isEmpty) return;

    final remoteIds = remoteNotes.map((n) => n.id).toList();
    final existingLocals = await (_db.select(_db.notes)..where((tbl) => tbl.id.isIn(remoteIds))).get();
    final localMap = {for (var n in existingLocals) n.id: n};

    final companionsToUpsert = <NotesCompanion>[];

    for (final remote in remoteNotes) {
      final local = localMap[remote.id];
      if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
        companionsToUpsert.add(_mapModelToCompanion(remote));
      }
    }

    if (companionsToUpsert.isNotEmpty) {
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(_db.notes, companionsToUpsert);
      });
    }
  }
}
