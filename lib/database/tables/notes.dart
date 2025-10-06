import 'package:drift/drift.dart';
import 'package:catatan_kaki/models/enums/note_status.dart';

class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get content => text()();
  IntColumn get status => intEnum<NoteStatus>()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
