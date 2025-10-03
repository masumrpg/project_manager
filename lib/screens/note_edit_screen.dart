import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';

import '../models/enums/note_status.dart';
import '../models/note.dart';
import '../providers/project_detail_provider.dart';

class NoteEditScreen extends StatefulWidget {
  final Note note;

  const NoteEditScreen({super.key, required this.note});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final QuillController _quillController;
  late NoteStatus _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _descriptionController = TextEditingController(text: widget.note.description ?? '');

    Document document;
    final noteContent = widget.note.content;
    if (noteContent.isNotEmpty) {
      try {
        final json = jsonDecode(noteContent);
        document = Document.fromJson(json);
      } catch (e) {
        document = Document()..insert(0, noteContent);
      }
    } else {
      document = Document();
    }
    _quillController = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );

    _selectedStatus = widget.note.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

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

    final provider = context.read<ProjectDetailProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final contentJson = jsonEncode(_quillController.document.toDelta().toJson());

    final updatedNote = widget.note
      ..title = _titleController.text.trim()
      ..description = _descriptionController.text.trim()
      ..content = contentJson
      ..status = _selectedStatus
      ..updatedAt = DateTime.now();

    final didSucceed = await provider.updateNote(updatedNote);

    if (mounted) {
      if (didSucceed) {
        await provider.loadProject(showLoading: false);
        navigator.pop(true);
      } else {
        setState(() {
          _isLoading = false;
        });
        messenger.showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to save note'),
            backgroundColor: const Color(0xFFE07A5F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: AppBar(
        title: const Text(
          'Edit Note',
          style: TextStyle(
            color: Color(0xFF2D3436),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFFFFBF7),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D3436)),
        ),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 3)),
                )
              : IconButton(
                  onPressed: _saveNote,
                  icon: const Icon(Icons.save_outlined, color: Color(0xFF2D3436)),
                  tooltip: 'Save Note',
                ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
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
              value: _selectedStatus,
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
          ],
        ),
      ),
    );
  }
}
