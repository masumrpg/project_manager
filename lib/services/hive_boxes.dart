import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/enums/app_category.dart';
import '../models/enums/content_type.dart';
import '../models/enums/environment.dart';
import '../models/enums/note_status.dart';
import '../models/enums/revision_status.dart';
import '../models/enums/todo_priority.dart';
import '../models/enums/todo_status.dart';
import '../models/note.dart';
import '../models/project.dart';
import '../models/revision.dart';
import '../models/todo.dart';

class HiveBoxes {
  HiveBoxes._();

  static const String _projectsBoxName = 'projects_box';
  static const String _notesBoxName = 'notes_box';
  static const String _revisionsBoxName = 'revisions_box';
  static const String _todosBoxName = 'todos_box';

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    try {
      await Hive.initFlutter();
      _registerAdapters();
      await Future.wait([
        Hive.openBox<Project>(_projectsBoxName),
        Hive.openBox<Note>(_notesBoxName),
        Hive.openBox<Revision>(_revisionsBoxName),
        Hive.openBox<Todo>(_todosBoxName),
      ]);
      _initialized = true;
    } catch (error, stackTrace) {
      debugPrint('Failed to initialize Hive: $error');
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  /// Clear all Hive data and reset the database
  static Future<void> clearAllData() async {
    try {
      // Close all boxes first
      await Hive.close();

      // Delete all boxes from disk
      await Hive.deleteBoxFromDisk(_projectsBoxName);
      await Hive.deleteBoxFromDisk(_notesBoxName);
      await Hive.deleteBoxFromDisk(_revisionsBoxName);
      await Hive.deleteBoxFromDisk(_todosBoxName);

      // Reset initialization flag
      _initialized = false;

      debugPrint('All Hive data cleared successfully');
    } catch (error, stackTrace) {
      debugPrint('Failed to clear Hive data: $error');
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(AppCategoryAdapter().typeId)) {
      Hive.registerAdapter(AppCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(EnvironmentAdapter().typeId)) {
      Hive.registerAdapter(EnvironmentAdapter());
    }
    if (!Hive.isAdapterRegistered(ContentTypeAdapter().typeId)) {
      Hive.registerAdapter(ContentTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(NoteStatusAdapter().typeId)) {
      Hive.registerAdapter(NoteStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(RevisionStatusAdapter().typeId)) {
      Hive.registerAdapter(RevisionStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(TodoPriorityAdapter().typeId)) {
      Hive.registerAdapter(TodoPriorityAdapter());
    }
    if (!Hive.isAdapterRegistered(TodoStatusAdapter().typeId)) {
      Hive.registerAdapter(TodoStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(ProjectAdapter().typeId)) {
      Hive.registerAdapter(ProjectAdapter());
    }
    if (!Hive.isAdapterRegistered(NoteAdapter().typeId)) {
      Hive.registerAdapter(NoteAdapter());
    }
    if (!Hive.isAdapterRegistered(RevisionAdapter().typeId)) {
      Hive.registerAdapter(RevisionAdapter());
    }
    if (!Hive.isAdapterRegistered(TodoAdapter().typeId)) {
      Hive.registerAdapter(TodoAdapter());
    }
  }

  static Box<Project> get projectsBox => Hive.box<Project>(_projectsBoxName);
  static Box<Note> get notesBox => Hive.box<Note>(_notesBoxName);
  static Box<Revision> get revisionsBox =>
      Hive.box<Revision>(_revisionsBoxName);
  static Box<Todo> get todosBox => Hive.box<Todo>(_todosBoxName);
}
