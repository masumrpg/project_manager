import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/project_provider.dart';
import 'repositories/project_repository.dart';
import 'screens/home_screen.dart';
import 'services/hive_boxes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveBoxes.init();
  runApp(const ProjectManagerApp());
}

class ProjectManagerApp extends StatelessWidget {
  const ProjectManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ProjectRepository()),
        ChangeNotifierProvider(
          create: (context) =>
              ProjectProvider(context.read<ProjectRepository>())
                ..loadProjects(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Project Manager',
        theme: _buildTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}

ThemeData _buildTheme() {
  const primary = Color(0xFF8A4AF3);
  const secondary = Color(0xFFBB86FC);
  const background = Color(0xFF1A1A1A);
  const surface = Color(0xFF2D2D2D);
  const onPrimary = Color(0xFFFFFFFF);
  const onBackground = Color(0xFFD3D3D3);

  final baseScheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: Brightness.dark,
  );

  final colorScheme = baseScheme.copyWith(
    primary: primary,
    onPrimary: onPrimary,
    secondary: secondary,
    onSecondary: onPrimary,
    surface: surface,
    onSurface: onBackground,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
    ),
    cardTheme: CardThemeData(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: surface,
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
