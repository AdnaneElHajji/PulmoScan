import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class V4 {
  V4._();

  // ── Color tokens ──────────────────────────────────────────────
  static const Color bg           = Color(0xFF0A0E1A);
  static const Color surface1     = Color(0xFF131A2A);
  static const Color surface2     = Color(0xFF1B2438);
  static const Color surface3     = Color(0xFF252E45);
  static const Color border       = Color(0x14FFFFFF);
  static const Color borderStrong = Color(0x23FFFFFF);
  static const Color ink          = Color(0xFFE5EEFB);
  static const Color inkSoft      = Color(0xFFA8B4CC);
  static const Color inkMuted     = Color(0xFF6E7B95);
  static const Color teal         = Color(0xFF34E5C5);
  static const Color tealDim      = Color(0xFF1AAA90);
  static const Color tealGlow     = Color(0x4734E5C5);
  static const Color coral        = Color(0xFFFF7361);
  static const Color amber        = Color(0xFFFFB547);
  static const Color blue         = Color(0xFF5A9BFF);
  static const Color violet       = Color(0xFFA78BFA);

  // ── PATH14 — per-pathology accent colors ─────────────────────
  static const List<Color> pathColors = [
    Color(0xFF5A9BFF), // 0  Atelectasis
    Color(0xFFFF7361), // 1  Cardiomegaly
    Color(0xFF34E5C5), // 2  Effusion
    Color(0xFFFFB547), // 3  Infiltration
    Color(0xFFA78BFA), // 4  Mass
    Color(0xFFF472B6), // 5  Nodule
    Color(0xFFFB7185), // 6  Pneumonia
    Color(0xFF22D3EE), // 7  Pneumothorax
    Color(0xFFFACC15), // 8  Consolidation
    Color(0xFF60A5FA), // 9  Edema
    Color(0xFF84CC16), // 10 Emphysema
    Color(0xFFF97316), // 11 Fibrosis
    Color(0xFFC084FC), // 12 Pleural_Thickening
    Color(0xFF2DD4BF), // 13 Hernia
  ];

  static const List<String> pathNames = [
    'Atelectasis', 'Cardiomegaly', 'Effusion', 'Infiltration', 'Mass',
    'Nodule', 'Pneumonia', 'Pneumothorax', 'Consolidation', 'Edema',
    'Emphysema', 'Fibrosis', 'Pleural_Thickening', 'Hernia',
  ];

  // ── Global theme ──────────────────────────────────────────────
  static ThemeData theme() {
    final base = ThemeData.dark();
    final geistTextTheme = GoogleFonts.interTextTheme(base.textTheme)
        .apply(bodyColor: ink, displayColor: ink);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      textTheme: geistTextTheme,
      colorScheme: const ColorScheme.dark(
        primary: teal,
        onPrimary: bg,
        surface: surface1,
        onSurface: ink,
        error: coral,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: inkSoft),
        titleTextStyle: GoogleFonts.inter(
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
      tabBarTheme: TabBarThemeData(
        labelColor: teal,
        unselectedLabelColor: inkMuted,
        indicatorColor: teal,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface2,
        contentTextStyle: GoogleFonts.inter(color: ink),
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
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: teal),
      textSelectionTheme: const TextSelectionThemeData(cursorColor: teal),
    );
  }

  // ── Input decoration ──────────────────────────────────────────
  static InputDecoration inputDec({
    String? hint,
    String? label,
    IconData? prefix,
    Widget? suffix,
  }) =>
      InputDecoration(
        hintText: hint,
        labelText: label,
        hintStyle: const TextStyle(color: inkMuted),
        labelStyle: GoogleFonts.jetBrainsMono(
          fontSize: 9,
          color: inkMuted,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: GoogleFonts.jetBrainsMono(
          fontSize: 9,
          color: teal,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        prefixIcon:
            prefix != null ? Icon(prefix, color: inkMuted, size: 20) : null,
        suffixIcon: suffix,
        filled: true,
        fillColor: surface1,
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
        disabledBackgroundColor: tealDim,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        shadowColor: Colors.transparent,
      ).copyWith(
        shadowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed) ||
              states.contains(WidgetState.disabled)) {
            return Colors.transparent;
          }
          return const Color(0x8C34E5C5);
        }),
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return 0;
          return 8;
        }),
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
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: bg,
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
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  // ── Chip ─────────────────────────────────────────────────────
  static Widget chip(String label, Color color, {bool filled = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: filled
                  ? Colors.transparent
                  : color.withValues(alpha: 0.35)),
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: filled ? bg : color,
            letterSpacing: 0.4,
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
  static final TextStyle monoLabel = GoogleFonts.jetBrainsMono(
    fontSize: 10,
    letterSpacing: 1.4,
    color: inkMuted,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle monoValue = GoogleFonts.jetBrainsMono(
    fontSize: 11,
    letterSpacing: 0.8,
    fontWeight: FontWeight.w600,
    color: inkSoft,
  );
}
