import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/enums/app_category.dart';
import '../models/enums/environment.dart';
import '../models/project.dart';
import '../providers/auth_provider.dart';
import '../providers/project_provider.dart';
import 'auth_screen.dart';
import '../widgets/home/dashboard_metrics.dart';
import '../widgets/home/home_constants.dart';
import '../widgets/home/modern_header.dart';
import '../widgets/home/project_grid.dart';
import '../widgets/home/state_widgets.dart';
import 'project_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 768 && screenWidth <= 1024;
    final auth = context.watch<AuthProvider>();

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
                      onSignOut: () => _confirmSignOut(context),
                      user: auth.currentUser,
                    ),
                  ),
                  if (projects.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: isDesktop ? 120 : 110,
                        ),
                        child: const EmptyState(),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProjectDialog(context),
        backgroundColor: HomeConstants.accentOrange,
        foregroundColor: Colors.white,
        elevation: 8,
        label: const Text('New Project', style: TextStyle(fontWeight: FontWeight.w600)),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  Future<void> _showProjectDialog(
    BuildContext context, {
    Project? project,
  }) async {
    final provider = context.read<ProjectProvider>();
    final auth = context.read<AuthProvider>();
    final currentUserId = auth.currentUser?.id ?? '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        final titleController = TextEditingController(
          text: project?.title ?? '',
        );
        final descriptionController = TextEditingController(
          text: project?.description ?? '',
        );
        var selectedCategory = project?.category ?? AppCategory.mobile;
        var selectedEnvironment =
            project?.environment ?? Environment.development;
        bool isLoading = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: HomeConstants.cardBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project == null ? 'Create New Project' : 'Edit Project',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: HomeConstants.darkText,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Project Title',
                          labelStyle: const TextStyle(
                            color: HomeConstants.lightText,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: HomeConstants.secondaryBeige,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: HomeConstants.accentOrange,
                              width: 2,
                            ),
                          ),
                          fillColor: HomeConstants.primaryBeige.withValues(
                            alpha: 0.3,
                          ),
                          filled: true,
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
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: const TextStyle(
                            color: HomeConstants.lightText,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: HomeConstants.secondaryBeige,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: HomeConstants.accentOrange,
                              width: 2,
                            ),
                          ),
                          fillColor: HomeConstants.primaryBeige.withValues(
                            alpha: 0.3,
                          ),
                          filled: true,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<AppCategory>(
                        initialValue: selectedCategory,
                        dropdownColor: HomeConstants.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: const TextStyle(
                            color: HomeConstants.lightText,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: HomeConstants.secondaryBeige,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: HomeConstants.accentOrange,
                              width: 2,
                            ),
                          ),
                          fillColor: HomeConstants.primaryBeige.withValues(
                            alpha: 0.3,
                          ),
                          filled: true,
                        ),
                        items: AppCategory.values.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat.label),
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
                        dropdownColor: HomeConstants.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        decoration: InputDecoration(
                          labelText: 'Environment',
                          labelStyle: const TextStyle(
                            color: HomeConstants.lightText,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: HomeConstants.secondaryBeige,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: HomeConstants.accentOrange,
                              width: 2,
                            ),
                          ),
                          fillColor: HomeConstants.primaryBeige.withValues(
                            alpha: 0.3,
                          ),
                          filled: true,
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
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (formKey.currentState!.validate()) {
                                    setState(() => isLoading = true);

                                    final now = DateTime.now();
                                    final updatedProject =
                                        project?.copyWith(
                                          title: titleController.text.trim(),
                                          description: descriptionController
                                              .text
                                              .trim(),
                                          category: selectedCategory,
                                          environment: selectedEnvironment,
                                          updatedAt: now,
                                        ) ??
                                        Project(
                                          id: '',
                                          userId: currentUserId,
                                          title: titleController.text.trim(),
                                          description: descriptionController
                                              .text
                                              .trim(),
                                          category: selectedCategory,
                                          environment: selectedEnvironment,
                                          createdAt: now,
                                          updatedAt: now,
                                        );

                                    bool success = false;
                                    if (project == null) {
                                      success = await provider.createProject(
                                        updatedProject,
                                      );
                                    } else {
                                      success = await provider.updateProject(
                                        updatedProject,
                                      );
                                    }

                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      if (success) {
                                        _showOperationResult(
                                          context,
                                          project == null
                                              ? 'Project created successfully!'
                                              : 'Project updated successfully!',
                                        );
                                      }
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
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  project == null
                                      ? 'Create Project'
                                      : 'Update Project',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Project project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: HomeConstants.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
                  onPressed: isLoading
                      ? null
                      : () => Navigator.pop(context, false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: HomeConstants.lightText),
                  ),
                ),
                FilledButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() => isLoading = true);
                          Navigator.pop(context, true);
                        },
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Delete',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
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

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: HomeConstants.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Sign Out',
                style: TextStyle(
                  color: HomeConstants.darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Text(
                'Are you sure you want to sign out from this device?',
                style: TextStyle(color: HomeConstants.lightText),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.pop(context, false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: HomeConstants.lightText),
                  ),
                ),
                FilledButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() => isLoading = true);
                          Navigator.pop(context, true);
                        },
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Sign Out',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true && context.mounted) {
      final auth = context.read<AuthProvider>();
      final projects = context.read<ProjectProvider>();
      await auth.signOut();
      projects.clear();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    }
  }
}
