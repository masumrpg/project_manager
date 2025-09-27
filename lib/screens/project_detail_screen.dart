import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/enums/app_category.dart';
import '../models/enums/content_type.dart';
import '../models/enums/environment.dart';
import '../models/enums/todo_priority.dart';
import '../models/enums/todo_status.dart';
import '../models/note.dart';
import '../models/project.dart';
import '../models/revision.dart';
import '../models/todo.dart';
import '../repositories/project_repository.dart';
import '../providers/project_provider.dart';

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
                CircularProgressIndicator(
                  color: accentOrange,
                  strokeWidth: 3,
                ),
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
        body: _ErrorSection(
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
                Icon(
                  Icons.folder_off_outlined,
                  size: 64,
                  color: lightText,
                ),
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
                  style: TextStyle(
                    color: lightText,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final notes = List<Note>.from(project.notes ?? const <Note>[])
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final revisions = List<Revision>.from(
      project.revisions ?? const <Revision>[],
    )..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final todos = List<Todo>.from(project.todos ?? const <Todo>[])
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
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: cardBackground.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              tooltip: 'Edit project',
              onPressed: () => _showEditProjectDialog(context, provider, project),
              icon: Icon(Icons.edit_outlined, color: accentOrange),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildModernFab(context, provider, accentOrange),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Project header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isDesktop ? 32 : 24),
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
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
                  Text(
                    project.description,
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 16,
                      color: lightText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 16, color: lightText),
                      const SizedBox(width: 8),
                      Text(
                        'Created ${DateFormat('MMM d, y').format(project.createdAt)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: lightText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Tab bar with badge/card style
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryBeige,
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBackground,
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: _TabButton(
                        text: 'Notes',
                        isSelected: _tabController.index == 0,
                        onTap: () => _tabController.animateTo(0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TabButton(
                        text: 'Revisions',
                        isSelected: _tabController.index == 1,
                        onTap: () => _tabController.animateTo(1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TabButton(
                        text: 'Todos',
                        isSelected: _tabController.index == 2,
                        onTap: () => _tabController.animateTo(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Tab content
            Expanded(
              child: Container(
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
                child: TabBarView(
                   controller: _tabController,
                   children: [
                     _NotesTab(
                       notes: notes,
                       onEdit: (note) => _showNoteSheet(context, provider, note: note),
                       onDelete: (note) => _confirmDeleteNote(context, provider, note),
                       onAdd: () => _showNoteSheet(context, provider),
                     ),
                     _RevisionsTab(
                       revisions: revisions,
                       onEdit: (revision) => _showRevisionSheet(context, provider, revision: revision),
                       onDelete: (revision) => _confirmDeleteRevision(context, provider, revision),
                       onAdd: () => _showRevisionSheet(context, provider),
                     ),
                     _TodosTab(
                       todos: todos,
                       onEdit: (todo) => _showTodoSheet(context, provider, todo: todo),
                       onDelete: (todo) => _confirmDeleteTodo(context, provider, todo),
                       onStatusChange: (todo, status) => _updateTodoStatus(context, provider, todo, status),
                       onAdd: () => _showTodoSheet(context, provider),
                     ),
                   ],
                 ),
              ),
            ),
              ],
            ),
          ),
        ),
    );
  }

  Widget? _buildModernFab(BuildContext context, ProjectDetailProvider provider, Color accentOrange) {
    switch (_tabController.index) {
      case 0:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: accentOrange.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            backgroundColor: accentOrange,
            foregroundColor: Colors.white,
            elevation: 0,
            onPressed: () => _showNoteSheet(context, provider),
            icon: const Icon(Icons.note_add_outlined),
            label: const Text('Add Note'),
          ),
        );
      case 1:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: accentOrange.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            backgroundColor: accentOrange,
            foregroundColor: Colors.white,
            elevation: 0,
            onPressed: () => _showRevisionSheet(context, provider),
            icon: const Icon(Icons.history_edu_outlined),
            label: const Text('Add Revision'),
          ),
        );
      case 2:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: accentOrange.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            backgroundColor: accentOrange,
            foregroundColor: Colors.white,
            elevation: 0,
            onPressed: () => _showTodoSheet(context, provider),
            icon: const Icon(Icons.add_task),
            label: const Text('Add Todo'),
          ),
        );
      default:
        return null;
    }
  }

  Future<void> _showEditProjectDialog(
    BuildContext context,
    ProjectDetailProvider detailProvider,
    Project project,
  ) async {
    final projectProvider = context.read<ProjectProvider>();
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: project.title);
    final descriptionController = TextEditingController(
      text: project.description,
    );
    var selectedCategory = project.category;
    var selectedEnvironment = project.environment;

    try {
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: const Color(0xFFFFFBF7), // cardBackground
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(
              'Edit Project',
              style: TextStyle(color: const Color(0xFF2D3436), fontWeight: FontWeight.w600), // darkText
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE8D5C4)), // secondaryBeige
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 2), // accentOrange
                        ),
                        fillColor: const Color(0xFFF5E6D3).withValues(alpha: 0.3), // primaryBeige
                        filled: true,
                        labelStyle: const TextStyle(color: Color(0xFF636E72)), // lightText
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE8D5C4)), // secondaryBeige
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 2), // accentOrange
                        ),
                        fillColor: const Color(0xFFF5E6D3).withValues(alpha: 0.3), // primaryBeige
                        filled: true,
                        labelStyle: const TextStyle(color: Color(0xFF636E72)), // lightText
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonFormField<AppCategory>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        items: AppCategory.values
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) selectedCategory = value;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonFormField<Environment>(
                        initialValue: selectedEnvironment,
                        decoration: const InputDecoration(
                          labelText: 'Environment',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        items: Environment.values
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) selectedEnvironment = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  final now = DateTime.now();
                  project
                    ..title = titleController.text.trim()
                    ..description = descriptionController.text.trim()
                    ..category = selectedCategory
                    ..environment = selectedEnvironment
                    ..updatedAt = now;

                  final success = await projectProvider.updateProject(project);

                  if (success) {
                    await detailProvider.loadProject(showLoading: false);
                    if (!context.mounted || !dialogContext.mounted) return;
                    Navigator.of(dialogContext).pop(true);
                    _showFeedback(
                      context,
                      success: true,
                      message: 'Project updated successfully',
                    );
                  } else {
                    if (!context.mounted) return;
                    _showFeedback(
                      context,
                      success: false,
                      message:
                          projectProvider.error ?? 'Failed to update project',
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    } finally {
      titleController.dispose();
      descriptionController.dispose();
    }
  }

  Future<void> _showNoteSheet(
    BuildContext context,
    ProjectDetailProvider provider, {
    Note? note,
  }) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    var selectedType = note?.contentType ?? ContentType.text;

    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFFFFFBF7), // cardBackground
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF636E72).withValues(alpha: 0.3), // lightText
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    note == null ? 'Add Note' : 'Edit Note',
                    style: const TextStyle(
                      color: Color(0xFF2D3436), // darkText
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE8D5C4)), // secondaryBeige
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 2), // accentOrange
                    ),
                    fillColor: const Color(0xFFF5E6D3).withValues(alpha: 0.3), // primaryBeige
                    filled: true,
                    labelStyle: const TextStyle(color: Color(0xFF636E72)), // lightText
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: contentController,
                  decoration: InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE8D5C4)), // secondaryBeige
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 2), // accentOrange
                    ),
                    fillColor: const Color(0xFFF5E6D3).withValues(alpha: 0.3), // primaryBeige
                    filled: true,
                    labelStyle: const TextStyle(color: Color(0xFF636E72)), // lightText
                  ),
                  minLines: 4,
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Content is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonFormField<ContentType>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Content Type',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    items: ContentType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedType = value;
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        final now = DateTime.now();
                        final didSucceed = note == null
                            ? await provider.addNote(
                                Note(
                                  id: _uuid.v4(),
                                  title: titleController.text.trim(),
                                  content: contentController.text.trim(),
                                  contentType: selectedType,
                                  createdAt: now,
                                  updatedAt: now,
                                ),
                              )
                            : await provider.updateNote(
                                note
                                  ..title = titleController.text.trim()
                                  ..content = contentController.text.trim()
                                  ..contentType = selectedType,
                              );

                        if (!sheetContext.mounted) return;
                        Navigator.of(sheetContext).pop(didSucceed);
                      },
                      child: Text(note == null ? 'Create' : 'Save'),
                    ),
                  ],
                ),
                ],
              ),
            ),
          ),
        );
      },
    );

    titleController.dispose();
    contentController.dispose();

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
    final formKey = GlobalKey<FormState>();
    final versionController = TextEditingController(
      text: revision?.version ?? '',
    );
    final descriptionController = TextEditingController(
      text: revision?.description ?? '',
    );
    final changeLogController = TextEditingController(
      text: revision?.changes ?? '',
    );

    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFFFFFBF7), // cardBackground
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF636E72).withValues(alpha: 0.3), // lightText
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    revision == null ? 'Add Revision' : 'Edit Revision',
                    style: const TextStyle(
                      color: Color(0xFF2D3436), // darkText
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 16),
                TextFormField(
                  controller: versionController,
                  decoration: InputDecoration(
                    labelText: 'Version',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE8D5C4)), // secondaryBeige
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 2), // accentOrange
                    ),
                    fillColor: const Color(0xFFF5E6D3).withValues(alpha: 0.3), // primaryBeige
                    filled: true,
                    labelStyle: const TextStyle(color: Color(0xFF636E72)), // lightText
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Version is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE8D5C4)), // secondaryBeige
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 2), // accentOrange
                    ),
                    fillColor: const Color(0xFFF5E6D3).withValues(alpha: 0.3), // primaryBeige
                    filled: true,
                    labelStyle: const TextStyle(color: Color(0xFF636E72)), // lightText
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: changeLogController,
                  decoration: InputDecoration(
                    labelText: 'Changes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE8D5C4)), // secondaryBeige
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 2), // accentOrange
                    ),
                    fillColor: const Color(0xFFF5E6D3).withValues(alpha: 0.3), // primaryBeige
                    filled: true,
                    labelStyle: const TextStyle(color: Color(0xFF636E72)), // lightText
                  ),
                  minLines: 4,
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Changes is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        final didSucceed = revision == null
                            ? await provider.addRevision(
                                Revision(
                                  id: _uuid.v4(),
                                  version: versionController.text.trim(),
                                  description: descriptionController.text
                                      .trim(),
                                  changes: changeLogController.text.trim(),
                                  createdAt: DateTime.now(),
                                ),
                              )
                            : await provider.updateRevision(
                                revision
                                  ..version = versionController.text.trim()
                                  ..description = descriptionController.text
                                      .trim()
                                  ..changes = changeLogController.text.trim(),
                              );

                        if (!sheetContext.mounted) return;
                        Navigator.of(sheetContext).pop(didSucceed);
                      },
                      child: Text(revision == null ? 'Create' : 'Save'),
                    ),
                  ],
                ),
                ],
              ),
            ),
          ),
        );
      },
    );

    versionController.dispose();
    descriptionController.dispose();
    changeLogController.dispose();

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
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: todo?.title ?? '');
    final descriptionController = TextEditingController(
      text: todo?.description ?? '',
    );
    DateTime? dueDate = todo?.dueDate;
    var selectedPriority = todo?.priority ?? TodoPriority.medium;
    var selectedStatus = todo?.status ?? TodoStatus.pending;

    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFFFFFBF7), // cardBackground
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF636E72).withValues(alpha: 0.3), // lightText
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Text(
                        todo == null ? 'Add Todo' : 'Edit Todo',
                        style: const TextStyle(
                          color: Color(0xFF2D3436), // darkText
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE8D5C4)), // secondaryBeige
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 2), // accentOrange
                        ),
                        fillColor: const Color(0xFFF5E6D3).withValues(alpha: 0.3), // primaryBeige
                        filled: true,
                        labelStyle: const TextStyle(color: Color(0xFF636E72)), // lightText
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE8D5C4)), // secondaryBeige
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 2), // accentOrange
                        ),
                        fillColor: const Color(0xFFF5E6D3).withValues(alpha: 0.3), // primaryBeige
                        filled: true,
                        labelStyle: const TextStyle(color: Color(0xFF636E72)), // lightText
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonFormField<TodoPriority>(
                        initialValue: selectedPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        items: TodoPriority.values
                            .map(
                              (priority) => DropdownMenuItem(
                                value: priority,
                                child: Text(priority.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) selectedPriority = value;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonFormField<TodoStatus>(
                        initialValue: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        items: TodoStatus.values
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) selectedStatus = value;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: sheetContext,
                                initialDate: dueDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setSheetState(() {
                                  dueDate = picked;
                                });
                              }
                            },
                            icon: const Icon(Icons.event_outlined),
                            label: Text(
                              dueDate == null
                                  ? 'Due date (optional)'
                                  : DateFormat('dd MMM yyyy').format(dueDate!),
                            ),
                          ),
                        ),
                        if (dueDate != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Clear due date',
                            onPressed: () {
                              setSheetState(() {
                                dueDate = null;
                              });
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(sheetContext).pop(false),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;

                            final now = DateTime.now();
                            final didSucceed = todo == null
                                ? await provider.addTodo(
                                    Todo(
                                      id: _uuid.v4(),
                                      title: titleController.text.trim(),
                                      description: descriptionController.text
                                          .trim(),
                                      priority: selectedPriority,
                                      status: selectedStatus,
                                      dueDate: dueDate,
                                      createdAt: now,
                                      completedAt:
                                          selectedStatus == TodoStatus.completed
                                          ? now
                                          : null,
                                    ),
                                  )
                                : await provider.updateTodo(
                                    todo
                                      ..title = titleController.text.trim()
                                      ..description = descriptionController.text
                                          .trim()
                                      ..priority = selectedPriority
                                      ..status = selectedStatus
                                      ..dueDate = dueDate
                                      ..completedAt =
                                          selectedStatus == TodoStatus.completed
                                          ? (todo.completedAt ?? DateTime.now())
                                          : null,
                                  );

                            if (!sheetContext.mounted) return;
                            Navigator.of(sheetContext).pop(didSucceed);
                          },
                          child: Text(todo == null ? 'Create' : 'Save'),
                        ),
                      ],
                    ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            title,
            style: const TextStyle(color: Color(0xFF2D3436), fontWeight: FontWeight.w600), // darkText
          ),
          content: Text(
            message,
            style: const TextStyle(color: Color(0xFF636E72)), // lightText
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF636E72)), // lightText
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFE5E5),
                foregroundColor: const Color(0xFFE07A5F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: success
            ? const Color(0xFF2E7D32)
            : const Color(0xFFC62828),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({
    required this.notes,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
  });

  final List<Note> notes;
  final ValueChanged<Note> onEdit;
  final ValueChanged<Note> onDelete;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return _EmptyState(
        icon: Icons.note_alt_outlined,
        title: 'No notes yet',
        description:
            'Document project insights, decisions, and references in rich notes.',
        actionLabel: 'Add Note',
        onAction: onAdd,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemBuilder: (context, index) {
        final note = notes[index];
        return Card(
          elevation: 0,
          color: const Color(0xFFFFFBF7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Icon(_iconForContent(note.contentType), size: 28),
            title: Text(
              note.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                note.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  tooltip: 'Edit note',
                  onPressed: () => onEdit(note),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Delete note',
                  onPressed: () => onDelete(note),
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFE07A5F)),
                ),
              ],
            ),
            onTap: () => onEdit(note),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: notes.length,
    );
  }

  IconData _iconForContent(ContentType type) {
    switch (type) {
      case ContentType.text:
        return Icons.subject_outlined;
      case ContentType.markdown:
        return Icons.article_outlined;
      case ContentType.code:
        return Icons.code;
      case ContentType.image:
        return Icons.image_outlined;
      case ContentType.link:
        return Icons.link_outlined;
      case ContentType.document:
        return Icons.description_outlined;
    }
  }
}

