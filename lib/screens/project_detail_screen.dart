import 'dart:convert';

import 'package:catatan_kaki/models/enums/todo_status.dart';
import 'package:catatan_kaki/models/note.dart';
import 'package:catatan_kaki/models/project.dart';
import 'package:catatan_kaki/models/revision.dart';
import 'package:catatan_kaki/models/todo.dart';
import 'package:catatan_kaki/providers.dart';
import 'package:catatan_kaki/widgets/project_detail/note_form_sheet.dart';
import 'package:catatan_kaki/widgets/project_detail/revision_form_sheet.dart';
import 'package:catatan_kaki/widgets/project_detail/todo_form_sheet.dart';
import 'package:catatan_kaki/widgets/project_detail/notes_tab.dart';
import 'package:catatan_kaki/widgets/project_detail/revisions_tab.dart';
import 'package:catatan_kaki/widgets/project_detail/todos_tab.dart';
import 'package:catatan_kaki/widgets/project_detail/error_section.dart';
import 'package:catatan_kaki/widgets/project_detail/tab_button.dart';
import 'package:catatan_kaki/widgets/shared/hover_expandable_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectProvider(projectId));

    return projectAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: ErrorSection(
          message: err.toString(),
          onRetry: () => ref.refresh(projectProvider(projectId)),
        ),
      ),
      data: (project) {
        if (project == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: const Center(child: Text('Project not found.')),
          );
        }
        return _ProjectDetailView(project: project);
      },
    );
  }
}

class _ProjectDetailView extends ConsumerStatefulWidget {
  const _ProjectDetailView({required this.project});

  final Project project;

  @override
  ConsumerState<_ProjectDetailView> createState() => _ProjectDetailViewState();
}

