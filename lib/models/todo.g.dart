// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Todo _$TodoFromJson(Map<String, dynamic> json) => _Todo(
  id: json['id'] as String,
  projectId: json['projectId'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  content: const TodoContentConverter().fromJson(json['content']),
  priority: $enumDecode(_$TodoPriorityEnumMap, json['priority']),
  status: $enumDecode(_$TodoStatusEnumMap, json['status']),
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TodoToJson(_Todo instance) => <String, dynamic>{
  'id': instance.id,
  'projectId': instance.projectId,
  'title': instance.title,
  'description': instance.description,
  'content': const TodoContentConverter().toJson(instance.content),
  'priority': _$TodoPriorityEnumMap[instance.priority]!,
  'status': _$TodoStatusEnumMap[instance.status]!,
  'dueDate': instance.dueDate?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$TodoPriorityEnumMap = {
  TodoPriority.low: 'low',
  TodoPriority.medium: 'medium',
  TodoPriority.high: 'high',
  TodoPriority.urgent: 'urgent',
};

const _$TodoStatusEnumMap = {
  TodoStatus.pending: 'pending',
  TodoStatus.inProgress: 'inProgress',
  TodoStatus.completed: 'completed',
  TodoStatus.cancelled: 'cancelled',
};
