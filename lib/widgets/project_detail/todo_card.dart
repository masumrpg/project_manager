import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_manager/models/todo.dart';
import 'package:project_manager/models/enums/todo_status.dart';
import 'package:project_manager/models/enums/todo_priority.dart';

class TodoCard extends StatelessWidget {
  const TodoCard({
    required this.todo,
    required this.onTap,
    required this.onStatusChange,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final Todo todo;
  final VoidCallback onTap;
  final ValueChanged<bool> onStatusChange;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompleted = todo.status == TodoStatus.completed;
    final isOverdue = todo.dueDate != null && todo.dueDate!.isBefore(DateTime.now()) && !isCompleted;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isCompleted ? const Color(0xFFF5F5F5) : const Color(0xFFFFFBF7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: isCompleted,
                onChanged: (value) => onStatusChange(value ?? false),
                activeColor: colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          avatar: Icon(Icons.circle, size: 12, color: todo.status.color),
                          label: Text(todo.status.label),
                          labelStyle: theme.textTheme.labelSmall,
                          backgroundColor: todo.status.color.withAlpha(25),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        Chip(
                          avatar: Icon(Icons.flag_outlined, size: 14, color: todo.priority.color),
                          label: Text(todo.priority.label),
                          labelStyle: theme.textTheme.labelSmall,
                          backgroundColor: todo.priority.color.withAlpha(25),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        if (todo.dueDate != null)
                          Chip(
                            avatar: Icon(Icons.event, size: 14, color: isOverdue ? colorScheme.error : colorScheme.onSurfaceVariant),
                            label: Text(DateFormat.yMMMd().format(todo.dueDate!)),
                            labelStyle: theme.textTheme.labelSmall?.copyWith(color: isOverdue ? colorScheme.error : null),
                            backgroundColor: (isOverdue ? colorScheme.error : colorScheme.onSurfaceVariant).withAlpha(25),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'More actions',
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
