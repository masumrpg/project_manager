import 'package:hive/hive.dart';

import '../models/enums/note_status.dart';
import '../models/enums/revision_status.dart';
import '../models/enums/todo_status.dart';
import '../models/note.dart';
import '../models/project.dart';
import '../models/revision.dart';
import '../models/todo.dart';
import '../services/hive_boxes.dart';

class ProjectRepository {
  Future<List<Project>> getAllProjects() async {
    final projects = HiveBoxes.projectsBox.values.toList();
    projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return projects;
  }

  Future<Project?> getProjectById(String id) async {
    return HiveBoxes.projectsBox.get(id);
  }

  Future<void> createProject(Project project) async {
    project
      ..notes ??= HiveList(HiveBoxes.notesBox)
      ..revisions ??= HiveList(HiveBoxes.revisionsBox)
      ..todos ??= HiveList(HiveBoxes.todosBox);

    await HiveBoxes.projectsBox.put(project.id, project);
  }

  Future<void> updateProject(Project project) async {
    project.updatedAt = DateTime.now();
    await HiveBoxes.projectsBox.put(project.id, project);
  }

  Future<void> updateProjectLongDescription(
    String projectId,
    String longDescription,
  ) async {
    final project = HiveBoxes.projectsBox.get(projectId);
    if (project == null) return;

    project
      ..longDescription = longDescription
      ..updatedAt = DateTime.now();
    await project.save();
  }

  Future<void> deleteProject(String id) async {
    final project = HiveBoxes.projectsBox.get(id);
    if (project == null) return;

    final notes = project.notes?.toList() ?? [];
    final revisions = project.revisions?.toList() ?? [];
    final todos = project.todos?.toList() ?? [];

    for (final note in notes) {
      await note.delete();
    }
    for (final revision in revisions) {
      await revision.delete();
    }
    for (final todo in todos) {
      await todo.delete();
    }

    await project.delete();
  }

  Future<void> addNoteToProject(String projectId, Note note) async {
    final project = HiveBoxes.projectsBox.get(projectId);
    if (project == null) return;

    await HiveBoxes.notesBox.put(note.id, note);
    project.notes ??= HiveList(HiveBoxes.notesBox);
    project.notes?.add(note);
    project.updatedAt = DateTime.now();
    await project.save();
  }

  Future<void> removeNoteFromProject(String projectId, String noteId) async {
    final project = HiveBoxes.projectsBox.get(projectId);
    if (project == null || project.notes == null) return;

    Note? target;
    for (final note in project.notes!) {
      if (note.id == noteId) {
        target = note;
        break;
      }
    }

    if (target == null) return;

    project.notes?.remove(target);
    project.updatedAt = DateTime.now();
    await project.save();
    await target.delete();
  }

  Future<void> updateNote(String projectId, Note note) async {
    final project = HiveBoxes.projectsBox.get(projectId);
    if (project == null) return;

    note.updatedAt = DateTime.now();
    await note.save();

    project.updatedAt = DateTime.now();
    await project.save();
  }

  Future<void> addRevisionToProject(String projectId, Revision revision) async {
    final project = HiveBoxes.projectsBox.get(projectId);
    if (project == null) return;

    await HiveBoxes.revisionsBox.put(revision.id, revision);
    project.revisions ??= HiveList(HiveBoxes.revisionsBox);
    project.revisions?.add(revision);
    project.updatedAt = DateTime.now();
    await project.save();
  }

  Future<void> removeRevisionFromProject(
    String projectId,
    String revisionId,
  ) async {
    final project = HiveBoxes.projectsBox.get(projectId);
    if (project == null || project.revisions == null) return;

    Revision? target;
    for (final revision in project.revisions!) {
      if (revision.id == revisionId) {
        target = revision;
        break;
      }
    }

    if (target == null) return;

    project.revisions?.remove(target);
    project.updatedAt = DateTime.now();
    await project.save();
    await target.delete();
  }

  Future<void> updateRevision(String projectId, Revision revision) async {
    final project = HiveBoxes.projectsBox.get(projectId);
    if (project == null) return;

    await revision.save();

    project.updatedAt = DateTime.now();
    await project.save();
  }

  Future<void> addTodoToProject(String projectId, Todo todo) async {
    final project = HiveBoxes.projectsBox.get(projectId);
    if (project == null) return;

    await HiveBoxes.todosBox.put(todo.id, todo);
    project.todos ??= HiveList(HiveBoxes.todosBox);
    project.todos?.add(todo);
    project.updatedAt = DateTime.now();
    await project.save();
  }

  Future<void> updateNoteStatus(
    String projectId,
    String noteId,
    NoteStatus status,
  ) async {
    final project = HiveBoxes.projectsBox.get(projectId);
    if (project == null || project.notes == null) return;

    Note? target;
    for (final note in project.notes!) {
      if (note.id == noteId) {
        target = note;
        break;
      }
    }

    if (target == null) return;

    target.status = status;
    await target.save();

    project.updatedAt = DateTime.now();
    await project.save();
  }

  Future<void> updateRevisionStatus(
    String projectId,
    String revisionId,
    RevisionStatus status,
  ) async {
    final project = HiveBoxes.projectsBox.get(projectId);
    if (project == null || project.revisions == null) return;

    Revision? target;
    for (final revision in project.revisions!) {
      if (revision.id == revisionId) {
        target = revision;
        break;
      }
    }

    if (target == null) return;

    target.status = status;
    await target.save();

    project.updatedAt = DateTime.now();
    await project.save();
  }

  Future<void> updateTodoStatus(
    String projectId,
    String todoId,
    TodoStatus status,
  ) async {
    final project = HiveBoxes.projectsBox.get(projectId);
    if (project == null || project.todos == null) return;

    Todo? target;
    for (final todo in project.todos!) {
      if (todo.id == todoId) {
        target = todo;
        break;
      }
    }

    if (target == null) return;

    target
      ..status = status
      ..completedAt = status == TodoStatus.completed ? DateTime.now() : null;
    await target.save();

    project.updatedAt = DateTime.now();
    await project.save();
  }

  Future<void> updateTodo(String projectId, Todo todo) async {
    final project = HiveBoxes.projectsBox.get(projectId);
    if (project == null) return;

    await todo.save();

    project.updatedAt = DateTime.now();
    await project.save();
  }

  Future<void> removeTodoFromProject(String projectId, String todoId) async {
    final project = HiveBoxes.projectsBox.get(projectId);
    if (project == null || project.todos == null) return;

    Todo? target;
    for (final todo in project.todos!) {
      if (todo.id == todoId) {
        target = todo;
        break;
      }
    }

    if (target == null) return;

    project.todos?.remove(target);
    project.updatedAt = DateTime.now();
    await project.save();
    await target.delete();
  }
}
