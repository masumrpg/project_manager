import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import '../models/note.dart';
import '../models/enums/note_status.dart';

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({
    required this.note,
    super.key,
  });

  final Note note;

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late QuillController _quillController;

  @override
  void initState() {
    super.initState();

    // Initialize Quill controller with note content
    Document document;
    if (widget.note.content.isNotEmpty) {
      try {
        // Try to parse as JSON (Quill format)
        final json = jsonDecode(widget.note.content);
        document = Document.fromJson(json);
      } catch (e) {
        // If parsing fails, treat as plain text
        document = Document()..insert(0, widget.note.content);
      }
    } else {
      document = Document();
    }

    _quillController = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true, // Make it read-only for detail view
    );
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final description = widget.note.description ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF7),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D3436)),
        ),
        title: const Text(
          'Note Detail',
          style: TextStyle(
            color: Color(0xFF2D3436),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(widget.note.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.note.status.label,
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
            Text(
              'Title',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF636E72),
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.note.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF2D3436),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 32),
            if (description.isNotEmpty) ...[
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
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E6D3).withAlpha(76),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8D5C4)),
                ),
                padding: const EdgeInsets.all(16),
                child: Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF2D3436),
                        height: 1.5,
                      ),
                ),
              ),
              const SizedBox(height: 32),
            ],
            Text(
              'Content',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF2D3436),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 150),
              decoration: BoxDecoration(
                color: const Color(0xFFF5E6D3).withAlpha(76),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8D5C4)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AbsorbPointer(
                  child: QuillEditor.basic(
                    controller: _quillController,
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
                            .format(widget.note.createdAt.toLocal()),
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
                            .format(widget.note.updatedAt.toLocal()),
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

  Color _getStatusColor(NoteStatus status) {
    return switch (status) {
      NoteStatus.active => const Color(0xFF00B894),
      NoteStatus.archived => const Color(0xFF636E72),
      NoteStatus.draft => const Color(0xFFE17055),
    };
  }
}