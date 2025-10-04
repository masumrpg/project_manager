import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/enums/revision_status.dart';
import '../models/revision.dart';
import '../providers/project_detail_provider.dart';

class RevisionDetailScreen extends StatefulWidget {
  const RevisionDetailScreen({
    required this.revision,
    super.key,
  });

  final Revision revision;

  @override
  State<RevisionDetailScreen> createState() => _RevisionDetailScreenState();
}

class _RevisionDetailScreenState extends State<RevisionDetailScreen> {
  late Revision _revision;
  late QuillController _changesQuillController;

  @override
  void initState() {
    super.initState();
    _revision = widget.revision;
    _changesQuillController = _buildReadOnlyController(_revision);
  }

  @override
  void dispose() {
    _changesQuillController.dispose();
    super.dispose();
  }

  QuillController _buildReadOnlyController(Revision revision) {
    Document document;
    final changes = revision.changes;
    if (changes.isNotEmpty) {
      final text = changes.join('\n');
      document = Document()..insert(0, text);
    } else {
      document = Document();
    }
    return QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
  }

  void _syncWithProvider(Revision updatedRevision) {
    if (_revision.updatedAt == updatedRevision.updatedAt) return;
    final newController = _buildReadOnlyController(updatedRevision);
    final oldController = _changesQuillController;
    setState(() {
      _revision = updatedRevision;
      _changesQuillController = newController;
    });
    oldController.dispose();
  }

  void _showFeedback({required bool success, required String message}) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success
              ? const Color(0xFF2E7D32)
              : const Color(0xFFC62828),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final providerRevision = context.select<ProjectDetailProvider, Revision?>(
      (provider) {
        final project = provider.project;
        if (project == null) return null;
        for (final revision in project.revisions) {
          if (revision.id == widget.revision.id) {
            return revision;
          }
        }
        return null;
      },
    );

    if (providerRevision != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _syncWithProvider(providerRevision);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF7),
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D3436)),
        ),
        title: Text(
          'Versi ${_revision.version}',
          style: const TextStyle(
            color: Color(0xFF2D3436),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final provider = context.read<ProjectDetailProvider>();
              final result = await context.push<bool>(
                '/revision/edit',
                extra: {
                  'revision': _revision,
                  'provider': provider,
                },
              );
              if (!mounted || result != true) return;
              _showFeedback(
                success: true,
                message: 'Revisi berhasil diperbarui',
              );
            },
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF2D3436)),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(_revision.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _revision.status.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Version and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Versi',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: const Color(0xFF636E72),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _revision.version,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: const Color(0xFF2D3436),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Dibuat',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: const Color(0xFF636E72),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm')
                          .format(_revision.createdAt.toLocal()),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF2D3436),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Description
            if (_revision.description.isNotEmpty) ...[
              Text(
                'Deskripsi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF2D3436),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E6D3).withAlpha(76),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8D5C4)),
                ),
                child: Text(
                  _revision.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF2D3436),
                        height: 1.5,
                      ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Changes
            Text(
              'Perubahan',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF2D3436),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 200),
              decoration: BoxDecoration(
                color: const Color(0xFFF5E6D3).withAlpha(76),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8D5C4)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AbsorbPointer(
                  child: QuillEditor.basic(
                    controller: _changesQuillController,
                    config: const QuillEditorConfig(
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dibuat',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: const Color(0xFF636E72),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm')
                            .format(_revision.createdAt.toLocal()),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF2D3436),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Terakhir Diperbarui',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: const Color(0xFF636E72),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm')
                          .format(_revision.updatedAt.toLocal()),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF2D3436),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(RevisionStatus status) {
    return switch (status) {
      RevisionStatus.pending => const Color(0xFF74B9FF),
      RevisionStatus.approved => const Color(0xFF00B894),
      RevisionStatus.rejected => const Color(0xFFD63031),
    };
  }
}
