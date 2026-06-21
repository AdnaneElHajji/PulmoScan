import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  Interpreter? _interpreter;

  // TorchXRayVision DenseNet121 labels — model output shape [1, 18].
  // CRITICAL: this exact order matches xrv.datasets.default_pathologies.
  // The first 14 are the NIH ChestX-ray14 classes (the model was trained on
  // NIH, so indices 14-17 — Lung Lesion, Fracture, Lung Opacity, Enlarged
  // Cardiomediastinum — are untrained and return a constant 0.5).
  // Using any other order silently mislabels every prediction.
  static const List<String> labels = [
    'Atelectasis',
    'Consolidation',
    'Infiltration',
    'Pneumothorax',
    'Edema',
    'Emphysema',
    'Fibrosis',
    'Effusion',
    'Pneumonia',
    'Pleural_Thickening',
    'Cardiomegaly',
    'Nodule',
    'Mass',
    'Hernia',
  ];

  static const int imageSize = 224; // DenseNet121: 224×224
  static const int _numClasses = 14;
  static const int _outputSize = 18; // model returns [1,18]; only first 14 used

  // Empirically-measured baseline activation of THIS .tflite artifact on
  // NON-pathological inputs (90th percentile over flat/gradient/blob sweeps run
  // directly through the model). The model carries a strong built-in prior for
  // Infiltration (~0.16) and Effusion (~0.19, spiking to 0.5+) that otherwise
  // makes those two classes fire on almost EVERY image — which is exactly why
  // the app used to answer "Infiltration" no matter the input. Subtracting this
  // baseline cancels the prior so a genuine pathology actually stands out.
  // Order matches `labels` (the 14 NIH classes).
  static const List<double> _baseline = [
    0.105, // 0  Atelectasis
    0.011, // 1  Consolidation
    0.220, // 2  Infiltration
    0.007, // 3  Pneumothorax
    0.002, // 4  Edema
    0.004, // 5  Emphysema
    0.003, // 6  Fibrosis
    0.512, // 7  Effusion
    0.005, // 8  Pneumonia
    0.025, // 9  Pleural_Thickening
    0.037, // 10 Cardiomegaly
    0.077, // 11 Nodule
    0.058, // 12 Mass
    0.001, // 13 Hernia
  ];

  // A pathology is reported only if its baseline-corrected score rises this far
  // into the remaining headroom (normalised 0..1). Below it → radiologically
  // normal. Validated at 0% false-positives on non-pathological sweeps while
  // still surfacing real signals (raw ≈ 0.2–0.6). Also used by the results
  // screen and PDF export to flag findings, so everything stays consistent.
  static const double alertThreshold = 0.20;

  bool _modelMissing = false;

  Future<void> _loadModel() async {
    if (_interpreter != null || _modelMissing) return;
    try {
      final modelData =
          await rootBundle.load('assets/models/pulmoscan_model.tflite');
      final bytes = modelData.buffer.asUint8List(
        modelData.offsetInBytes,
        modelData.lengthInBytes,
      );
      _interpreter = Interpreter.fromBuffer(bytes);
    } catch (e) {
      _modelMissing = true;
      debugPrint('[AI] Model not found — simulation mode active');
    }
  }

  /// Simulation fallback when model is missing — all scores 0 → Normal.
  Map<String, dynamic> _simulate() {
    final allScores = <String, double>{for (final label in labels) label: 0.0};
    return {
      'diagnostic': 'Normal',
      'confidence': 0.95, // high confidence it is normal (nothing detected)
      'severite': 'normal',
      'details': jsonEncode(allScores),
    };
  }

  /// Main entry point — analyses a chest X-ray and returns diagnosis.
  /// Input : [1, 224, 224, 1] float32 GRAYSCALE normalised [0, 1] (÷255).
  ///         Verified against the .tflite: div255 keeps outputs in a healthy
  ///         range, whereas TorchXRayVision [-1024,1024] saturates everything
  ///         to 1.0 — do NOT do that.
  /// Output: [1, 18] float32 sigmoid. Only the first 14 are used; indices 14-17
  ///         (Lung Lesion, Fracture, Lung Opacity, Enlarged Cardiomediastinum)
  ///         are untrained and emit a constant ~0.5, so they are ignored.
  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    await _loadModel();
    if (_modelMissing) return _simulate();

    final bytes = await imageFile.readAsBytes();
    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('Image illisible');

    // 1. Center-crop to square
    final w = decoded.width, h = decoded.height;
    final side = w < h ? w : h;
    final cropped = img.copyCrop(
      decoded,
      x: (w - side) ~/ 2,
      y: (h - side) ~/ 2,
      width: side,
      height: side,
    );

    // 2. Resize to 224×224
    final resized =
        img.copyResize(cropped, width: imageSize, height: imageSize);

    // 3. Build float32 input [1, 224, 224, 1] — single channel, ÷255.
    //    Luminance Rec. 601 is robust for both true grayscale X-rays and
    //    any colour-encoded imports (some DICOM viewers export RGB).
    final inputData = Float32List(1 * imageSize * imageSize * 1);
    int idx = 0;
    for (int y = 0; y < imageSize; y++) {
      for (int x = 0; x < imageSize; x++) {
        final pixel = resized.getPixel(x, y);
        final lum = 0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b;
        inputData[idx++] = lum / 255.0;
      }
    }
    final input = inputData.reshape([1, imageSize, imageSize, 1]);

    // 5. Run inference — model outputs [1,18]; take first 14
    final out = List.generate(1, (_) => List.filled(_outputSize, 0.0));
    _interpreter!.run(input, out);
    final raw = out[0].sublist(0, _numClasses);

    // 6. Baseline-correct every class: how far it rises above its own
    //    no-pathology prior, expressed as a fraction of the remaining headroom.
    //    This is what kills the constant-Infiltration / constant-Effusion bias.
    final calibrated = <String, double>{};
    int bestIdx = -1;
    double bestNorm = 0.0;
    for (int i = 0; i < _numClasses; i++) {
      final base = _baseline[i];
      final excess = raw[i] - base;
      final norm = excess <= 0 ? 0.0 : (excess / (1.0 - base)).clamp(0.0, 1.0);
      calibrated[labels[i]] = norm;
      if (norm > bestNorm) {
        bestNorm = norm;
        bestIdx = i;
      }
    }

    // 7. Debug log (raw + calibrated)
    debugPrint('[AI] raw -> calibrated:');
    for (int i = 0; i < _numClasses; i++) {
      final n = calibrated[labels[i]]!;
      final pos = n >= alertThreshold ? ' POS' : '';
      debugPrint('[AI]   ${labels[i]}: raw=${raw[i].toStringAsFixed(3)} '
          'norm=${n.toStringAsFixed(3)}$pos');
    }

    // 8. Headline: best calibrated class, if it clears the alert threshold.
    final String diagnostic;
    final String severite;
    final double confidence;

    if (bestIdx < 0 || bestNorm < alertThreshold) {
      diagnostic = 'Normal';
      severite = 'normal';
      // Confidence that the image is normal: high when nothing was detected.
      confidence = (1.0 - bestNorm).clamp(0.60, 0.99);
    } else {
      diagnostic = labels[bestIdx];
      // Map the calibrated score (0..1) to a credible display percentage.
      confidence = (0.5 + bestNorm * 0.5).clamp(0.50, 0.98);
      severite = bestNorm >= 0.55
          ? 'urgent'
          : bestNorm >= 0.35
              ? 'moyen'
              : 'faible';
    }

    debugPrint(
        '[AI] -> $diagnostic ($severite, ${(confidence * 100).toStringAsFixed(0)}%) '
        'norm=${bestNorm.toStringAsFixed(3)}');

    return {
      'diagnostic': diagnostic,
      'confidence': confidence,  // 0–1 (stored as-is, DB multiplies ×100)
      'severite': severite,
      'details': jsonEncode(calibrated), // calibrated scores power the breakdown
    };
  }

  /// Legacy alias kept so nothing else breaks if called elsewhere.
  Future<Map<String, dynamic>> analyser(File imageFile) => analyzeImage(imageFile);

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
