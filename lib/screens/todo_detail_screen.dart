import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/enums/todo_priority.dart';
import '../models/enums/todo_status.dart';
import '../models/todo.dart';
import '../providers/project_detail_provider.dart';
import 'todo_edit_screen.dart';

class TodoDetailScreen extends StatefulWidget {
  const TodoDetailScreen({
    required this.todo,
    required this.onStatusChange,
    super.key,
  });

  final Todo todo;
  final Future<void> Function(Todo, TodoStatus) onStatusChange;

  @override
  State<TodoDetailScreen> createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  late Todo _todo;
  late QuillController _contentQuillController;
  late TodoStatus _currentStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _todo = widget.todo;
    _currentStatus = _todo.status;
    _contentQuillController = _buildReadOnlyController(_todo);
  }

  @override
  void dispose() {
    _contentQuillController.dispose();
    super.dispose();
  }

  QuillController _buildReadOnlyController(Todo todo) {
    // Initialize Quill controller with existing content payload
    Document document;
    final content = todo.content;
    if (content != null && content.isNotEmpty) {
      try {
        final jsonData = jsonDecode(content);
        document = Document.fromJson(jsonData);
      } catch (e) {
        document = Document()..insert(0, content);
      }
    } else {
      document = Document();
    }
    return QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
  }

  void _syncWithProvider(Todo updatedTodo) {
    if (_todo.updatedAt == updatedTodo.updatedAt) return;
    final newController = _buildReadOnlyController(updatedTodo);
    final oldController = _contentQuillController;
    setState(() {
      _todo = updatedTodo;
      _currentStatus = updatedTodo.status;
      _contentQuillController = newController;
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
          backgroundColor:
              success ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final providerTodo = context.select<ProjectDetailProvider, Todo?>(
      (provider) {
        final project = provider.project;
        if (project == null) return null;
        for (final todo in project.todos) {
          if (todo.id == widget.todo.id) {
            return todo;
          }
        }
        return null;
      },
    );

    if (providerTodo != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _syncWithProvider(providerTodo);
      });
    }

    final description = _todo.description ?? '';
    final hasContent = _todo.content != null && _todo.content!.isNotEmpty;

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
          'Todo Details',
          style: const TextStyle(
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
                    child: TodoEditScreen(todo: _todo),
                  ),
                ),
              );
              if (!mounted || result != true) return;
              _showFeedback(success: true, message: 'Todo updated successfully');
            },
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF2D3436)),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(_currentStatus),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _currentStatus.label,
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
            // Title and Priority
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
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
                        _todo.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF2D3436),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Priority',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF636E72),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(_todo.priority).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _getPriorityColor(_todo.priority).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPriorityIcon(_todo.priority),
                            size: 16,
                            color: _getPriorityColor(_todo.priority),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _todo.priority.label,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getPriorityColor(_todo.priority),
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
            
            const SizedBox(height: 32),
            
            // Description
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
                  color: const Color(0xFFF5E6D3).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8D5C4)),
                ),
                padding: const EdgeInsets.all(16),
                child: Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF2D3436),
                        height: 1.5,
                      ) ??
                      const TextStyle(color: Color(0xFF2D3436)),
                ),
              ),
            const SizedBox(height: 32),
          ],

          // Due Date
          if (_todo.dueDate != null) ...[
              Text(
                'Due Date',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF2D3436),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E6D3).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8D5C4)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event,
                      color: _isOverdue(_todo.dueDate!)
                          ? const Color(0xFFD63031)
                          : const Color(0xFF636E72),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_todo.dueDate != null) ...[
                          Text(
                            DateFormat('EEEE, dd MMMM yyyy')
                                .format(_todo.dueDate!.toLocal()),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF2D3436),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_todo.dueDate != null &&
                              _isOverdue(_todo.dueDate!)) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Overdue',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFFD63031),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ] else ...[
                          Text(
                            'No due date set',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF636E72),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Detailed Content
            if (hasContent) ...[
              Text(
                'Details',
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
                  color: const Color(0xFFF5E6D3).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8D5C4)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AbsorbPointer(
                    child: QuillEditor.basic(
                      controller: _contentQuillController,
                      config: const QuillEditorConfig(
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Status with Checkbox
            Text(
              'Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF2D3436),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getStatusColor(_currentStatus).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _getStatusColor(_currentStatus).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(14.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        )
                      : Checkbox(
                          value: _currentStatus == TodoStatus.completed,
                          onChanged: (bool? value) async {
                            setState(() {
                              _isLoading = true;
                            });
                            final newStatus =
                                value == true ? TodoStatus.completed : TodoStatus.pending;
                            await widget.onStatusChange(_todo, newStatus);
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                                _currentStatus = newStatus;
                              });
                            }
                          },
                          activeColor: const Color(0xFF00B894),
                        ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _currentStatus == TodoStatus.completed ? 'Completed' : 'Mark as completed',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _getStatusColor(_currentStatus),
                        fontWeight: FontWeight.w500,
                        decoration: _currentStatus == TodoStatus.completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getStatusColor(_currentStatus),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Timestamps
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
                            .format(_todo.createdAt.toLocal()),
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
                            .format(_todo.updatedAt.toLocal()),
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

  bool _isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now()) && _currentStatus != TodoStatus.completed;
  }

  Color _getStatusColor(TodoStatus status) {
    return switch (status) {
      TodoStatus.pending => const Color(0xFF74B9FF),
      TodoStatus.inProgress => const Color(0xFFE17055),
      TodoStatus.completed => const Color(0xFF00B894),
      TodoStatus.cancelled => const Color(0xFFD63031),
    };
  }

  Color _getPriorityColor(TodoPriority priority) {
    return switch (priority) {
      TodoPriority.low => const Color(0xFF00B894),
      TodoPriority.medium => const Color(0xFFE17055),
      TodoPriority.high => const Color(0xFFD63031),
      TodoPriority.urgent => const Color(0xFF6C5CE7),
    };
  }

  IconData _getPriorityIcon(TodoPriority priority) {
    return switch (priority) {
      TodoPriority.low => Icons.arrow_downward,
      TodoPriority.medium => Icons.drag_handle,
      TodoPriority.high => Icons.arrow_upward,
      TodoPriority.urgent => Icons.priority_high,
    };
  }

}
