import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';

import '../models/enums/revision_status.dart';
import '../models/revision.dart';

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
  late final QuillController _changesQuillController;

  @override
  void initState() {
    super.initState();

    // Initialize Quill controller with existing changes content
    Document document;
    final changes = widget.revision.changes;
    if (changes.isNotEmpty) {
      final text = changes.join('\n');
      document = Document()..insert(0, text);
    } else {
      document = Document();
    }
    _changesQuillController = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
  }

  @override
  void dispose() {
    _changesQuillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF7),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D3436)),
        ),
        title: Text(
          'Version ${widget.revision.version}',
          style: const TextStyle(
            color: Color(0xFF2D3436),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(widget.revision.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.revision.status.label,
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
                        'Version',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: const Color(0xFF636E72),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.revision.version,
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
                      'Created',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: const Color(0xFF636E72),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm')
                          .format(widget.revision.createdAt.toLocal()),
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
            if (widget.revision.description.isNotEmpty) ...[
              Text(
                'Description',
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
                  widget.revision.description,
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
              'Changes',
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
                        'Created',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: const Color(0xFF636E72),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm')
                            .format(widget.revision.createdAt.toLocal()),
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
                        'Last Updated',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: const Color(0xFF636E72),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm')
                            .format(widget.revision.updatedAt.toLocal()),
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