import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/enums/app_category.dart';
import '../models/enums/environment.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import '../services/hive_boxes.dart';
import '../widgets/home/dashboard_metrics.dart';
import '../widgets/home/home_constants.dart';
import '../widgets/home/modern_header.dart';
import '../widgets/home/project_grid.dart';
import '../widgets/home/state_widgets.dart';
import 'project_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final _uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 768 && screenWidth <= 1024;

    return Scaffold(
      backgroundColor: HomeConstants.primaryBeige,
      body: SafeArea(
        child: Consumer<ProjectProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const CenteredLoader();
            }

            if (provider.error != null) {
              return ErrorState(
                error: provider.error!,
                onRetry: () => provider.loadProjects(),
              );
            }

            final projects = provider.projects;
            final metrics = DashboardMetrics.fromProjects(projects);

            return RefreshIndicator(
              onRefresh: () => provider.loadProjects(showLoading: false),
              color: HomeConstants.accentOrange,
              backgroundColor: HomeConstants.cardBackground,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: ModernHeader(
                      metrics: metrics,
                      onCreateProject: () => _showProjectDialog(context),
                      isDesktop: isDesktop,
                      isTablet: isTablet,
                      onClearDatabase: () => _showClearDatabaseDialog(context),
                    ),
                  ),
                  if (projects.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(),
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
                                color: HomeConstants.darkText,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.5,
                              ),
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
                          ? SliverToBoxAdapter(
                              child: DesktopProjectGrid(
                                projects: projects,
                                onProjectTap: (project) =>
                                    _openProjectDetail(context, project.id),
                                onEditProject: (project) => _showProjectDialog(
                                  context,
                                  project: project,
                                ),
                                onDeleteProject: (project) =>
                                    _confirmDelete(context, project),
                              ),
                            )
                          : SliverToBoxAdapter(
                              child: MobileProjectList(
                                projects: projects,
                                onProjectTap: (project) =>
                                    _openProjectDetail(context, project.id),
                                onEditProject: (project) => _showProjectDialog(
                                  context,
                                  project: project,
                                ),
                                onDeleteProject: (project) =>
                                    _confirmDelete(context, project),
                              ),
                            ),
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
            backgroundColor: HomeConstants.accentOrange,
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
      backgroundColor: HomeConstants.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        project == null ? 'Create Project' : 'Edit Project',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: HomeConstants.darkText,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: HomeConstants.lightText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Project Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: HomeConstants.secondaryBeige,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: HomeConstants.accentOrange,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: HomeConstants.primaryBeige,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a project title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: HomeConstants.secondaryBeige,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: HomeConstants.accentOrange,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: HomeConstants.primaryBeige,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<AppCategory>(
                    initialValue: selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: HomeConstants.secondaryBeige,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: HomeConstants.accentOrange,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: HomeConstants.primaryBeige,
                    ),
                    items: AppCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              HomeConstants.categoryIcons[category] ??
                                  Icons.folder,
                              color: _categoryColor(category),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(category.name.toUpperCase()),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedCategory = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Environment>(
                    initialValue: selectedEnvironment,
                    decoration: InputDecoration(
                      labelText: 'Environment',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: HomeConstants.secondaryBeige,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: HomeConstants.accentOrange,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: HomeConstants.primaryBeige,
                    ),
                    items: Environment.values.map((env) {
                      return DropdownMenuItem(
                        value: env,
                        child: Text(env.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedEnvironment = value);
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final newProject = Project(
                            id: project?.id ?? _uuid.v4(),
                            title: titleController.text.trim(),
                            description: descriptionController.text.trim(),
                            category: selectedCategory,
                            environment: selectedEnvironment,
                            createdAt: project?.createdAt ?? DateTime.now(),
                            updatedAt: DateTime.now(),
                          );

                          if (project == null) {
                            await provider.createProject(newProject);
                          } else {
                            await provider.updateProject(newProject);
                          }

                          if (context.mounted) {
                            Navigator.pop(context);
                            _showOperationResult(
                              context,
                              project == null
                                  ? 'Project created successfully!'
                                  : 'Project updated successfully!',
                            );
                          }
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: HomeConstants.accentOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        project == null ? 'Create Project' : 'Update Project',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Project project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HomeConstants.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Project',
          style: TextStyle(
            color: HomeConstants.darkText,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${project.title}"? This action cannot be undone.',
          style: TextStyle(color: HomeConstants.lightText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: HomeConstants.lightText),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<ProjectProvider>().deleteProject(project.id);
      if (context.mounted) {
        _showOperationResult(context, 'Project deleted successfully!');
      }
    }
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }

  Color _categoryColor(AppCategory category) {
    return HomeConstants.categoryColors[category] ?? HomeConstants.accentOrange;
  }

  void _openProjectDetail(BuildContext context, String projectId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailScreen(projectId: projectId),
      ),
    );
  }

  void _showOperationResult(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: HomeConstants.accentOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _showClearDatabaseDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HomeConstants.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear Database',
          style: TextStyle(
            color: HomeConstants.darkText,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to clear all data? This will delete all projects, notes, todos, and revisions. This action cannot be undone.',
          style: TextStyle(color: HomeConstants.lightText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: HomeConstants.lightText),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await HiveBoxes.clearAllData();
      if (context.mounted) {
        await context.read<ProjectProvider>().loadProjects();
        if (context.mounted) {
          _showOperationResult(context, 'Database cleared successfully!');
        }
      }
    }
  }
}
