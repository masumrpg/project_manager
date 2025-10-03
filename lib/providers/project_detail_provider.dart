import 'package:flutter/foundation.dart';

import '../models/enums/todo_status.dart';
import '../models/note.dart';
import '../models/project.dart';
import '../models/revision.dart';
import '../models/todo.dart';
import '../repositories/project_repository.dart';

class ProjectDetailProvider extends ChangeNotifier {
  ProjectDetailProvider({
    required ProjectRepository repository,
    required this.projectId,
  }) : _repository = repository;

  final ProjectRepository _repository;
  final String projectId;

  Project? _project;
  bool _isLoading = true;
  String? _error;

  Project? get project => _project;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProject({bool showLoading = true}) async {
    await _runTask(() async {
      _project = await _repository.getProjectById(projectId);
    }, showLoading: showLoading);
  }

  Future<bool> addNote(Note note) async {
    return _runTask(() async {
      await _repository.addNoteToProject(projectId, note);
      await _refreshProject();
    }, showLoading: false);
  }

  Future<bool> updateNote(Note note) async {
    return _runTask(() async {
      await _repository.updateNote(projectId, note);
      await _refreshProject();
    }, showLoading: false);
  }

  Future<bool> deleteNote(String noteId) async {
    return _runTask(() async {
      await _repository.removeNoteFromProject(projectId, noteId);
      await _refreshProject();
    }, showLoading: true);
  }

  Future<bool> addRevision(Revision revision) async {
    return _runTask(() async {
      await _repository.addRevisionToProject(projectId, revision);
      await _refreshProject();
    }, showLoading: false);
  }

  Future<bool> updateRevision(Revision revision) async {
    return _runTask(() async {
      await _repository.updateRevision(projectId, revision);
      await _refreshProject();
    }, showLoading: false);
  }

  Future<bool> deleteRevision(String revisionId) async {
    return _runTask(() async {
      await _repository.removeRevisionFromProject(projectId, revisionId);
      await _refreshProject();
    }, showLoading: true);
  }

  Future<bool> addTodo(Todo todo) async {
    return _runTask(() async {
      await _repository.addTodoToProject(projectId, todo);
      await _refreshProject();
    }, showLoading: false);
  }

  Future<bool> updateTodo(Todo todo) async {
    return _runTask(() async {
      await _repository.updateTodo(projectId, todo);
      await _refreshProject();
    }, showLoading: false);
  }

  Future<bool> deleteTodo(String todoId) async {
    return _runTask(() async {
      await _repository.removeTodoFromProject(projectId, todoId);
      await _refreshProject();
    }, showLoading: true);
  }

  Future<bool> updateTodoStatus(String todoId, TodoStatus status) async {
    return _runTask(() async {
      await _repository.updateTodoStatus(projectId, todoId, status);
      await _refreshProject();
    }, showLoading: false);
  }

  Future<void> _refreshProject() async {
    _project = await _repository.getProjectById(projectId);
  }

  Future<bool> updateLongDescription(String content) async {
    return _runTask(() async {
      await _repository.updateProjectLongDescription(projectId, content);
      await _refreshProject();
    }, showLoading: false);
  }

  Future<bool> _runTask(
    Future<void> Function() task, {
    required bool showLoading,
  }) async {
    if (showLoading) {
      _setLoading(true);
    }

    try {
      await task();
      _error = null;
      return true;
    } catch (error, stackTrace) {
      _error = error.toString();
      debugPrint('ProjectDetailProvider error: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    } finally {
      if (showLoading) {
        _setLoading(false);
      } else {
        notifyListeners();
      }
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
