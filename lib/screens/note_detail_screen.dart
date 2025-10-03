import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/enums/note_status.dart';
import '../models/note.dart';
import '../providers/project_detail_provider.dart';
import 'note_edit_screen.dart';

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
  late Note _note;
  late QuillController _quillController;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _quillController = _buildReadOnlyController(_note);
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  QuillController _buildReadOnlyController(Note note) {
    // Initialize Quill controller with note content
    Document document;
    if (note.content.isNotEmpty) {
      try {
        // Try to parse as JSON (Quill format)
        final json = jsonDecode(note.content);
        document = Document.fromJson(json);
      } catch (e) {
        // If parsing fails, treat as plain text
        document = Document()..insert(0, note.content);
      }
    } else {
      document = Document();
    }

    return QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true, // Make it read-only for detail view
    );
  }

  void _syncWithProvider(Note updatedNote) {
    if (_note.updatedAt == updatedNote.updatedAt) return;
    final newController = _buildReadOnlyController(updatedNote);
    final oldController = _quillController;
    setState(() {
      _note = updatedNote;
      _quillController = newController;
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
    final providerNote = context.select<ProjectDetailProvider, Note?>(
      (provider) {
        final project = provider.project;
        if (project == null) return null;
        for (final note in project.notes) {
          if (note.id == widget.note.id) {
            return note;
          }
        }
        return null;
      },
    );

    if (providerNote != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _syncWithProvider(providerNote);
      });
    }

    final description = _note.description ?? '';

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
          IconButton(
            onPressed: () async {
              final detailProvider = context.read<ProjectDetailProvider>();
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) =>
                      ChangeNotifierProvider<ProjectDetailProvider>.value(
                    value: detailProvider,
                    child: NoteEditScreen(note: _note),
                  ),
                ),
              );
              if (!mounted || result != true) return;
              _showFeedback(success: true, message: 'Note updated successfully');
            },
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF2D3436)),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(_note.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _note.status.label,
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
              _note.title,
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
                            .format(_note.createdAt.toLocal()),
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
                            .format(_note.updatedAt.toLocal()),
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
