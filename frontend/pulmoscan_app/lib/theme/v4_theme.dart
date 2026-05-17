import 'package:flutter/material.dart';

/// PulmoScan v4 design tokens — dark premium aesthetic
class V4 {
  V4._();

  static const Color bg = Color(0xFF0A0E1A);
  static const Color surface1 = Color(0xFF111827);
  static const Color surface2 = Color(0xFF182035);
  static const Color surface3 = Color(0xFF1F2940);
  static const Color border = Color(0x14FFFFFF);
  static const Color borderStrong = Color(0x24FFFFFF);
  static const Color ink = Color(0xFFE5EEFB);
  static const Color inkSoft = Color(0xFFA8B4CC);
  static const Color inkMuted = Color(0xFF6E7B95);
  static const Color teal = Color(0xFF34E5C5);
  static const Color coral = Color(0xFFFF7361);
  static const Color amber = Color(0xFFFFB547);
  static const Color blue = Color(0xFF5A9BFF);
  static const Color violet = Color(0xFFA78BFA);

  static const List<Color> pathColors = [
    Color(0xFFFF7361), // 0  Atelectasis
    Color(0xFFFF9F80), // 1  Cardiomegaly
    Color(0xFF5A9BFF), // 2  Effusion
    Color(0xFFFFB547), // 3  Infiltration
    Color(0xFFFF5C7A), // 4  Mass
    Color(0xFF34E5C5), // 5  Nodule
    Color(0xFFA78BFA), // 6  Pneumonia
    Color(0xFF34C5E5), // 7  Pneumothorax
    Color(0xFFFFD447), // 8  Consolidation
    Color(0xFF5ABFFF), // 9  Edema
    Color(0xFFFF9447), // 10 Emphysema
    Color(0xFFC47AFF), // 11 Fibrosis
    Color(0xFFFF7AB5), // 12 Pleural_Thickening
    Color(0xFFFF4444), // 13 Hernia
  ];

  static const List<String> pathNames = [
    'Atelectasis', 'Cardiomegaly', 'Effusion', 'Infiltration', 'Mass',
    'Nodule', 'Pneumonia', 'Pneumothorax', 'Consolidation', 'Edema',
    'Emphysema', 'Fibrosis', 'Pleural_Thickening', 'Hernia',
  ];

  // ── Global theme ──────────────────────────────────────────────
  static ThemeData theme() => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: teal,
          onPrimary: bg,
          surface: surface1,
          onSurface: ink,
          error: coral,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(color: inkSoft),
          titleTextStyle: TextStyle(
            color: ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        cardTheme: CardThemeData(
          color: surface1,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: border),
          ),
        ),
        dividerColor: border,
        tabBarTheme: const TabBarThemeData(
          labelColor: teal,
          unselectedLabelColor: inkMuted,
          indicatorColor: teal,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: TextStyle(fontSize: 13),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: surface2,
          contentTextStyle: TextStyle(color: ink),
          behavior: SnackBarBehavior.floating,
        ),
        popupMenuTheme: const PopupMenuThemeData(
          color: surface2,
          surfaceTintColor: Colors.transparent,
          textStyle: TextStyle(color: ink, fontSize: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: borderStrong),
          ),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: surface2,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          titleTextStyle: TextStyle(
            color: ink, fontSize: 18, fontWeight: FontWeight.w700,
          ),
          contentTextStyle: TextStyle(color: inkSoft, fontSize: 14),
        ),
        checkboxTheme: CheckboxThemeData(
          checkColor: WidgetStateProperty.all(bg),
          fillColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? teal : Colors.transparent),
          side: const BorderSide(color: borderStrong, width: 2),
        ),
        bottomAppBarTheme: const BottomAppBarThemeData(
          color: surface1,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: teal,
          foregroundColor: bg,
          elevation: 0,
          shape: CircleBorder(),
        ),
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: teal),
        textSelectionTheme:
            const TextSelectionThemeData(cursorColor: teal),
      );

  // ── Input decoration ──────────────────────────────────────────
  static InputDecoration inputDec({
    String? hint,
    IconData? prefix,
    Widget? suffix,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: inkMuted),
        prefixIcon:
            prefix != null ? Icon(prefix, color: inkMuted, size: 20) : null,
        suffixIcon: suffix,
        filled: true,
        fillColor: surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: teal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: coral),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: coral, width: 2),
        ),
        errorStyle: const TextStyle(color: coral, fontSize: 12),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  // ── Primary button ────────────────────────────────────────────
  static Widget primaryBtn({
    required String label,
    required VoidCallback? onTap,
    bool loading = false,
    bool fullWidth = true,
  }) {
    final btn = ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: teal,
        foregroundColor: bg,
        disabledBackgroundColor: const Color(0xFF1D5C52),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Color(0xFF0A0E1A)),
            )
          : Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A0E1A),
                letterSpacing: -0.2,
              ),
            ),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }

  // ── Ghost / outlined button ───────────────────────────────────
  static Widget ghostBtn({
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) =>
      OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color ?? ink,
          side: BorderSide(
              color: color?.withValues(alpha: 0.45) ?? borderStrong),
          padding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600)),
      );

  // ── Chip ─────────────────────────────────────────────────────
  static Widget chip(String label, Color color, {bool filled = false}) =>
      Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: filled
                  ? Colors.transparent
                  : color.withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: filled ? bg : color,
            letterSpacing: 0.2,
          ),
        ),
      );

  // ── Severity helpers ──────────────────────────────────────────
  static Color severityColor(String? s) {
    if (s == 'urgent' || s == 'severe') return coral;
    if (s == 'moyen' || s == 'modere') return amber;
    return teal;
  }

  static String severityLabel(String? s) {
    if (s == 'urgent' || s == 'severe') return 'Urgent';
    if (s == 'moyen' || s == 'modere') return 'À surveiller';
    return 'Normal';
  }

  // ── Shared text styles ────────────────────────────────────────
  static const TextStyle monoLabel = TextStyle(
    fontSize: 10,
    letterSpacing: 1.4,
    color: inkMuted,
    fontFamily: 'monospace',
  );
  static const TextStyle monoValue = TextStyle(
    fontSize: 11,
    letterSpacing: 0.8,
    fontFamily: 'monospace',
    fontWeight: FontWeight.w600,
    color: inkSoft,
  );
}