class _RevisionsTab extends StatelessWidget {
  const _RevisionsTab({
    required this.revisions,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
  });

  final List<Revision> revisions;
  final ValueChanged<Revision> onEdit;
  final ValueChanged<Revision> onDelete;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    if (revisions.isEmpty) {
      return _EmptyState(
        icon: Icons.history,
        title: 'Revision history is empty',
        description:
            'Track milestones and release notes to keep everyone aligned.',
        actionLabel: 'Add Revision',
        onAction: onAdd,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemBuilder: (context, index) {
        final revision = revisions[index];
        return Card(
          elevation: 0,
          color: const Color(0xFFFFFBF7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const Icon(Icons.history_toggle_off, size: 28),
            title: Text('Version ${revision.version}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (revision.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      revision.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (revision.changes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      revision.changes,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat(
                      'dd MMM yyyy, HH:mm',
                    ).format(revision.createdAt.toLocal()),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  tooltip: 'Edit revision',
                  onPressed: () => onEdit(revision),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Delete revision',
                  onPressed: () => onDelete(revision),
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFE07A5F)),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: revisions.length,
    );
  }
}

class _TodosTab extends StatelessWidget {
  const _TodosTab({
    required this.todos,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChange,
    required this.onAdd,
  });

  final List<Todo> todos;
  final ValueChanged<Todo> onEdit;
  final ValueChanged<Todo> onDelete;
  final void Function(Todo, TodoStatus) onStatusChange;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) {
      return _EmptyState(
        icon: Icons.check_circle_outline,
        title: 'No todos yet',
        description:
            'Break work into actionable todos with priorities and due dates.',
        actionLabel: 'Add Todo',
        onAction: onAdd,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      itemBuilder: (context, index) {
        final todo = todos[index];
        return Card(
          elevation: 0,
          color: const Color(0xFFFFFBF7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: _badgeColor(todo.priority).withValues(alpha: 0.2),
              foregroundColor: _badgeColor(todo.priority),
              child: Icon(_priorityIcon(todo.priority)),
            ),
            title: Text(todo.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (todo.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      todo.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.flag_outlined, size: 16),
                        label: Text(todo.priority.label),
                      ),
                      Chip(
                        avatar: const Icon(Icons.bolt_outlined, size: 16),
                        label: Text(todo.status.label),
                      ),
                      if (todo.dueDate != null)
                        Chip(
                          avatar: const Icon(Icons.event_outlined, size: 16),
                          label: Text(
                            DateFormat('dd MMM yyyy').format(todo.dueDate!.toLocal()),
                          ),
                        ),
                    ],
                  ),
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
                PopupMenuButton<TodoStatus>(
                  tooltip: 'Update status',
                  onSelected: (status) => onStatusChange(todo, status),
                  itemBuilder: (context) => TodoStatus.values
                      .map(
                        (status) => PopupMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                      )
                      .toList(),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  const _ErrorSection({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return _EmptyState(
      icon: Icons.error_outline,
      title: 'Something went wrong',
      description: message,
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}

// Custom Tab Button Widget for badge/card style
class _TabButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const accentOrange = Color(0xFFE07A5F);
    const lightText = Color(0xFF636E72);
    const cardBackground = Color(0xFFFFFBF7);
    const primaryBeige = Color(0xFFF5E6D3);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? accentOrange : primaryBeige,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [
            BoxShadow(
              color: accentOrange.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? cardBackground : lightText,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
