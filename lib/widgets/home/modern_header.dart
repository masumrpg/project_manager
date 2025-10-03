import 'package:flutter/material.dart';
import '../../models/user.dart';
import 'dashboard_metrics.dart';
import 'home_constants.dart';

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

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 48 : 24,
        16,
        isDesktop ? 48 : 24,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: isDesktop ? 36 : 28,
              horizontal: isDesktop ? 40 : 24,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  HomeConstants.accentOrange,
                  HomeConstants.accentOrange.withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: HomeConstants.shadowColor,
                  blurRadius: 26,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: isDesktop ? 28 : 24,
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      child: const Icon(
                        Icons.dashboard_customize_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser != null
                                ? _buildGreeting(currentUser)
                                : 'Welcome back',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.76),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ship your next project with confidence',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_horiz,
                          color: Colors.white70,
                        ),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'sign_out',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color: HomeConstants.accentOrange,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Sign out',
                                  style: TextStyle(
                                    color: HomeConstants.accentOrange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'sign_out') onSignOut();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                LayoutBuilder(
                  builder: (context, constraints) {
                    const double spacing = 24;
                    final blocks = <Widget>[
                    _StatBlock(
                      label: 'Projects',
                      value: metrics.totalProjects,
                      accent: Colors.white,
                      icon: Icons.dashboard_outlined,
                    ),
                      _StatBlock(
                        label: 'Notes',
                        value: metrics.totalNotes,
                        accent: Colors.white,
                        icon: Icons.sticky_note_2_outlined,
                      ),
                      _StatBlock(
                        label: 'Revisions',
                        value: metrics.totalRevisions,
                        accent: Colors.white,
                        icon: Icons.history_edu_outlined,
                      ),
                      _StatBlock(
                        label: 'Todos',
                        value: metrics.totalTodos,
                        accent: Colors.white,
                        icon: Icons.checklist_rounded,
                      ),
                    ];

                    final maxWidth = constraints.maxWidth;
                    int columns;
                    if (maxWidth >= 1120) {
                      columns = 4;
                    } else if (maxWidth >= 760) {
                      columns = 3;
                    } else if (maxWidth >= 340) {
                      columns = 2;
                    } else {
                      columns = 1;
                    }

                    columns = columns.clamp(1, blocks.length).toInt();

                    final double itemWidth = columns == 1
                        ? maxWidth
                        : (maxWidth - spacing * (columns - 1)) / columns;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: 16,
                      children: blocks
                          .map(
                            (block) => SizedBox(
                              width: columns == 1 ? maxWidth : itemWidth,
                              child: block,
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
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

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.label,
    required this.value,
    required this.accent,
    required this.icon,
  });

  final String label;
  final int value;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$value',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    letterSpacing: 0.3,
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
