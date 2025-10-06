// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardStatistics _$DashboardStatisticsFromJson(Map<String, dynamic> json) =>
    _DashboardStatistics(
      projectsCount: (json['projectsCount'] as num).toInt(),
      noteCount: (json['noteCount'] as num).toInt(),
      todoCount: (json['todoCount'] as num).toInt(),
      revisionsCount: (json['revisionsCount'] as num).toInt(),
    );

Map<String, dynamic> _$DashboardStatisticsToJson(
  _DashboardStatistics instance,
) => <String, dynamic>{
  'projectsCount': instance.projectsCount,
  'noteCount': instance.noteCount,
  'todoCount': instance.todoCount,
  'revisionsCount': instance.revisionsCount,
};
