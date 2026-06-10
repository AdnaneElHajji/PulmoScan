import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/v4_theme.dart';

// ── ApertureMark ─────────────────────────────────────────────────────────────
// 14-segment aperture wheel representing the 14 NIH pathologies.
// [active] is the list of segment indices that are lit in teal.
class ApertureMark extends StatelessWidget {
  final double size;
  final List<int> active;

  const ApertureMark({super.key, required this.size, this.active = const []});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AperturePainter(active: active, progress: 1.0),
      ),
    );
  }
}

// ── AnimatedApertureMark ──────────────────────────────────────────────────────
// Animated version: segments light up progressively.
class AnimatedApertureMark extends StatefulWidget {
  final double size;
  final List<int> targetActive;
  final Duration duration;

  const AnimatedApertureMark({
    super.key,
    required this.size,
    required this.targetActive,
    required this.duration,
  });

  @override
  State<AnimatedApertureMark> createState() => _AnimatedApertureMarkState();
}

class _AnimatedApertureMarkState extends State<AnimatedApertureMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final count = (_anim.value * widget.targetActive.length).round();
        final visible = widget.targetActive.take(count).toList();
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _AperturePainter(active: visible, progress: _anim.value),
          ),
        );
      },
    );
  }
}

class _AperturePainter extends CustomPainter {
  final List<int> active;
  final double progress;
  static const int _segments = 14;

  const _AperturePainter({required this.active, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2;
    final innerR = outerR * 0.38;
    final segR = outerR * 0.72;
    final dotR = outerR * 0.10;

    final paintInactive = Paint()
      ..color = V4.surface3
      ..style = PaintingStyle.fill;

    final paintActive = Paint()
      ..color = V4.teal
      ..style = PaintingStyle.fill;

    final paintRing = Paint()
      ..color = V4.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Outer ring
    canvas.drawCircle(Offset(cx, cy), outerR - 1, paintRing);

    // Inner ring
    canvas.drawCircle(Offset(cx, cy), innerR,
        Paint()..color = V4.surface2..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx, cy), innerR, paintRing);

    // 14 segments
    for (int i = 0; i < _segments; i++) {
      final angle = (2 * math.pi / _segments) * i - math.pi / 2;
      final x = cx + segR * math.cos(angle);
      final y = cy + segR * math.sin(angle);
      final isActive = active.contains(i);
      canvas.drawCircle(
        Offset(x, y),
        dotR,
        isActive ? paintActive : paintInactive,
      );
      if (isActive) {
        canvas.drawCircle(
          Offset(x, y),
          dotR,
          Paint()
            ..color = V4.teal.withValues(alpha: 0.25)
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
      }
    }

    // Center dot
    canvas.drawCircle(
      Offset(cx, cy),
      innerR * 0.3,
      Paint()..color = V4.teal.withValues(alpha: 0.6)..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_AperturePainter old) =>
      old.active != active || old.progress != progress;
}

// ── Wordmark ──────────────────────────────────────────────────────────────────
class Wordmark extends StatelessWidget {
  final double size;
  const Wordmark({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Pulmo',
            style: GoogleFonts.inter(
              fontSize: size,
              fontWeight: FontWeight.w700,
              color: V4.ink,
              letterSpacing: -0.8,
            ),
          ),
          TextSpan(
            text: 'Scan',
            style: GoogleFonts.inter(
              fontSize: size,
              fontWeight: FontWeight.w700,
              color: V4.teal,
              letterSpacing: -0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ── GridBackground ────────────────────────────────────────────────────────────
class GridBackground extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x08FFFFFF)
      ..strokeWidth = 0.5;

    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(GridBackground old) => false;
}
