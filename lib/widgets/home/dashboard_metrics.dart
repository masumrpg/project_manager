import '../../models/dashboard_statistics.dart';
import '../../models/project.dart';

// Dashboard Metrics Data Class
class DashboardMetrics {
  const DashboardMetrics({
    required this.totalProjects,
    required this.totalNotes,
    required this.totalRevisions,
    required this.totalTodos,
    required this.lastUpdated,
  });

  factory DashboardMetrics.fromData({
    required DashboardStatistics stats,
    required List<Project> projects,
  }) {
    DateTime? latest;
    for (final project in projects) {
      if (latest == null || project.updatedAt.isAfter(latest)) {
        latest = project.updatedAt;
      }
    }

    return DashboardMetrics(
      totalProjects: stats.projectsCount,
      totalNotes: stats.noteCount,
      totalRevisions: stats.revisionsCount,
      totalTodos: stats.todoCount,
      lastUpdated: latest,
    );
  }

  final int totalProjects;
  final int totalNotes;
  final int totalRevisions;
  final int totalTodos;
  final DateTime? lastUpdated;
}
