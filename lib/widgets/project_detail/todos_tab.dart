import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../models/enums/todo_status.dart';
import '../../../models/todo.dart';
import '../../providers/project_detail_provider.dart';
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
  final Future<void> Function(Todo, TodoStatus) onStatusChange;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final detailProvider = context.read<ProjectDetailProvider>();
    Future<void> refreshProject() =>
        detailProvider.loadProject(showLoading: false);

    void openTodoDetail(Todo todo) {
      context.push('/todo', extra: {
        'todo': todo,
        'provider': detailProvider,
      });
    }

    const scrollPhysics = AlwaysScrollableScrollPhysics(
      parent: BouncingScrollPhysics(),
    );

    return RefreshIndicator(
      onRefresh: refreshProject,
      child: todos.isEmpty
          ? CustomScrollView(
              physics: scrollPhysics,
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada tugas',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Rencanakan tugas dan lacak kemajuan di sini.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: onAdd,
                            icon: const Icon(Icons.add_task),
                            label: const Text('Tambah Tugas'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount =
                    (constraints.maxWidth / 380).floor().clamp(1, 3);

                if (crossAxisCount > 1) {
                  // Use GridView for wider screens
                  return GridView.builder(
                    physics: scrollPhysics,
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
                        onTap: () => openTodoDetail(todo),
                        onStatusChange: (isCompleted) async {
                          final newStatus = isCompleted
                              ? TodoStatus.completed
                              : TodoStatus.pending;
                          await onStatusChange(todo, newStatus);
                        },
                        onEdit: () => onEdit(todo),
                        onDelete: () => onDelete(todo),
                      );
                    },
                  );
                } else {
                  // Use ListView for narrower screens
                  return ListView.separated(
                    physics: scrollPhysics,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: todos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return TodoCard(
                        todo: todo,
                        onTap: () => openTodoDetail(todo),
                        onStatusChange: (isCompleted) async {
                          final newStatus = isCompleted
                              ? TodoStatus.completed
                              : TodoStatus.pending;
                          await onStatusChange(todo, newStatus);
                        },
                        onEdit: () => onEdit(todo),
                        onDelete: () => onDelete(todo),
                      );
                    },
                  );
                }
              },
            ),
    );
  }
}
