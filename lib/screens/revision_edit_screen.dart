import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/enums/revision_status.dart';
import '../models/revision.dart';
import '../providers/project_detail_provider.dart';

class RevisionEditScreen extends StatefulWidget {
  final Revision revision;

  const RevisionEditScreen({super.key, required this.revision});

  @override
  State<RevisionEditScreen> createState() => _RevisionEditScreenState();
}

class _RevisionEditScreenState extends State<RevisionEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _versionController;
  late final TextEditingController _descriptionController;
  late final QuillController _changeLogController;
  late RevisionStatus _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _versionController = TextEditingController(text: widget.revision.version);
    _descriptionController = TextEditingController(text: widget.revision.description);

    Document document;
    final existingChanges = widget.revision.changes;
    if (existingChanges.isNotEmpty) {
      try {
        final json = jsonDecode(existingChanges);
        document = Document.fromJson(json);
      } catch (e) {
        document = Document()..insert(0, existingChanges);
      }
    } else {
      document = Document();
    }

    _changeLogController = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );

    _selectedStatus = widget.revision.status;
  }

  @override
  void dispose() {
    _versionController.dispose();
    _descriptionController.dispose();
    _changeLogController.dispose();
    super.dispose();
  }

  Future<void> _saveRevision() async {
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

    final provider = context.read<ProjectDetailProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final changesJson = jsonEncode(_changeLogController.document.toDelta().toJson());

    final updatedRevision = widget.revision
      ..version = _versionController.text.trim()
      ..description = _descriptionController.text.trim()
      ..changes = changesJson
      ..status = _selectedStatus
      ..updatedAt = DateTime.now();

    final didSucceed = await provider.updateRevision(updatedRevision);

    if (!mounted) return;

    if (didSucceed) {
      await provider.loadProject(showLoading: false);
      if (mounted) context.pop(true);
    } else {
      setState(() {
        _isLoading = false;
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Gagal menyimpan revisi'),
          backgroundColor: const Color(0xFFE07A5F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      appBar: AppBar(
        title: const Text(
          'Edit Revisi',
          style: TextStyle(
            color: Color(0xFF2D3436),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFFFFBF7),
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D3436)),
        ),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 3)),
                )
              : IconButton(
                  onPressed: _saveRevision,
                  icon: const Icon(Icons.save_outlined, color: Color(0xFF2D3436)),
                  tooltip: 'Simpan Revisi',
                ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
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
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Versi harus diisi' : null,
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
          ],
        ),
      ),
    );
  }
}
