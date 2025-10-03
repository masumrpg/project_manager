import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/enums/todo_priority.dart';
import '../models/enums/todo_status.dart';
import '../models/todo.dart';
import '../providers/project_detail_provider.dart';

class TodoEditScreen extends StatefulWidget {
  final Todo todo;

  const TodoEditScreen({super.key, required this.todo});

  @override
  State<TodoEditScreen> createState() => _TodoEditScreenState();
}

class _TodoEditScreenState extends State<TodoEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final QuillController _contentQuillController;
  DateTime? _dueDate;
  late TodoPriority _selectedPriority;
  late TodoStatus _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(
      text: widget.todo.description ?? '',
    );

    Document document;
    final todoContent = widget.todo.content;
    if (todoContent?.isNotEmpty == true) {
      try {
        final jsonData = jsonDecode(todoContent!);
        document = Document.fromJson(jsonData);
      } catch (e) {
        document = Document()..insert(0, todoContent!);
      }
    } else {
      document = Document();
    }
    _contentQuillController = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );

    _dueDate = widget.todo.dueDate;
    _selectedPriority = widget.todo.priority;
    _selectedStatus = widget.todo.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentQuillController.dispose();
    super.dispose();
  }

  Future<void> _saveTodo() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final provider = context.read<ProjectDetailProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final descriptionText = _descriptionController.text.trim();
    final contentJson = _contentQuillController.document.isEmpty()
        ? null
        : jsonEncode(
            _contentQuillController.document.toDelta().toJson(),
          );

    final updatedTodo = widget.todo
      ..title = _titleController.text.trim()
      ..description = descriptionText
      ..content = contentJson
      ..priority = _selectedPriority
      ..status = _selectedStatus
      ..dueDate = _dueDate
      ..updatedAt = DateTime.now()
      ..completedAt = _selectedStatus == TodoStatus.completed
          ? (widget.todo.completedAt ?? DateTime.now())
          : null;

    final didSucceed = await provider.updateTodo(updatedTodo);

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
            content: Text(provider.error ?? 'Failed to save todo'),
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
          'Edit Todo',
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
                  onPressed: _saveTodo,
                  icon: const Icon(Icons.save_outlined, color: Color(0xFF2D3436)),
                  tooltip: 'Save Todo',
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
                  borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 2),
                ),
                fillColor: const Color(0xFFF5E6D3).withAlpha(76),
                filled: true,
                labelStyle: const TextStyle(color: Color(0xFF636E72)),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Title is required' : null,
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
                  borderSide: const BorderSide(
                    color: Color(0xFFE07A5F),
                    width: 2,
                  ),
                ),
                fillColor: const Color(0xFFF5E6D3).withAlpha(76),
                filled: true,
                labelStyle: const TextStyle(color: Color(0xFF636E72)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
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
                    color: const Color(0xFFF5E6D3).withAlpha(76),
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
                    value: _selectedPriority,
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
                      fillColor: const Color(0xFFF5E6D3).withAlpha(76),
                      filled: true,
                      labelStyle: const TextStyle(color: Color(0xFF636E72)),
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    items: TodoPriority.values
                        .map((priority) =>
                            DropdownMenuItem(value: priority, child: Text(priority.label)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedPriority = value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<TodoStatus>(
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
                    items: TodoStatus.values
                        .map((status) =>
                            DropdownMenuItem(value: status, child: Text(status.label)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _selectedStatus = value);
                    },
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
                    onPressed: () {
                      setState(() => _dueDate = null);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
