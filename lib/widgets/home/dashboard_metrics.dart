import '../../models/enums/todo_status.dart';
import '../../models/project.dart';

// Dashboard Metrics Data Class
class DashboardMetrics {
  const DashboardMetrics({
    required this.totalProjects,
    required this.totalNotes,
    required this.completedTodos,
    required this.activeTodos,
    required this.lastUpdated,
  });

  factory DashboardMetrics.fromProjects(List<Project> projects) {
    if (projects.isEmpty) {
      return const DashboardMetrics(
        totalProjects: 0,
        totalNotes: 0,
        completedTodos: 0,
        activeTodos: 0,
        lastUpdated: null,
      );
    }

    var notes = 0;
    var completed = 0;
    var totalTodos = 0;
    DateTime? latest;

    for (final project in projects) {
      notes += project.notes?.length ?? 0;

      final todos = project.todos;
      if (todos != null) {
        totalTodos += todos.length;
        for (final todo in todos) {
          if (todo.status == TodoStatus.completed) {
            completed++;
          }
        }
      }

      if (latest == null || project.updatedAt.isAfter(latest)) {
        latest = project.updatedAt;
      }
    }

    final active = totalTodos - completed;

    return DashboardMetrics(
      totalProjects: projects.length,
      totalNotes: notes,
      completedTodos: completed,
      activeTodos: active,
      lastUpdated: latest,
    );
  }

  final int totalProjects;
  final int totalNotes;
  final int completedTodos;
  final int activeTodos;
  final DateTime? lastUpdated;
}