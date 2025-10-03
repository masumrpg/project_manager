import 'package:flutter/material.dart';

class HoverExpandableFab extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const HoverExpandableFab({
    super.key,
    this.onPressed,
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<HoverExpandableFab> createState() => _HoverExpandableFabState();
}

class _HoverExpandableFabState extends State<HoverExpandableFab> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: FloatingActionButton.extended(
        onPressed: widget.onPressed,
        icon: Icon(widget.icon),
        label: Text(widget.label),
        isExtended: _isHovered,
        backgroundColor: widget.backgroundColor,
        foregroundColor: widget.foregroundColor,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        heroTag: null, // Avoid hero tag conflicts
      ),
    );
  }
}
