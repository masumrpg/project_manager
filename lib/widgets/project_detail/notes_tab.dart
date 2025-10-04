import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/note.dart';
import '../../providers/project_detail_provider.dart';
import 'note_card.dart';

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
    final detailProvider = context.read<ProjectDetailProvider>();
    Future<void> refreshProject() =>
        detailProvider.loadProject(showLoading: false);

    void openNoteDetail(Note note) {
      context.push('/note', extra: {
        'note': note,
        'provider': detailProvider,
      });
    }

    const scrollPhysics = AlwaysScrollableScrollPhysics(
      parent: BouncingScrollPhysics(),
    );

    return RefreshIndicator(
      onRefresh: refreshProject,
      child: notes.isEmpty
          ? CustomScrollView(
              physics: scrollPhysics,
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.subject_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada catatan',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tambahkan catatan rapat, temuan, atau keputusan.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: onAdd,
                            icon: const Icon(Icons.add),
                            label: const Text('Tambah Catatan'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount =
                    (constraints.maxWidth / 300).floor().clamp(1, 4);

                if (crossAxisCount > 1) {
                  // Use GridView for wider screens
                  return GridView.builder(
                    physics: scrollPhysics,
                    padding: const EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return NoteCard(
                        note: note,
                        onTap: () => openNoteDetail(note),
                        onEdit: () => onEdit(note),
                        onDelete: () => onDelete(note),
                      );
                    },
                  );
                } else {
                  // Use ListView for narrower screens
                  return ListView.separated(
                    physics: scrollPhysics,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: notes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return NoteCard(
                        note: note,
                        onTap: () => openNoteDetail(note),
                        onEdit: () => onEdit(note),
                        onDelete: () => onDelete(note),
                      );
                    },
                  );
                }
              },
            ),
    );
  }
}
