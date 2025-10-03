import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_manager/models/revision.dart';
import 'package:project_manager/models/enums/revision_status.dart';

class RevisionCard extends StatelessWidget {
  const RevisionCard({
    required this.revision,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Revision revision;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0.5,
      color: const Color(0xFFFFFBF7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: revision.status.color.withAlpha(25),
                    foregroundColor: revision.status.color,
                    child: const Icon(Icons.history_edu_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Version ${revision.version}',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat.yMMMd().format(revision.createdAt),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'More actions',
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                    icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (revision.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    revision.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              const Divider(height: 16),
              Row(
                children: [
                  Icon(Icons.circle, size: 12, color: revision.status.color),
                  const SizedBox(width: 6),
                  Text(revision.status.label, style: theme.textTheme.bodySmall),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
