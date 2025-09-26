import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/enums/app_category.dart';
import '../models/enums/environment.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      appBar: AppBar(title: const Text('My Projects'), centerTitle: false),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return _ErrorState(
              message: provider.error!,
              onRetry: () => provider.loadProjects(),
            );
          }

          if (provider.projects.isEmpty) {
            return _EmptyState(onCreate: () => _showProjectDialog(context));
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadProjects(showLoading: false),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: provider.projects.length,
              itemBuilder: (context, index) {
                final project = provider.projects[index];
                return _ProjectCard(
                  project: project,
                  onOpenDetail: () => _openProjectDetail(context, project.id),
                  onEdit: () => _showProjectDialog(context, project: project),
                  onDelete: () => _confirmDelete(context, project),
                );
              },
            ),
          );
        },
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
    final cardStart = Color.lerp(categoryColor, Colors.white, 0.65)!;
    final cardEnd = Color.lerp(categoryColor, theme.colorScheme.surface, 0.2)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onOpenDetail,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cardStart, cardEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.title,
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              project.description.isEmpty
                                  ? 'No description provided.'
                                  : project.description,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit project',
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
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
                              children: const [
                                Icon(Icons.edit_outlined),
                                SizedBox(width: 12),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: const [
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
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(project.category.label),
                        backgroundColor: categoryColor.withValues(alpha: 0.15),
                        labelStyle: TextStyle(color: categoryColor),
                      ),
                      Chip(
                        avatar: const Icon(Icons.cloud_outlined, size: 18),
                        label: Text(project.environment.label),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _InfoBadge(
                        icon: Icons.sticky_note_2_outlined,
                        label: 'Notes',
                        value: project.notes?.length ?? 0,
                      ),
                      const SizedBox(width: 12),
                      _InfoBadge(
                        icon: Icons.history,
                        label: 'Revisions',
                        value: project.revisions?.length ?? 0,
                      ),
                      const SizedBox(width: 12),
                      _InfoBadge(
                        icon: Icons.check_circle_outline,
                        label: 'Todos',
                        value: project.todos?.length ?? 0,
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Text(
                    'Created: ${HomeScreen.formatDate(project.createdAt)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Updated: ${HomeScreen.formatDate(project.updatedAt)}',
                    style: theme.textTheme.bodySmall,
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
    return Chip(avatar: Icon(icon, size: 18), label: Text('$label: $value'));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_open, size: 64),
            const SizedBox(height: 16),
            Text(
              'No projects yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Start by creating your first project to manage notes, revisions, and todos.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create Project'),
            ),
          ],
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