class _ProjectDetailViewState extends ConsumerState<_ProjectDetailView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Uuid _uuid = const Uuid();
  bool _isLongDescExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final notesAsync = ref.watch(notesForProjectProvider(project.id));
    final revisionsAsync = ref.watch(revisionsForProjectProvider(project.id));
    final todosAsync = ref.watch(todosForProjectProvider(project.id));

    const primaryBeige = Color(0xFFF5E6D3);
    const accentOrange = Color(0xFFE07A5F);
    const darkText = Color(0xFF2D3436);
    const lightText = Color(0xFF636E72);
    const cardBackground = Color(0xFFFFFBF7);
    const shadowColor = Color(0x1A2D3436);

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;

    return Scaffold(
      backgroundColor: primaryBeige,
      appBar: AppBar(
        backgroundColor: cardBackground,
        elevation: 0,
        title: Text(
          project.title,
          style: TextStyle(
            color: darkText,
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Segarkan proyek',
            onPressed: () => ref.read(syncServiceProvider).syncProjects(),
            icon: Icon(Icons.refresh_rounded, color: accentOrange),
          ),
        ],
      ),
      floatingActionButton: _buildModernFab(context, ref, accentOrange),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isDesktop ? 32 : 24),
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor.withAlpha(15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: TextStyle(
                        fontSize: isDesktop ? 32 : 24,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      project.description ?? '',
                      style: TextStyle(
                        fontSize: isDesktop ? 18 : 16,
                        color: lightText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: lightText,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Dibuat ${DateFormat('MMM d, y').format(project.createdAt)}',
                          style: TextStyle(fontSize: 14, color: lightText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 32 : 24,
                  8,
                  isDesktop ? 32 : 24,
                  0,
                ),
                width: double.infinity,
                decoration: const BoxDecoration(color: primaryBeige),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TabButton(
                          text: 'Catatan',
                          isSelected: _tabController.index == 0,
                          onTap: () => _tabController.animateTo(0),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TabButton(
                          text: 'Revisi',
                          isSelected: _tabController.index == 1,
                          onTap: () => _tabController.animateTo(1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TabButton(
                          text: 'Tugas',
                          isSelected: _tabController.index == 2,
                          onTap: () => _tabController.animateTo(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: primaryBeige,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 16,
                  vertical: isDesktop ? 24 : 16,
                ),
                height: MediaQuery.of(context).size.height * 0.6,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    notesAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => ErrorSection(message: e.toString(), onRetry: () => ref.refresh(notesForProjectProvider(project.id))),
                      data: (notes) => NotesTab(
                        notes: notes,
                        onEdit: (note) => _showNoteSheet(context, ref, note: note),
                        onDelete: (note) => _confirmDeleteNote(context, ref, note),
                        onAdd: () => _showNoteSheet(context, ref),
                      ),
                    ),
                    revisionsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => ErrorSection(message: e.toString(), onRetry: () => ref.refresh(revisionsForProjectProvider(project.id))),
                      data: (revisions) => RevisionsTab(
                        revisions: revisions,
                        onEdit: (revision) => _showRevisionSheet(context, ref, revision: revision),
                        onDelete: (revision) => _confirmDeleteRevision(context, ref, revision),
                        onAdd: () => _showRevisionSheet(context, ref),
                      ),
                    ),
                    todosAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => ErrorSection(message: e.toString(), onRetry: () => ref.refresh(todosForProjectProvider(project.id))),
                      data: (todos) => TodosTab(
                        todos: todos,
                        onEdit: (todo) => _showTodoSheet(context, ref, todo: todo),
                        onDelete: (todo) => _confirmDeleteTodo(context, ref, todo),
                        onStatusChange: (todo, status) => _updateTodoStatus(context, ref, todo, status),
                        onAdd: () => _showTodoSheet(context, ref),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isDesktop ? 100 : 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildModernFab(
    BuildContext context,
    WidgetRef ref,
    Color accentOrange,
  ) {
    switch (_tabController.index) {
      case 0:
        return HoverExpandableFab(
          onPressed: () => _showNoteSheet(context, ref),
          icon: Icons.note_add_outlined,
          label: 'Tambah Catatan',
          backgroundColor: accentOrange,
          foregroundColor: Colors.white,
        );
      case 1:
        return HoverExpandableFab(
          onPressed: () => _showRevisionSheet(context, ref),
          icon: Icons.history_edu_outlined,
          label: 'Tambah Revisi',
          backgroundColor: accentOrange,
          foregroundColor: Colors.white,
        );
      case 2:
        return HoverExpandableFab(
          onPressed: () => _showTodoSheet(context, ref),
          icon: Icons.add_task,
          label: 'Tambah Tugas',
          backgroundColor: accentOrange,
          foregroundColor: Colors.white,
        );
      default:
        return null;
    }
  }

  Future<void> _showNoteSheet(
    BuildContext context,
    WidgetRef ref, {
    Note? note,
  }) async {
    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return ProviderScope(
          parent: ProviderScope.containerOf(context),
          child: NoteFormSheet(
            uuid: _uuid,
            note: note,
            projectId: widget.project.id,
            onSave: (noteToSave) async {
              final repo = ref.read(noteLocalRepositoryProvider);
              await repo.insertOrUpdateNote(noteToSave);
            },
          ),
        );
      },
    );

    if (success == true && context.mounted) {
      _showFeedback(
        context,
        success: true,
        message: note == null ? 'Catatan ditambahkan' : 'Catatan diperbarui',
      );
    }
  }

  Future<void> _confirmDeleteNote(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    final confirmed = await _confirmDeletion(
      context,
      title: 'Hapus Catatan',
      message: 'Anda yakin ingin menghapus "${note.title}"?',
    );

    if (confirmed != true) return;

    try {
      await ref.read(noteLocalRepositoryProvider).deleteNote(note.id);
      if (context.mounted) {
        _showFeedback(context, success: true, message: 'Catatan dihapus');
      }
    } catch (e) {
      if (context.mounted) {
        _showFeedback(context, success: false, message: 'Gagal menghapus: $e');
      }
    }
  }

  Future<void> _showRevisionSheet(
    BuildContext context,
    WidgetRef ref, {
    Revision? revision,
  }) async {
    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return ProviderScope(
          parent: ProviderScope.containerOf(context),
          child: RevisionFormSheet(
            uuid: _uuid,
            revision: revision,
            projectId: widget.project.id,
            onSave: (revisionToSave) async {
              final repo = ref.read(revisionLocalRepositoryProvider);
              await repo.insertOrUpdateRevision(revisionToSave);
            },
          ),
        );
      },
    );

    if (success == true && context.mounted) {
      _showFeedback(
        context,
        success: true,
        message: revision == null ? 'Revisi ditambahkan' : 'Revisi diperbarui',
      );
    }
  }

  Future<void> _confirmDeleteRevision(
    BuildContext context,
    WidgetRef ref,
    Revision revision,
  ) async {
    final confirmed = await _confirmDeletion(
      context,
      title: 'Hapus Revisi',
      message: 'Hapus revisi ${revision.version}?',
    );

    if (confirmed != true) return;

    try {
      await ref.read(revisionLocalRepositoryProvider).deleteRevision(revision.id);
      if (context.mounted) {
        _showFeedback(context, success: true, message: 'Revisi dihapus');
      }
    } catch (e) {
      if (context.mounted) {
        _showFeedback(context, success: false, message: 'Gagal menghapus: $e');
      }
    }
  }

  Future<void> _showTodoSheet(
    BuildContext context,
    WidgetRef ref, {
    Todo? todo,
  }) async {
    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return ProviderScope(
          parent: ProviderScope.containerOf(context),
          child: TodoFormSheet(
            uuid: _uuid,
            todo: todo,
            projectId: widget.project.id,
            onSave: (todoToSave) async {
              final repo = ref.read(todoLocalRepositoryProvider);
              await repo.insertOrUpdateTodo(todoToSave);
            },
          ),
        );
      },
    );

    if (success == true && context.mounted) {
      _showFeedback(
        context,
        success: true,
        message: todo == null ? 'Tugas ditambahkan' : 'Tugas diperbarui',
      );
    }
  }

  Future<void> _confirmDeleteTodo(
    BuildContext context,
    WidgetRef ref,
    Todo todo,
  ) async {
    final confirmed = await _confirmDeletion(
      context,
      title: 'Hapus Tugas',
      message: 'Hapus tugas "${todo.title}"?',
    );

    if (confirmed != true) return;

    try {
      await ref.read(todoLocalRepositoryProvider).deleteTodo(todo.id);
      if (context.mounted) {
        _showFeedback(context, success: true, message: 'Tugas dihapus');
      }
    } catch (e) {
      if (context.mounted) {
        _showFeedback(context, success: false, message: 'Gagal menghapus: $e');
      }
    }
  }

  Future<void> _updateTodoStatus(
    BuildContext context,
    WidgetRef ref,
    Todo todo,
    TodoStatus status,
  ) async {
    final repo = ref.read(todoLocalRepositoryProvider);
    await repo.insertOrUpdateTodo(todo.copyWith(status: status));
    if (context.mounted) {
      _showFeedback(
        context,
        success: true,
        message: 'Status tugas diperbarui',
      );
    }
  }

  Future<bool?> _confirmDeletion(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFBF7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF2D3436),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Color(0xFF636E72)),
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(false),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF636E72),
              ),
              child: const Text('Batal'),
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFE5E5),
                foregroundColor: const Color(0xFFE07A5F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => dialogContext.pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _showFeedback(
    BuildContext context, {
    required bool success,
    required String message,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success
              ? const Color(0xFF2E7D32)
              : const Color(0xFFC62828),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    });
  }
}
