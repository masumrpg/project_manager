import 'package:flutter/material.dart';

import '../../../models/enums/todo_status.dart';
import '../../../models/todo.dart';
import '../../screens/todo_detail_screen.dart';
import 'todo_card.dart';

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
            Icon(Icons.check_circle_outline, size: 64, color: Theme.of(context).colorScheme.primary),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 380).floor().clamp(1, 3);

        if (crossAxisCount > 1) {
          // Use GridView for wider screens
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 2.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return TodoCard(
                todo: todo,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TodoDetailScreen(
                      todo: todo,
                      onStatusChange: onStatusChange,
                    ),
                  ),
                ),
                onStatusChange: (isCompleted) {
                  final newStatus = isCompleted ? TodoStatus.completed : TodoStatus.pending;
                  onStatusChange(todo, newStatus);
                },
                onEdit: () => onEdit(todo),
                onDelete: () => onDelete(todo),
              );
            },
          );
        } else {
          // Use ListView for narrower screens
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: todos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final todo = todos[index];
              return TodoCard(
                todo: todo,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TodoDetailScreen(
                      todo: todo,
                      onStatusChange: onStatusChange,
                    ),
                  ),
                ),
                onStatusChange: (isCompleted) {
                  final newStatus = isCompleted ? TodoStatus.completed : TodoStatus.pending;
                  onStatusChange(todo, newStatus);
                },
                onEdit: () => onEdit(todo),
                onDelete: () => onDelete(todo),
              );
            },
          );
        }
      },
    );
  }
}

