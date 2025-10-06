import 'dart:convert';

import 'package:catatan_kaki/database/app_database.dart';
import 'package:catatan_kaki/models/todo.dart' as domain;
import 'package:drift/drift.dart';

class TodoLocalRepository {
  TodoLocalRepository(this._db);

  final AppDatabase _db;

  domain.Todo _mapDataToModel(Todo data) {
    return domain.Todo(
      id: data.id,
      projectId: data.projectId,
      title: data.title,
      description: data.description,
      content: data.content,
      priority: data.priority,
      status: data.status,
      dueDate: data.dueDate,
      createdAt: data.createdAt,
      completedAt: data.completedAt,
      updatedAt: data.updatedAt,
    );
  }

  TodosCompanion _mapModelToCompanion(domain.Todo model) {
    return TodosCompanion(
      id: Value(model.id),
      projectId: Value(model.projectId),
      title: Value(model.title),
      description: Value(model.description),
      content: Value(model.content),
      priority: Value(model.priority),
      status: Value(model.status),
      dueDate: Value(model.dueDate),
      createdAt: Value(model.createdAt),
      completedAt: Value(model.completedAt),
      updatedAt: Value(model.updatedAt),
    );
  }

  Stream<List<domain.Todo>> watchTodosForProject(String projectId) {
    final query = _db.select(_db.todos)
      ..where((tbl) => tbl.projectId.equals(projectId));
    return query.watch().map((rows) => rows.map(_mapDataToModel).toList());
  }

  Future<void> insertOrUpdateTodo(domain.Todo todo) async {
    final existing = await (_db.select(_db.todos)..where((tbl) => tbl.id.equals(todo.id))).getSingleOrNull();
    final operation = existing == null ? 'create' : 'update';

    await _db.transaction(() async {
      final companion = _mapModelToCompanion(todo);
      await _db.into(_db.todos).insertOnConflictUpdate(companion);

      await _db.into(_db.syncQueue).insert(
            SyncQueueCompanion.insert(
              entityType: 'todo',
              entityId: todo.id,
              operation: operation,
              payload: jsonEncode(todo.toJson()),
            ),
          );
    });
  }

  Future<void> deleteTodo(String todoId) async {
    final todo = await (_db.select(_db.todos)..where((tbl) => tbl.id.equals(todoId))).getSingleOrNull();
    if (todo == null) return;

    await _db.transaction(() async {
      await (_db.delete(_db.todos)..where((tbl) => tbl.id.equals(todoId))).go();

      await _db.into(_db.syncQueue).insert(
            SyncQueueCompanion.insert(
              entityType: 'todo',
              entityId: todoId,
              operation: 'delete',
              payload: jsonEncode({'id': todoId, 'projectId': todo.projectId}),
            ),
          );
    });
  }

  Future<void> insertOrUpdateTodos(List<domain.Todo> remoteTodos) async {
    if (remoteTodos.isEmpty) return;

    final remoteIds = remoteTodos.map((t) => t.id).toList();
    final existingLocals = await (_db.select(_db.todos)..where((tbl) => tbl.id.isIn(remoteIds))).get();
    final localMap = {for (var t in existingLocals) t.id: t};

    final companionsToUpsert = <TodosCompanion>[];

    for (final remote in remoteTodos) {
      final local = localMap[remote.id];
      if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
        companionsToUpsert.add(_mapModelToCompanion(remote));
      }
    }

    if (companionsToUpsert.isNotEmpty) {
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(_db.todos, companionsToUpsert);
      });
    }
  }
}
