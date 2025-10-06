import 'package:catatan_kaki/database/app_database.dart';
import 'package:drift/drift.dart';

class SyncMetadataRepository {
  SyncMetadataRepository(this._db);

  final AppDatabase _db;

  Stream<DateTime?> watchLastSyncTimestamp() {
    final query = _db.select(_db.syncMetadata)
      ..where((tbl) => tbl.key.equals('last_sync_timestamp'));

    return query.watchSingleOrNull().map((row) {
      if (row == null || row.value.isEmpty) {
        return null;
      }
      return DateTime.tryParse(row.value);
    });
  }

  Future<void> setLastSyncTimestamp(DateTime time) {
    return _db.into(_db.syncMetadata).insertOnConflictUpdate(
          SyncMetadataCompanion(
            key: const Value('last_sync_timestamp'),
            value: Value(time.toIso8601String()),
          ),
        );
  }

  Stream<int> watchSyncQueueCount() {
    final countExpression = countAll();
    final query = _db.selectOnly(_db.syncQueue)..addColumns([countExpression]);
    return query.map((row) => row.read(countExpression)).watchSingle();
  }
}
