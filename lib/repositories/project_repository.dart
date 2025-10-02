import 'dart:convert';

import '../models/enums/note_status.dart';
import '../models/enums/revision_status.dart';
import '../models/enums/todo_status.dart';
import '../models/note.dart';
import '../models/project.dart';
import '../models/revision.dart';
import '../models/todo.dart';
import '../services/api_client.dart';

class ProjectRepository {
  ProjectRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Project>> getAllProjects() async {
    final response = await _apiClient.get(
      '/api/projects',
      queryParameters: {
        'pageSize': '50',
        'page': '1',
      },
    );

    final data = _extractDataList(response);
    final projects = data
        .map((item) => Project.fromJson(item as Map<String, dynamic>))
        .toList();

    projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return projects;
  }

  Future<Project?> getProjectById(String id) async {
    try {
      final response = await _apiClient.get('/api/projects/$id')
          as Map<String, dynamic>;
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) return null;

      final project = Project.fromJson(data);

      final stats = response['stats'];
      if (stats is Map<String, dynamic>) {
        project
          ..notesCount = stats['notes'] as int?
          ..todosCount = stats['todos'] as int?
          ..revisionsCount = stats['revisions'] as int?
          ..completedTodosCount = stats['completedTodos'] as int?;
      }

      project
        ..notes = await _fetchNotes(id)
        ..todos = await _fetchTodos(id)
        ..revisions = await _fetchRevisions(id);

      return project;
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> createProject(Project project) async {
    await _apiClient.post(
      '/api/projects',
      body: project.toCreatePayload(),
    );
  }

  Future<void> updateProject(Project project) async {
    await _apiClient.patch(
      '/api/projects/${project.id}',
      body: project.toUpdatePayload(),
    );
  }

  Future<void> updateProjectLongDescription(
    String projectId,
    String longDescription,
  ) async {
    dynamic payload;
    if (longDescription.isEmpty) {
      payload = null;
    } else {
      try {
        payload = jsonDecode(longDescription);
      } catch (_) {
        payload = longDescription;
      }
    }

    await _apiClient.patch(
      '/api/projects/$projectId',
      body: {'longDescription': payload},
    );
  }

  Future<void> deleteProject(String id) async {
    await _apiClient.delete('/api/projects/$id');
  }

  Future<void> addNoteToProject(String projectId, Note note) async {
    await _apiClient.post(
      '/api/projects/$projectId/notes',
      body: note.copyWith(projectId: projectId).toApiPayload(),
    );
  }

  Future<void> removeNoteFromProject(String projectId, String noteId) async {
    await _apiClient.delete('/api/projects/$projectId/notes/$noteId');
  }

  Future<void> updateNote(String projectId, Note note) async {
    await _apiClient.patch(
      '/api/projects/$projectId/notes/${note.id}',
      body: note.toApiPayload(),
    );
  }

  Future<void> addRevisionToProject(String projectId, Revision revision) async {
    await _apiClient.post(
      '/api/projects/$projectId/revisions',
      body: revision.copyWith(projectId: projectId).toApiPayload(),
    );
  }

  Future<void> removeRevisionFromProject(
    String projectId,
    String revisionId,
  ) async {
    await _apiClient.delete('/api/projects/$projectId/revisions/$revisionId');
  }

  Future<void> updateRevision(String projectId, Revision revision) async {
    await _apiClient.patch(
      '/api/projects/$projectId/revisions/${revision.id}',
      body: revision.toApiPayload(),
    );
  }

  Future<void> addTodoToProject(String projectId, Todo todo) async {
    await _apiClient.post(
      '/api/projects/$projectId/todos',
      body: todo.copyWith(projectId: projectId).toApiPayload(),
    );
  }

  Future<void> updateNoteStatus(
    String projectId,
    String noteId,
    NoteStatus status,
  ) async {
    await _apiClient.patch(
      '/api/projects/$projectId/notes/$noteId',
      body: {
        'status': status.apiValue,
      },
    );
  }

  Future<void> updateRevisionStatus(
    String projectId,
    String revisionId,
    RevisionStatus status,
  ) async {
    await _apiClient.patch(
      '/api/projects/$projectId/revisions/$revisionId',
      body: {
        'status': status.apiValue,
      },
    );
  }

  Future<void> updateTodoStatus(
    String projectId,
    String todoId,
    TodoStatus status,
  ) async {
    await _apiClient.patch(
      '/api/projects/$projectId/todos/$todoId',
      body: {
        'status': status.apiValue,
      },
    );
  }

  Future<void> updateTodo(String projectId, Todo todo) async {
    await _apiClient.patch(
      '/api/projects/$projectId/todos/${todo.id}',
      body: todo.toApiPayload(),
    );
  }

  Future<void> removeTodoFromProject(String projectId, String todoId) async {
    await _apiClient.delete('/api/projects/$projectId/todos/$todoId');
  }

  List<dynamic> _extractDataList(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is List) return data;
    } else if (response is List) {
      return response;
    }
    return const <dynamic>[];
  }

  Future<List<Note>> _fetchNotes(String projectId) async {
    final response = await _apiClient.get(
      '/api/projects/$projectId/notes',
      queryParameters: {
        'pageSize': '50',
        'page': '1',
      },
    );
    final data = _extractDataList(response);
    return data
        .map((item) => Note.fromJson(
              item as Map<String, dynamic>,
              fallbackProjectId: projectId,
            ))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<List<Todo>> _fetchTodos(String projectId) async {
    final response = await _apiClient.get(
      '/api/projects/$projectId/todos',
      queryParameters: {
        'pageSize': '50',
        'page': '1',
      },
    );
    final data = _extractDataList(response);
    return data
        .map((item) => Todo.fromJson(
              item as Map<String, dynamic>,
              fallbackProjectId: projectId,
            ))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<List<Revision>> _fetchRevisions(String projectId) async {
    final response = await _apiClient.get(
      '/api/projects/$projectId/revisions',
      queryParameters: {
        'pageSize': '50',
        'page': '1',
      },
    );
    final data = _extractDataList(response);
    return data
        .map((item) => Revision.fromJson(
              item as Map<String, dynamic>,
              fallbackProjectId: projectId,
            ))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
