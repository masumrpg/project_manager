import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:catatan_kaki/models/enums/revision_status.dart';

class ListConverter extends TypeConverter<List<String>, String> {
  const ListConverter();
  @override
  List<String> fromSql(String fromDb) {
    return (json.decode(fromDb) as List<dynamic>).cast<String>();
  }

  @override
  String toSql(List<String> value) {
    return json.encode(value);
  }
}

class Revisions extends Table {
  TextColumn get id => text()();
  TextColumn get projectId => text()();
  TextColumn get version => text()();
  TextColumn get description => text()();
  TextColumn get changes => text().map(const ListConverter())();
  IntColumn get status => intEnum<RevisionStatus>()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
