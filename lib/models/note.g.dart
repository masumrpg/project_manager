// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Note _$NoteFromJson(Map<String, dynamic> json) => _Note(
  id: json['id'] as String,
  projectId: json['projectId'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  content: const NoteContentConverter().fromJson(json['content']),
  status:
      $enumDecodeNullable(_$NoteStatusEnumMap, json['status']) ??
      NoteStatus.draft,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$NoteToJson(_Note instance) => <String, dynamic>{
  'id': instance.id,
  'projectId': instance.projectId,
  'title': instance.title,
  'description': instance.description,
  'content': const NoteContentConverter().toJson(instance.content),
  'status': _$NoteStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$NoteStatusEnumMap = {
  NoteStatus.draft: 'draft',
  NoteStatus.active: 'active',
  NoteStatus.archived: 'archived',
};
