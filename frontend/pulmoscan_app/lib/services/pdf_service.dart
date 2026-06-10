import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/patient.dart';
import '../models/result.dart';

// ── Color palette (mirrors V4 theme) ─────────────────────────────────────────
const _surface  = PdfColor(0.075, 0.102, 0.165);   // #131A2A
const _surface2 = PdfColor(0.106, 0.141, 0.220);   // #1B2438
const _teal     = PdfColor(0.204, 0.898, 0.773);   // #34E5C5
const _coral    = PdfColor(1.0,   0.451, 0.380);   // #FF7361
const _amber    = PdfColor(1.0,   0.710, 0.278);   // #FFB547
const _ink      = PdfColor(0.898, 0.933, 0.984);   // #E5EEFB
const _inkSoft  = PdfColor(0.659, 0.706, 0.800);   // #A8B4CC
const _inkMuted = PdfColor(0.431, 0.482, 0.584);   // #6E7B95

// Per-pathology accent colors (same order as V4.pathColors)
const _pathColors = <PdfColor>[
  PdfColor(0.353, 0.608, 1.000), // Atelectasis   #5A9BFF
  PdfColor(1.000, 0.451, 0.380), // Cardiomegaly  #FF7361
  PdfColor(0.204, 0.898, 0.773), // Effusion      #34E5C5
  PdfColor(1.000, 0.710, 0.278), // Infiltration  #FFB547
  PdfColor(0.655, 0.545, 0.980), // Mass          #A78BFA
  PdfColor(0.957, 0.447, 0.714), // Nodule        #F472B6
  PdfColor(0.984, 0.443, 0.522), // Pneumonia     #FB7185
  PdfColor(0.133, 0.827, 0.933), // Pneumothorax  #22D3EE
  PdfColor(0.980, 0.800, 0.082), // Consolidation #FACC15
  PdfColor(0.376, 0.647, 0.980), // Edema         #60A5FA
  PdfColor(0.518, 0.800, 0.086), // Emphysema     #84CC16
  PdfColor(0.976, 0.451, 0.086), // Fibrosis      #F97316
  PdfColor(0.753, 0.518, 0.988), // PleuralThick. #C084FC
  PdfColor(0.176, 0.831, 0.749), // Hernia        #2DD4BF
];

const _pathNames = [
  'Atelectasis', 'Cardiomegaly', 'Effusion', 'Infiltration', 'Mass',
  'Nodule', 'Pneumonia', 'Pneumothorax', 'Consolidation', 'Edema',
  'Emphysema', 'Fibrosis', 'Pleural_Thickening', 'Hernia',
];

PdfColor _pathColor(String name) {
  final i = _pathNames.indexOf(name);
  return (i >= 0 && i < _pathColors.length) ? _pathColors[i] : _teal;
}

PdfColor _severityColor(String? s) {
  if (s == 'urgent' || s == 'severe') return _coral;
  if (s == 'moyen'  || s == 'modere') return _amber;
  return _teal;
}

String _severityLabel(String? s) {
  if (s == 'urgent' || s == 'severe') return 'URGENT';
  if (s == 'moyen'  || s == 'modere') return 'À SURVEILLER';
  return 'NORMAL';
}

// ── Public API ────────────────────────────────────────────────────────────────

