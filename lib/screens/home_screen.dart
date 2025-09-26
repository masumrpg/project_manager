import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/enums/app_category.dart';
import '../models/enums/environment.dart';
import '../models/enums/todo_status.dart';
import '../models/project.dart';
import '../repositories/project_repository.dart';

class ProjectProvider extends ChangeNotifier {
  ProjectProvider(this._repository);

  final ProjectRepository _repository;
  final List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;

  List<Project> get projects => List.unmodifiable(_projects);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProjects({bool showLoading = true}) async {
    if (showLoading) {
      _setLoading(true);
    }

    try {
      final data = await _repository.getAllProjects();
      _projects
        ..clear()
        ..addAll(data);
      _error = null;
    } catch (error) {
      _error = error.toString();
    } finally {
      if (showLoading) {
        _setLoading(false);
      } else {
        notifyListeners();
      }
    }
  }

  Future<void> createProject(Project project) async {
    await _runGuarded(() async {
      await _repository.createProject(project);
      await loadProjects(showLoading: false);
    });
  }

  Future<void> updateProject(Project project) async {
    await _runGuarded(() async {
      await _repository.updateProject(project);
      await loadProjects(showLoading: false);
    });
  }

  Future<void> deleteProject(String id) async {
    await _runGuarded(() async {
      await _repository.deleteProject(id);
      _projects.removeWhere((project) => project.id == id);
    });
  }

  Future<void> updateTodoStatus(
    String projectId,
    String todoId,
    TodoStatus status,
  ) async {
    await _runGuarded(() async {
      await _repository.updateTodoStatus(projectId, todoId, status);
      await loadProjects(showLoading: false);
    });
  }

  Future<void> _runGuarded(Future<void> Function() runner) async {
    _setLoading(true);
    try {
      await runner();
      _error = null;
    } catch (error) {
      _error = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      if (!value) {
        notifyListeners();
      }
      return;
    }
    _isLoading = value;
    notifyListeners();
  }
}

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
      appBar: AppBar(title: const Text('My Projects')),
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
                if (project == null) {
                  final newProject = Project(
                    id: _uuid.v4(),
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    category: selectedCategory,
                    environment: selectedEnvironment,
                    createdAt: now,
                    updatedAt: now,
                  );
                  await provider.createProject(newProject);
                } else {
                  project
                    ..title = titleController.text.trim()
                    ..description = descriptionController.text.trim()
                    ..category = selectedCategory
                    ..environment = selectedEnvironment
                    ..updatedAt = now;
                  await provider.updateProject(project);
                }

                if (context.mounted) {
                  Navigator.of(dialogContext).pop();
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
      await provider.deleteProject(project.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Project "${project.title}" deleted.')),
        );
      }
    }
  }

  static String formatDate(DateTime date) => _dateFormat.format(date.toLocal());

  static Color _categoryColor(AppCategory category, BuildContext context) {
    return _categoryColors[category] ?? Theme.of(context).colorScheme.primary;
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.onEdit,
    required this.onDelete,
  });

  final Project project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final categoryColor = HomeScreen._categoryColor(project.category, context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onEdit,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              project.description.isEmpty
                                  ? 'No description provided.'
                                  : project.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            onEdit();
                          } else if (value == 'delete') {
                            onDelete();
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 12),
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
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Updated: ${HomeScreen.formatDate(project.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
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
