import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../models/enums/revision_status.dart';
import '../../../models/revision.dart';

class RevisionFormSheet extends StatefulWidget {
  const RevisionFormSheet({
    required this.uuid,
    required this.onCreate,
    required this.onUpdate,
    this.revision,
    super.key,
  });

  final Uuid uuid;
  final Revision? revision;
  final Future<bool> Function(Revision) onCreate;
  final Future<bool> Function(Revision) onUpdate;

  @override
  State<RevisionFormSheet> createState() => _RevisionFormSheetState();
}

class _RevisionFormSheetState extends State<RevisionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _versionController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _changeLogController;
  late RevisionStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _versionController = TextEditingController(text: widget.revision?.version ?? '');
    _descriptionController = TextEditingController(text: widget.revision?.description ?? '');
    _changeLogController = TextEditingController(text: widget.revision?.changes ?? '');
    _selectedStatus = widget.revision?.status ?? RevisionStatus.draft;
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFBF7),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF636E72).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Revision',
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
                    labelText: 'Version',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE8D5C4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 2),
                    ),
                    fillColor: const Color(0xFFF5E6D3).withValues(alpha: 0.3),
                    filled: true,
                    labelStyle: const TextStyle(color: Color(0xFF636E72)),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Version is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE8D5C4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 2),
                    ),
                    fillColor: const Color(0xFFF5E6D3).withValues(alpha: 0.3),
                    filled: true,
                    labelStyle: const TextStyle(color: Color(0xFF636E72)),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _changeLogController,
                  decoration: InputDecoration(
                    labelText: 'Changes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE8D5C4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 2),
                    ),
                    fillColor: const Color(0xFFF5E6D3).withValues(alpha: 0.3),
                    filled: true,
                    labelStyle: const TextStyle(color: Color(0xFF636E72)),
                  ),
                  minLines: 4,
                  maxLines: 8,
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Changes is required' : null,
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonFormField<RevisionStatus>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        final navigator = Navigator.of(context);
                        final didSucceed = widget.revision == null
                            ? await widget.onCreate(
                                Revision(
                                  id: widget.uuid.v4(),
                                  version: _versionController.text.trim(),
                                  description: _descriptionController.text.trim(),
                                  changes: _changeLogController.text.trim(),
                                  status: _selectedStatus,
                                  createdAt: DateTime.now(),
                                ),
                              )
                            : await widget.onUpdate(
                                widget.revision!
                                  ..version = _versionController.text.trim()
                                  ..description = _descriptionController.text.trim()
                                  ..changes = _changeLogController.text.trim()
                                  ..status = _selectedStatus,
                              );
                        if (!mounted) return;
                        navigator.pop(didSucceed);
                      },
                      child: Text(widget.revision == null ? 'Create' : 'Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
