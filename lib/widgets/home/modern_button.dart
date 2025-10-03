import 'package:flutter/material.dart';
import 'home_constants.dart';

// Modern Button Component
class ModernButton extends StatelessWidget {
  const ModernButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isLight = false,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool isLight;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      style: FilledButton.styleFrom(
        backgroundColor: isLight ? Colors.white : HomeConstants.accentOrange,
        foregroundColor: isLight ? HomeConstants.accentOrange : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    );
  }
}