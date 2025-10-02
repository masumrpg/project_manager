import 'package:flutter/material.dart';
import '../../models/enums/app_category.dart';

class HomeConstants {
  // Modern warm color palette inspired by the reference
  static const Color primaryBeige = Color(0xFFF5E6D3);
  static const Color secondaryBeige = Color(0xFFE8D5C4);
  static const Color accentOrange = Color(0xFFE07A5F);
  static const Color darkText = Color(0xFF2D3436);
  static const Color lightText = Color(0xFF636E72);
  static const Color cardBackground = Color(0xFFFFFBF7);
  static const Color shadowColor = Color(0x1A2D3436);

  static const Map<AppCategory, Color> categoryColors = {
    AppCategory.web: Color(0xFF6C7B95),
    AppCategory.mobile: Color(0xFF7FB069),
    AppCategory.desktop: Color(0xFF81B3BA),
    AppCategory.api: Color(0xFFB08BBB),
    AppCategory.other: Color(0xFF95A3A4),
  };

  static const Map<AppCategory, IconData> categoryIcons = {
    AppCategory.web: Icons.web_asset,
    AppCategory.mobile: Icons.smartphone,
    AppCategory.desktop: Icons.desktop_windows,
    AppCategory.api: Icons.api,
    AppCategory.other: Icons.folder_outlined,
  };

  static Color categoryColor(AppCategory category, BuildContext context) {
    return categoryColors[category] ?? accentOrange;
  }
}
