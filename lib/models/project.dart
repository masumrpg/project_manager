import 'package:hive/hive.dart';

import 'enums/app_category.dart';
import 'enums/environment.dart';
import 'note.dart';
import 'revision.dart';
import 'todo.dart';

part 'project.g.dart';

@HiveType(typeId: 10)
class Project extends HiveObject {
  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.environment,
    required this.createdAt,
    required this.updatedAt,
    this.longDescription,
    this.notes,
    this.revisions,
    this.todos,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  AppCategory category;

  @HiveField(4)
  Environment environment;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  String? longDescription;

  @HiveField(8)
  HiveList<Note>? notes;

  @HiveField(9)
  HiveList<Revision>? revisions;

  @HiveField(10)
  HiveList<Todo>? todos;

  Project copyWith({
    String? title,
    String? description,
    String? longDescription,
    AppCategory? category,
    Environment? environment,
    DateTime? updatedAt,
    HiveList<Note>? notes,
    HiveList<Revision>? revisions,
    HiveList<Todo>? todos,
  }) {
    return Project(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      environment: environment ?? this.environment,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      longDescription: longDescription ?? this.longDescription,
      notes: notes ?? this.notes,
      revisions: revisions ?? this.revisions,
      todos: todos ?? this.todos,
    );
  }
}
