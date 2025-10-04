import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../models/enums/revision_status.dart';
import '../../models/revision.dart';

class RevisionFormSheet extends StatefulWidget {
  const RevisionFormSheet({
    required this.uuid,
    required this.onCreate,
    required this.onUpdate,
    required this.projectId,
    this.revision,
    super.key,
  });

  final Uuid uuid;
  final Revision? revision;
  final Future<bool> Function(Revision) onCreate;
  final Future<bool> Function(Revision) onUpdate;
  final String projectId;

  @override
  State<RevisionFormSheet> createState() => _RevisionFormSheetState();
}

class _RevisionFormSheetState extends State<RevisionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _versionController;
  late final TextEditingController _descriptionController;
  late final QuillController _changeLogController;
  late RevisionStatus _selectedStatus;
  bool _isLoading = false;
  double _borderRadius = 24.0;

  @override
  void initState() {
    super.initState();
    _versionController = TextEditingController(text: widget.revision?.version ?? '');
    _descriptionController = TextEditingController(text: widget.revision?.description ?? '');
    
    // Initialize Quill controller for changes
    Document document;
    final existingChanges = widget.revision?.changes ?? const <String>[];
    if (existingChanges.isNotEmpty) {
      final text = existingChanges.join('\n');
      document = Document()..insert(0, text);
    } else {
      document = Document();
    }
    
    _changeLogController = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
    
    _selectedStatus = widget.revision?.status ?? RevisionStatus.pending;
  }

  @override
  void dispose() {
    _versionController.dispose();
    _descriptionController.dispose();
    _changeLogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        final newRadius = notification.extent < 1.0 ? 24.0 : 0.0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && newRadius != _borderRadius) {
            setState(() {
              _borderRadius = newRadius;
            });
          }
        });
        return true;
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        expand: true,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF7),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_borderRadius),
                topRight: Radius.circular(_borderRadius),
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF636E72).withAlpha(76),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.only(
                        left: 24,
                        right: 24,
                        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
                      ),
                      children: [
                        const Text(
                          'Revisi',
                          style: TextStyle(
                            color: Color(0xFF2D3436),
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _versionController,
                          decoration: InputDecoration(
                            label: RichText(
                              text: const TextSpan(
                                text: 'Versi',
                                style: TextStyle(color: Color(0xFF636E72)),
                                children: [
                                  TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE8D5C4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 2),
                            ),
                            fillColor: const Color(0xFFF5E6D3).withAlpha(76),
                            filled: true,
                            labelStyle: const TextStyle(color: Color(0xFF636E72)),
                          ),
                          validator: (value) => (value == null || value.trim().isEmpty) ? 'Versi harus diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Deskripsi',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE8D5C4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 2),
                            ),
                            fillColor: const Color(0xFFF5E6D3).withAlpha(76),
                            filled: true,
                            labelStyle: const TextStyle(color: Color(0xFF636E72)),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        // Changes field with Quill editor
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: const TextSpan(
                                text: 'Perubahan',
                                style: TextStyle(
                                  color: Color(0xFF636E72),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(
                                      text: ' *',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5E6D3).withAlpha(76),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE8D5C4)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Column(
                                  children: [
                                    QuillSimpleToolbar(
                                      controller: _changeLogController,
                                      config: const QuillSimpleToolbarConfig(
                                        toolbarSize: 40,
                                        multiRowsDisplay: false,
                                      ),
                                    ),
                                    Container(
                                      constraints: const BoxConstraints(
                                        minHeight: 120,
                                        maxHeight: 200,
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: QuillEditor.basic(
                                        controller: _changeLogController,
                                        config: const QuillEditorConfig(
                                          padding: EdgeInsets.zero,
                                          expands: false,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<RevisionStatus>(
                          initialValue: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Status',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE8D5C4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 2),
                            ),
                            fillColor: const Color(0xFFF5E6D3).withAlpha(76),
                            filled: true,
                            labelStyle: const TextStyle(color: Color(0xFF636E72)),
                          ),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          items: RevisionStatus.values
                              .map((status) => DropdownMenuItem(value: status, child: Text(status.label)))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) setState(() => _selectedStatus = value);
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _isLoading ? null : () => context.pop(false),
                              child: const Text('Batal'),
                            ),
                            const SizedBox(width: 12),
                            FilledButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      // Validate changes field manually since it's not a TextFormField
                                      final changesText = _changeLogController.document.toPlainText().trim();
                                      if (changesText.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('Perubahan harus diisi'),
                                            backgroundColor: const Color(0xFFE07A5F),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                                          ),
                                        );
                                        return;
                                      }

                                      final formState = _formKey.currentState;
                                      if (formState == null || !formState.validate()) return;

                                      setState(() {
                                        _isLoading = true;
                                      });

                                      final now = DateTime.now();
                                      final changeLines = changesText
                                          .split('\n')
                                          .map((line) => line.trim())
                                          .where((line) => line.isNotEmpty)
                                          .toList();

                                      final didSucceed = await (widget.revision == null
                                          ? widget.onCreate(
                                              Revision(
                                                id: widget.uuid.v4(),
                                                projectId: widget.projectId,
                                                version: _versionController.text.trim(),
                                                description: _descriptionController.text.trim(),
                                                changes: changeLines,
                                                status: _selectedStatus,
                                                createdAt: now,
                                                updatedAt: now,
                                              ),
                                            )
                                          : widget.onUpdate(
                                              widget.revision!
                                                ..version = _versionController.text.trim()
                                                ..description = _descriptionController.text.trim()
                                                ..changes = changeLines
                                                ..status = _selectedStatus
                                                ..updatedAt = now,
                                            ));
                                      if (!context.mounted) return;
                                      context.pop(didSucceed);
                                    },
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(widget.revision == null ? 'Buat' : 'Simpan'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
