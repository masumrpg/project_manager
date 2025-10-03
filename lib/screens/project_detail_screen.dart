import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_manager/widgets/project_detail/project_edit_sheet.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../models/enums/todo_status.dart';
import '../models/note.dart';
import '../models/project.dart';
import '../models/revision.dart';
import '../models/todo.dart';
import '../repositories/project_repository.dart';
import '../providers/project_provider.dart';
import 'long_description_editor_screen.dart';
import '../widgets/project_detail/note_form_sheet.dart';
import '../widgets/project_detail/revision_form_sheet.dart';
import '../widgets/project_detail/todo_form_sheet.dart';
import '../widgets/project_detail/notes_tab.dart';
import '../widgets/project_detail/revisions_tab.dart';
import '../widgets/project_detail/todos_tab.dart';
import '../widgets/project_detail/error_section.dart';
import '../widgets/project_detail/tab_button.dart';
import '../widgets/shared/hover_expandable_fab.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProjectDetailProvider>(
      create: (_) => ProjectDetailProvider(
        repository: context.read<ProjectRepository>(),
        projectId: projectId,
      )..loadProject(),
      child: const _ProjectDetailView(),
    );
  }
}

class ProjectDetailProvider extends ChangeNotifier {
  ProjectDetailProvider({
    required ProjectRepository repository,
    required this.projectId,
  }) : _repository = repository;

  final ProjectRepository _repository;
  final String projectId;

  Project? _project;
  bool _isLoading = true;
  String? _error;

  Project? get project => _project;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProject({bool showLoading = true}) async {
    await _runTask(() async {
      _project = await _repository.getProjectById(projectId);
    }, showLoading: showLoading);
  }

  Future<bool> addNote(Note note) async {
    return _runTask(() async {
      await _repository.addNoteToProject(projectId, note);
      await _refreshProject();
    }, showLoading: false);
  }

  Future<bool> updateNote(Note note) async {
    return _runTask(() async {
      await _repository.updateNote(projectId, note);
      await _refreshProject();
    }, showLoading: false);
  }

  Future<bool> deleteNote(String noteId) async {
    return _runTask(() async {
      await _repository.removeNoteFromProject(projectId, noteId);
      await _refreshProject();
    }, showLoading: false);
  }

  Future<bool> addRevision(Revision revision) async {
    return _runTask(() async {
      await _repository.addRevisionToProject(projectId, revision);
      await _refreshProject();
    }, showLoading: false);
  }

  Future<bool> updateRevision(Revision revision) async {
    return _runTask(() async {
      await _repository.updateRevision(projectId, revision);
      await _refreshProject();
    }, showLoading: false);
  }

  Future<bool> deleteRevision(String revisionId) async {
    return _runTask(() async {
      await _repository.removeRevisionFromProject(projectId, revisionId);
      await _refreshProject();
    }, showLoading: false);
  }

  Future<bool> addTodo(Todo todo) async {
    return _runTask(() async {
      await _repository.addTodoToProject(projectId, todo);
      await _refreshProject();
    }, showLoading: false);
  }

  Future<bool> updateTodo(Todo todo) async {
    return _runTask(() async {
      await _repository.updateTodo(projectId, todo);
      await _refreshProject();
    }, showLoading: false);
  }

  Future<bool> deleteTodo(String todoId) async {
    return _runTask(() async {
      await _repository.removeTodoFromProject(projectId, todoId);
      await _refreshProject();
    }, showLoading: false);
  }

  Future<bool> updateTodoStatus(String todoId, TodoStatus status) async {
    return _runTask(() async {
      await _repository.updateTodoStatus(projectId, todoId, status);
      await _refreshProject();
    }, showLoading: false);
  }

  Future<void> _refreshProject() async {
    _project = await _repository.getProjectById(projectId);
  }

  Future<bool> updateLongDescription(String content) async {
    return _runTask(() async {
      await _repository.updateProjectLongDescription(projectId, content);
      await _refreshProject();
    }, showLoading: false);
  }

  Future<bool> _runTask(
    Future<void> Function() task, {
    required bool showLoading,
  }) async {
    if (showLoading) {
      _setLoading(true);
    }

    try {
      await task();
      _error = null;
      return true;
    } catch (error, stackTrace) {
      _error = error.toString();
      debugPrint('ProjectDetailProvider error: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    } finally {
      if (showLoading) {
        _setLoading(false);
      } else {
        notifyListeners();
      }
    }
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      if (!value) {
        notifyListeners();
      }
      return;
    }
    _isLoading = value;
    notifyListeners();
  }
}

class _ProjectDetailView extends StatefulWidget {
  const _ProjectDetailView();

