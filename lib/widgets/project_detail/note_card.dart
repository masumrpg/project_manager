import 'package:flutter/material.dart';
import 'package:project_manager/models/note.dart';
import 'package:project_manager/models/enums/note_status.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    required this.note,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Note note;
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
                  Icon(
                    Icons.sticky_note_2_outlined,
                    color: note.status.color,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      note.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
              const SizedBox(height: 8),
              if (note.description?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    note.description!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              const Divider(height: 16),
              Row(
                children: [
                  Icon(Icons.circle, size: 12, color: note.status.color),
                  const SizedBox(width: 6),
                  Text(note.status.label, style: theme.textTheme.bodySmall),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
