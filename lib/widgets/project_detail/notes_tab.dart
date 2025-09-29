import 'package:flutter/material.dart';

import '../../models/note.dart';
import '../../screens/note_detail_screen.dart';

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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.subject_outlined, size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                Text('No notes yet', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Add meeting notes, findings, or decisions.'),
                const SizedBox(height: 20),
                FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Add Note')),
              ],
            ),
          ),
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
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NoteDetailScreen(note: note),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Leading Icon
                  Icon(Icons.subject_outlined, size: 32, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 16),
                  // Title and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(note.title, style: Theme.of(context).textTheme.titleMedium),
                        if (note.description?.isNotEmpty == true)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              note.description!,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Trailing Icons
                  Wrap(
                    spacing: 0,
                    children: [
                      IconButton(
                        tooltip: 'Edit note',
                        onPressed: () => onEdit(note),
                        icon: const Icon(Icons.edit_outlined),
                        iconSize: 20,
                      ),
                      IconButton(
                        tooltip: 'Delete note',
                        onPressed: () => onDelete(note),
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFE07A5F)),
                        iconSize: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: notes.length,
    );
  }

}

