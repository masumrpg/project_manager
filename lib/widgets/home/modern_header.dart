import 'package:flutter/material.dart';
import '../../models/enums/app_category.dart';
import '../../models/user.dart';
import 'dashboard_metrics.dart';
import 'home_constants.dart';
import 'modern_button.dart';
import 'metric_card.dart';

// Modern Header Component
class ModernHeader extends StatelessWidget {
  const ModernHeader({
    super.key,
    required this.metrics,
    required this.onCreateProject,
    required this.isDesktop,
    required this.isTablet,
    required this.onSignOut,
    required this.user,
  });

  final DashboardMetrics metrics;
  final VoidCallback onCreateProject;
  final bool isDesktop;
  final bool isTablet;
  final VoidCallback onSignOut;
  final User? user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = user;

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
                colors: [HomeConstants.accentOrange, HomeConstants.accentOrange.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: HomeConstants.shadowColor,
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
                    if (currentUser != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _buildGreeting(currentUser),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Hello, Guest',
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
                      color: HomeConstants.cardBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'sign_out',
                          child: Row(
                            children: [
                              Icon(
                                Icons.logout,
                                color: Colors.red.shade400,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Sign Out',
                                style: TextStyle(color: Colors.red.shade400),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'sign_out') {
                          onSignOut();
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
                  ModernButton(
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
                Expanded(child: MetricCard(
                  icon: Icons.pending_actions_outlined,
                  label: 'Active todos',
                  value: metrics.activeTodos.toString(),
                  color: HomeConstants.categoryColors[AppCategory.api]!,
                )),
                const SizedBox(width: 16),
                Expanded(child: MetricCard(
                  icon: Icons.task_alt_rounded,
                  label: 'Completed',
                  value: metrics.completedTodos.toString(),
                  color: HomeConstants.categoryColors[AppCategory.desktop]!,
                )),
                const SizedBox(width: 16),
                Expanded(child: MetricCard(
                  icon: Icons.note_alt_outlined,
                  label: 'Notes',
                  value: metrics.totalNotes.toString(),
                  color: HomeConstants.categoryColors[AppCategory.mobile]!,
                )),
              ],
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: MetricCard(
                      icon: Icons.pending_actions_outlined,
                      label: 'Active todos',
                      value: metrics.activeTodos.toString(),
                      color: HomeConstants.categoryColors[AppCategory.api]!,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: MetricCard(
                      icon: Icons.task_alt_rounded,
                      label: 'Completed',
                      value: metrics.completedTodos.toString(),
                      color: HomeConstants.categoryColors[AppCategory.desktop]!,
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        icon: Icons.note_alt_outlined,
                        label: 'Notes collected',
                        value: metrics.totalNotes.toString(),
                        color: HomeConstants.categoryColors[AppCategory.mobile]!,
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

  String _buildGreeting(User user) {
    final displayName = (user.name != null && user.name!.trim().isNotEmpty)
        ? user.name!
        : user.email;
    final role = user.role;
    final roleSuffix = (role != null && role.trim().isNotEmpty) ? ' ($role)' : '';
    return 'Hello, $displayName$roleSuffix';
  }
}
