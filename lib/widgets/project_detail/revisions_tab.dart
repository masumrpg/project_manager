import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/revision.dart';
import '../../providers/project_detail_provider.dart';
import '../../screens/revision_detail_screen.dart';
import 'empty_state.dart';
import 'revision_card.dart';

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
    void openRevisionDetail(Revision revision) {
      final detailProvider = context.read<ProjectDetailProvider>();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              ChangeNotifierProvider<ProjectDetailProvider>.value(
            value: detailProvider,
            child: RevisionDetailScreen(revision: revision),
          ),
        ),
      );
    }

    if (revisions.isEmpty) {
      return EmptyState(
        icon: Icons.history,
        title: 'Revision history is empty',
        description: 'Track milestones and release notes to keep everyone aligned.',
        actionLabel: 'Add Revision',
        onAction: onAdd,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 320).floor().clamp(1, 4);

        if (crossAxisCount > 1) {
          // Use GridView for wider screens
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.25,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: revisions.length,
            itemBuilder: (context, index) {
              final revision = revisions[index];
              return RevisionCard(
                revision: revision,
                onTap: () => openRevisionDetail(revision),
                onEdit: () => onEdit(revision),
                onDelete: () => onDelete(revision),
              );
            },
          );
        } else {
          // Use ListView for narrower screens
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: revisions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final revision = revisions[index];
              return RevisionCard(
                revision: revision,
                onTap: () => openRevisionDetail(revision),
                onEdit: () => onEdit(revision),
                onDelete: () => onDelete(revision),
              );
            },
          );
        }
      },
    );
  }
}

