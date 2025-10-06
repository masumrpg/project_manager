import 'package:catatan_kaki/models/enums/sync_status.dart';
import 'package:catatan_kaki/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/user.dart';
import 'dashboard_metrics.dart';
import 'home_constants.dart';

class ModernHeader extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = user;

    final syncStatus = ref.watch(syncStatusProvider);
    final lastSyncTime = ref.watch(lastSyncTimestampProvider).value;
    final pendingCount = ref.watch(syncQueueCountProvider).value ?? 0;

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
                  HomeConstants.accentOrange.withAlpha(215),
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
                      backgroundColor: Colors.white.withAlpha(46),
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
                                : 'Selamat datang kembali',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white.withAlpha(194),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kirim proyek Anda berikutnya dengan percaya diri',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withAlpha(140),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(38),
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
                            value: 'settings',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.settings_outlined,
                                  color: HomeConstants.darkText,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Pengaturan',
                                  style: TextStyle(
                                    color: HomeConstants.darkText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
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
                                  'Keluar',
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
                          if (value == 'settings') context.push('/settings');
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
                      label: 'Proyek',
                      value: metrics.totalProjects,
                      accent: Colors.white,
                      icon: Icons.dashboard_outlined,
                    ),
                      _StatBlock(
                        label: 'Catatan',
                        value: metrics.totalNotes,
                        accent: Colors.white,
                        icon: Icons.sticky_note_2_outlined,
                      ),
                      _StatBlock(
                        label: 'Revisi',
                        value: metrics.totalRevisions,
                        accent: Colors.white,
                        icon: Icons.history_edu_outlined,
                      ),
                      _StatBlock(
                        label: 'Tugas',
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

                    columns = columns.clamp(2, blocks.length).toInt();

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
                const SizedBox(height: 24),
                _buildSyncStatus(context, syncStatus, lastSyncTime, pendingCount),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatus(BuildContext context, SyncStatus status, DateTime? lastSync, int pendingCount) {
    Widget icon;
    String text;

    switch (status) {
      case SyncStatus.syncing:
        icon = const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
        );
        text = 'Menyinkronkan...';
        break;
      case SyncStatus.success:
        icon = const Icon(Icons.check_circle, color: Colors.white70, size: 14);
        text = 'Sinkron ${_formatTimestamp(lastSync)}';
        break;
      case SyncStatus.error:
        icon = const Icon(Icons.error, color: Colors.orange, size: 14);
        text = 'Sinkronisasi gagal';
        break;
      case SyncStatus.idle:
      default:
        icon = const Icon(Icons.cloud_done, color: Colors.white70, size: 14);
        text = 'Sinkron ${_formatTimestamp(lastSync)}';
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
        if (pendingCount > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$pendingCount',
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ]
      ],
    );
  }

  String _formatTimestamp(DateTime? time) {
    if (time == null) return 'tidak pernah';

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else {
      return DateFormat.yMd().add_jm().format(time);
    }
  }

  String _buildGreeting(User user) {
    final displayName = (user.name != null && user.name!.trim().isNotEmpty)
        ? user.name!
        : user.email;
    final role = user.role;
    final roleSuffix = (role != null && role.trim().isNotEmpty) ? ' ($role)' : '';
    return 'Halo, $displayName$roleSuffix';
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
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(30)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(46),
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
                    color: Colors.white.withAlpha(191),
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