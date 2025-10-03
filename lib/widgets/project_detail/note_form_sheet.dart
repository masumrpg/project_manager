import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

import '../../../models/enums/note_status.dart';
import '../../../models/note.dart';

class NoteFormSheet extends StatefulWidget {
  const NoteFormSheet({
    required this.uuid,
    required this.onCreate,
    required this.onUpdate,
    required this.projectId,
    this.note,
    super.key,
  });

  final Uuid uuid;
  final Note? note;
  final Future<bool> Function(Note) onCreate;
  final Future<bool> Function(Note) onUpdate;
  final String projectId;

  @override
  State<NoteFormSheet> createState() => _NoteFormSheetState();
}

class _NoteFormSheetState extends State<NoteFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final QuillController _quillController;
  late NoteStatus _selectedStatus;
  bool _isLoading = false;
  double _borderRadius = 24.0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.note?.description ?? '');

    // Initialize Quill controller with existing content or empty document
    Document document;
    final noteContent = widget.note?.content;
    if (noteContent != null && noteContent.isNotEmpty) {
      try {
        // Try to parse as JSON (Quill format)
        final json = jsonDecode(noteContent);
        document = Document.fromJson(json);
      } catch (e) {
        // If parsing fails, treat as plain text
        document = Document()..insert(0, noteContent);
      }
    } else {
      document = Document();
    }
    _quillController = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );

    _selectedStatus = widget.note?.status ?? NoteStatus.active;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        final newRadius = notification.extent < 1.0 ? 24.0 : 0.0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && newRadius != _borderRadius) {
            setState(() {
              _borderRadius = newRadius;
            });
          }
        });
        return true;
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        expand: true,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF7),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_borderRadius),
                topRight: Radius.circular(_borderRadius),
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF636E72).withAlpha(76),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.only(
                        left: 24,
                        right: 24,
                        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
                      ),
                      children: [
                        Text(
                          widget.note == null ? 'Add Note' : 'Edit Note',
                          style: const TextStyle(
                            color: Color(0xFF2D3436),
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            label: RichText(
                              text: const TextSpan(
                                text: 'Title',
                                style: TextStyle(color: Color(0xFF636E72)),
                                children: [
                                  TextSpan(
                                    text: ' *',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE8D5C4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFE07A5F),
                                width: 2,
                              ),
                            ),
                            fillColor: const Color(0xFFF5E6D3).withAlpha(76),
                            filled: true,
                            labelStyle: const TextStyle(color: Color(0xFF636E72)),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Title is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE8D5C4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 2),
                            ),
                            fillColor: const Color(0xFFF5E6D3).withAlpha(76),
                            filled: true,
                            labelStyle: const TextStyle(color: Color(0xFF636E72)),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                text: 'Content',
                                style: TextStyle(
                                  color: Color(0xFF636E72),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' *',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5E6D3).withAlpha(76),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE8D5C4)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Column(
                                  children: [
                                    QuillSimpleToolbar(
                                      controller: _quillController,
                                      config: const QuillSimpleToolbarConfig(
                                        toolbarSize: 40,
                                        multiRowsDisplay: false,
                                      ),
                                    ),
                                    Container(
                                      constraints: const BoxConstraints(
                                        minHeight: 120,
                                        maxHeight: 200,
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: QuillEditor.basic(
                                        controller: _quillController,
                                        config: const QuillEditorConfig(
                                          placeholder: 'Write your note content here...',
                                          padding: EdgeInsets.zero,
                                          expands: false,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<NoteStatus>(
                          initialValue: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE8D5C4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 2),
                            ),
                            fillColor: const Color(0xFFF5E6D3).withAlpha(76),
                            filled: true,
                            labelStyle: const TextStyle(color: Color(0xFF636E72)),
                          ),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          items: NoteStatus.values
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status.label),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) setState(() => _selectedStatus = value);
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 12),
                            FilledButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      final formState = _formKey.currentState;
                                      if (formState == null || !formState.validate()) return;

                                      // Validate that content is not empty
                                      final plainText = _quillController.document.toPlainText().trim();
                                      if (plainText.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('Content is required'),
                                            backgroundColor: const Color(0xFFE07A5F),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                                          ),
                                        );
                                        return;
                                      }

                                      setState(() {
                                        _isLoading = true;
                                      });

                                      final navigator = Navigator.of(context);
                                      final now = DateTime.now();

                                      // Convert Quill document to JSON string
                                      final contentJson = jsonEncode(_quillController.document.toDelta().toJson());

                                      final didSucceed = widget.note == null
                                          ? await widget.onCreate(
                                              Note(
                                                id: widget.uuid.v4(),
                                                projectId: widget.projectId,
                                                title: _titleController.text.trim(),
                                                description: _descriptionController.text.trim(),
                                                content: contentJson,
                                                status: _selectedStatus,
                                                createdAt: now,
                                                updatedAt: now,
                                              ),
                                            )
                                          : widget.note != null
                                              ? await widget.onUpdate(
                                                  widget.note!
                                                    ..title = _titleController.text.trim()
                                                    ..description = _descriptionController.text.trim()
                                                    ..content = contentJson
                                                    ..status = _selectedStatus
                                                    ..updatedAt = now,
                                                )
                                              : false;

                                      if (!mounted) return;
                                      navigator.pop(didSucceed);
                                    },
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(widget.note == null ? 'Create' : 'Save'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
