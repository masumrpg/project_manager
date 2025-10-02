import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../models/enums/todo_priority.dart';
import '../../../models/enums/todo_status.dart';
import '../../../models/todo.dart';

class TodoFormSheet extends StatefulWidget {
  const TodoFormSheet({
    required this.uuid,
    required this.onCreate,
    required this.onUpdate,
    required this.projectId,
    this.todo,
    super.key,
  });

  final Uuid uuid;
  final Todo? todo;
  final Future<bool> Function(Todo) onCreate;
  final Future<bool> Function(Todo) onUpdate;
  final String projectId;

  @override
  State<TodoFormSheet> createState() => _TodoFormSheetState();
}

class _TodoFormSheetState extends State<TodoFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final QuillController _contentQuillController;
  DateTime? _dueDate;
  late TodoPriority _selectedPriority;
  late TodoStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.todo?.description ?? '',
    );

    // Initialize Quill controller for the new 'content' field
    Document document;
    final todoContent = widget.todo?.content;
    if (todoContent?.isNotEmpty == true) {
      try {
        // Try to parse as JSON (Quill document)
        final jsonData = jsonDecode(todoContent!);
        document = Document.fromJson(jsonData);
      } catch (e) {
        // If parsing fails, treat as plain text
        document = Document()..insert(0, todoContent!);
      }
    } else {
      document = Document();
    }
    _contentQuillController = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );

    _dueDate = widget.todo?.dueDate;
    _selectedPriority = widget.todo?.priority ?? TodoPriority.medium;
    _selectedStatus = widget.todo?.status ?? TodoStatus.pending;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentQuillController.dispose();
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
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF636E72).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  widget.todo == null ? 'Add Todo' : 'Edit Todo',
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
                      borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 2),
                    ),
                    fillColor: const Color(0xFFF5E6D3).withValues(alpha: 0.3),
                    filled: true,
                    labelStyle: const TextStyle(color: Color(0xFF636E72)),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: 12),
                // Description with TextFormField
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
                      borderSide: const BorderSide(
                        color: Color(0xFFE07A5F),
                        width: 2,
                      ),
                    ),
                    fillColor: const Color(0xFFF5E6D3).withValues(alpha: 0.3),
                    filled: true,
                    labelStyle: const TextStyle(color: Color(0xFF636E72)),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                // Content with Quill Editor
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Content',
                      style: TextStyle(
                        color: const Color(0xFF636E72),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5E6D3).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8D5C4)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Column(
                          children: [
                            QuillSimpleToolbar(
                              controller: _contentQuillController,
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
                                controller: _contentQuillController,
                                config: const QuillEditorConfig(
                                  placeholder: 'Add rich content here...',
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
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TodoPriority>(
                        initialValue: _selectedPriority,
                        decoration: InputDecoration(
                          labelText: 'Priority',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFE8D5C4)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 2),
                          ),
                          fillColor: const Color(0xFFF5E6D3).withValues(alpha: 0.3),
                          filled: true,
                          labelStyle: const TextStyle(color: Color(0xFF636E72)),
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        items: TodoPriority.values
                            .map((priority) => DropdownMenuItem(value: priority, child: Text(priority.label)))
                            .toList(),
                        onChanged: (value) { if (value != null) setState(() => _selectedPriority = value); },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<TodoStatus>(
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
                          fillColor: const Color(0xFFF5E6D3).withValues(alpha: 0.3),
                          filled: true,
                          labelStyle: const TextStyle(color: Color(0xFF636E72)),
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        items: TodoStatus.values
                            .map((status) => DropdownMenuItem(value: status, child: Text(status.label)))
                            .toList(),
                        onChanged: (value) { if (value != null) setState(() => _selectedStatus = value); },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dueDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              _dueDate = DateTime(picked.year, picked.month, picked.day);
                            });
                          }
                        },
                        icon: const Icon(Icons.event),
                        label: Text(
                          _dueDate == null
                              ? 'Due date'
                              : DateFormat('dd MMM yyyy').format(_dueDate!),
                        ),
                      ),
                    ),
                    if (_dueDate != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Clear due date',
                        onPressed: () { setState(() => _dueDate = null); },
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ],
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
                        final formState = _formKey.currentState;
                        if (formState == null || !formState.validate()) return;
                        final navigator = Navigator.of(context);
                        final now = DateTime.now();

                        final descriptionText = _descriptionController.text
                            .trim();
                        final contentJson =
                            _contentQuillController.document.isEmpty()
                            ? null
                            : jsonEncode(
                                _contentQuillController.document
                                    .toDelta()
                                    .toJson(),
                              );

                        final didSucceed = widget.todo == null
                            ? await widget.onCreate(
                                Todo(
                                  id: widget.uuid.v4(),
                                  projectId: widget.projectId,
                                  title: _titleController.text.trim(),
                                  description: descriptionText,
                                  content: contentJson,
                                  priority: _selectedPriority,
                                  status: _selectedStatus,
                                  dueDate: _dueDate,
                                  createdAt: now,
                                  completedAt: _selectedStatus == TodoStatus.completed ? now : null,
                                ),
                              )
                            : await widget.onUpdate(
                                widget.todo!
                                  ..title = _titleController.text.trim()
                                  ..description = descriptionText
                                  ..content = contentJson
                                  ..priority = _selectedPriority
                                  ..status = _selectedStatus
                                  ..dueDate = _dueDate
                                  ..completedAt =
                                      _selectedStatus == TodoStatus.completed
                                      ? (widget.todo?.completedAt ??
                                            DateTime.now())
                                      : null,
                              );
                        if (!mounted) return;
                        navigator.pop(didSucceed);
                      },
                      child: Text(widget.todo == null ? 'Create' : 'Save'),
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
