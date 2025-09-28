import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/revision.dart';
import '../../screens/revision_detail_screen.dart';
import 'empty_state.dart';

class RevisionsTab extends StatelessWidget {
  const RevisionsTab({
    required this.revisions,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
    super.key,
  });

  final List<Revision> revisions;
  final ValueChanged<Revision> onEdit;
  final ValueChanged<Revision> onDelete;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    if (revisions.isEmpty) {
      return EmptyState(
        icon: Icons.history,
        title: 'Revision history is empty',
        description: 'Track milestones and release notes to keep everyone aligned.',
        actionLabel: 'Add Revision',
        onAction: onAdd,
      );
    }

    return ListView.separated(
      itemBuilder: (context, index) {
        final revision = revisions[index];
        return Card(
          elevation: 0,
          color: const Color(0xFFFFFBF7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.history_toggle_off,
                  size: 28,
                  color: _getStatusColor(revision.status),
                ),
              ),
            ),
            title: Text('Version ${revision.version}', style: Theme.of(context).textTheme.titleMedium),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (revision.description.isNotEmpty) ...[
                    Text(revision.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                  ],
                  if (revision.changes.isNotEmpty) ...[
                    Text(
                      _getPlainTextContent(revision.changes),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(revision.createdAt.toLocal()),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).hintColor),
                  ),
                ],
              ),
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  tooltip: 'Edit revision',
                  onPressed: () => onEdit(revision),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Delete revision',
                  onPressed: () => onDelete(revision),
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFE07A5F)),
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RevisionDetailScreen(revision: revision),
                ),
              );
            },
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: revisions.length,
    );
  }

  String _getPlainTextContent(String content) {
    if (content.isEmpty) return '';
    
    try {
      // Try to parse as JSON (Quill document)
      final jsonData = jsonDecode(content);
      if (jsonData is Map && jsonData.containsKey('ops')) {
        final ops = jsonData['ops'] as List;
        final buffer = StringBuffer();
        for (final op in ops) {
          if (op is Map && op.containsKey('insert')) {
            final insert = op['insert'];
            if (insert is String) {
              buffer.write(insert);
            }
          }
        }
        return buffer.toString().trim();
      }
    } catch (e) {
      // If parsing fails, return as plain text
    }
    
    return content;
  }

  Color _getStatusColor(status) {
    switch (status.toString()) {
      case 'RevisionStatus.pending':
        return const Color(0xFF74B9FF);
      case 'RevisionStatus.inProgress':
        return const Color(0xFFE17055);
      case 'RevisionStatus.completed':
        return const Color(0xFF00B894);
      case 'RevisionStatus.cancelled':
        return const Color(0xFFD63031);
      case 'RevisionStatus.onHold':
        return const Color(0xFFFDCB6E);
      default:
        return const Color(0xFF636E72);
    }
  }
}

