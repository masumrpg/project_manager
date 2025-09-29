import 'package:flutter/material.dart';
import '../../models/project.dart';
import 'project_card.dart';

// Desktop Project Grid
class DesktopProjectGrid extends StatelessWidget {
  const DesktopProjectGrid({
    super.key,
    required this.projects,
    required this.onProjectTap,
    required this.onEditProject,
    required this.onDeleteProject,
  });

  final List<Project> projects;
  final Function(Project) onProjectTap;
  final Function(Project) onEditProject;
  final Function(Project) onDeleteProject;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.2,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return ModernProjectCard(
          project: project,
          onTap: () => onProjectTap(project),
          onEdit: () => onEditProject(project),
          onDelete: () => onDeleteProject(project),
        );
      },
    );
  }
}

// Mobile Project List
class MobileProjectList extends StatelessWidget {
  const MobileProjectList({
    super.key,
    required this.projects,
    required this.onProjectTap,
    required this.onEditProject,
    required this.onDeleteProject,
  });

  final List<Project> projects;
  final Function(Project) onProjectTap;
  final Function(Project) onEditProject;
  final Function(Project) onDeleteProject;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projects.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final project = projects[index];
        return ModernProjectCard(
          project: project,
          onTap: () => onProjectTap(project),
          onEdit: () => onEditProject(project),
          onDelete: () => onDeleteProject(project),
        );
      },
    );
  }
}