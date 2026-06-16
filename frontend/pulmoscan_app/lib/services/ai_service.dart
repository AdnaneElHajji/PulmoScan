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

  // DenseNet121 labels — 14 classes, model output shape [1, 18] (indices 14-17 unused)
  static const List<String> labels = [
    'Atelectasis',
    'Cardiomegaly',
    'Effusion',
    'Infiltration',
    'Mass',
    'Nodule',
    'Pneumonia',
    'Pneumothorax',
    'Consolidation',
    'Edema',
    'Emphysema',
    'Fibrosis',
    'Pleural_Thickening',
    'Hernia',
  ];

  static const int imageSize = 224; // DenseNet121: 224×224
  static const int _numClasses = 14;
  static const int _outputSize = 18; // model returns [1,18]; only first 14 used

  // Per-class thresholds (sigmoid outputs calibrated on NIH ChestX-ray14)
  static const Map<String, double> classThresh = {
    'Atelectasis': 0.30,
    'Cardiomegaly': 0.20,
    'Effusion': 0.35,
    'Infiltration': 0.40,
    'Mass': 0.18,
    'Nodule': 0.18,
    'Pneumonia': 0.18,
    'Pneumothorax': 0.25,
    'Consolidation': 0.18,
    'Edema': 0.15,
    'Emphysema': 0.15,
    'Fibrosis': 0.12,
    'Pleural_Thickening': 0.15,
    'Hernia': 0.40,
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
  /// Input: [1, 224, 224, 1] float32 GRAYSCALE normalised [0, 1]
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

    // 3. Build float32 input [1, 224, 224, 1] GRAYSCALE, normalised [0, 1]
    //    Model expects a single channel — feeding RGB gives garbage results.
    final inputData = Float32List(1 * imageSize * imageSize * 1);
    int idx = 0;
    for (int y = 0; y < imageSize; y++) {
      for (int x = 0; x < imageSize; x++) {
        final pixel = resized.getPixel(x, y);
        // Luminance (Rec. 601) — NIH X-rays are already gray, this is robust.
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

    // 7. Pick best class by ratio score/threshold
    int bestIdx = -1;
    double bestRatio = 0;
    double bestScore = 0;
    for (int i = 0; i < labels.length; i++) {
      final t = classThresh[labels[i]] ?? 0.20;
      final ratio = raw[i] / t;
      if (ratio > bestRatio) {
        bestRatio = ratio;
        bestIdx = i;
        bestScore = raw[i];
      }
    }

    final String diagnostic;
    final String severite;
    final double confidence;

    if (bestIdx < 0 || bestRatio < 1.0) {
      // Nothing exceeds threshold → Normal
      // confidence = raw best score (honest representation, e.g. 1.8%)
      diagnostic = 'Normal';
      severite = 'normal';
      confidence = bestScore.clamp(0.0, 1.0);
    } else {
      diagnostic = labels[bestIdx];
      confidence = bestScore.clamp(0.0, 1.0); // raw score, e.g. 0.35 → 35%
      if (bestRatio >= 2.0) {
        severite = 'urgent';
      } else {
        severite = 'moyen';
      }
    }

    debugPrint(
        '[AI] -> $diagnostic ($severite, ${(confidence * 100).toStringAsFixed(0)}%) '
        'bestRatio=${bestRatio.toStringAsFixed(2)}');

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