class PdfService {
  /// Generate and share a PDF report via the native share sheet.
  static Future<void> exportAndShare({
    required Patient patient,
    required Result result,
    required List<MapEntry<String, double>> scores,
    required String imagePath,
  }) async {
    final bytes = await _build(
      patient: patient,
      result: result,
      scores: scores,
      imagePath: imagePath,
    );

    final date = result.dateAnalyse;
    final filename =
        'PulmoScan_${patient.nom.replaceAll(' ', '_')}_'
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}.pdf';

    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  // ── PDF builder ─────────────────────────────────────────────────────────────
  static Future<Uint8List> _build({
    required Patient patient,
    required Result result,
    required List<MapEntry<String, double>> scores,
    required String imagePath,
  }) async {
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: await PdfGoogleFonts.interRegular(),
        bold: await PdfGoogleFonts.interBold(),
        italic: await PdfGoogleFonts.interItalic(),
      ),
    );

    // Load X-ray image if available
    pw.MemoryImage? xrayImage;
    if (imagePath.isNotEmpty) {
      try {
        final bytes = await File(imagePath).readAsBytes();
        xrayImage = pw.MemoryImage(bytes);
      } catch (_) {}
    }

    final sevColor = _severityColor(result.severite);
    final sevLabel = _severityLabel(result.severite);
    final alerts   = scores.where((e) => e.value > 0.5).toList();
    final recs     = _recommendations(result.severite);
    final topColor = scores.isNotEmpty ? _pathColor(scores.first.key) : _teal;
    final now      = result.dateAnalyse;
    final dateFmt  = '${now.day.toString().padLeft(2, '0')}/'
                     '${now.month.toString().padLeft(2, '0')}/'
                     '${now.year}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 36),
        build: (ctx) => [
          // ── Header ──────────────────────────────────────────────────────────
          _buildHeader(dateFmt),
          pw.SizedBox(height: 20),

          // ── Patient band ─────────────────────────────────────────────────────
          _buildPatientBand(patient, result, dateFmt, sevColor, sevLabel),
          pw.SizedBox(height: 18),

          // ── X-ray + primary diagnosis (side by side) ─────────────────────────
          _buildXrayAndDiag(xrayImage, result, topColor, sevColor, sevLabel),
          pw.SizedBox(height: 18),

          // ── 14 pathology bars ────────────────────────────────────────────────
          _buildAllScores(scores),
          pw.SizedBox(height: 18),

          // ── Alerts ───────────────────────────────────────────────────────────
          if (alerts.isNotEmpty) ...[
            _buildAlerts(alerts, sevColor),
            pw.SizedBox(height: 18),
          ],

          // ── Recommendations ──────────────────────────────────────────────────
          _buildRecommendations(recs, sevColor),
          pw.SizedBox(height: 18),

          // ── Disclaimer ───────────────────────────────────────────────────────
          _buildDisclaimer(),
        ],
      ),
    );

    return pdf.save();
  }

  // ── Sections ─────────────────────────────────────────────────────────────────

  static pw.Widget _buildHeader(String date) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
        border: pw.Border.all(color: _teal.shade(0.4), width: 1),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PulmoScan IA',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: _teal,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Rapport d\'analyse radiologique',
                style: pw.TextStyle(fontSize: 11, color: _inkSoft),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _monoText('GÉNÉRÉ LE', 8, _inkMuted),
              pw.SizedBox(height: 3),
              _monoText(date, 12, _inkSoft),
              pw.SizedBox(height: 3),
              _monoText('DenseNet121 · NIH ChestX-ray14', 8, _inkMuted),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPatientBand(
    Patient patient,
    Result result,
    String date,
    PdfColor sevColor,
    String sevLabel,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: pw.BoxDecoration(
        color: _surface2,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Row(
        children: [
          // Avatar circle with initials
          pw.Container(
            width: 48,
            height: 48,
            decoration: pw.BoxDecoration(
              color: sevColor.shade(0.2),
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                _initials(patient.nom),
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: sevColor,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  patient.nom,
                  style: pw.TextStyle(
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                    color: _ink,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  '${patient.age} ans · ${patient.genre} · Examen du $date',
                  style: pw.TextStyle(fontSize: 10, color: _inkMuted),
                ),
              ],
            ),
          ),
          // Severity badge
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: pw.BoxDecoration(
              color: sevColor.shade(0.15),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: sevColor.shade(0.5), width: 0.8),
            ),
            child: pw.Text(
              sevLabel,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: sevColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildXrayAndDiag(
    pw.MemoryImage? xrayImage,
    Result result,
    PdfColor topColor,
    PdfColor sevColor,
    String sevLabel,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // X-ray image box
        pw.Expanded(
          flex: 5,
          child: pw.Container(
            height: 180,
            decoration: pw.BoxDecoration(
              color: const PdfColor(0.02, 0.03, 0.06),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
            ),
            child: xrayImage != null
                ? pw.ClipRRect(
                    horizontalRadius: 10,
                    verticalRadius: 10,
                    child: pw.Image(xrayImage, fit: pw.BoxFit.cover),
                  )
                : pw.Center(
                    child: pw.Text(
                      'RADIOGRAPHIE\nNON DISPONIBLE',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontSize: 9, color: _inkMuted),
                    ),
                  ),
          ),
        ),
        pw.SizedBox(width: 14),

        // Primary diagnosis card
        pw.Expanded(
          flex: 5,
          child: pw.Container(
            height: 180,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: topColor.shade(0.1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
              border: pw.Border.all(color: topColor.shade(0.5), width: 0.8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _monoText('DIAGNOSTIC PRINCIPAL', 8, _inkMuted),
                pw.SizedBox(height: 8),
                pw.Text(
                  result.diagnostic,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: topColor,
                  ),
                ),
                pw.Spacer(),
                // Confidence bar
                _monoText('CONFIANCE', 8, _inkMuted),
                pw.SizedBox(height: 4),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.LayoutBuilder(
                        builder: (ctx, constraints) {
                          final maxW = constraints?.maxWidth ?? 200.0;
                          final filled = maxW *
                              (result.confidence / 100).clamp(0.0, 1.0);
                          return pw.Stack(
                            children: [
                              pw.Container(
                                width: maxW,
                                height: 6,
                                decoration: pw.BoxDecoration(
                                  color: _surface2,
                                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                                ),
                              ),
                              pw.Container(
                                width: filled,
                                height: 6,
                                decoration: pw.BoxDecoration(
                                  color: topColor,
                                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      '${result.confidence.toStringAsFixed(0)}%',
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: topColor,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: sevColor.shade(0.15),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        border: pw.Border.all(color: sevColor.shade(0.5), width: 0.7),
                      ),
                      child: pw.Text(
                        sevLabel,
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: sevColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildAllScores(List<MapEntry<String, double>> scores) {
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: _teal.shade(0.15), width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _monoText('PROBABILITÉS · 14 PATHOLOGIES', 8, _teal),
          pw.SizedBox(height: 12),
          ...scores.map((e) {
            final c = _pathColor(e.key);
            final pct = e.value * 100;
            final isAlert = e.value > 0.5;
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 7),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 5,
                    height: 5,
                    decoration: pw.BoxDecoration(color: c, shape: pw.BoxShape.circle),
                  ),
                  pw.SizedBox(width: 7),
                  pw.SizedBox(
                    width: 110,
                    child: pw.Text(
                      e.key,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: isAlert ? pw.FontWeight.bold : pw.FontWeight.normal,
                        color: isAlert ? _ink : _inkSoft,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Expanded(
                    child: pw.LayoutBuilder(
                      builder: (ctx, constraints) {
                        final maxW = constraints?.maxWidth ?? 200.0;
                        final filled = maxW * e.value.clamp(0.0, 1.0);
                        return pw.Stack(
                          children: [
                            pw.Container(
                              width: maxW,
                              height: 4,
                              decoration: pw.BoxDecoration(
                                color: _surface2,
                                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                              ),
                            ),
                            pw.Container(
                              width: filled,
                              height: 4,
                              decoration: pw.BoxDecoration(
                                color: c,
                                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.SizedBox(
                    width: 36,
                    child: pw.Text(
                      '${pct.toStringAsFixed(1)}%',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: c,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static pw.Widget _buildAlerts(
    List<MapEntry<String, double>> alerts,
    PdfColor sevColor,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: pw.BoxDecoration(
        color: sevColor.shade(0.08),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: sevColor.shade(0.35), width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _monoText('ANOMALIES DÉTECTÉES (p > 50%)', 8, sevColor),
          pw.SizedBox(height: 10),
          ...alerts.map((e) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 5),
            child: pw.Row(
              children: [
                pw.Text('•  ', style: pw.TextStyle(color: sevColor, fontSize: 10)),
                pw.Text(
                  e.key,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: _ink,
                  ),
                ),
                pw.Spacer(),
                pw.Text(
                  '${(e.value * 100).toStringAsFixed(1)}%',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: sevColor,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  static pw.Widget _buildRecommendations(
    List<String> recs,
    PdfColor sevColor,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: pw.BoxDecoration(
        color: _surface,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        border: pw.Border.all(color: _teal.shade(0.15), width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _monoText('RECOMMANDATIONS', 8, _teal),
          pw.SizedBox(height: 10),
          ...recs.map((rec) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 14,
                  height: 14,
                  margin: const pw.EdgeInsets.only(top: 1),
                  decoration: pw.BoxDecoration(
                    color: sevColor.shade(0.2),
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '✓',
                      style: pw.TextStyle(fontSize: 8, color: sevColor),
                    ),
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: pw.Text(
                    rec,
                    style: pw.TextStyle(fontSize: 10, color: _inkSoft),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  static pw.Widget _buildDisclaimer() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _surface2,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '⚠ AVERTISSEMENT MÉDICAL',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: _inkMuted,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            "Ce rapport est généré automatiquement à des fins d'aide au diagnostic par intelligence artificielle. "
            'Il ne remplace en aucun cas l\'avis d\'un médecin spécialiste qualifié. '
            'Toute décision médicale doit être validée par un professionnel de santé.',
            style: pw.TextStyle(fontSize: 8, color: _inkMuted),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Modèle : DenseNet121 · Dataset : NIH ChestX-ray14 · PulmoScan AI v1.0.0 · BTS 2026',
            style: pw.TextStyle(fontSize: 7, color: _inkMuted.shade(0.6)),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  static pw.Widget _monoText(String text, double size, PdfColor color) =>
      pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: size,
          letterSpacing: 1.2,
          color: color,
        ),
      );

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    final n = name.trim();
    return n.substring(0, n.length.clamp(0, 2)).toUpperCase();
  }

  static List<String> _recommendations(String? severite) {
    if (severite == 'severe' || severite == 'urgent') {
      return [
        'Consultation médicale urgente recommandée',
        'Bilan biologique complet à réaliser',
        'Contrôle radiologique dans 48–72 h',
        'Antibiothérapie à envisager selon la clinique',
      ];
    }
    if (severite == 'modere' || severite == 'moyen') {
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
}
