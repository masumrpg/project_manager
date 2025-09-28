import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';

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
            leading: SizedBox(
              width: 28,
              child: Icon(Icons.subject_outlined, size: 28),
            ),
            title: Text(note.title, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: SizedBox(
                  height: 60,
                  child: QuillEditor.basic(
                    controller: QuillController(
                      document: _parseNoteContent(note.content),
                      selection: const TextSelection.collapsed(offset: 0),
                      readOnly: true,
                    ),
                    config: const QuillEditorConfig(
                      padding: EdgeInsets.zero,
                      scrollable: false,
                    ),
                  ),
                ),
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
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NoteDetailScreen(note: note),
                ),
              );
            },
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: notes.length,
    );
  }

  Document _parseNoteContent(String content) {
    if (content.isEmpty) {
      return Document();
    }
    
    try {
      // Try to parse as JSON (Quill format)
      final json = jsonDecode(content);
      return Document.fromJson(json);
    } catch (e) {
      // If parsing fails, treat as plain text
      return Document()..insert(0, content);
    }
  }
}

