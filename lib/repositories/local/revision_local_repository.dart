import 'dart:convert';

import 'package:catatan_kaki/database/app_database.dart';
import 'package:catatan_kaki/models/revision.dart' as domain;
import 'package:drift/drift.dart';

class RevisionLocalRepository {
  RevisionLocalRepository(this._db);

  final AppDatabase _db;

  domain.Revision _mapDataToModel(Revision data) {
    return domain.Revision(
      id: data.id,
      projectId: data.projectId,
      version: data.version,
      description: data.description,
      changes: data.changes,
      status: data.status,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  RevisionsCompanion _mapModelToCompanion(domain.Revision model) {
    return RevisionsCompanion(
      id: Value(model.id),
      projectId: Value(model.projectId),
      version: Value(model.version),
      description: Value(model.description),
      changes: Value(model.changes),
      status: Value(model.status),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  Stream<List<domain.Revision>> watchRevisionsForProject(String projectId) {
    final query = _db.select(_db.revisions)
      ..where((tbl) => tbl.projectId.equals(projectId));
    return query.watch().map((rows) => rows.map(_mapDataToModel).toList());
  }

  Future<void> insertOrUpdateRevision(domain.Revision revision) async {
    final existing = await (_db.select(_db.revisions)..where((tbl) => tbl.id.equals(revision.id))).getSingleOrNull();
    final operation = existing == null ? 'create' : 'update';

    await _db.transaction(() async {
      final companion = _mapModelToCompanion(revision);
      await _db.into(_db.revisions).insertOnConflictUpdate(companion);

      await _db.into(_db.syncQueue).insert(
            SyncQueueCompanion.insert(
              entityType: 'revision',
              entityId: revision.id,
              operation: operation,
              payload: jsonEncode(revision.toJson()),
            ),
          );
    });
  }

  Future<void> deleteRevision(String revisionId) async {
    final revision = await (_db.select(_db.revisions)..where((tbl) => tbl.id.equals(revisionId))).getSingleOrNull();
    if (revision == null) return;

    await _db.transaction(() async {
      await (_db.delete(_db.revisions)..where((tbl) => tbl.id.equals(revisionId))).go();

      await _db.into(_db.syncQueue).insert(
            SyncQueueCompanion.insert(
              entityType: 'revision',
              entityId: revisionId,
              operation: 'delete',
              payload: jsonEncode({'id': revisionId, 'projectId': revision.projectId}),
            ),
          );
    });
  }

  Future<void> insertOrUpdateRevisions(List<domain.Revision> remoteRevisions) async {
    if (remoteRevisions.isEmpty) return;

    final remoteIds = remoteRevisions.map((r) => r.id).toList();
    final existingLocals = await (_db.select(_db.revisions)..where((tbl) => tbl.id.isIn(remoteIds))).get();
    final localMap = {for (var r in existingLocals) r.id: r};

    final companionsToUpsert = <RevisionsCompanion>[];

    for (final remote in remoteRevisions) {
      final local = localMap[remote.id];
      if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
        companionsToUpsert.add(_mapModelToCompanion(remote));
      }
    }

    if (companionsToUpsert.isNotEmpty) {
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(_db.revisions, companionsToUpsert);
      });
    }
  }
}
