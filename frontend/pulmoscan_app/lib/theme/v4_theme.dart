import 'package:flutter/material.dart';

class V4 {
  // Background / surface tokens
  static const Color bg = Color(0xFF0A0E1A);
  static const Color surface1 = Color(0xFF111827);
  static const Color surface2 = Color(0xFF1A2233);
  static const Color surface3 = Color(0xFF1E2A3B);
  static const Color border = Color(0xFF1E2D45);
  static const Color borderLight = Color(0xFF2A3F5F);

  // Text tokens
  static const Color ink = Color(0xFFE8F1FF);
  static const Color inkSoft = Color(0xFFB0C4DE);
  static const Color inkMuted = Color(0xFF6B8AB0);

  // Accent colors
  static const Color teal = Color(0xFF34E5C5);
  static const Color coral = Color(0xFFFF6B6B);
  static const Color amber = Color(0xFFFFB347);
  static const Color blue = Color(0xFF4A90E2);
  static const Color violet = Color(0xFF9B59B6);

  // Severity
  static Color severityColor(String s) {
    switch (s) {
      case 'urgent':
        return coral;
      case 'moyen':
        return amber;
      default:
        return teal;
    }
  }

  static String severityLabel(String s) {
    switch (s) {
      case 'urgent':
        return 'Priorité élevée';
      case 'moyen':
        return 'À surveiller';
      default:
        return 'Normal';
    }
  }

  // 14 pathology colors matching label order
  static const List<Color> pathColors = [
    Color(0xFF34E5C5), // Atelectasis
    Color(0xFF4A90E2), // Cardiomegaly
    Color(0xFF9B59B6), // Effusion
    Color(0xFFFFB347), // Infiltration
    Color(0xFFFF6B6B), // Mass
    Color(0xFF2ECC71), // Nodule
    Color(0xFFE74C3C), // Pneumonia
    Color(0xFFF39C12), // Pneumothorax
    Color(0xFF1ABC9C), // Consolidation
    Color(0xFF3498DB), // Edema
    Color(0xFF8E44AD), // Emphysema
    Color(0xFF27AE60), // Fibrosis
    Color(0xFF16A085), // Pleural_Thickening
    Color(0xFFD35400), // Hernia
  ];

  static ThemeData theme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      primaryColor: teal,
      colorScheme: const ColorScheme.dark(
        primary: teal,
        secondary: blue,
        surface: surface1,
        error: coral,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface1,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: inkSoft),
      ),
      cardTheme: CardThemeData(
        color: surface1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border),
        ),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: teal,
          foregroundColor: bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: teal, width: 2),
        ),
        hintStyle: const TextStyle(color: inkMuted),
        labelStyle: const TextStyle(color: inkSoft),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: ink),
        bodyMedium: TextStyle(color: inkSoft),
        bodySmall: TextStyle(color: inkMuted),
        titleLarge: TextStyle(color: ink, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: ink, fontWeight: FontWeight.w600),
      ),
      dividerColor: border,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: teal,
        foregroundColor: bg,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? teal : Colors.transparent,
        ),
        side: const BorderSide(color: inkMuted),
      ),
    );
  }
}
