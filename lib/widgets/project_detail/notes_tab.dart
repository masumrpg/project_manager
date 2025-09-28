import 'package:flutter/material.dart';

import '../../models/enums/content_type.dart';
import '../../models/note.dart';

class NotesTab extends StatelessWidget {
  const NotesTab({
    required this.notes,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
    super.key,
  });

  final List<Note> notes;
  final ValueChanged<Note> onEdit;
  final ValueChanged<Note> onDelete;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.subject_outlined, size: 64),
            const SizedBox(height: 16),
            Text('No notes yet', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Add meeting notes, findings, or decisions.'),
            const SizedBox(height: 20),
            FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Add Note')),
          ],
        ),
      );
    }

    return ListView.separated(
      itemBuilder: (context, index) {
        final note = notes[index];
        return Card(
          elevation: 0,
          color: const Color(0xFFFFFBF7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Icon(_iconForContent(note.contentType), size: 28),
            title: Text(note.title, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(note.content, maxLines: 3, overflow: TextOverflow.ellipsis),
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  tooltip: 'Edit note',
                  onPressed: () => onEdit(note),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Delete note',
                  onPressed: () => onDelete(note),
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFE07A5F)),
                ),
              ],
            ),
            onTap: () => onEdit(note),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: notes.length,
    );
  }

  IconData _iconForContent(ContentType type) {
    switch (type) {
      case ContentType.text:
        return Icons.subject_outlined;
      case ContentType.markdown:
        return Icons.article_outlined;
      case ContentType.code:
        return Icons.code;
      case ContentType.image:
        return Icons.image_outlined;
      case ContentType.link:
        return Icons.link_outlined;
      case ContentType.document:
        return Icons.description_outlined;
    }
  }
}

