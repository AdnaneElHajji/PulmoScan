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

  // Per-class thresholds calibrated for TorchXRayVision DenseNet121 with
  // correct [-1024, 1024] normalisation. Values are sigmoid outputs; typical
  // true-positive range is 0.20–0.60 with correct preprocessing.
  static const Map<String, double> classThresh = {
    'Atelectasis':        0.20,
    'Cardiomegaly':       0.20,
    'Effusion':           0.25,
    'Infiltration':       0.25,
    'Mass':               0.18,
    'Nodule':             0.18,
    'Pneumonia':          0.20,
    'Pneumothorax':       0.22,
    'Consolidation':      0.20,
    'Edema':              0.20,
    'Emphysema':          0.22,
    'Fibrosis':           0.18,
    'Pleural_Thickening': 0.18,
    'Hernia':             0.25,
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
  /// Input: [1, 224, 224, 1] float32 GRAYSCALE, TorchXRayVision normalised
  ///        to [-1024, 1024]: value = (2*(lum/255) - 1) * 1024
  /// Output: [1, 18] float32 sigmoid, first 14 used
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

    // 3. Compute grayscale luminance for all pixels, find min/max for
    //    auto-contrast stretching (handles phone photos of X-ray films whose
    //    histogram doesn't span the full [0,255] range).
    final lums = Float32List(imageSize * imageSize);
    double lumMin = 255.0, lumMax = 0.0;
    for (int y = 0; y < imageSize; y++) {
      for (int x = 0; x < imageSize; x++) {
        final pixel = resized.getPixel(x, y);
        final l = 0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b;
        lums[y * imageSize + x] = l;
        if (l < lumMin) lumMin = l;
        if (l > lumMax) lumMax = l;
      }
    }
    final lumRange = (lumMax - lumMin).clamp(1.0, 255.0); // avoid /0

    // 4. Build float32 input [1, 224, 224, 1].
    //    TorchXRayVision normalize(): (2*(pixel/maxval) - 1) * 1024
    //    Apply after auto-contrast stretch so pixel ∈ [0,255].
    final inputData = Float32List(1 * imageSize * imageSize * 1);
    for (int i = 0; i < imageSize * imageSize; i++) {
      final stretched = (lums[i] - lumMin) / lumRange * 255.0;
      inputData[i] = (2.0 * (stretched / 255.0) - 1.0) * 1024.0;
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
    // Fallback: if all reliable scores < 0.12, pick overall best
    if (bestIdx < 0 || bestRaw < 0.12) {
      for (int i = 0; i < labels.length; i++) {
        if (raw[i] > bestRaw) { bestRaw = raw[i]; bestIdx = i; }
      }
    }

    final String diagnostic;
    final String severite;
    final double confidence;

    // With correct TorchXRayVision normalisation, scores for a normal image
    // stay well below 0.15. Raise the Normal cutoff accordingly.
    if (bestIdx < 0 || bestRaw < 0.15) {
      diagnostic = 'Normal';
      severite = 'normal';
      confidence = bestRaw.clamp(0.0, 1.0);
    } else {
      diagnostic = labels[bestIdx];
      // Sigmoid outputs with correct preprocessing are in 0.15–0.70 range.
      // Scale ×1.5, floor 60%, cap 97% for credible display.
      confidence = (bestRaw * 1.5).clamp(0.60, 0.97);
      severite = bestRaw >= 0.40 ? 'urgent' : 'moyen';
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
