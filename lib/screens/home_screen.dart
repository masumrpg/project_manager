import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/enums/app_category.dart';
import '../models/enums/environment.dart';
import '../models/enums/todo_status.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import 'project_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final _uuid = Uuid();
  static final _dateFormat = DateFormat('dd MMM yyyy, HH:mm');

  static const Map<AppCategory, Color> _categoryColors = {
    AppCategory.personal: Color(0xFF6750A4),
    AppCategory.work: Color(0xFF005AC1),
    AppCategory.study: Color(0xFF386641),
    AppCategory.health: Color(0xFFD62828),
    AppCategory.finance: Color(0xFF8F2D56),
    AppCategory.travel: Color(0xFF1D3557),
    AppCategory.shopping: Color(0xFFBC4749),
    AppCategory.entertainment: Color(0xFF6A4C93),
    AppCategory.family: Color(0xFF457B9D),
    AppCategory.other: Color(0xFF666666),
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

    return Scaffold(
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
              color: theme.colorScheme.primary,
              edgeOffset: 16,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: _HomeHeader(
                      metrics: metrics,
                      onCreateProject: () => _showProjectDialog(context),
                    ),
                  ),
                  if (projects.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(
                        onCreate: () => _showProjectDialog(context),
                      ),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                        child: Text(
                          'Your projects',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final project = projects[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == projects.length - 1 ? 0 : 20,
                            ),
                            child: _ProjectCard(
                              project: project,
                              onOpenDetail: () =>
                                  _openProjectDetail(context, project.id),
                              onEdit: () =>
                                  _showProjectDialog(context, project: project),
                              onDelete: () => _confirmDelete(context, project),
                            ),
                          );
                        }, childCount: projects.length),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProjectDialog(context),
        label: const Text('New Project'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showProjectDialog(
    BuildContext context, {
    Project? project,
  }) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: project?.title ?? '');
    final descriptionController = TextEditingController(
      text: project?.description ?? '',
    );
    var selectedCategory = project?.category ?? AppCategory.personal;
    var selectedEnvironment = project?.environment ?? Environment.development;

    final provider = context.read<ProjectProvider>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(project == null ? 'Create Project' : 'Edit Project'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AppCategory>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: AppCategory.values
                        .map(
                          (category) => DropdownMenuItem<AppCategory>(
                            value: category,
                            child: Text(category.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedCategory = value;
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Environment>(
                    initialValue: selectedEnvironment,
                    decoration: const InputDecoration(
                      labelText: 'Environment',
                      border: OutlineInputBorder(),
                    ),
                    items: Environment.values
                        .map(
                          (env) => DropdownMenuItem<Environment>(
                            value: env,
                            child: Text(env.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedEnvironment = value;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final now = DateTime.now();
                final success = project == null
                    ? await provider.createProject(
                        Project(
                          id: _uuid.v4(),
                          title: titleController.text.trim(),
                          description: descriptionController.text.trim(),
                          category: selectedCategory,
                          environment: selectedEnvironment,
                          createdAt: now,
                          updatedAt: now,
                        ),
                      )
                    : await provider.updateProject(
                        project
                          ..title = titleController.text.trim()
                          ..description = descriptionController.text.trim()
                          ..category = selectedCategory
                          ..environment = selectedEnvironment
                          ..updatedAt = now,
                      );

                if (!context.mounted) return;

                if (success) {
                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop();
                  _showOperationResult(
                    context,
                    success: true,
                    message: project == null
                        ? 'Project created successfully'
                        : 'Project updated successfully',
                  );
                } else {
                  _showOperationResult(
                    context,
                    success: false,
                    message: provider.error ?? 'Failed to save project',
                  );
                }
              },
              child: Text(project == null ? 'Create' : 'Save'),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, Project project) async {
    final provider = context.read<ProjectProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Project'),
          content: Text(
            'Are you sure you want to delete "${project.title}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.of(dialogContext).pop(true),
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
    return _categoryColors[category] ?? Theme.of(context).colorScheme.primary;
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
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: success
            ? const Color(0xFF2E7D32)
            : const Color(0xFFC62828),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

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

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.metrics, required this.onCreateProject});

  final _DashboardMetrics metrics;
  final VoidCallback onCreateProject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.18),
                  blurRadius: 34,
                  offset: const Offset(0, 22),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      '${metrics.totalProjects} project${metrics.totalProjects == 1 ? '' : 's'} tracked',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Manage your projects smarter',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Keep track of revisions, notes, and todos with a single glance.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton(
                        onPressed: onCreateProject,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          textStyle: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Create project'),
                      ),
                      if (metrics.lastUpdated != null)
                        _HeaderMeta(
                          icon: Icons.watch_later_outlined,
                          label: 'Latest update',
                          value: HomeScreen.formatDate(metrics.lastUpdated!),
                          color: Colors.white,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 520;
              final tiles = [
                _MetricTile(
                  icon: Icons.pending_actions_outlined,
                  label: 'Active todos',
                  value: metrics.activeTodos.toString(),
                  color: colorScheme.primary,
                ),
                _MetricTile(
                  icon: Icons.task_alt_rounded,
                  label: 'Completed todos',
                  value: metrics.completedTodos.toString(),
                  color: colorScheme.secondary,
                ),
                _MetricTile(
                  icon: Icons.note_alt_outlined,
                  label: 'Notes collected',
                  value: metrics.totalNotes.toString(),
                  color: colorScheme.tertiary,
                ),
              ];

              if (isWide) {
                return Row(
                  children: tiles
                      .map((tile) => Expanded(child: tile))
                      .toList(growable: false),
                );
              }

              return Column(
                children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    tiles[i],
                    if (i != tiles.length - 1) const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
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
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderMeta extends StatelessWidget {
  const _HeaderMeta({
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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: color.withValues(alpha: 0.8),
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                value,
                style: textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
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
    final colorScheme = theme.colorScheme;
    final categoryIcon =
        HomeScreen._categoryIcons[project.category] ?? Icons.folder_outlined;

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
    final double? progress = totalTodos == 0
        ? null
        : completedTodos / totalTodos;
    final String? progressLabel = progress == null
        ? null
        : '${(progress * 100).round()}%';

    final description = project.description.isEmpty
        ? 'No description yet. Add a short summary to highlight key goals.'
        : project.description;
    final isDescriptionPlaceholder = project.description.isEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onOpenDetail,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                categoryColor.withValues(alpha: 0.14),
                colorScheme.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: categoryColor.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: categoryColor.withValues(alpha: 0.16),
                blurRadius: 26,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: categoryColor.withValues(alpha: 0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withValues(alpha: 0.18),
                            blurRadius: 16,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(categoryIcon, color: categoryColor, size: 26),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _CategoryChip(
                                label: project.category.label,
                                color: categoryColor,
                              ),
                              _CategoryChip(
                                label: project.environment.label,
                                icon: Icons.cloud_outlined,
                                color: colorScheme.primary,
                                foreground: colorScheme.onSurface,
                                outlined: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: onEdit,
                      tooltip: 'Edit project',
                      icon: const Icon(Icons.edit_outlined),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.85),
                        foregroundColor: categoryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'More options',
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          onEdit();
                        } else if (value == 'delete') {
                          onDelete();
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined),
                              SizedBox(width: 12),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.red),
                              SizedBox(width: 12),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: isDescriptionPlaceholder
                        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.65)
                        : colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _InfoBadge(
                      icon: Icons.sticky_note_2_outlined,
                      label: 'Notes',
                      value: project.notes?.length ?? 0,
                    ),
                    _InfoBadge(
                      icon: Icons.history_outlined,
                      label: 'Revisions',
                      value: project.revisions?.length ?? 0,
                    ),
                    _InfoBadge(
                      icon: Icons.check_circle_outline,
                      label: 'Todos',
                      value: totalTodos,
                    ),
                  ],
                ),
                if (totalTodos > 0) ...[
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      color: categoryColor,
                      backgroundColor: categoryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$completedTodos of $totalTodos todos completed • ${progressLabel!}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (totalTodos == 0) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceTint.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.segment, color: categoryColor, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Add todos to start tracking progress for this project.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(
                      Icons.event_note_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Created ${HomeScreen.formatDate(project.createdAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.update,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Updated ${HomeScreen.formatDate(project.updatedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.color,
    this.icon,
    this.foreground,
    this.outlined = false,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final Color? foreground;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveForeground = foreground ?? Colors.white;
    final showOutline = outlined || foreground != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: showOutline ? Colors.transparent : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (showOutline ? color : color.withValues(alpha: 0.25)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: showOutline ? color : effectiveForeground,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: showOutline ? color : effectiveForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

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
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.folder_open,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Create your first project',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Organise notes, revisions, and todos in a single workspace.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: onCreate,
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
