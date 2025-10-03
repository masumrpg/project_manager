class DashboardStatistics {
  const DashboardStatistics({
    required this.projectsCount,
    required this.noteCount,
    required this.todoCount,
    required this.revisionsCount,
  });

  factory DashboardStatistics.fromJson(Map<String, dynamic> json) {
    return DashboardStatistics(
      projectsCount: json['projectsCount'] as int? ?? 0,
      noteCount: json['noteCount'] as int? ?? 0,
      todoCount: json['todoCount'] as int? ?? 0,
      revisionsCount: json['revisionsCount'] as int? ?? 0,
    );
  }

  static const empty = DashboardStatistics(
    projectsCount: 0,
    noteCount: 0,
    todoCount: 0,
    revisionsCount: 0,
  );

  final int projectsCount;
  final int noteCount;
  final int todoCount;
  final int revisionsCount;
}