  @override
  State<_ProjectDetailView> createState() => _ProjectDetailViewState();
}

class _ProjectDetailViewState extends State<_ProjectDetailView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Uuid _uuid = const Uuid();
  // Toggle header long description preview expand/collapse
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
    final provider = context.watch<ProjectDetailProvider>();
    final project = provider.project;

    // Modern warm color palette - consistent with home screen
    const primaryBeige = Color(0xFFF5E6D3);
    const accentOrange = Color(0xFFE07A5F);
    const darkText = Color(0xFF2D3436);
    const lightText = Color(0xFF636E72);
    const cardBackground = Color(0xFFFFFBF7);
    const shadowColor = Color(0x1A2D3436);

    // Responsive breakpoints
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;

    if (provider.isLoading) {
      return Scaffold(
        backgroundColor: primaryBeige,
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: accentOrange, strokeWidth: 3),
                const SizedBox(height: 16),
                Text(
                  'Loading project...',
                  style: TextStyle(
                    color: lightText,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (provider.error != null && project == null) {
      return Scaffold(
        backgroundColor: primaryBeige,
        appBar: AppBar(
          backgroundColor: cardBackground,
          elevation: 0,
          title: Text(
            'Project',
            style: TextStyle(
              color: darkText,
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: ErrorSection(
          message: provider.error!,
          onRetry: () => provider.loadProject(),
        ),
      );
    }

    if (project == null) {
      return Scaffold(
        backgroundColor: primaryBeige,
        appBar: AppBar(
          backgroundColor: cardBackground,
          elevation: 0,
          title: Text(
            'Project',
            style: TextStyle(
              color: darkText,
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.folder_off_outlined, size: 64, color: lightText),
                const SizedBox(height: 16),
                Text(
                  'Project not found',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'It may have been deleted.',
                  style: TextStyle(color: lightText, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final notes = List<Note>.from(project.notes)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final revisions = List<Revision>.from(project.revisions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final todos = List<Todo>.from(project.todos)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

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
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: cardBackground.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                tooltip: 'Edit project',
                onPressed: () => _showEditProjectDialog(context, project),
                icon: Icon(Icons.edit_outlined, color: accentOrange),
              ),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: cardBackground.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                tooltip: (project.longDescription ?? '').isEmpty
                    ? 'Tambahkan deskripsi lengkap'
                    : 'Edit deskripsi lengkap',
                onPressed: () =>
                    _openLongDescriptionEditor(context, provider, project),
                icon: Icon(Icons.notes_outlined, color: accentOrange),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildModernFab(context, provider, accentOrange),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Project header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isDesktop ? 32 : 24),
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor.withValues(alpha: 0.1),
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
                    if ((project.longDescription ?? '').isNotEmpty) ...[
                      // Render longDescription with Quill (read-only, limited height)
                      Builder(
                        builder: (context) {
                          Document doc;
                          try {
                            doc = Document.fromJson(
                              (jsonDecode(project.longDescription!)
                                  as List<dynamic>),
                            );
                          } catch (_) {
                            doc = Document()..insert(0, project.longDescription!);
                          }
                          final ctrl = QuillController(
                            document: doc,
                            selection: const TextSelection.collapsed(offset: 0),
                          );
                          final maxH = _isLongDescExpanded
                              ? (isDesktop ? 480.0 : 360.0)
                              : (isDesktop ? 220.0 : 160.0);
                          return Stack(
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxHeight: maxH,
                                  minWidth: double.infinity,
                                ),
                                padding: const EdgeInsets.only(top: 4),
                                child: ClipRect(
                                  child: AbsorbPointer(
                                    child: Scrollbar(
                                      child: QuillEditor.basic(
                                        controller: ctrl,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Fade hint to indicate more content (always show for visual consistency)
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: IgnorePointer(
                                  child: Container(
                                    height: 36,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          cardBackground
                                              .withValues(alpha: 0.0),
                                          cardBackground
                                              .withValues(alpha: 0.9),
                                          cardBackground,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLongDescExpanded = !_isLongDescExpanded;
                              });
                            },
                            child: Text(
                              _isLongDescExpanded
                                  ? 'Tutup'
                                  : 'Lihat lebih banyak',
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () =>
                                _openLongDescriptionViewer(context, project),
                            child: const Text('Buka layar penuh'),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        project.description ?? '',
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                          color: lightText,
                        ),
                      ),
                    ],
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
                          'Created ${DateFormat('MMM d, y').format(project.createdAt)}',
                          style: TextStyle(fontSize: 14, color: lightText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Tab bar with badge/card style
              Container(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 32 : 24,
                  8,
                  isDesktop ? 32 : 24,
                  0,
                ),
                width: double.infinity,
                decoration: BoxDecoration(color: primaryBeige),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: TabButton(
                            text: 'Notes',
                            isSelected: _tabController.index == 0,
                            onTap: () => _tabController.animateTo(0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: TabButton(
                            text: 'Revisions',
                            isSelected: _tabController.index == 1,
                            onTap: () => _tabController.animateTo(1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: TabButton(
                            text: 'Todos',
                            isSelected: _tabController.index == 2,
                            onTap: () => _tabController.animateTo(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Tab content
              Container(
                decoration: BoxDecoration(
                  color: primaryBeige,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 16,
                  vertical: isDesktop ? 24 : 16,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      NotesTab(
                        notes: notes,
                        onEdit: (note) =>
                            _showNoteSheet(context, provider, note: note),
                        onDelete: (note) =>
                            _confirmDeleteNote(context, provider, note),
                        onAdd: () => _showNoteSheet(context, provider),
                      ),
                      RevisionsTab(
                        revisions: revisions,
                        onEdit: (revision) => _showRevisionSheet(
                          context,
                          provider,
                          revision: revision,
                        ),
                        onDelete: (revision) =>
                            _confirmDeleteRevision(context, provider, revision),
                        onAdd: () => _showRevisionSheet(context, provider),
                      ),
                      TodosTab(
                        todos: todos,
                        onEdit: (todo) =>
                            _showTodoSheet(context, provider, todo: todo),
                        onDelete: (todo) =>
                            _confirmDeleteTodo(context, provider, todo),
                        onStatusChange: (todo, status) =>
                            _updateTodoStatus(context, provider, todo, status),
                        onAdd: () => _showTodoSheet(context, provider),
                      ),
                    ],
                  ),
                ),
              ),
              // Add bottom padding to prevent content cutoff
              SizedBox(height: isDesktop ? 100 : 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildModernFab(
    BuildContext context,
    ProjectDetailProvider provider,
    Color accentOrange,
  ) {
    switch (_tabController.index) {
      case 0:
        return HoverExpandableFab(
          onPressed: () => _showNoteSheet(context, provider),
          icon: Icons.note_add_outlined,
          label: 'Add Note',
          backgroundColor: accentOrange,
          foregroundColor: Colors.white,
        );
      case 1:
        return HoverExpandableFab(
          onPressed: () => _showRevisionSheet(context, provider),
          icon: Icons.history_edu_outlined,
          label: 'Add Revision',
          backgroundColor: accentOrange,
          foregroundColor: Colors.white,
        );
      case 2:
        return HoverExpandableFab(
          onPressed: () => _showTodoSheet(context, provider),
          icon: Icons.add_task,
          label: 'Add Todo',
          backgroundColor: accentOrange,
          foregroundColor: Colors.white,
        );
      default:
        return null;
    }
  }

  void _openLongDescriptionEditor(
    BuildContext context,
    ProjectDetailProvider provider,
    Project project,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LongDescriptionEditorScreen(
          projectTitle: project.title,
          initialJson: project.longDescription,
          onSave: (json) async {
            final ok = await provider.updateLongDescription(json);
            if (context.mounted) {
              _showFeedback(
                context,
                success: ok,
                message: ok
                    ? 'Long description saved'
                    : provider.error ?? 'Failed to save',
              );
            }
            return ok;
          },
        ),
      ),
    );
  }

  void _openLongDescriptionViewer(BuildContext context, Project project) {
    final provider = context.read<ProjectDetailProvider>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LongDescriptionEditorScreen(
          projectTitle: project.title,
          initialJson: project.longDescription,
          readOnly: true,
          onEdit: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LongDescriptionEditorScreen(
                  projectTitle: project.title,
                  initialJson: project.longDescription,
                  onSave: (json) async {
                    final ok = await provider.updateLongDescription(json);
                    if (context.mounted) {
                      _showFeedback(
                        context,
                        success: ok,
                        message: ok
                            ? 'Long description saved'
                            : provider.error ?? 'Failed to save',
                      );
                    }
                    return ok;
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showEditProjectDialog(
    BuildContext context,
    Project project,
  ) async {
    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        // The new sheet is self-contained and receives the providers it needs.
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: context.read<ProjectProvider>(),
            ),
            ChangeNotifierProvider.value(
              value: context.read<ProjectDetailProvider>(),
            ),
          ],
          child: ProjectEditSheet(project: project),
        );
      },
    );

    if (success == true && context.mounted) {
      _showFeedback(
        context,
        success: true,
        message: 'Project updated successfully',
      );
    }
  }

  Future<void> _showNoteSheet(
    BuildContext context,
    ProjectDetailProvider provider, {
    Note? note,
  }) async {
    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return NoteFormSheet(
          uuid: _uuid,
          note: note,
          onCreate: (n) => provider.addNote(n),
          onUpdate: (n) => provider.updateNote(n),
          projectId: provider.projectId,
        );
      },
    );
    if (!context.mounted) return;

    if (success == true) {
      _showFeedback(
        context,
        success: true,
        message: note == null ? 'Note added' : 'Note updated',
      );
    } else if (success == false) {
      _showFeedback(
        context,
        success: false,
        message: provider.error ?? 'Failed to save note',
      );
    }
  }

  Future<void> _confirmDeleteNote(
    BuildContext context,
    ProjectDetailProvider provider,
    Note note,
  ) async {
    final confirmed = await _confirmDeletion(
      context,
      title: 'Delete Note',
      message: 'Are you sure you want to delete "${note.title}"?',
    );

    if (confirmed != true) return;

    final success = await provider.deleteNote(note.id);
    if (!context.mounted) return;
    _showFeedback(
      context,
      success: success,
      message: success
          ? 'Note deleted'
          : provider.error ?? 'Failed to delete note',
    );
  }

  Future<void> _showRevisionSheet(
    BuildContext context,
    ProjectDetailProvider provider, {
    Revision? revision,
  }) async {
    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return RevisionFormSheet(
          uuid: _uuid,
          revision: revision,
          onCreate: (r) => provider.addRevision(r),
          onUpdate: (r) => provider.updateRevision(r),
          projectId: provider.projectId,
        );
      },
    );

    if (!context.mounted) return;

    if (success == true) {
      _showFeedback(
        context,
        success: true,
        message: revision == null ? 'Revision added' : 'Revision updated',
      );
    } else if (success == false) {
      _showFeedback(
        context,
        success: false,
        message: provider.error ?? 'Failed to save revision',
      );
    }
  }

  Future<void> _confirmDeleteRevision(
    BuildContext context,
    ProjectDetailProvider provider,
    Revision revision,
  ) async {
    final confirmed = await _confirmDeletion(
      context,
      title: 'Delete Revision',
      message: 'Delete revision ${revision.version}?',
    );

    if (confirmed != true) return;

    final success = await provider.deleteRevision(revision.id);
    if (!context.mounted) return;
    _showFeedback(
      context,
      success: success,
      message: success
          ? 'Revision deleted'
          : provider.error ?? 'Failed to delete revision',
    );
  }

  Future<void> _showTodoSheet(
    BuildContext context,
    ProjectDetailProvider provider, {
    Todo? todo,
  }) async {
    // New path: use stateful form widget to avoid controller lifecycle issues
    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return TodoFormSheet(
          uuid: _uuid,
          todo: todo,
          onCreate: (t) => provider.addTodo(t),
          onUpdate: (t) => provider.updateTodo(t),
          projectId: provider.projectId,
        );
      },
    );

    if (!context.mounted) return;

    if (success == true) {
      _showFeedback(
        context,
        success: true,
        message: todo == null ? 'Todo created' : 'Todo updated',
      );
    } else if (success == false) {
      _showFeedback(
        context,
        success: false,
        message: provider.error ?? 'Failed to save todo',
      );
    }
    return;
  }

  Future<void> _confirmDeleteTodo(
    BuildContext context,
    ProjectDetailProvider provider,
    Todo todo,
  ) async {
    final confirmed = await _confirmDeletion(
      context,
      title: 'Delete Todo',
      message: 'Delete todo "${todo.title}"?',
    );

    if (confirmed != true) return;

    final success = await provider.deleteTodo(todo.id);
    if (!context.mounted) return;
    _showFeedback(
      context,
      success: success,
      message: success
          ? 'Todo deleted'
          : provider.error ?? 'Failed to delete todo',
    );
  }

  Future<void> _updateTodoStatus(
    BuildContext context,
    ProjectDetailProvider provider,
    Todo todo,
    TodoStatus status,
  ) async {
    final success = await provider.updateTodoStatus(todo.id, status);
    if (!context.mounted) return;
    _showFeedback(
      context,
      success: success,
      message: success
          ? 'Todo marked as ${status.label.toLowerCase()}'
          : provider.error ?? 'Failed to update status',
    );
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
          backgroundColor: const Color(0xFFFFFBF7), // cardBackground
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF2D3436),
              fontWeight: FontWeight.w600,
            ), // darkText
          ),
          content: Text(
            message,
            style: const TextStyle(color: Color(0xFF636E72)), // lightText
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF636E72),
              ), // lightText
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFE5E5),
                foregroundColor: const Color(0xFFE07A5F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
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
              ? const Color(0xFF2E7D32) // A slightly darker green
              : const Color(0xFFC62828), // A slightly darker red
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    });
  }
}
