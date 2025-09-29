import 'package:flutter/material.dart';
import '../../models/project.dart';
import '../../models/enums/app_category.dart';
import 'home_constants.dart';

// Modern Project Card
class ModernProjectCard extends StatefulWidget {
  const ModernProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Project project;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<ModernProjectCard> createState() => _ModernProjectCardState();
}

class _ModernProjectCardState extends State<ModernProjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _categoryColor(widget.project.category);
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: isCompact ? 140 : 160,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      HomeConstants.cardBackground,
                      HomeConstants.cardBackground.withValues(alpha: 0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isHovered 
                        ? categoryColor.withValues(alpha: 0.3)
                        : HomeConstants.secondaryBeige,
                    width: _isHovered ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered 
                          ? categoryColor.withValues(alpha: 0.15)
                          : HomeConstants.shadowColor,
                      blurRadius: _isHovered ? 20 : 12,
                      offset: Offset(0, _isHovered ? 8 : 4),
                      spreadRadius: _isHovered ? 2 : 0,
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.8),
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Subtle gradient overlay
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                categoryColor.withValues(alpha: 0.05),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Main content
                      Padding(
                        padding: EdgeInsets.all(isCompact ? 16 : 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header with icon and menu
                            _buildHeader(categoryColor, isCompact),
                            
                            SizedBox(height: isCompact ? 12 : 16),
                            
                            // Content section
                            Flexible(
                              child: _buildContent(theme, isCompact),
                            ),
                            
                            SizedBox(height: isCompact ? 12 : 16),
                            
                            // Footer with category and date
                            _buildFooter(theme, categoryColor, isCompact),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Color categoryColor, bool isCompact) {
    return Row(
      children: [
        // Enhanced category icon with better styling
        Container(
          padding: EdgeInsets.all(isCompact ? 10 : 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                categoryColor.withValues(alpha: 0.15),
                categoryColor.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: categoryColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(
            HomeConstants.categoryIcons[widget.project.category] ?? Icons.folder_rounded,
            color: categoryColor,
            size: isCompact ? 20 : 24,
          ),
        ),
        const Spacer(),
        // Enhanced popup menu with better styling
        Container(
          decoration: BoxDecoration(
            color: HomeConstants.lightText.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: HomeConstants.lightText,
              size: isCompact ? 18 : 20,
            ),
            color: HomeConstants.cardBackground,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                widget.onEdit();
              } else if (value == 'delete') {
                widget.onDelete();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_rounded,
                      size: 18,
                      color: HomeConstants.darkText,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Edit',
                      style: TextStyle(
                        color: HomeConstants.darkText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_rounded,
                      size: 18,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme, bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Enhanced title with better typography
        Text(
          widget.project.title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: HomeConstants.darkText,
            fontWeight: FontWeight.w700,
            fontSize: isCompact ? 16 : 18,
            letterSpacing: -0.3,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isCompact ? 6 : 8),
        // Enhanced description with better readability
        Text(
          widget.project.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: HomeConstants.lightText,
            fontSize: isCompact ? 13 : 14,
            height: 1.4,
          ),
          maxLines: isCompact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme, Color categoryColor, bool isCompact) {
    return Row(
      children: [
        // Enhanced info chip with better styling
        Flexible(
          child: EnhancedInfoChip(
            label: widget.project.category.name.toUpperCase(),
            color: categoryColor,
            isCompact: isCompact,
          ),
        ),
        SizedBox(width: isCompact ? 8 : 12),
        // Enhanced date display
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule_rounded,
                size: isCompact ? 12 : 14,
                color: HomeConstants.lightText.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  formatDate(widget.project.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: HomeConstants.lightText,
                    fontSize: isCompact ? 11 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _categoryColor(AppCategory category) {
    return HomeConstants.categoryColors[category] ?? HomeConstants.accentOrange;
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }
}

// Enhanced Info Chip Component
class EnhancedInfoChip extends StatelessWidget {
  const EnhancedInfoChip({
    super.key,
    required this.label,
    required this.color,
    required this.isCompact,
  });

  final String label;
  final Color color;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: isCompact ? 9 : 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// Legacy Info Chip for backward compatibility
class InfoChip extends StatelessWidget {
  const InfoChip({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return EnhancedInfoChip(
      label: label,
      color: color,
      isCompact: false,
    );
  }
}