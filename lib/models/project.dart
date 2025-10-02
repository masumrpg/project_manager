import 'dart:convert';

import 'enums/app_category.dart';
import 'enums/environment.dart';
import 'note.dart';
import 'revision.dart';
import 'todo.dart';

class Project {
  Project({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.longDescription,
    required this.category,
    required this.environment,
    required this.createdAt,
    required this.updatedAt,
    List<Note>? notes,
    List<Revision>? revisions,
    List<Todo>? todos,
    this.notesCount,
    this.todosCount,
    this.revisionsCount,
    this.completedTodosCount,
  })  : notes = notes ?? <Note>[],
        revisions = revisions ?? <Revision>[],
        todos = todos ?? <Todo>[];

  String id;
  String userId;
  String title;
  String? description;
  String? longDescription;
  AppCategory category;
  Environment environment;
  DateTime createdAt;
  DateTime updatedAt;
  List<Note> notes;
  List<Revision> revisions;
  List<Todo> todos;
  int? notesCount;
  int? todosCount;
  int? revisionsCount;
  int? completedTodosCount;

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      longDescription: _encodeLongDescription(json['longDescription']),
      category: AppCategoryX.fromApiValue(json['category'] as String? ?? 'other'),
      environment: EnvironmentX.fromApiValue(json['environment'] as String? ?? 'development'),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      notesCount: json['notesCount'] as int?,
      todosCount: json['todosCount'] as int?,
      revisionsCount: json['revisionsCount'] as int?,
      completedTodosCount: json['completedTodosCount'] as int?,
    );
  }

  Project copyWith({
    String? title,
    String? description,
    String? longDescription,
    AppCategory? category,
    Environment? environment,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Note>? notes,
    List<Revision>? revisions,
    List<Todo>? todos,
    int? notesCount,
    int? todosCount,
    int? revisionsCount,
    int? completedTodosCount,
  }) {
    return Project(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      longDescription: longDescription ?? this.longDescription,
      category: category ?? this.category,
      environment: environment ?? this.environment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? List<Note>.from(this.notes),
      revisions: revisions ?? List<Revision>.from(this.revisions),
      todos: todos ?? List<Todo>.from(this.todos),
      notesCount: notesCount ?? this.notesCount,
      todosCount: todosCount ?? this.todosCount,
      revisionsCount: revisionsCount ?? this.revisionsCount,
      completedTodosCount: completedTodosCount ?? this.completedTodosCount,
    );
  }

  Map<String, dynamic> toCreatePayload() {
    return {
      'title': title,
      if (description != null && description!.trim().isNotEmpty)
        'description': description,
      'category': category.apiValue,
      'environment': environment.apiValue,
      'longDescription': _decodeLongDescription(longDescription),
    };
  }

  Map<String, dynamic> toUpdatePayload({bool includeLongDescription = false}) {
    final payload = <String, dynamic>{
      'title': title,
      'description': description,
      'category': category.apiValue,
      'environment': environment.apiValue,
    };

    payload.removeWhere((_, value) => value == null);

    if (includeLongDescription) {
      payload['longDescription'] = _decodeLongDescription(longDescription);
    }

    return payload;
  }

  static String? _encodeLongDescription(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    try {
      return jsonEncode(value);
    } catch (_) {
      return value.toString();
    }
  }

  static dynamic _decodeLongDescription(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return jsonDecode(value);
    } catch (_) {
      return value;
    }
  }
}
