import 'package:catatan_kaki/repositories/project_repository.dart';
import 'package:catatan_kaki/services/api_client.dart';
import 'package:catatan_kaki/services/auth_service.dart';
import 'package:catatan_kaki/services/auth_storage.dart';
import 'package:catatan_kaki/services/background_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' show FlutterQuillLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catatan_kaki/providers.dart';
import 'package:catatan_kaki/services/settings_service.dart';

// ... (imports)

// ... (createContainer function)

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // Initialize Workmanager
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  final container = await createContainer();

  // Perform initial sync
  try {
    await container.read(syncServiceProvider).syncProjects();
  } catch (e) {
    // Log error, but don't block app start
    print('Initial sync failed: $e');
  }

  // Register background task only if enabled
  final settingsService = SettingsService();
  if (await settingsService.isAutoSyncEnabled()) {
    Workmanager().registerPeriodicTask(
      "1", // Unique name
      backgroundSyncTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ProjectManagerApp(),
    ),
  );
}

class ProjectManagerApp extends ConsumerWidget {
  const ProjectManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'Catatan Kaki',
      theme: _buildTheme(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('id'),
      ],
    );
  }
}

ThemeData _buildTheme() {
  // Consistent color palette matching the app design
  const primary = Color(0xFFE07A5F); // accentOrange
  const secondary = Color(0xFFF5E6D3); // primaryBeige
  const background = Color(0xFFFFFBF7); // cardBackground
  const surface = Color(0xFFF5E6D3); // primaryBeige
  const onPrimary = Color(0xFFFFFBF7); // cardBackground
  const onBackground = Color(0xFF2D3436); // darkText

  final baseScheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: Brightness.light,
  );

  final colorScheme = baseScheme.copyWith(
    primary: primary,
    onPrimary: onPrimary,
    secondary: secondary,
    onSecondary: onBackground,
    surface: surface,
    onSurface: onBackground,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: onBackground,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
    ),
    cardTheme: CardThemeData(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: background,
    ),
    chipTheme: ChipThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      side: BorderSide(color: colorScheme.outlineVariant),
      backgroundColor: surface,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      extendedIconLabelSpacing: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: surface,
      contentTextStyle: TextStyle(color: colorScheme.onSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme: DividerThemeData(
      space: 32,
      thickness: 1,
      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
    ),
    textTheme: ThemeData.dark().textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
  );
}