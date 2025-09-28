import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/enums/todo_priority.dart';
import '../../../models/enums/todo_status.dart';
import '../../../models/todo.dart';
import '../../screens/todo_detail_screen.dart';

class TodosTab extends StatelessWidget {
  const TodosTab({
    required this.todos,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChange,
    required this.onAdd,
    super.key,
  });

  final List<Todo> todos;
  final ValueChanged<Todo> onEdit;
  final ValueChanged<Todo> onDelete;
  final void Function(Todo, TodoStatus) onStatusChange;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 64),
            const SizedBox(height: 16),
            Text('No todos yet', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Plan tasks and track progress here.'),
            const SizedBox(height: 20),
            FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add_task), label: const Text('Add Todo')),
          ],
        ),
      );
    }

    return ListView.separated(
      itemBuilder: (context, index) {
        final todo = todos[index];
        return Card(
          elevation: 0,
          color: const Color(0xFFFFFBF7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _getStatusColor(todo.status).withValues(alpha: 0.1),
                  foregroundColor: _getStatusColor(todo.status),
                  child: Icon(_priorityIcon(todo.priority)),
                ),
              ],
            ),
            title: Text(
              todo.title, 
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                decoration: todo.status == TodoStatus.completed ? TextDecoration.lineThrough : null,
                color: todo.status == TodoStatus.completed ? const Color(0xFF636E72) : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (todo.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _getPlainTextContent(todo.description), 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      decoration: todo.status == TodoStatus.completed ? TextDecoration.lineThrough : null,
                      color: todo.status == TodoStatus.completed ? const Color(0xFF636E72) : null,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Chip(
                      label: Text(todo.priority.label),
                      backgroundColor: _badgeColor(todo.priority).withValues(alpha: 0.08),
                      labelStyle: TextStyle(color: _badgeColor(todo.priority)),
                      side: BorderSide(color: _badgeColor(todo.priority).withValues(alpha: 0.4)),
                    ),
                    if (todo.dueDate != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event, 
                            size: 14,
                            color: _isOverdue(todo.dueDate!) && todo.status != TodoStatus.completed 
                                ? const Color(0xFFD63031) 
                                : null,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM yyyy').format(todo.dueDate!),
                            style: TextStyle(
                              color: _isOverdue(todo.dueDate!) && todo.status != TodoStatus.completed 
                                  ? const Color(0xFFD63031) 
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(todo.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getStatusColor(todo.status).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _getStatusColor(todo.status),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            todo.status.label,
                            style: TextStyle(
                              color: _getStatusColor(todo.status),
                              fontSize: 12,
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: todo.status == TodoStatus.completed,
                  onChanged: (bool? value) {
                    final newStatus = value == true ? TodoStatus.completed : TodoStatus.pending;
                    onStatusChange(todo, newStatus);
                  },
                  activeColor: const Color(0xFF00B894),
                ),
                IconButton(
                  tooltip: 'Edit todo',
                  onPressed: () => onEdit(todo),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Delete todo',
                  onPressed: () => onDelete(todo),
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFE07A5F)),
                ),
              ],
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TodoDetailScreen(
                    todo: todo,
                    onStatusChange: onStatusChange,
                  ),
                ),
              );
            },
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: todos.length,
    );
  }

  String _getPlainTextContent(String content) {
    if (content.isEmpty) return '';
    
    try {
      // Try to parse as JSON (Quill document)
      final jsonData = jsonDecode(content);
      if (jsonData is List) {
        final buffer = StringBuffer();
        for (final op in jsonData) {
          if (op is Map && op.containsKey('insert')) {
            final insert = op['insert'];
            if (insert is String) {
              buffer.write(insert);
            }
          }
        }
        return buffer.toString().trim();
      }
    } catch (e) {
      // If parsing fails, return as plain text
    }
    return content;
  }

  bool _isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }

  Color _getStatusColor(TodoStatus status) {
    switch (status) {
      case TodoStatus.pending:
        return const Color(0xFF74B9FF);
      case TodoStatus.inProgress:
        return const Color(0xFFE17055);
      case TodoStatus.completed:
        return const Color(0xFF00B894);
      case TodoStatus.cancelled:
        return const Color(0xFFD63031);
      case TodoStatus.onHold:
        return const Color(0xFFFDCB6E);
    }
  }

  Color _badgeColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.low:
        return const Color(0xFF4CAF50);
      case TodoPriority.medium:
        return const Color(0xFFFFA000);
      case TodoPriority.high:
        return const Color(0xFFEF5350);
      case TodoPriority.critical:
        return const Color(0xFFB71C1C);
    }
  }

  IconData _priorityIcon(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.low:
        return Icons.arrow_downward;
      case TodoPriority.medium:
        return Icons.filter_list;
      case TodoPriority.high:
        return Icons.warning_amber_outlined;
      case TodoPriority.critical:
        return Icons.priority_high;
    }
  }
}
