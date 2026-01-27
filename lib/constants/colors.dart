import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF1E1E2C);
  static const Color secondaryColor = Color(0xFF2A2A3C);
  static const Color accentColor = Color(0xFFFF6B35);
  static const Color backgroundColor = Color(0xFF151521);
  static const Color cardColor = Color(0xFF252536);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B8);
  static const Color dividerColor = Color(0xFF3A3A4C);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF2A2A3C), Color(0xFF1E1E2C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
