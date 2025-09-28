import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../models/enums/content_type.dart';
import '../../../models/enums/note_status.dart';
import '../../../models/note.dart';

class NoteFormSheet extends StatefulWidget {
  const NoteFormSheet({
    required this.uuid,
    required this.onCreate,
    required this.onUpdate,
    this.note,
    super.key,
  });

  final Uuid uuid;
  final Note? note;
  final Future<bool> Function(Note) onCreate;
  final Future<bool> Function(Note) onUpdate;

  @override
  State<NoteFormSheet> createState() => _NoteFormSheetState();
}

class _NoteFormSheetState extends State<NoteFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late ContentType _selectedType;
  late NoteStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedType = widget.note?.contentType ?? ContentType.text;
    _selectedStatus = widget.note?.status ?? NoteStatus.active;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBF7),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF636E72).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
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
                    labelText: 'Title',
                    border: OutlineInputBorder(
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
                    fillColor: const Color(0xFFF5E6D3).withValues(alpha: 0.3),
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
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(
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
                    fillColor: const Color(0xFFF5E6D3).withValues(alpha: 0.3),
                    filled: true,
                    labelStyle: const TextStyle(color: Color(0xFF636E72)),
                  ),
                  minLines: 4,
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Content is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonFormField<NoteStatus>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonFormField<ContentType>(
                    initialValue: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Content Type',
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    items: ContentType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedType = value);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        final navigator = Navigator.of(context);
                        final now = DateTime.now();
                        final didSucceed = widget.note == null
                            ? await widget.onCreate(
                                Note(
                                  id: widget.uuid.v4(),
                                  title: _titleController.text.trim(),
                                  content: _contentController.text.trim(),
                                  contentType: _selectedType,
                                  status: _selectedStatus,
                                  createdAt: now,
                                  updatedAt: now,
                                ),
                              )
                            : await widget.onUpdate(
                                widget.note!
                                  ..title = _titleController.text.trim()
                                  ..content = _contentController.text.trim()
                                  ..contentType = _selectedType
                                  ..status = _selectedStatus
                                  ..updatedAt = now,
                              );

                        if (!mounted) return;
                        navigator.pop(didSucceed);
                      },
                      child: Text(widget.note == null ? 'Create' : 'Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
