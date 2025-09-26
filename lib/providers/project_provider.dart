import 'package:flutter/foundation.dart';

import '../models/enums/todo_status.dart';
import '../models/project.dart';
import '../repositories/project_repository.dart';

class ProjectProvider extends ChangeNotifier {
  ProjectProvider(this._repository);

  final ProjectRepository _repository;
  final List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;

  List<Project> get projects => List.unmodifiable(_projects);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProjects({bool showLoading = true}) async {
    if (showLoading) {
      _setLoading(true);
    }

    try {
      final data = await _repository.getAllProjects();
      _projects
        ..clear()
        ..addAll(data);
      _error = null;
    } catch (error) {
      _error = error.toString();
    } finally {
      if (showLoading) {
        _setLoading(false);
      } else {
        notifyListeners();
      }
    }
  }

  Future<bool> createProject(Project project) async {
    return _runGuarded(() async {
      await _repository.createProject(project);
      await loadProjects(showLoading: false);
    });
  }

  Future<bool> updateProject(Project project) async {
    return _runGuarded(() async {
      await _repository.updateProject(project);
      await loadProjects(showLoading: false);
    });
  }

  Future<bool> deleteProject(String id) async {
    return _runGuarded(() async {
      await _repository.deleteProject(id);
      _projects.removeWhere((project) => project.id == id);
    });
  }

  Future<void> updateTodoStatus(
    String projectId,
    String todoId,
    TodoStatus status,
  ) async {
    await _runGuarded(() async {
      await _repository.updateTodoStatus(projectId, todoId, status);
      await loadProjects(showLoading: false);
    });
  }

  Future<bool> _runGuarded(Future<void> Function() runner) async {
    _setLoading(true);
    try {
      await runner();
      _error = null;
      return true;
    } catch (error, stackTrace) {
      _error = error.toString();
      debugPrint('ProjectProvider error: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      if (!value) {
        notifyListeners();
      }
      return;
    }
    _isLoading = value;
    notifyListeners();
  }
}
