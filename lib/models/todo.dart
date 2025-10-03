import 'dart:convert';

import 'enums/todo_priority.dart';
import 'enums/todo_status.dart';

class Todo {
  Todo({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    this.content,
    required this.priority,
    required this.status,
    this.dueDate,
    required this.createdAt,
    this.completedAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  String id;
  String projectId;
  String title;
  String? description;
  String? content;
  TodoPriority priority;
  TodoStatus status;
  DateTime? dueDate;
  DateTime createdAt;
  DateTime? completedAt;
  DateTime updatedAt;

  factory Todo.fromJson(Map<String, dynamic> json, {String? fallbackProjectId}) {
    return Todo(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? fallbackProjectId ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      content: _encodeContent(json['content']),
      priority: TodoPriorityX.fromApiValue(json['priority'] as String? ?? 'medium'),
      status: TodoStatusX.fromApiValue(json['status'] as String? ?? 'pending'),
      dueDate: _parseDate(json['dueDate']),
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      completedAt: _parseDate(json['completedAt']),
      updatedAt: _parseDate(json['updatedAt']) ?? _parseDate(json['createdAt']) ?? DateTime.now(),
    );
  }

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
      if (content != null && content!.isNotEmpty) 'content': _decodeContent(),
    };
  }

  Todo copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    String? content,
    TodoPriority? priority,
    TodoStatus? status,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static String? _encodeContent(dynamic content) {
    if (content == null) return null;
    if (content is String) return content;
    try {
      return jsonEncode(content);
    } catch (_) {
      return content.toString();
    }
  }

  dynamic _decodeContent() {
    if (content == null || content!.isEmpty) return [];
    try {
      return jsonDecode(content!);
    } catch (_) {
      return content;
    }
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
