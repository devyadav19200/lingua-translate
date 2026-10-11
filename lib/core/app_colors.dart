import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primary = Color(0xFF4F46E5);       // Indigo-600
  static const Color primaryLight = Color(0xFF6366F1);  // Indigo-500
  static const Color primaryDark = Color(0xFF3730A3);   // Indigo-800
  static const Color primarySoft = Color(0xFFEEF2FF);   // Indigo-50

  // Secondary / Accent
  static const Color secondary = Color(0xFF7C3AED);     // Violet-600
  static const Color secondaryLight = Color(0xFF8B5CF6);// Violet-500
  static const Color accent = Color(0xFF06B6D4);        // Cyan-500

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
  );

  static const LinearGradient micGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );

  // Light Theme
  static const Color backgroundLight = Color(0xFFF8F9FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLight2 = Color(0xFFF1F5F9);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textSecondaryDark = Color(0xFF64748B);
  static const Color dividerLight = Color(0xFFE2E8F0);

  // Dark Theme
  static const Color backgroundDark = Color(0xFF0F0F23);
  static const Color surfaceDark = Color(0xFF1A1B2E);
  static const Color surfaceDark2 = Color(0xFF16213E);
  static const Color textLight = Color(0xFFF1F5F9);
  static const Color textSecondaryLight = Color(0xFF94A3B8);
  static const Color dividerDark = Color(0xFF1E293B);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Mic Active
  static const Color micActive = Color(0xFFEF4444);
  static const Color micActiveGlow = Color(0x33EF4444);

  // Favorites
  static const Color favorite = Color(0xFFF59E0B);
}
