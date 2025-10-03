import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../widgets/shared/hover_expandable_fab.dart';
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
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;

    final scaffold = Scaffold(
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
            final metrics = DashboardMetrics.fromData(
              stats: provider.statistics,
              projects: projects,
            );

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
                          0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: HomeConstants.shadowColor
                                            .withValues(alpha: 0.25),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.grid_view_rounded,
                                    color: HomeConstants.accentOrange,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '${projects.length} projects',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: HomeConstants.darkText,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.2,
                                      ),
                                ),
                              ],
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
                        32,
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
      floatingActionButton: HoverExpandableFab(
        onPressed: () => _showProjectDialog(context),
        icon: Icons.add_rounded,
        label: 'New Project',
        backgroundColor: HomeConstants.accentOrange,
        foregroundColor: Colors.white,
      ),
    );

    if (!isAndroid) return scaffold;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: scaffold,
    );
  }

  Future<void> _showProjectDialog(
    BuildContext context, {
    Project? project,
  }) async {
    final auth = context.read<AuthProvider>();
    final currentUserId = auth.currentUser?.id ?? '';

    final result = await showModalBottomSheet<_ProjectDialogResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _ProjectFormBottomSheet(
          project: project,
          currentUserId: currentUserId,
        );
      },
    );

    if (context.mounted && result != null) {
      _showFeedback(context, success: result.success, message: result.message);
    }
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
      final provider = context.read<ProjectProvider>();
      final success = await provider.deleteProject(project.id);
      if (context.mounted) {
        _showFeedback(
          context,
          success: success,
          message: success
              ? 'Project deleted successfully!'
              : provider.error ?? 'Failed to delete project.',
        );
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

  void _showFeedback(
    BuildContext context, {
    required bool success,
    required String message,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success
              ? const Color(0xFF2E7D32) // A slightly darker green
              : const Color(0xFFC62828), // A slightly darker red
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
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

class _ProjectDialogResult {
  const _ProjectDialogResult({required this.success, required this.message});

  final bool success;
  final String message;
}

class _ProjectFormBottomSheet extends StatefulWidget {
  const _ProjectFormBottomSheet({
    required this.project,
    required this.currentUserId,
  });

  final Project? project;
  final String currentUserId;

  @override
  State<_ProjectFormBottomSheet> createState() =>
      _ProjectFormBottomSheetState();
}

class _ProjectFormBottomSheetState extends State<_ProjectFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late AppCategory _selectedCategory;
  late Environment _selectedEnvironment;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.project?.description ?? '',
    );
    _selectedCategory = widget.project?.category ?? AppCategory.mobile;
    _selectedEnvironment =
        widget.project?.environment ?? Environment.development;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<ProjectProvider>();
    final now = DateTime.now();

    final updatedProject =
        widget.project?.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          environment: _selectedEnvironment,
          updatedAt: now,
        ) ??
        Project(
          id: '',
          userId: widget.currentUserId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          environment: _selectedEnvironment,
          createdAt: now,
          updatedAt: now,
        );

    bool success;
    try {
      if (widget.project == null) {
        success = await provider.createProject(updatedProject);
      } else {
        success = await provider.updateProject(updatedProject);
      }
    } catch (_) {
      success = false;
    }

    final message = success
        ? (widget.project == null
              ? 'Project created successfully!'
              : 'Project updated successfully!')
        : provider.error ?? 'An unknown error occurred.';

    if (!mounted) return;

    Navigator.pop(
      context,
      _ProjectDialogResult(success: success, message: message),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: HomeConstants.lightText),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: HomeConstants.secondaryBeige),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: HomeConstants.accentOrange,
          width: 2,
        ),
      ),
      fillColor: HomeConstants.primaryBeige.withAlpha(76),
      filled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
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
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.project == null
                      ? 'Create New Project'
                      : 'Edit Project',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: HomeConstants.darkText,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: _fieldDecoration('Project Title'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a project title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: _fieldDecoration('Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AppCategory>(
                  value: _selectedCategory,
                  dropdownColor: HomeConstants.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  decoration: _fieldDecoration('Category'),
                  items: AppCategory.values
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Environment>(
                  value: _selectedEnvironment,
                  dropdownColor: HomeConstants.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  decoration: _fieldDecoration('Environment'),
                  items: Environment.values
                      .map(
                        (env) => DropdownMenuItem(
                          value: env,
                          child: Text(env.name.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedEnvironment = value);
                    }
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: FilledButton.styleFrom(
                      backgroundColor: HomeConstants.accentOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.project == null
                                ? 'Create Project'
                                : 'Update Project',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
