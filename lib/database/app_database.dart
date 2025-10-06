import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:catatan_kaki/models/enums/app_category.dart';
import 'package:catatan_kaki/models/enums/environment.dart';
import 'package:catatan_kaki/models/enums/note_status.dart';
import 'package:catatan_kaki/models/enums/revision_status.dart';
import 'package:catatan_kaki/models/enums/todo_priority.dart';
import 'package:catatan_kaki/models/enums/todo_status.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'tables/notes.dart';
import 'tables/projects.dart';
import 'tables/revisions.dart';
import 'tables/sync_metadata.dart';
import 'tables/sync_queue.dart';
import 'tables/todos.dart';
import 'tables/users.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Projects,
  Notes,
  Todos,
  Revisions,
  Users,
  SyncQueue,
  SyncMetadata,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  Future<void> deleteAllData() {
    return transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}
