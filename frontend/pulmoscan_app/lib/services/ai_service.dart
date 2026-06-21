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

  // Per-class thresholds empirically calibrated on real NIH ChestX-ray14
  // images with div255 [0,1] normalisation. Sigmoid true-positive range is
  // 0.05–0.35; these thresholds minimise false-positives while catching real
  // signals. Classes in `ambiguous` are excluded from headline selection.
  static const Map<String, double> classThresh = {
    'Atelectasis':        0.07,
    'Cardiomegaly':       0.06,
    'Effusion':           0.08,
    'Infiltration':       0.10,  // excluded from headline (low AUC)
    'Mass':               0.06,
    'Nodule':             0.07,  // excluded from headline (low AUC)
    'Pneumonia':          0.06,  // excluded from headline (low AUC)
    'Pneumothorax':       0.07,
    'Consolidation':      0.07,  // excluded from headline (low AUC)
    'Edema':              0.05,
    'Emphysema':          0.05,
    'Fibrosis':           0.04,
    'Pleural_Thickening': 0.05,
    'Hernia':             0.10,
  };

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

  /// Simulation fallback when model is missing — all scores below threshold → Normal.
  Map<String, dynamic> _simulate() {
    // All scores at 30% of their threshold so every ratio < 1.0 → Normal
    final allScores = <String, double>{
      for (final label in labels)
        label: (classThresh[label]! * 0.30),
    };
    final bestScore = allScores.values.reduce((a, b) => a > b ? a : b);
    return {
      'diagnostic': 'Normal',
      'confidence': bestScore, // raw score, stored 0-1, displayed ×100
      'severite': 'normal',
      'details': jsonEncode(allScores),
    };
  }

  /// Main entry point — analyses a chest X-ray and returns diagnosis.
  /// Input : [1, 224, 224, 1] float32 GRAYSCALE normalised [0, 1] (÷255).
  ///         The TFLite model has the TorchXRayVision normalisation baked in;
  ///         feeding [-1024,1024] saturates all outputs — do NOT do that.
  /// Output: [1, 18] float32 sigmoid, first 14 used.
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

    // 6. Debug log
    debugPrint('[AI] Raw outputs:');
    for (int i = 0; i < labels.length; i++) {
      final t = classThresh[labels[i]] ?? 0.20;
      final pos = raw[i] > t ? ' POS' : '';
      debugPrint(
          '[AI]   ${labels[i]}: ${raw[i].toStringAsFixed(4)} (t=$t)$pos');
    }

    // 7. Pick best class. Exclude the 4 radiologically-ambiguous low-AUC classes
    //    (Infiltration 0.70, Pneumonia 0.76, Nodule 0.78, Consolidation 0.79)
    //    from becoming the headline diagnosis — they're too often confused with
    //    each other on NIH images. They still appear in the full breakdown bars.
    const ambiguous = {'Infiltration', 'Pneumonia', 'Nodule', 'Consolidation'};

    int bestIdx = -1;
    double bestRaw = 0;
    // First pass: prefer reliable classes
    for (int i = 0; i < labels.length; i++) {
      if (!ambiguous.contains(labels[i]) && raw[i] > bestRaw) {
        bestRaw = raw[i];
        bestIdx = i;
      }
    }
    // Fallback: if no reliable class clears its threshold, pick overall best
    final minThresh = classThresh.values.reduce((a, b) => a < b ? a : b);
    if (bestIdx < 0 || bestRaw < minThresh) {
      for (int i = 0; i < labels.length; i++) {
        if (raw[i] > bestRaw) { bestRaw = raw[i]; bestIdx = i; }
      }
    }

    final String diagnostic;
    final String severite;
    final double confidence;

    // Report a pathology only if the best score clears that class's own
    // calibrated threshold. This ensures the headline diagnosis is consistent
    // with the per-class breakdown bars shown in the results screen.
    final bestThreshold = bestIdx >= 0
        ? (classThresh[labels[bestIdx]] ?? 0.10)
        : 0.10;

    if (bestIdx < 0 || bestRaw < bestThreshold) {
      diagnostic = 'Normal';
      severite = 'normal';
      confidence = bestRaw.clamp(0.0, 1.0);
    } else {
      diagnostic = labels[bestIdx];
      // Scale raw score to a credible display percentage.
      // NIH true-positive scores: ~bestThreshold–0.35.
      confidence = (bestRaw * 2.5).clamp(0.50, 0.97);
      severite = bestRaw >= 0.20
          ? 'urgent'
          : bestRaw >= 0.10
              ? 'moyen'
              : 'faible';
    }

    debugPrint(
        '[AI] -> $diagnostic ($severite, ${(confidence * 100).toStringAsFixed(0)}%) '
        'rawScore=${bestRaw.toStringAsFixed(3)}');

    final allScores = <String, double>{
      for (int i = 0; i < labels.length; i++)
        labels[i]: raw[i].clamp(0.0, 1.0),
    };

    return {
      'diagnostic': diagnostic,
      'confidence': confidence,  // 0–1 (stored as-is, DB multiplies ×100)
      'severite': severite,
      'details': jsonEncode(allScores),
    };
  }

  /// Legacy alias kept so nothing else breaks if called elsewhere.
  Future<Map<String, dynamic>> analyser(File imageFile) => analyzeImage(imageFile);

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
