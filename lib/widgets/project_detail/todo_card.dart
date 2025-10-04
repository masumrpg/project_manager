import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:catatan_kaki/models/todo.dart';
import 'package:catatan_kaki/models/enums/todo_status.dart';
import 'package:catatan_kaki/models/enums/todo_priority.dart';

class TodoCard extends StatefulWidget {
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
  final Future<void> Function(bool) onStatusChange;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompleted = widget.todo.status == TodoStatus.completed;
    final isOverdue = widget.todo.dueDate != null &&
        widget.todo.dueDate!.isBefore(DateTime.now()) &&
        !isCompleted;
    final titleColor =
        isCompleted ? colorScheme.onSurfaceVariant : colorScheme.onSurface;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isCompleted ? const Color(0xFFF5F5F5) : const Color(0xFFFFFBF7),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      value: isCompleted,
                      onChanged: (value) async {
                        setState(() {
                          _isLoading = true;
                        });
                        await widget.onStatusChange(value ?? false);
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      activeColor: colorScheme.primary,
                    ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.todo.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor:
                            isCompleted ? titleColor : null,
                        color: titleColor,
                      ),
                    ),
                    if (widget.todo.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.todo.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(
                          avatar: Icon(Icons.circle,
                              size: 12, color: widget.todo.status.color),
                          label: Text(widget.todo.status.label),
                          labelStyle: theme.textTheme.labelSmall,
                          backgroundColor:
                              widget.todo.status.color.withAlpha(25),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        Chip(
                          avatar: Icon(Icons.flag_outlined,
                              size: 14, color: widget.todo.priority.color),
                          label: Text(widget.todo.priority.label),
                          labelStyle: theme.textTheme.labelSmall,
                          backgroundColor:
                              widget.todo.priority.color.withAlpha(25),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        if (widget.todo.dueDate != null)
                          Chip(
                            avatar: Icon(Icons.event,
                                size: 14,
                                color: isOverdue
                                    ? colorScheme.error
                                    : colorScheme.onSurfaceVariant),
                            label:
                                Text(DateFormat.yMMMd().format(widget.todo.dueDate!)),
                            labelStyle: theme.textTheme.labelSmall?.copyWith(
                                color: isOverdue ? colorScheme.error : null),
                            backgroundColor: (isOverdue
                                    ? colorScheme.error
                                    : colorScheme.onSurfaceVariant)
                                .withAlpha(25),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'More actions',
                onSelected: (value) {
                  if (value == 'edit') widget.onEdit();
                  if (value == 'delete') widget.onDelete();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                icon: Icon(Icons.more_vert,
                    color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
