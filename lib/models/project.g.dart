// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Project _$ProjectFromJson(Map<String, dynamic> json) => _Project(
  id: json['id'] as String,
  userId: json['userId'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  longDescription: const LongDescriptionConverter().fromJson(
    json['longDescription'],
  ),
  category: $enumDecode(_$AppCategoryEnumMap, json['category']),
  environment: $enumDecode(_$EnvironmentEnumMap, json['environment']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  notesCount: (json['notesCount'] as num?)?.toInt(),
  todosCount: (json['todosCount'] as num?)?.toInt(),
  revisionsCount: (json['revisionsCount'] as num?)?.toInt(),
  completedTodosCount: (json['completedTodosCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$ProjectToJson(_Project instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'title': instance.title,
  'description': instance.description,
  'longDescription': const LongDescriptionConverter().toJson(
    instance.longDescription,
  ),
  'category': _$AppCategoryEnumMap[instance.category]!,
  'environment': _$EnvironmentEnumMap[instance.environment]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'notesCount': instance.notesCount,
  'todosCount': instance.todosCount,
  'revisionsCount': instance.revisionsCount,
  'completedTodosCount': instance.completedTodosCount,
};

const _$AppCategoryEnumMap = {
  AppCategory.web: 'web',
  AppCategory.mobile: 'mobile',
  AppCategory.desktop: 'desktop',
  AppCategory.api: 'api',
  AppCategory.other: 'other',
};

const _$EnvironmentEnumMap = {
  Environment.development: 'development',
  Environment.staging: 'staging',
  Environment.production: 'production',
};
