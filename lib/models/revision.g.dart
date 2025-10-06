// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revision.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Revision _$RevisionFromJson(Map<String, dynamic> json) => _Revision(
  id: json['id'] as String,
  projectId: json['projectId'] as String,
  version: json['version'] as String,
  description: json['description'] as String,
  changes: const ChangesConverter().fromJson(json['changes']),
  status:
      $enumDecodeNullable(_$RevisionStatusEnumMap, json['status']) ??
      RevisionStatus.pending,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$RevisionToJson(_Revision instance) => <String, dynamic>{
  'id': instance.id,
  'projectId': instance.projectId,
  'version': instance.version,
  'description': instance.description,
  'changes': const ChangesConverter().toJson(instance.changes),
  'status': _$RevisionStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$RevisionStatusEnumMap = {
  RevisionStatus.pending: 'pending',
  RevisionStatus.approved: 'approved',
  RevisionStatus.rejected: 'rejected',
};
