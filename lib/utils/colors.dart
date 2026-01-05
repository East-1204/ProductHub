import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryDark = Color(0xFF059669);
  
  // Accent Colors
  static const Color accent = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  
  // Neutral Colors
  static const Color dark = Color(0xFF111827);
  static const Color darkGrey = Color(0xFF374151);
  static const Color grey = Color(0xFF6B7280);
  static const Color lightGrey = Color(0xFF9CA3AF);
  static const Color lighterGrey = Color(0xFFE5E7EB);
  static const Color lightestGrey = Color(0xFFF3F4F6);
  static const Color white = Color(0xFFFFFFFF);
  
  // Background Colors
  static const Color bgLight = Color(0xFFF9FAFB);
  static const Color bgDark = Color(0xFF1F2937);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
  );
}