
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/enums/app_category.dart';
import '../../../models/enums/environment.dart';
import '../../../models/project.dart';
import '../../../providers/project_provider.dart';
import '../../../screens/project_detail_screen.dart';

class ProjectEditSheet extends StatefulWidget {
  const ProjectEditSheet({
    required this.project,
    super.key,
  });

  final Project project;

  @override
  State<ProjectEditSheet> createState() => _ProjectEditSheetState();
}

class _ProjectEditSheetState extends State<ProjectEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late AppCategory _selectedCategory;
  late Environment _selectedEnvironment;
  bool _isLoading = false;
  double _borderRadius = 24.0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project.title);
    _descriptionController = TextEditingController(text: widget.project.description);
    _selectedCategory = widget.project.category;
    _selectedEnvironment = widget.project.environment;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final projectProvider = context.read<ProjectProvider>();
    final detailProvider = context.read<ProjectDetailProvider>();
    final navigator = Navigator.of(context);

    final updatedProject = widget.project
      ..title = _titleController.text.trim()
      ..description = _descriptionController.text.trim()
      ..category = _selectedCategory
      ..environment = _selectedEnvironment
      ..updatedAt = DateTime.now();

    final success = await projectProvider.updateProject(updatedProject);

    if (!mounted) return;

    if (success) {
      await detailProvider.loadProject(showLoading: false);
      navigator.pop(true); // Pop with success
    } else {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              projectProvider.error ?? 'Failed to update project',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          ),
        );
      }
    }
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
              color: const Color(0xFFFFFBF7), // cardBackground
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_borderRadius),
                topRight: Radius.circular(_borderRadius),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF636E72).withAlpha((255 * 0.3).round()), // lightText
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row(
                          children: [
                            const Text(
                              'Edit Project',
                              style: TextStyle(
                                color: Color(0xFF2D3436), // darkText
                                fontWeight: FontWeight.w600,
                                fontSize: 24,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                              icon: const Icon(Icons.close),
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFF5E6D3).withAlpha((255 * 0.3).round()), // primaryBeige
                                foregroundColor: const Color(0xFF636E72), // lightText
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Form
                      Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _titleController,
                                decoration: _buildInputDecoration(label: 'Title', isRequired: true),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Title is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _descriptionController,
                                decoration: _buildInputDecoration(label: 'Description'),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<AppCategory>(
                                initialValue: _selectedCategory,
                                decoration: _buildInputDecoration(label: 'Category'),
                                dropdownColor: const Color(0xFFFFFBF7), // cardBackground
                                borderRadius: BorderRadius.circular(16),
                                items: AppCategory.values
                                    .map((value) => DropdownMenuItem<AppCategory>(
                                          value: value,
                                          child: Text(value.label, style: const TextStyle(color: Color(0xFF2D3436))),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedCategory = value);
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<Environment>(
                                initialValue: _selectedEnvironment,
                                decoration: _buildInputDecoration(label: 'Environment'),
                                dropdownColor: const Color(0xFFFFFBF7), // cardBackground
                                borderRadius: BorderRadius.circular(16),
                                items: Environment.values
                                    .map((value) => DropdownMenuItem<Environment>(
                                          value: value,
                                          child: Text(value.label, style: const TextStyle(color: Color(0xFF2D3436))),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedEnvironment = value);
                                  }
                                },
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                      // Actions
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF636E72), // lightText
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: const BorderSide(color: Color(0xFFE8D5C4)), // secondaryBeige
                                  ),
                                ),
                                child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: _isLoading ? null : _submitForm,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFE07A5F), // accentOrange
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String label, bool isRequired = false}) {
    return InputDecoration(
      label: isRequired
          ? RichText(
              text: TextSpan(
                text: label,
                style: const TextStyle(color: Color(0xFF636E72)),
                children: const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
              ),
            )
          : Text(label),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE8D5C4)), // secondaryBeige
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE07A5F), width: 2), // accentOrange
      ),
      fillColor: const Color(0xFFF5E6D3).withAlpha((255 * 0.3).round()), // primaryBeige
      filled: true,
      labelStyle: const TextStyle(color: Color(0xFF636E72)), // lightText
    );
  }
}
