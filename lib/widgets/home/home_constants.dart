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
    AppCategory.personal: Color(0xFF81B3BA),
    AppCategory.work: Color(0xFF6C7B95),
    AppCategory.study: Color(0xFF8FA68E),
    AppCategory.health: Color(0xFFE07A5F),
    AppCategory.finance: Color(0xFFB08BBB),
    AppCategory.travel: Color(0xFF7FB069),
    AppCategory.shopping: Color(0xFFE9A46A),
    AppCategory.entertainment: Color(0xFF9A8194),
    AppCategory.family: Color(0xFF457B9D),
    AppCategory.other: Color(0xFF95A3A4),
  };

  static const Map<AppCategory, IconData> categoryIcons = {
    AppCategory.personal: Icons.person_rounded,
    AppCategory.work: Icons.work_outline,
    AppCategory.study: Icons.menu_book_outlined,
    AppCategory.health: Icons.monitor_heart_outlined,
    AppCategory.finance: Icons.ssid_chart_rounded,
    AppCategory.travel: Icons.flight_takeoff,
    AppCategory.shopping: Icons.shopping_bag_outlined,
    AppCategory.entertainment: Icons.movie_filter_outlined,
    AppCategory.family: Icons.family_restroom,
    AppCategory.other: Icons.folder_outlined,
  };

  static Color categoryColor(AppCategory category, BuildContext context) {
    return categoryColors[category] ?? accentOrange;
  }
}