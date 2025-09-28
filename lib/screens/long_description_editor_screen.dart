import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class LongDescriptionEditorScreen extends StatefulWidget {
  const LongDescriptionEditorScreen({
    required this.projectTitle,
    this.onSave,
    this.initialJson,
    this.readOnly = false,
    super.key,
  });

  final String projectTitle;
  final String? initialJson;
  final bool readOnly;
  final Future<bool> Function(String json)? onSave;

  @override
  State<LongDescriptionEditorScreen> createState() => _LongDescriptionEditorScreenState();
}

class _LongDescriptionEditorScreenState extends State<LongDescriptionEditorScreen> {
  late final QuillController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuillController(
      document: _loadInitialDocument(widget.initialJson),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Document _loadInitialDocument(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) {
      return Document();
    }
    try {
      final data = json.decode(jsonStr);
      return Document.fromJson(data as List<dynamic>);
    } catch (_) {
      // Fallback: treat as plain text if not valid JSON
      return Document()..insert(0, jsonStr);
    }
  }

  Future<void> _save() async {
    if (widget.onSave == null) {
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }
    final jsonStr = jsonEncode(_controller.document.toDelta().toJson());
    final ok = await widget.onSave!(jsonStr);
    if (!mounted) return;
    if (ok) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deskripsi Lengkap • ${widget.projectTitle}'),
        actions: [
          if (!widget.readOnly && widget.onSave != null)
            IconButton(
              tooltip: 'Simpan',
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
            ),
        ],
      ),
      body: Column(
        children: [
          if (!widget.readOnly) QuillSimpleToolbar(controller: _controller),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: widget.readOnly
                  ? AbsorbPointer(child: QuillEditor.basic(controller: _controller))
                  : QuillEditor.basic(controller: _controller),
            ),
          ),
        ],
      ),
    );
  }
}
