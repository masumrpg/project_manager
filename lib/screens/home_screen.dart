import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/enums/app_category.dart';
import '../models/enums/environment.dart';
import '../models/enums/todo_status.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import '../services/hive_boxes.dart';
import 'project_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final _uuid = Uuid();
  static final _dateFormat = DateFormat('dd MMM yyyy, HH:mm');

  // Modern warm color palette inspired by the reference
  static const Color _primaryBeige = Color(0xFFF5E6D3);
  static const Color _secondaryBeige = Color(0xFFE8D5C4);
  static const Color _accentOrange = Color(0xFFE07A5F);
  static const Color _darkText = Color(0xFF2D3436);
  static const Color _lightText = Color(0xFF636E72);
  static const Color _cardBackground = Color(0xFFFFFBF7);
  static const Color _shadowColor = Color(0x1A2D3436);

  static const Map<AppCategory, Color> _categoryColors = {
    AppCategory.personal: Color(0xFF81B3BA),
    AppCategory.work: Color(0xFF6C7B95),
    AppCategory.study: Color(0xFF8FA68E),
    AppCategory.health: Color(0xFFE07A5F),
    AppCategory.finance: Color(0xFFB08BBB),
    AppCategory.travel: Color(0xFF7FB069),
    AppCategory.shopping: Color(0xFFE9A46A),
    AppCategory.entertainment: Color(0xFF9A8194),
    AppCategory.family: Color(0xFF457B9D),
    AppCategory.other: Color(0xFF95A3A4),
  };

  static const Map<AppCategory, IconData> _categoryIcons = {
    AppCategory.personal: Icons.person_rounded,
    AppCategory.work: Icons.work_outline,
    AppCategory.study: Icons.menu_book_outlined,
    AppCategory.health: Icons.monitor_heart_outlined,
    AppCategory.finance: Icons.ssid_chart_rounded,
    AppCategory.travel: Icons.flight_takeoff,
    AppCategory.shopping: Icons.shopping_bag_outlined,
    AppCategory.entertainment: Icons.movie_filter_outlined,
    AppCategory.family: Icons.family_restroom,
    AppCategory.other: Icons.folder_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 768 && screenWidth <= 1024;

    return Scaffold(
      backgroundColor: _primaryBeige,
      body: SafeArea(
        child: Consumer<ProjectProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const _CenteredLoader();
            }

            if (provider.error != null) {
              return _ErrorState(
                message: provider.error!,
                onRetry: () => provider.loadProjects(),
              );
            }

            final projects = provider.projects;
            final metrics = _DashboardMetrics.fromProjects(projects);

            return RefreshIndicator(
              onRefresh: () => provider.loadProjects(showLoading: false),
              color: _accentOrange,
              backgroundColor: _cardBackground,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: _ModernHeader(
                      metrics: metrics,
                      onCreateProject: () => _showProjectDialog(context),
                      isDesktop: isDesktop,
                      isTablet: isTablet,
                    ),
                  ),
                  if (projects.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(
                        onCreateProject: () => _showProjectDialog(context),
                      ),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          isDesktop ? 48 : 24,
                          24,
                          isDesktop ? 48 : 24,
                          0
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Projects (${projects.length})',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: _darkText,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (isDesktop)
                              _ModernButton(
                                onPressed: () => _showProjectDialog(context),
                                icon: Icons.add_rounded,
                                label: 'New Project',
                              ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        isDesktop ? 48 : 24,
                        16,
                        isDesktop ? 48 : 24,
                        32
                      ),
                      sliver: isDesktop
                        ? _DesktopProjectGrid(projects: projects)
                        : _MobileProjectList(projects: projects),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1024) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => _showProjectDialog(context),
            backgroundColor: _accentOrange,
            foregroundColor: Colors.white,
            elevation: 8,
            label: const Text('New Project', style: TextStyle(fontWeight: FontWeight.w600)),
            icon: const Icon(Icons.add_rounded),
          );
        },
      ),
    );
  }

  Future<void> _showProjectDialog(
    BuildContext context, {
    Project? project,
  }) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: project?.title ?? '');
    final descriptionController = TextEditingController(text: project?.description ?? '');
    AppCategory selectedCategory = project?.category ?? AppCategory.work;
    Environment selectedEnvironment = project?.environment ?? Environment.development;

    final provider = context.read<ProjectProvider>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: _cardBackground,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _lightText.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Text(
                          project == null ? 'Create Project' : 'Edit Project',
                          style: TextStyle(
                            color: _darkText,
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            titleController.dispose();
                            descriptionController.dispose();
                            Navigator.of(bottomSheetContext).pop();
                          },
                          icon: Icon(Icons.close, color: _lightText),
                          style: IconButton.styleFrom(
                            backgroundColor: _primaryBeige.withValues(
                              alpha: 0.3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Form(
                      key: formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: titleController,
                              decoration: InputDecoration(
                                label: RichText(
                                  text: TextSpan(
                                    text: 'Title',
                                    style: TextStyle(color: _lightText),
                                    children: const [
                                      TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                                labelStyle: TextStyle(color: _lightText),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: _secondaryBeige,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: _accentOrange,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: _primaryBeige.withValues(alpha: 0.3),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Title is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Description',
                                labelStyle: TextStyle(color: _lightText),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: _secondaryBeige,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: _accentOrange,
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: _primaryBeige.withValues(alpha: 0.3),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<AppCategory>(
                              initialValue: selectedCategory,
                              decoration: InputDecoration(
                                labelText: 'Category',
                                labelStyle: TextStyle(color: _lightText),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: _secondaryBeige),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: _accentOrange, width: 2),
                                ),
                                filled: true,
                                fillColor: _primaryBeige.withValues(alpha: 0.3),
                              ),
                              dropdownColor: _cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              items: AppCategory.values
                                  .map(
                                    (category) =>
                                        DropdownMenuItem<AppCategory>(
                                          value: category,
                                          child: Text(
                                            category.label,
                                            style: TextStyle(
                                              color: _darkText,
                                            ),
                                          ),
                                        ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedCategory = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<Environment>(
                              initialValue: selectedEnvironment,
                              decoration: InputDecoration(
                                labelText: 'Environment',
                                labelStyle: TextStyle(color: _lightText),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: _secondaryBeige),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: _accentOrange, width: 2),
                                ),
                                filled: true,
                                fillColor: _primaryBeige.withValues(alpha: 0.3),
                              ),
                              dropdownColor: _cardBackground,
                              borderRadius: BorderRadius.circular(16),
                              items: Environment.values
                                  .map(
                                    (env) => DropdownMenuItem<Environment>(
                                      value: env,
                                      child: Text(
                                        env.label,
                                        style: TextStyle(color: _darkText),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedEnvironment = value;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Bottom actions
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _cardBackground,
                      border: Border(
                        top: BorderSide(
                          color: _secondaryBeige.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              titleController.dispose();
                              descriptionController.dispose();
                              Navigator.of(bottomSheetContext).pop();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: _lightText,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: _secondaryBeige),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              final formState = formKey.currentState;
                              if (formState == null || !formState.validate()) return;

                              final titleText = titleController.text.trim();
                              final descriptionText = descriptionController.text.trim();
                              
                              final now = DateTime.now();
                              final success = project == null
                                  ? await provider.createProject(
                                      Project(
                                        id: _uuid.v4(),
                                        title: titleText,
                                        description: descriptionText,
                                        category: selectedCategory,
                                        environment: selectedEnvironment,
                                        createdAt: now,
                                        updatedAt: now,
                                      ),
                                    )
                                  : await provider.updateProject(
                                      project.copyWith(
                                        title: titleText,
                                        description: descriptionText,
                                        category: selectedCategory,
                                        environment: selectedEnvironment,
                                        updatedAt: now,
                                      ),
                                    );

                              titleController.dispose();
                              descriptionController.dispose();

                              if (!bottomSheetContext.mounted) return;
                              Navigator.of(bottomSheetContext).pop();

                              if (!context.mounted) return;
                              _showOperationResult(
                                context,
                                success: success,
                                message: success
                                    ? project == null
                                          ? 'Project "$titleText" created'
                                          : 'Project "$titleText" updated'
                                    : provider.error ?? 'Operation failed',
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: _accentOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              project == null
                                  ? 'Create Project'
                                  : 'Update Project',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Project project) async {
    final provider = context.read<ProjectProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Delete Project',
            style: TextStyle(color: _darkText, fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you sure you want to delete "${project.title}"? This action cannot be undone.',
            style: TextStyle(color: _lightText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(foregroundColor: _lightText),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await provider.deleteProject(project.id);
      if (!context.mounted) return;
      _showOperationResult(
        context,
        success: success,
        message: success
            ? 'Project "${project.title}" deleted'
            : provider.error ?? 'Failed to delete project',
      );
    }
  }

  static String formatDate(DateTime date) => _dateFormat.format(date.toLocal());

  static Color _categoryColor(AppCategory category, BuildContext context) {
    return _categoryColors[category] ?? _accentOrange;
  }

  void _openProjectDetail(BuildContext context, String projectId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProjectDetailScreen(projectId: projectId),
      ),
    );
  }

  void _showOperationResult(
    BuildContext context, {
    required bool success,
    required String message,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? Colors.green.shade600 : Colors.red.shade600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static Future<void> _showClearDatabaseDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade400),
            const SizedBox(width: 12),
            const Text('Clear Database'),
          ],
        ),
        content: const Text(
          'Are you sure you want to clear all data? This will delete all projects, notes, revisions, and todos. This action cannot be undone.',
          style: TextStyle(color: _lightText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(foregroundColor: _lightText),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        // Clear all Hive data
        await HiveBoxes.clearAllData();

        // Reinitialize
        await HiveBoxes.init();

        // Reload projects
        if (context.mounted) {
          context.read<ProjectProvider>().loadProjects();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Database cleared successfully',
                style: TextStyle(color: Colors.white),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              margin: EdgeInsets.all(16),
            ),
          );
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to clear database: $error',
                style: const TextStyle(color: Colors.white),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    }
  }
}

// Modern Header Component
class _ModernHeader extends StatelessWidget {
  const _ModernHeader({
    required this.metrics,
    required this.onCreateProject,
    required this.isDesktop,
    required this.isTablet,
  });

  final _DashboardMetrics metrics;
  final VoidCallback onCreateProject;
  final bool isDesktop;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.fromLTRB(
        isDesktop ? 48 : 24,
        16,
        isDesktop ? 48 : 24,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isDesktop ? 32 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [HomeScreen._accentOrange, HomeScreen._accentOrange.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: HomeScreen._shadowColor,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Hello, Masum',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 20,
                      ),
                      color: HomeScreen._cardBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'clear_database',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_forever,
                                color: Colors.red.shade400,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Clear Database',
                                style: TextStyle(color: Colors.red.shade400),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'clear_database') {
                          HomeScreen._showClearDatabaseDialog(context);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: const Icon(Icons.person, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Your\nProjects (${metrics.totalProjects})',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                if (!isDesktop)
                  _ModernButton(
                    onPressed: onCreateProject,
                    icon: Icons.add_rounded,
                    label: 'New Project',
                    isLight: true,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Metrics Cards
          if (isDesktop)
            Row(
              children: [
                Expanded(child: _MetricCard(
                  icon: Icons.pending_actions_outlined,
                  label: 'Active todos',
                  value: metrics.activeTodos.toString(),
                  color: HomeScreen._categoryColors[AppCategory.work]!,
                )),
                const SizedBox(width: 16),
                Expanded(child: _MetricCard(
                  icon: Icons.task_alt_rounded,
                  label: 'Completed',
                  value: metrics.completedTodos.toString(),
                  color: HomeScreen._categoryColors[AppCategory.health]!,
                )),
                const SizedBox(width: 16),
                Expanded(child: _MetricCard(
                  icon: Icons.note_alt_outlined,
                  label: 'Notes',
                  value: metrics.totalNotes.toString(),
                  color: HomeScreen._categoryColors[AppCategory.study]!,
                )),
              ],
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _MetricCard(
                      icon: Icons.pending_actions_outlined,
                      label: 'Active todos',
                      value: metrics.activeTodos.toString(),
                      color: HomeScreen._categoryColors[AppCategory.work]!,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _MetricCard(
                      icon: Icons.task_alt_rounded,
                      label: 'Completed',
                      value: metrics.completedTodos.toString(),
                      color: HomeScreen._categoryColors[AppCategory.health]!,
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        icon: Icons.note_alt_outlined,
                        label: 'Notes collected',
                        value: metrics.totalNotes.toString(),
                        color:
                            HomeScreen._categoryColors[AppCategory.study]!,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Placeholder to keep grid alignment and equal widths
                    const Expanded(child: SizedBox.shrink()),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// Modern Button Component
class _ModernButton extends StatelessWidget {
  const _ModernButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isLight = false,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      style: FilledButton.styleFrom(
        backgroundColor: isLight ? Colors.white : HomeScreen._accentOrange,
        foregroundColor: isLight ? HomeScreen._accentOrange : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    );
  }
}

// Modern Metric Card
class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HomeScreen._cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HomeScreen._secondaryBeige),
        boxShadow: [
          BoxShadow(
            color: HomeScreen._shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: HomeScreen._darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: HomeScreen._lightText,
            ),
          ),
        ],
      ),
    );
  }
}

// Desktop Project Grid
class _DesktopProjectGrid extends StatelessWidget {
  const _DesktopProjectGrid({required this.projects});

  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive column count based on screen width
    int crossAxisCount;
    double childAspectRatio;

    if (screenWidth > 1600) {
      // Extra large screens: 4 columns
      crossAxisCount = 4;
      childAspectRatio = 1.3;
    } else if (screenWidth > 1200) {
      // Large screens: 3 columns
      crossAxisCount = 3;
      childAspectRatio = 1.2;
    } else {
      // Medium screens: 2 columns
      crossAxisCount = 2;
      childAspectRatio = 1.1;
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: childAspectRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final project = projects[index];
          return _ModernProjectCard(
            project: project,
            onOpenDetail: () {
              final homeScreen = context.findAncestorWidgetOfExactType<HomeScreen>();
              if (homeScreen != null) {
                homeScreen._openProjectDetail(context, project.id);
              }
            },
            onEdit: () {
              final homeScreen = context.findAncestorWidgetOfExactType<HomeScreen>();
              if (homeScreen != null) {
                homeScreen._showProjectDialog(context, project: project);
              }
            },
            onDelete: () {
              final homeScreen = context.findAncestorWidgetOfExactType<HomeScreen>();
              if (homeScreen != null) {
                homeScreen._confirmDelete(context, project);
              }
            },
          );
        },
        childCount: projects.length,
      ),
    );
  }


}

// Mobile Project List
class _MobileProjectList extends StatelessWidget {
  const _MobileProjectList({required this.projects});

  final List<Project> projects;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final project = projects[index];
          return Padding(
            padding: EdgeInsets.only(bottom: index == projects.length - 1 ? 0 : 20),
            child: _ModernProjectCard(
              project: project,
              onOpenDetail: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProjectDetailScreen(projectId: project.id),
                  ),
                );
              },
              onEdit: () {
                final homeScreen = context.findAncestorWidgetOfExactType<HomeScreen>();
                if (homeScreen != null) {
                  homeScreen._showProjectDialog(context, project: project);
                }
              },
              onDelete: () {
                final homeScreen = context.findAncestorWidgetOfExactType<HomeScreen>();
                if (homeScreen != null) {
                  homeScreen._confirmDelete(context, project);
                }
              },
            ),
          );
        },
        childCount: projects.length,
      ),
    );
  }


}

