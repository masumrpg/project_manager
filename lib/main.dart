import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' show FlutterQuillLocalizations;
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/project_provider.dart';
import 'repositories/project_repository.dart';
import 'screens/splash_screen.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/auth_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final envBaseUrl = dotenv.env['BASE_URL']?.trim();
  if (envBaseUrl == null || envBaseUrl.isEmpty) {
    throw StateError('BASE_URL is not set in .env');
  }

  final authStorage = await AuthStorage.create();
  final apiClient = ApiClient(baseUrl: envBaseUrl, authStorage: authStorage);
  final authService = AuthService(apiClient: apiClient, storage: authStorage);

  runApp(ProjectManagerApp(
    apiClient: apiClient,
    authService: authService,
  ));
}

class ProjectManagerApp extends StatelessWidget {
  const ProjectManagerApp({
    required this.apiClient,
    required this.authService,
    super.key,
  });

  final ApiClient apiClient;
  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<AuthService>.value(value: authService),
        Provider<ProjectRepository>(
          create: (context) => ProjectRepository(context.read<ApiClient>()),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(context.read<AuthService>())
            ..bootstrap(),
        ),
        ChangeNotifierProvider<ProjectProvider>(
          create: (context) => ProjectProvider(context.read<ProjectRepository>()),
        ),
      ],
      child: MaterialApp(
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
        home: const SplashScreen(),
      ),
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
