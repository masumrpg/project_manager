import 'package:drift/drift.dart';
import 'package:catatan_kaki/models/enums/app_category.dart';
import 'package:catatan_kaki/models/enums/environment.dart';

class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get longDescription => text().nullable()();
  IntColumn get category => intEnum<AppCategory>()();
  IntColumn get environment => intEnum<Environment>()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get notesCount => integer().nullable()();
  IntColumn get todosCount => integer().nullable()();
  IntColumn get revisionsCount => integer().nullable()();
  IntColumn get completedTodosCount => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