// Modern Project Card
class _ModernProjectCard extends StatelessWidget {
  const _ModernProjectCard({
    required this.project,
    required this.onOpenDetail,
    required this.onEdit,
    required this.onDelete,
  });

  final Project project;
  final VoidCallback onOpenDetail;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = HomeScreen._categoryColor(project.category, context);
    final categoryIcon = HomeScreen._categoryIcons[project.category] ?? Icons.folder_outlined;

    final todos = project.todos;
    final totalTodos = todos?.length ?? 0;
    var completedTodos = 0;
    if (todos != null) {
      for (final todo in todos) {
        if (todo.status == TodoStatus.completed) {
          completedTodos++;
        }
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onOpenDetail,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: HomeScreen._cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: HomeScreen._secondaryBeige),
            boxShadow: [
              BoxShadow(
                color: HomeScreen._shadowColor,
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(categoryIcon, color: categoryColor, size: 24),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: HomeScreen._lightText),
                    color: HomeScreen._cardBackground,
                    surfaceTintColor: Colors.transparent,
                    shadowColor: HomeScreen._shadowColor.withValues(alpha: 0.2),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: HomeScreen._secondaryBeige),
                    ),
                    onSelected: (value) async {
                      if (!context.mounted) return;
                      
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, color: HomeScreen._darkText),
                            const SizedBox(width: 12),
                            Text('Edit', style: TextStyle(color: HomeScreen._darkText)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red.shade400),
                            const SizedBox(width: 12),
                            Text('Delete', style: TextStyle(color: Colors.red.shade400)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                project.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: HomeScreen._darkText,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                project.description.isEmpty
                  ? 'No description provided'
                  : project.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: HomeScreen._lightText,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.note_outlined,
                    count: project.notes?.length ?? 0,
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.check_circle_outline,
                    count: totalTodos,
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.history_outlined,
                    count: project.revisions?.length ?? 0,
                  ),
                ],
              ),
              if (totalTodos > 0) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: completedTodos / totalTodos,
                        backgroundColor: categoryColor.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$completedTodos/$totalTodos',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: HomeScreen._lightText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Info Chip Component
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.count,
  });

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: HomeScreen._primaryBeige,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HomeScreen._secondaryBeige),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: HomeScreen._lightText),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: HomeScreen._lightText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}



