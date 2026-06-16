import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/patient.dart';
import '../models/result.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';
import '../services/segmentation_service.dart';
import '../theme/v4_theme.dart';
import '../services/pdf_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class ResultsScreen extends StatefulWidget {
  final int examId;
  final Patient patient;
  final String imagePath;

  const ResultsScreen({
    super.key,
    required this.examId,
    required this.patient,
    required this.imagePath,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  Result? _result;
  bool _loading = true;
  late final TabController _tab;
  List<MapEntry<String, double>> _scores = [];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final r = await DatabaseService().getResultatByExam(widget.examId);
      if (r != null) {
        setState(() {
          _result = r;
          _scores = _parseScores(r.details);
          _loading = false;
        });
        return;
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  List<MapEntry<String, double>> _parseScores(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return (decoded.entries
            .map((e) =>
                MapEntry(e.key.toString(), (e.value as num).toDouble()))
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value)));
      }
    } catch (_) {}
    return [];
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String get _initials {
    final parts = widget.patient.nom.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    final n = widget.patient.nom.trim();
    return n.substring(0, math.min(2, n.length)).toUpperCase();
  }

  void _copyReport() {
    final r = _result;
    if (r == null) return;
    final findings = _scores
        .where((e) => e.value > (AiService.classThresh[e.key] ?? 0.20))
        .map((e) => '  • ${e.key}: ${(e.value * 100).toStringAsFixed(1)}%')
        .join('\n');
    final lines = <String>[
      'RAPPORT — PulmoScan AI',
      '══════════════════════════════',
      'Patient : ${widget.patient.nom}',
      'Âge     : ${widget.patient.age} ans · ${widget.patient.genre}',
      'Date    : ${_fmt(r.dateAnalyse)}',
      '',
      'DIAGNOSTIC PRINCIPAL : ${r.diagnostic}',
      'Confiance            : ${r.confidence.toStringAsFixed(0)}%',
      'Sévérité             : ${V4.severityLabel(r.severite)}',
      '',
      if (findings.isNotEmpty) ...[
        'ANOMALIES DÉTECTÉES :',
        findings,
        '',
      ],
      'Modèle  : DenseNet121 · NIH ChestX-ray14',
      'Version : PulmoScan AI v1.0.0',
      '══════════════════════════════',
      'Aide au diagnostic uniquement. Toute décision doit être validée par un médecin.',
    ];
    Clipboard.setData(ClipboardData(text: lines.join('\n')));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rapport copié dans le presse-papier')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: V4.bg,
        body: Center(child: CircularProgressIndicator(color: V4.teal)),
      );
    }

    if (_result == null) {
      return Scaffold(
        backgroundColor: V4.bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: V4.inkSoft),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 56, color: V4.surface3),
                      SizedBox(height: 14),
                      Text(
                        'Résultat non disponible',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: V4.inkSoft),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final r = _result!;
    final sevColor = V4.severityColor(r.severite);
    final sevLabel = V4.severityLabel(r.severite);

    return Scaffold(
      backgroundColor: V4.bg,
      body: Column(
        children: [
          _Header(
            examId: r.examId,
            patient: widget.patient,
            result: r,
            sevColor: sevColor,
            sevLabel: sevLabel,
            initials: _initials,
            fmt: _fmt,
            tab: _tab,
            onBack: () => Navigator.pop(context),
            onShare: _copyReport,
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _ResultsTab(scores: _scores, result: r, imagePath: widget.imagePath),
                _RapportTab(
                  result: r,
                  patient: widget.patient,
                  scores: _scores,
                  sevColor: sevColor,
                  sevLabel: sevLabel,
                  fmt: _fmt,
                  onShare: _copyReport,
                  imagePath: widget.imagePath,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final int examId;
  final Patient patient;
  final Result result;
  final Color sevColor;
  final String sevLabel;
  final String initials;
  final String Function(DateTime) fmt;
  final TabController tab;
  final VoidCallback onBack;
  final VoidCallback onShare;

  const _Header({
    required this.examId,
    required this.patient,
    required this.result,
    required this.sevColor,
    required this.sevLabel,
    required this.initials,
    required this.fmt,
    required this.tab,
    required this.onBack,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: V4.surface1,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nav row
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: V4.inkSoft),
                    onPressed: onBack,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(8),
                  ),
                  Expanded(
                    child: Text(
                      'EX-${examId.toString().padLeft(5, '0')}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        letterSpacing: 1.2,
                        color: V4.inkMuted,
                      ),
                    ),
                  ),
                  V4.chip(sevLabel, sevColor),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onShare,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: V4.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: V4.border),
                      ),
                      child: const Icon(Icons.ios_share_rounded,
                          size: 15, color: V4.inkMuted),
                    ),
                  ),
                ],
              ),
            ),

            // Patient + confidence row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar initials
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: sevColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(13),
                      border:
                          Border.all(color: sevColor.withValues(alpha: 0.35)),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: sevColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.nom,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: V4.ink,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${patient.age} ans · ${patient.genre} · ${fmt(result.dateAnalyse)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: V4.inkMuted,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Confidence
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${result.confidence.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: sevColor,
                          letterSpacing: -1,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const Text(
                        'confiance',
                        style: TextStyle(fontSize: 10, color: V4.inkMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab bar
            TabBar(
              controller: tab,
              tabs: const [
                Tab(text: 'Résultats IA'),
                Tab(text: 'Rapport'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Results Tab
// ─────────────────────────────────────────────────────────────────────────────
class _ResultsTab extends StatefulWidget {
  final List<MapEntry<String, double>> scores;
  final Result result;
  final String imagePath;

  const _ResultsTab({
    required this.scores,
    required this.result,
    required this.imagePath,
  });

  @override
  State<_ResultsTab> createState() => _ResultsTabState();
}

class _ResultsTabState extends State<_ResultsTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  SegmentationResult? _segResult;
  bool _segLoading = true;
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
    _runSegmentation();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _runSegmentation() async {
    if (widget.imagePath.isEmpty) {
      if (mounted) setState(() => _segLoading = false);
      return;
    }
    try {
      final r = await SegmentationService().segment(widget.imagePath);
      if (mounted) {
        setState(() {
          _segResult = r;
          _segLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _segLoading = false);
    }
  }

  Color _color(String name) {
    final i = V4.pathNames.indexOf(name);
    return (i >= 0 && i < V4.pathColors.length) ? V4.pathColors[i] : V4.teal;
  }

  // Staggered eased value per bar index
  double _barVal(int index, double t) {
    final n = widget.scores.length;
    final start = (index / n) * 0.45;
    final end = (start + 0.55).clamp(0.0, 1.0);
    if (t <= start) return 0.0;
    if (t >= end) return 1.0;
    return Curves.easeOut.transform((t - start) / (end - start));
  }

  Widget _buildXRay() {
    final hasSeg = _segResult != null;
    final showingOverlay = hasSeg && _showOverlay;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 200,
        color: const Color(0xFF060810),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image : overlay U-Net si dispo et activé, sinon radio brute
            if (showingOverlay)
              Image.memory(
                _segResult!.overlayBytes,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              )
            else if (widget.imagePath.isNotEmpty)
              Image.file(
                File(widget.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _XRayPlaceholder(),
              )
            else
              const _XRayPlaceholder(),

            // Indicateur de chargement de la segmentation
            if (_segLoading)
              const Positioned(
                top: 10,
                left: 10,
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: V4.teal,
                  ),
                ),
              ),

            // Badge couverture pulmonaire (haut droite)
            if (hasSeg)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: V4.teal.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'POUMONS ${_segResult!.lungCoveragePercent.toStringAsFixed(1)}%',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

            // Bouton bascule overlay (bas droite)
            if (hasSeg)
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _showOverlay = !_showOverlay),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: V4.teal.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          showingOverlay
                              ? Icons.layers
                              : Icons.layers_outlined,
                          size: 13,
                          color: V4.teal,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          showingOverlay
                              ? 'Segmentation'
                              : 'Radio brute',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Bandeau bas
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.72),
                    ],
                  ),
                ),
                child: Text(
                  showingOverlay
                      ? 'SEGMENTATION U-NET · POUMONS DÉTECTÉS'
                      : 'RADIOGRAPHIE · DENSENET121 · NIH CHESTX-RAY14',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 8,
                    letterSpacing: 1.0,
                    color: V4.inkMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.scores.isEmpty) {
      return const Center(
        child: Text('Aucune donnée disponible',
            style: TextStyle(color: V4.inkMuted, fontSize: 14)),
      );
    }

    final top = widget.scores.first;
    final topColor = _color(top.key);
    final confNorm = widget.result.confidence / 100;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      children: [
        // ── X-ray with pathology overlays ─────────────────────
        _buildXRay(),
        const SizedBox(height: 16),
        // ── Primary diagnosis hero card ───────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                topColor.withValues(alpha: 0.18),
                topColor.withValues(alpha: 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: topColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              // Left: label + name + model
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DIAGNOSTIC PRINCIPAL',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.6,
                        color: V4.inkMuted,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      top.key,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: topColor,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'DenseNet121 · NIH ChestX-ray14',
                      style: TextStyle(
                        fontSize: 10,
                        color: V4.inkMuted,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Right: arc gauge
              AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => _ArcGauge(
                  size: 90,
                  progress: confNorm * _ctrl.value,
                  color: topColor,
                  label:
                      '${(widget.result.confidence * _ctrl.value).toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── All 14 pathologies ────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          decoration: BoxDecoration(
            color: V4.surface1,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: V4.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PROBABILITÉS · 14 PATHOLOGIES',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.6,
                  color: V4.inkMuted,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) {
                  final t = _ctrl.value;
                  return Column(
                    children: widget.scores.asMap().entries.map((entry) {
                      final i = entry.key;
                      final e = entry.value;
                      final c = _color(e.key);
                      // Only highlight if score is meaningfully elevated (>15%)
                      final isAlert = e.value > 0.15;
                      final v = _barVal(i, t);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                      color: c, shape: BoxShape.circle),
                                ),
                                Expanded(
                                  child: Text(
                                    e.key,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isAlert
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isAlert ? V4.ink : V4.inkSoft,
                                    ),
                                  ),
                                ),
                                if (isAlert)
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: c.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '!',
                                      style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          color: c),
                                    ),
                                  ),
                                Text(
                                  '${(e.value * 100 * v).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: c,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: e.value * v,
                                minHeight: 4,
                                backgroundColor: V4.surface3,
                                valueColor: AlwaysStoppedAnimation(c),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// X-ray placeholder
// ─────────────────────────────────────────────────────────────────────────────
class _XRayPlaceholder extends StatelessWidget {
  const _XRayPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF060810),
      child: const Center(
        child: Icon(Icons.image_search_rounded, size: 48, color: V4.surface3),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Arc Gauge
// ─────────────────────────────────────────────────────────────────────────────
class _ArcGauge extends StatelessWidget {
  final double size;
  final double progress; // 0–1
  final Color color;
  final String label;

  const _ArcGauge({
    required this.size,
    required this.progress,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ArcPainter(
            progress: progress.clamp(0.0, 1.0), color: color),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: size * 0.21,
              fontWeight: FontWeight.w800,
              color: color,
              fontFamily: 'monospace',
              letterSpacing: -1,
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _ArcPainter({required this.progress, required this.color});

  static const double _start = math.pi * 0.75; // 135° — bottom-left
  static const double _sweep = math.pi * 1.5;  // 270° arc

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 9;

    final track = Paint()
      ..color = const Color(0xFF1F2940)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, _start, _sweep, false, track);
    if (progress > 0.01) {
      canvas.drawArc(rect, _start, _sweep * progress, false, fill);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Rapport Tab
// ─────────────────────────────────────────────────────────────────────────────
class _RapportTab extends StatefulWidget {
  final Result result;
  final Patient patient;
  final List<MapEntry<String, double>> scores;
  final Color sevColor;
  final String sevLabel;
  final String Function(DateTime) fmt;
  final VoidCallback onShare;
  final String imagePath;

  const _RapportTab({
    required this.result,
    required this.patient,
    required this.scores,
    required this.sevColor,
    required this.sevLabel,
    required this.fmt,
    required this.onShare,
    required this.imagePath,
  });

  @override
  State<_RapportTab> createState() => _RapportTabState();
}

class _RapportTabState extends State<_RapportTab> {
  bool _exporting = false;

  Future<void> _exportPdf() async {
    setState(() => _exporting = true);
    try {
      await PdfService.exportAndShare(
        patient: widget.patient,
        result: widget.result,
        scores: widget.scores,
        imagePath: widget.imagePath,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur PDF : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  List<String> get _recs {
    final s = widget.result.severite;
    if (s == 'severe' || s == 'urgent') {
      return [
        'Consultation médicale urgente recommandée',
        'Bilan biologique complet à réaliser',
        'Contrôle radiologique dans 48–72 h',
        'Antibiothérapie à envisager selon la clinique',
      ];
    }
    if (s == 'modere' || s == 'moyen') {
      return [
        'Suivi médical recommandé',
        'Contrôle radiologique dans 4 semaines',
        'Surveillance des symptômes respiratoires',
      ];
    }
    return [
      "Pas d'anomalie significative détectée",
      'Contrôle annuel recommandé',
      'Maintenir un mode de vie sain',
    ];
  }

  IconData get _bannerIcon {
    final s = widget.result.severite;
    if (s == 'severe' || s == 'urgent') return Icons.warning_amber_rounded;
    if (s == 'modere' || s == 'moyen') return Icons.info_outline_rounded;
    return Icons.check_circle_outline_rounded;
  }

  String get _bannerText {
    final s = widget.result.severite;
    if (s == 'severe' || s == 'urgent') {
      return 'Consultation médicale urgente recommandée';
    }
    if (s == 'modere' || s == 'moyen') {
      return 'Suivi médical recommandé dans les prochaines semaines';
    }
    return "Pas d'anomalie significative détectée";
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(label,
                style:
                    const TextStyle(fontSize: 12, color: V4.inkMuted)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: V4.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: V4.surface1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: V4.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              letterSpacing: 1.6,
              color: V4.teal,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alerts = widget.scores
        .where((e) => e.value > (AiService.classThresh[e.key] ?? 0.20))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      children: [
        // Status banner
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: widget.sevColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.sevColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(_bannerIcon, color: widget.sevColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _bannerText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: widget.sevColor,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Info
        _card(
          title: 'INFORMATIONS',
          children: [
            _row('Patient', widget.patient.nom),
            _row('Âge / Genre',
                '${widget.patient.age} ans · ${widget.patient.genre}'),
            _row('Date', widget.fmt(widget.result.dateAnalyse)),
            _row('Diagnostic', widget.result.diagnostic),
            _row('Confiance',
                '${widget.result.confidence.toStringAsFixed(0)}%'),
            _row('Modèle', 'DenseNet121 · NIH ChestX-ray14'),
          ],
        ),
        const SizedBox(height: 12),

        // Anomalies (conditional)
        if (alerts.isNotEmpty) ...[
          _card(
            title: 'ANOMALIES DÉTECTÉES',
            children: alerts
                .map((e) => _row(
                    e.key,
                    '${(e.value * 100).toStringAsFixed(1)}%'))
                .toList(),
          ),
          const SizedBox(height: 12),
        ],

        // Recommendations
        _card(
          title: 'RECOMMANDATIONS',
          children: _recs
              .map((rec) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 15, color: widget.sevColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            rec,
                            style: const TextStyle(
                                fontSize: 13,
                                color: V4.inkSoft,
                                height: 1.45),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),

        // Disclaimer
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: V4.surface1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: V4.border),
          ),
          child: const Text(
            "Ce rapport est généré automatiquement à des fins d'aide au diagnostic. Il ne remplace pas l'avis d'un médecin spécialiste qualifié.",
            style:
                TextStyle(fontSize: 11, color: V4.inkMuted, height: 1.55),
          ),
        ),
        const SizedBox(height: 20),

        // Copy report
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: widget.onShare,
            icon: const Icon(Icons.copy_rounded, size: 15),
            label: const Text('Copier le rapport'),
            style: OutlinedButton.styleFrom(
              foregroundColor: V4.teal,
              side: const BorderSide(color: V4.teal),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Export PDF
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _exporting ? null : _exportPdf,
            icon: _exporting
                ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.picture_as_pdf_rounded, size: 15),
            label: Text(_exporting ? 'Génération…' : 'Exporter PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: V4.teal,
              foregroundColor: V4.bg,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
