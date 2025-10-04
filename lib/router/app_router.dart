
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../models/revision.dart';
import '../models/todo.dart';
import '../screens/auth_screen.dart';
import '../screens/home_screen.dart';
import '../screens/long_description_editor_screen.dart';
import '../screens/note_detail_screen.dart';
import '../screens/note_edit_screen.dart';
import '../screens/project_detail_screen.dart';
import '../screens/revision_detail_screen.dart';
import '../screens/revision_edit_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/todo_detail_screen.dart';
import '../screens/todo_edit_screen.dart';
import '../providers/project_detail_provider.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/auth',
      builder: (BuildContext context, GoRouterState state) {
        return const AuthScreen();
      },
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/project/:id',
      builder: (BuildContext context, GoRouterState state) {
        final id = state.pathParameters['id']!;
        return ProjectDetailScreen(projectId: id);
      },
    ),
    GoRoute(
      path: '/note',
      builder: (BuildContext context, GoRouterState state) {
        final args = state.extra as Map<String, dynamic>;
        final note = args['note'] as Note;
        final provider = args['provider'] as ProjectDetailProvider;
        return ChangeNotifierProvider<ProjectDetailProvider>.value(
          value: provider,
          child: NoteDetailScreen(note: note),
        );
      },
    ),
    GoRoute(
      path: '/note/edit',
      builder: (BuildContext context, GoRouterState state) {
        final args = state.extra as Map<String, dynamic>;
        final note = args['note'] as Note;
        final provider = args['provider'] as ProjectDetailProvider;
        return ChangeNotifierProvider<ProjectDetailProvider>.value(
          value: provider,
          child: NoteEditScreen(note: note),
        );
      },
    ),
    GoRoute(
      path: '/revision',
      builder: (BuildContext context, GoRouterState state) {
        final args = state.extra as Map<String, dynamic>;
        final revision = args['revision'] as Revision;
        final provider = args['provider'] as ProjectDetailProvider;
        return ChangeNotifierProvider<ProjectDetailProvider>.value(
          value: provider,
          child: RevisionDetailScreen(revision: revision),
        );
      },
    ),
    GoRoute(
      path: '/revision/edit',
      builder: (BuildContext context, GoRouterState state) {
        final args = state.extra as Map<String, dynamic>;
        final revision = args['revision'] as Revision;
        final provider = args['provider'] as ProjectDetailProvider;
        return ChangeNotifierProvider<ProjectDetailProvider>.value(
          value: provider,
          child: RevisionEditScreen(revision: revision),
        );
      },
    ),
    GoRoute(
      path: '/todo',
      builder: (BuildContext context, GoRouterState state) {
        final args = state.extra as Map<String, dynamic>;
        final todo = args['todo'] as Todo;
        final provider = args['provider'] as ProjectDetailProvider;
        return ChangeNotifierProvider<ProjectDetailProvider>.value(
          value: provider,
          child: TodoDetailScreen(todo: todo),
        );
      },
    ),
    GoRoute(
      path: '/todo/edit',
      builder: (BuildContext context, GoRouterState state) {
        final args = state.extra as Map<String, dynamic>;
        final todo = args['todo'] as Todo;
        final provider = args['provider'] as ProjectDetailProvider;
        return ChangeNotifierProvider<ProjectDetailProvider>.value(
          value: provider,
          child: TodoEditScreen(todo: todo),
        );
      },
    ),
    GoRoute(
      path: '/long-description-editor',
      builder: (BuildContext context, GoRouterState state) {
        final args = state.extra as Map<String, dynamic>;
        return LongDescriptionEditorScreen(
          projectTitle: args['projectTitle'] as String,
          initialJson: args['initialJson'] as String?,
          onSave: args['onSave'] as Future<bool> Function(String json)?,
        );
      },
    ),
  ],
);