// Dashboard Metrics Data Class
class _DashboardMetrics {
  const _DashboardMetrics({
    required this.totalProjects,
    required this.totalNotes,
    required this.completedTodos,
    required this.activeTodos,
    required this.lastUpdated,
  });

  factory _DashboardMetrics.fromProjects(List<Project> projects) {
    if (projects.isEmpty) {
      return const _DashboardMetrics(
        totalProjects: 0,
        totalNotes: 0,
        completedTodos: 0,
        activeTodos: 0,
        lastUpdated: null,
      );
    }

    var notes = 0;
    var completed = 0;
    var totalTodos = 0;
    DateTime? latest;

    for (final project in projects) {
      notes += project.notes?.length ?? 0;

      final todos = project.todos;
      if (todos != null) {
        totalTodos += todos.length;
        for (final todo in todos) {
          if (todo.status == TodoStatus.completed) {
            completed++;
          }
        }
      }

      if (latest == null || project.updatedAt.isAfter(latest)) {
        latest = project.updatedAt;
      }
    }

    final active = totalTodos - completed;

    return _DashboardMetrics(
      totalProjects: projects.length,
      totalNotes: notes,
      completedTodos: completed,
      activeTodos: active,
      lastUpdated: latest,
    );
  }

  final int totalProjects;
  final int totalNotes;
  final int completedTodos;
  final int activeTodos;
  final DateTime? lastUpdated;
}

// Centered Loader Widget
class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: HomeScreen._accentOrange,
      ),
    );
  }
}

// Empty State Widget
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreateProject});

  final VoidCallback onCreateProject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.15),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.folder_open,
                      size: 40,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Create your first project',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Organise notes, revisions, and todos in a single workspace.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onCreateProject,
                    icon: const Icon(Icons.add),
                    label: const Text('Create project'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: colorScheme.error.withValues(alpha: 0.4),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 56, color: colorScheme.error),
                  const SizedBox(height: 18),
                  Text(
                    'Something went wrong',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onErrorContainer,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
