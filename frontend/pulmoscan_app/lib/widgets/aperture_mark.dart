import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/v4_theme.dart';

/// Animated aperture that lights up segments progressively.
class AnimatedApertureMark extends StatefulWidget {
  final double size;
  final List<int> targetActive;
  final Duration duration;

  const AnimatedApertureMark({
    super.key,
    required this.size,
    this.targetActive = const [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
    this.duration = const Duration(milliseconds: 2400),
  });

  @override
  State<AnimatedApertureMark> createState() => _AnimatedApertureMarkState();
}

class _AnimatedApertureMarkState extends State<AnimatedApertureMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  List<int> _lit = [];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _ctrl.addListener(_onTick);
    _ctrl.forward();
  }

  void _onTick() {
    final count =
        (_ctrl.value * widget.targetActive.length).floor()
            .clamp(0, widget.targetActive.length);
    if (count != _lit.length) {
      setState(() => _lit = widget.targetActive.sublist(0, count));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ApertureMark(size: widget.size, active: _lit);
}

/// 14-segment aperture ring — one arc per NIH pathology class.
class ApertureMark extends StatelessWidget {
  final double size;
  final List<int> active;

  const ApertureMark({
    super.key,
    required this.size,
    this.active = const [],
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _AperturePainter(active: active)),
    );
  }
}

class _AperturePainter extends CustomPainter {
  final List<int> active;
  const _AperturePainter({required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final ro = size.width / 2;
    final ri = ro * 0.62;
    const n = 14;
    const sweep = 360.0 / n;
    const gap = 3.5;
    const arc = sweep - gap;
    const startOffset = -90.0;

    final fill = Paint()..style = PaintingStyle.fill;
    final glow = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    for (int i = 0; i < n; i++) {
      final start = (startOffset + i * sweep + gap / 2) * pi / 180;
      final arcRad = arc * pi / 180;
      final isOn = active.contains(i);

      if (isOn) {
        glow.color = V4.pathColors[i].withValues(alpha: 0.25);
        _seg(canvas, glow, c, ro + 3, ri - 2, start, arcRad);
      }

      fill.color = isOn ? V4.pathColors[i] : V4.surface3;
      _seg(canvas, fill, c, ro, ri, start, arcRad);
    }
  }

  void _seg(Canvas cv, Paint p, Offset c, double ro, double ri,
      double start, double arcSweep) {
    final path = Path()
      ..arcTo(Rect.fromCircle(center: c, radius: ro), start, arcSweep, false)
      ..arcTo(
          Rect.fromCircle(center: c, radius: ri), start + arcSweep, -arcSweep, false)
      ..close();
    cv.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_AperturePainter old) =>
      old.active.length != active.length;
}

/// Wordmark: Pulmo + Scan (dimmed) + AI pill
class Wordmark extends StatelessWidget {
  final double size;
  const Wordmark({super.key, this.size = 26});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Pulmo',
          style: GoogleFonts.inter(
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: V4.ink,
            letterSpacing: -0.5,
            height: 1.0,
          ),
        ),
        Text(
          'Scan',
          style: GoogleFonts.inter(
            fontSize: size,
            fontWeight: FontWeight.w500,
            color: V4.ink.withValues(alpha: 0.55),
            letterSpacing: -0.5,
            height: 1.0,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: size * 0.22, vertical: size * 0.08),
          decoration: BoxDecoration(
            color: V4.teal,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'AI',
            style: GoogleFonts.jetBrainsMono(
              fontSize: size * 0.46,
              fontWeight: FontWeight.w600,
              color: V4.bg,
              letterSpacing: 0.5,
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}

/// Subtle grid-line background used in Splash / Login.
class GridBackground extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant GridBackground _) => false;
}
