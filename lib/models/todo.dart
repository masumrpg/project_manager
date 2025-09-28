import 'package:hive/hive.dart';

import 'enums/todo_priority.dart';
import 'enums/todo_status.dart';

part 'todo.g.dart';

@HiveType(typeId: 13)
class Todo extends HiveObject {
  Todo({
    required this.id,
    required this.title,
    required this.description,
    this.content,
    required this.priority,
    required this.status,
    this.dueDate,
    required this.createdAt,
    this.completedAt,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  TodoPriority priority;

  @HiveField(4)
  TodoStatus status;

  @HiveField(5)
  DateTime? dueDate;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? completedAt;

  @HiveField(8)
  String? content;
}
