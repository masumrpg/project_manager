import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_statistics.freezed.dart';
part 'dashboard_statistics.g.dart';

@freezed
class DashboardStatistics with _$DashboardStatistics {
  const factory DashboardStatistics({
    required int projectsCount,
    required int noteCount,
    required int todoCount,
    required int revisionsCount,
  }) = _DashboardStatistics;

  factory DashboardStatistics.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatisticsFromJson(json);

  static const empty = DashboardStatistics(
    projectsCount: 0,
    noteCount: 0,
    todoCount: 0,
    revisionsCount: 0,
  );
}