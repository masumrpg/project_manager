import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/enums/todo_priority.dart';
import '../../../models/enums/todo_status.dart';
import '../../../models/todo.dart';

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
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: _badgeColor(todo.priority).withValues(alpha: 0.1),
              foregroundColor: _badgeColor(todo.priority),
              child: Icon(_priorityIcon(todo.priority)),
            ),
            title: Text(todo.title, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (todo.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(todo.description, maxLines: 2, overflow: TextOverflow.ellipsis),
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
                          const Icon(Icons.event, size: 14),
                          const SizedBox(width: 4),
                          Text(DateFormat('dd MMM yyyy').format(todo.dueDate!)),
                        ],
                      ),
                    PopupMenuButton<TodoStatus>(
                      tooltip: 'Change status',
                      itemBuilder: (context) => TodoStatus.values
                          .map((status) => PopupMenuItem(
                                value: status,
                                child: Text(status.label),
                              ))
                          .toList(),
                      onSelected: (status) => onStatusChange(todo, status),
                      child: Chip(
                        label: Text(todo.status.label),
                        avatar: const Icon(Icons.swap_horiz, size: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
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
            onTap: () => onEdit(todo),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: todos.length,
    );
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
