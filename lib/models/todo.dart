import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums/todo_priority.dart';
import 'enums/todo_status.dart';

part 'todo.freezed.dart';
part 'todo.g.dart';

class TodoContentConverter implements JsonConverter<String?, dynamic> {
  const TodoContentConverter();

  @override
  String? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) return json;
    try {
      return jsonEncode(json);
    } catch (_) {
      return json.toString();
    }
  }

  @override
  dynamic toJson(String? object) {
    if (object == null || object.isEmpty) return [];
    try {
      return jsonDecode(object);
    } catch (_) {
      return object;
    }
  }
}

@freezed
class Todo with _$Todo {
  const Todo._();

  const factory Todo({
    required String id,
    required String projectId,
    required String title,
    String? description,
    @TodoContentConverter() String? content,
    required TodoPriority priority,
    required TodoStatus status,
    DateTime? dueDate,
    required DateTime createdAt,
    DateTime? completedAt,
    required DateTime updatedAt,
  }) = _Todo;

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

   Map<String, dynamic> toApiPayload({bool includeStatus = true}) {
    return {
      'title': title,
      if (description != null && description!.trim().isNotEmpty)
        'description': description,
      'priority': priority.apiValue,
      if (includeStatus) 'status': status.apiValue,
      if (dueDate != null) 'dueDate': dueDate!.toUtc().toIso8601String(),
      if (completedAt != null)
        'completedAt': completedAt!.toUtc().toIso8601String(),
      if (content != null && content!.isNotEmpty) 'content': const TodoContentConverter().toJson(content),
    };
  }
}