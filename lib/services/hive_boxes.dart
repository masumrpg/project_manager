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
import '../models/user.dart';

class HiveBoxes {
  HiveBoxes._();

  static const String _projectsBoxName = 'projects_box';
  static const String _notesBoxName = 'notes_box';
  static const String _revisionsBoxName = 'revisions_box';
  static const String _todosBoxName = 'todos_box';
  static const String _userBoxName = 'user_box';

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    try {
      await Hive.initFlutter('project_manager');
      _registerAdapters();
      
      // Ensure all adapters are registered before opening boxes
      await Future.delayed(const Duration(milliseconds: 100));
      
      await Future.wait([
        Hive.openBox<Project>(_projectsBoxName),
        Hive.openBox<Note>(_notesBoxName),
        Hive.openBox<Revision>(_revisionsBoxName),
        Hive.openBox<Todo>(_todosBoxName),
        Hive.openBox<User>(_userBoxName),
      ]);
      _initialized = true;
      debugPrint('Hive initialized successfully');
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
      await Hive.deleteBoxFromDisk(_userBoxName);

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
    debugPrint('Registering Hive adapters...');
    
    if (!Hive.isAdapterRegistered(AppCategoryAdapter().typeId)) {
      Hive.registerAdapter(AppCategoryAdapter());
      debugPrint('Registered AppCategoryAdapter');
    }
    if (!Hive.isAdapterRegistered(EnvironmentAdapter().typeId)) {
      Hive.registerAdapter(EnvironmentAdapter());
      debugPrint('Registered EnvironmentAdapter');
    }
    if (!Hive.isAdapterRegistered(ContentTypeAdapter().typeId)) {
      Hive.registerAdapter(ContentTypeAdapter());
      debugPrint('Registered ContentTypeAdapter');
    }
    if (!Hive.isAdapterRegistered(NoteStatusAdapter().typeId)) {
      Hive.registerAdapter(NoteStatusAdapter());
      debugPrint('Registered NoteStatusAdapter');
    }
    if (!Hive.isAdapterRegistered(RevisionStatusAdapter().typeId)) {
      Hive.registerAdapter(RevisionStatusAdapter());
      debugPrint('Registered RevisionStatusAdapter');
    }
    if (!Hive.isAdapterRegistered(TodoPriorityAdapter().typeId)) {
      Hive.registerAdapter(TodoPriorityAdapter());
      debugPrint('Registered TodoPriorityAdapter');
    }
    if (!Hive.isAdapterRegistered(TodoStatusAdapter().typeId)) {
      Hive.registerAdapter(TodoStatusAdapter());
      debugPrint('Registered TodoStatusAdapter');
    }
    if (!Hive.isAdapterRegistered(ProjectAdapter().typeId)) {
      Hive.registerAdapter(ProjectAdapter());
      debugPrint('Registered ProjectAdapter');
    }
    if (!Hive.isAdapterRegistered(NoteAdapter().typeId)) {
      Hive.registerAdapter(NoteAdapter());
      debugPrint('Registered NoteAdapter');
    }
    if (!Hive.isAdapterRegistered(RevisionAdapter().typeId)) {
      Hive.registerAdapter(RevisionAdapter());
      debugPrint('Registered RevisionAdapter');
    }
    if (!Hive.isAdapterRegistered(TodoAdapter().typeId)) {
      Hive.registerAdapter(TodoAdapter());
      debugPrint('Registered TodoAdapter');
    }
    if (!Hive.isAdapterRegistered(UserAdapter().typeId)) {
      Hive.registerAdapter(UserAdapter());
      debugPrint('Registered UserAdapter');
    }
    
    debugPrint('All Hive adapters registered successfully');
  }

  static Box<Project> get projectsBox => Hive.box<Project>(_projectsBoxName);
  static Box<Note> get notesBox => Hive.box<Note>(_notesBoxName);
  static Box<Revision> get revisionsBox =>
      Hive.box<Revision>(_revisionsBoxName);
  static Box<Todo> get todosBox => Hive.box<Todo>(_todosBoxName);
  static Box<User> get userBox => Hive.box<User>(_userBoxName);
}
