import 'package:catatan_kaki/database/app_database.dart';
import 'package:catatan_kaki/models/project.dart';
import 'package:catatan_kaki/models/note.dart';
import 'package:catatan_kaki/models/revision.dart';
import 'package:catatan_kaki/models/todo.dart';
import 'package:catatan_kaki/repositories/local/project_local_repository.dart';
import 'package:catatan_kaki/repositories/project_repository.dart';
import 'package:catatan_kaki/router/app_router.dart';
import 'package:catatan_kaki/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:catatan_kaki/services/sync_service.dart';
import 'package:catatan_kaki/services/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:catatan_kaki/models/enums/sync_status.dart';
import 'package:catatan_kaki/repositories/local/sync_metadata_repository.dart';
import 'package:catatan_kaki/services/settings_service.dart';
import 'package:catatan_kaki/repositories/local/note_local_repository.dart';
import 'package:catatan_kaki/repositories/local/revision_local_repository.dart';
import 'package:catatan_kaki/repositories/local/todo_local_repository.dart';

import 'providers/auth_provider.dart';
import 'providers/project_provider.dart';

// --- Core Services (to be overridden in main.dart) ---
final authServiceProvider =
    Provider<AuthService>((ref) => throw UnimplementedError());
final projectRepositoryProvider =
    Provider<ProjectRepository>((ref) => throw UnimplementedError());

// --- App Services ---
final syncServiceProvider = Provider<SyncService>((ref) => SyncService(ref));
final connectivityServiceProvider = Provider((ref) => ConnectivityService());
final settingsServiceProvider = Provider((ref) => SettingsService());

// --- Database Provider ---
final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

// --- Repository Providers ---
final projectLocalRepositoryProvider = Provider<ProjectLocalRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProjectLocalRepository(db);
});
final noteLocalRepositoryProvider = Provider<NoteLocalRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return NoteLocalRepository(db);
});
final revisionLocalRepositoryProvider = Provider<RevisionLocalRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return RevisionLocalRepository(db);
});
final todoLocalRepositoryProvider = Provider<TodoLocalRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TodoLocalRepository(db);
});
final syncMetadataRepositoryProvider = Provider((ref) {
  return SyncMetadataRepository(ref.watch(appDatabaseProvider));
});

// --- State Notifier Providers ---
final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthProvider(authService)..bootstrap();
});

// This is the old provider, now managed by Riverpod
final projectProvider = ChangeNotifierProvider<ProjectProvider>((ref) {
  final repo = ref.watch(projectRepositoryProvider);
  return ProjectProvider(repo);
});

// --- Stream Providers ---
final connectivityStreamProvider = StreamProvider<ConnectivityResult>((ref) {
  return ref.watch(connectivityServiceProvider).onConnectivityChanged;
});

final syncStatusProvider = StateProvider<SyncStatus>((ref) => SyncStatus.idle);

final lastSyncTimestampProvider = StreamProvider<DateTime?>((ref) {
  return ref.watch(syncMetadataRepositoryProvider).watchLastSyncTimestamp();
});

final syncQueueCountProvider = StreamProvider<int>((ref) {
  return ref.watch(syncMetadataRepositoryProvider).watchSyncQueueCount();
});

final syncErrorProvider = StateProvider<String?>((ref) => null);

final autoSyncEnabledProvider = FutureProvider<bool>((ref) async {
  return ref.watch(settingsServiceProvider).isAutoSyncEnabled();
});

// --- UI Data Providers ---
final projectListStreamProvider = StreamProvider<List<domain.Project>>((ref) {
  final localRepo = ref.watch(projectLocalRepositoryProvider);
  return localRepo.watchAllProjects();
});

// Provider for a single project stream from local DB
final projectProvider = StreamProvider.family<domain.Project?, String>((ref, id) {
  final localRepo = ref.watch(projectLocalRepositoryProvider);
  return localRepo.watchProjectById(id);
});

// Provider for a stream of notes for a project
final notesForProjectProvider = StreamProvider.family<List<domain.Note>, String>((ref, projectId) {
  final localRepo = ref.watch(noteLocalRepositoryProvider);
  return localRepo.watchNotesForProject(projectId);
});

// Provider for a stream of revisions for a project
final revisionsForProjectProvider = StreamProvider.family<List<domain.Revision>, String>((ref, projectId) {
  final localRepo = ref.watch(revisionLocalRepositoryProvider);
  return localRepo.watchRevisionsForProject(projectId);
});

// Provider for a stream of todos for a project
final todosForProjectProvider = StreamProvider.family<List<domain.Todo>, String>((ref, projectId) {
  final localRepo = ref.watch(todoLocalRepositoryProvider);
  return localRepo.watchTodosForProject(projectId);
});

// --- Router Provider ---
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);
  return createRouter(auth);
});