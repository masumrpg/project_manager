import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:catatan_kaki/widgets/project_detail/project_edit_sheet.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../models/enums/todo_status.dart';
import '../models/note.dart';
import '../models/project.dart';
import '../models/revision.dart';
import '../models/todo.dart';
import '../providers/project_detail_provider.dart';
import '../repositories/project_repository.dart';
import '../providers/project_provider.dart';
import '../widgets/project_detail/note_form_sheet.dart';
import '../widgets/project_detail/revision_form_sheet.dart';
import '../widgets/project_detail/todo_form_sheet.dart';
import '../widgets/project_detail/notes_tab.dart';
import '../widgets/project_detail/revisions_tab.dart';
import '../widgets/project_detail/todos_tab.dart';
import '../widgets/project_detail/error_section.dart';

import 'package:catatan_kaki/widgets/shared/hover_expandable_fab.dart';

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _SliverTabBarDelegate(this.tabBar);
  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // A simple container that sticks the tab bar to the top
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

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

class _ProjectDetailView extends StatefulWidget {
  const _ProjectDetailView();

  @override
  State<_ProjectDetailView> createState() => _ProjectDetailViewState();
}

class _ProjectDetailViewState extends State<_ProjectDetailView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final Uuid _uuid = const Uuid();
  double _titleOpacity = 0.0;
  double _appBarHeight = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _scrollController.addListener(() {
      final scrollOffset = _scrollController.offset;
      // Use the state field _appBarHeight, which is updated in build()
      final fadeStartOffset = _appBarHeight - kToolbarHeight - 100;

      if (scrollOffset > fadeStartOffset) {
        final rawOpacity = (scrollOffset - fadeStartOffset) / 100;
        final newOpacity = rawOpacity.clamp(0.0, 1.0);
        if (newOpacity != _titleOpacity) {
          setState(() {
            _titleOpacity = newOpacity;
          });
        }
      } else {
        if (_titleOpacity != 0.0) {
          setState(() {
            _titleOpacity = 0.0;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildProjectHeader(
    BuildContext context,
    Project project,
    bool isDesktop,
    Color darkText,
    Color lightText,
    Color cardBackground,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 32 : 24,
        kToolbarHeight +
            MediaQuery.of(context).padding.top, // Top padding for status bar
        isDesktop ? 32 : 24,
        16,
      ),
      decoration: BoxDecoration(
        color: cardBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Opacity(
            opacity: 1.0 - _titleOpacity,
            child: Text(
              project.title,
              style: TextStyle(
                fontSize: isDesktop ? 32 : 24,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if ((project.longDescription ?? '').isNotEmpty) ...[
            Builder(builder: (context) {
              Document doc;
              try {
                doc = Document.fromJson(
                  (jsonDecode(project.longDescription!) as List<dynamic>),
                );
              } catch (_) {
                doc = Document()..insert(0, project.longDescription!);
              }
              final plainText =
                  doc.toPlainText().replaceAll('\n', ' ').trim();
              return Text(
                plainText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                  color: lightText,
                ),
              );
            }),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: () => _openLongDescriptionViewer(context, project),
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
                'Dibuat ${DateFormat('MMM d, y').format(project.createdAt)}',
                style: TextStyle(fontSize: 14, color: lightText),
              ),
            ],
          ),
        ],
      ),
    );
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
                  'Memuat proyek...',
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
            'Proyek',
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
            'Proyek',
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
                  'Proyek tidak ditemukan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mungkin sudah dihapus.',
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

    final bool hasLongDesc = (project.longDescription ?? '').isNotEmpty;
    // Responsive app bar height
    if (isDesktop) {
      _appBarHeight = hasLongDesc ? 260.0 : 220.0;
    } else {
      _appBarHeight = hasLongDesc ? 220.0 : 180.0;
    }

    return Scaffold(
      backgroundColor: primaryBeige,
      floatingActionButton: ListenableBuilder(
        listenable: _tabController,
        builder: (context, _) {
          return _buildModernFab(context, provider, accentOrange);
        },
      ),
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: cardBackground, // Static color
              surfaceTintColor: cardBackground, // Prevent tinting on scroll
              elevation: 0,
              pinned: true,
              floating: true,
              stretch: true,
              centerTitle: false,
              expandedHeight: _appBarHeight,
              title: Opacity(
                opacity: _titleOpacity,
                child: Text(
                  project.title,
                  style: TextStyle(
                    color: darkText,
                    fontSize: isDesktop ? 22 : 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'Segarkan proyek',
                  onPressed: () => provider.loadProject(),
                  icon: Icon(Icons.refresh_rounded, color: accentOrange),
                ),
                IconButton(
                  tooltip: 'Edit proyek',
                  onPressed: () => _showEditProjectDialog(context, project),
                  icon: Icon(Icons.edit_outlined, color: accentOrange),
                ),
                IconButton(
                  tooltip: (project.longDescription ?? '').isEmpty
                      ? 'Tambah deskripsi panjang'
                      : 'Edit deskripsi panjang',
                  onPressed: () =>
                      _openLongDescriptionEditor(context, provider, project),
                  icon: Icon(Icons.notes_outlined, color: accentOrange),
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.fadeTitle,
                ],
                background: _buildProjectHeader(
                  context,
                  project,
                  isDesktop,
                  darkText,
                  lightText,
                  cardBackground,
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: accentOrange,
                  unselectedLabelColor: lightText,
                  indicatorSize: TabBarIndicatorSize.label, // Match the label width
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(color: accentOrange, width: 3),
                  ),
                  tabs: const [
                    Tab(text: 'Catatan'),
                    Tab(text: 'Revisi'),
                    Tab(text: 'Tugas'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            NotesTab(
              notes: notes,
              onEdit: (note) => _showNoteSheet(context, provider, note: note),
              onDelete: (note) => _confirmDeleteNote(context, provider, note),
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
              onEdit: (todo) => _showTodoSheet(context, provider, todo: todo),
              onDelete: (todo) => _confirmDeleteTodo(context, provider, todo),
              onStatusChange: (todo, status) =>
                  _updateTodoStatus(context, provider, todo, status),
              onAdd: () => _showTodoSheet(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernFab(
    BuildContext context,
    ProjectDetailProvider provider,
    Color accentOrange,
  ) {
    switch (_tabController.index) {
      case 0:
        return HoverExpandableFab(
          onPressed: () => _showNoteSheet(context, provider),
          icon: Icons.note_add_outlined,
          label: 'Tambah Catatan',
          backgroundColor: accentOrange,
          foregroundColor: Colors.white,
        );
      case 1:
        return HoverExpandableFab(
          onPressed: () => _showRevisionSheet(context, provider),
          icon: Icons.history_edu_outlined,
          label: 'Tambah Revisi',
          backgroundColor: accentOrange,
          foregroundColor: Colors.white,
        );
      case 2:
        return HoverExpandableFab(
          onPressed: () => _showTodoSheet(context, provider),
          icon: Icons.add_task,
          label: 'Tambah Tugas',
          backgroundColor: accentOrange,
          foregroundColor: Colors.white,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _openLongDescriptionEditor(
    BuildContext context,
    ProjectDetailProvider provider,
    Project project,
  ) {
    context.push('/long-description-editor', extra: {
      'projectTitle': project.title,
      'initialJson': project.longDescription,
      'onSave': (json) async {
        final ok = await provider.updateLongDescription(json);
        if (context.mounted) {
          _showFeedback(
            context,
            success: ok,
            message: ok
                ? 'Deskripsi panjang disimpan'
                : provider.error ?? 'Gagal menyimpan',
          );
        }
        return ok;
      },
    });
  }

  void _openLongDescriptionViewer(BuildContext context, Project project) {
    final provider = context.read<ProjectDetailProvider>();
    context.push('/long-description-editor', extra: {
      'projectTitle': project.title,
      'initialJson': project.longDescription,
      'readOnly': true,
      'onEdit': () {
        context.push('/long-description-editor', extra: {
          'projectTitle': project.title,
          'initialJson': project.longDescription,
          'onSave': (json) async {
            final ok = await provider.updateLongDescription(json);
            if (context.mounted) {
              _showFeedback(
                context,
                success: ok,
                message: ok
                    ? 'Deskripsi panjang disimpan'
                    : provider.error ?? 'Gagal menyimpan',
              );
            }
            return ok;
          },
        });
      },
    });
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
        message: 'Proyek berhasil diperbarui',
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
        message: note == null ? 'Catatan ditambahkan' : 'Catatan diperbarui',
      );
    } else if (success == false) {
      _showFeedback(
        context,
        success: false,
        message: provider.error ?? 'Gagal menyimpan catatan',
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
      title: 'Hapus Catatan',
      message: 'Anda yakin ingin menghapus "${note.title}"?',
    );

    if (confirmed != true) return;

    final success = await provider.deleteNote(note.id);
    if (!context.mounted) return;
    _showFeedback(
      context,
      success: success,
      message: success
          ? 'Catatan dihapus'
          : provider.error ?? 'Gagal menghapus catatan',
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
        message: revision == null ? 'Revisi ditambahkan' : 'Revisi diperbarui',
      );
    } else if (success == false) {
      _showFeedback(
        context,
        success: false,
        message: provider.error ?? 'Gagal menyimpan revisi',
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
      title: 'Hapus Revisi',
      message: 'Hapus revisi ${revision.version}?',
    );

    if (confirmed != true) return;

    final success = await provider.deleteRevision(revision.id);
    if (!context.mounted) return;
    _showFeedback(
      context,
      success: success,
      message: success
          ? 'Revisi dihapus'
          : provider.error ?? 'Gagal menghapus revisi',
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
        message: todo == null ? 'Tugas dibuat' : 'Tugas diperbarui',
      );
    } else if (success == false) {
      _showFeedback(
        context,
        success: false,
        message: provider.error ?? 'Gagal menyimpan tugas',
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
      title: 'Hapus Tugas',
      message: 'Hapus tugas "${todo.title}"?',
    );

    if (confirmed != true) return;

    final success = await provider.deleteTodo(todo.id);
    if (!context.mounted) return;
    _showFeedback(
      context,
      success: success,
      message: success
          ? 'Tugas dihapus'
          : provider.error ?? 'Gagal menghapus tugas',
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
          ? 'Tugas ditandai sebagai ${status.label.toLowerCase()}'
          : provider.error ?? 'Gagal memperbarui status',
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
              onPressed: () => dialogContext.pop(false),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF636E72),
              ), // lightText
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
              ? const Color(0xFF2E7D32) // A slightly darker green
              : const Color(0xFFC62828), // A slightly darker red
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    });
  }
}
