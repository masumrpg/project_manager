import 'package:drift/drift.dart';
import 'package:catatan_kaki/models/enums/todo_priority.dart';
import 'package:catatan_kaki/models/enums/todo_status.dart';

class Todos extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get content => text().nullable()();
  IntColumn get priority => intEnum<TodoPriority>()();
  IntColumn get status => intEnum<TodoStatus>()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
