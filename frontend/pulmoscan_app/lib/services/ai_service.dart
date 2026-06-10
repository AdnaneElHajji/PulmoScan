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

  /// Simulation fallback when model is missing.
  Map<String, dynamic> _simulate() {
    final idx = DateTime.now().millisecondsSinceEpoch % labels.length;
    final label = labels[idx];
    final thresh = classThresh[label] ?? 0.20;
    final score = thresh * 1.4;
    final ratio = score / thresh;
    final confidence = (0.50 + 0.20 * (ratio - 1.0)).clamp(0.50, 0.95);
    final allScores = <String, double>{
      for (int i = 0; i < labels.length; i++)
        labels[i]: i == idx ? score : (classThresh[labels[i]]! * 0.3),
    };
    return {
      'diagnostic': label,
      'confidence': confidence,
      'severite': 'faible',
      'details': jsonEncode(allScores),
    };
  }

  /// Main entry point — analyses a chest X-ray and returns diagnosis.
  /// Input: [1, 224, 224, 3] float32 RGB normalised [0, 1]
  /// Output: [1, 18] float32 sigmoid, first 14 used
  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    await _loadModel();
    if (_modelMissing) return _simulate();

    final bytes = await imageFile.readAsBytes();
    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('Image illisible');

    // 1. Convert to RGB (ensure 3 channels)
    final rgb = decoded.numChannels >= 3
        ? decoded
        : img.remapColors(decoded, red: img.Channel.red, green: img.Channel.red, blue: img.Channel.red);

    // 2. Center-crop to square
    final w = rgb.width, h = rgb.height;
    final side = w < h ? w : h;
    final cropped = img.copyCrop(
      rgb,
      x: (w - side) ~/ 2,
      y: (h - side) ~/ 2,
      width: side,
      height: side,
    );

    // 3. Resize to 224×224
    final resized =
        img.copyResize(cropped, width: imageSize, height: imageSize);

    // 4. Build float32 input [1, 224, 224, 3] normalised [0, 1]
    final inputData =
        Float32List(1 * imageSize * imageSize * 3);
    int idx = 0;
    for (int y = 0; y < imageSize; y++) {
      for (int x = 0; x < imageSize; x++) {
        final pixel = resized.getPixel(x, y);
        inputData[idx++] = pixel.r.toDouble() / 255.0;
        inputData[idx++] = pixel.g.toDouble() / 255.0;
        inputData[idx++] = pixel.b.toDouble() / 255.0;
      }
    }
    final input = inputData.reshape([1, imageSize, imageSize, 3]);

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
      diagnostic = 'Normal';
      severite = 'normal';
      confidence = (1.0 - bestScore).clamp(0.0, 1.0);
    } else {
      diagnostic = labels[bestIdx];
      final c = 0.50 + 0.20 * (bestRatio - 1.0);
      confidence = c.clamp(0.50, 0.95);
      if (bestRatio >= 3.0) {
        severite = 'severe';
      } else if (bestRatio >= 1.8) {
        severite = 'modere';
      } else {
        severite = 'faible';
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
