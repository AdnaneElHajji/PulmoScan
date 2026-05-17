import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class AiService {
  static Interpreter? _interpreter;

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

  Future<Interpreter> _getInterpreter() async {
    _interpreter ??= await Interpreter.fromAsset(
      'assets/models/pulmoscan_model.tflite',
    );
    return _interpreter!;
  }

  /// Runs EfficientNetB1 inference on [imagePath].
  /// Returns diagnostic, confidence (0–100), severite, and details JSON.
  Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
    final interpreter = await _getInterpreter();

    final bytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) throw Exception('Impossible de décoder l\'image');

    final resized = img.copyResize(original, width: 240, height: 240);

    // Input tensor shape: [1, 240, 240, 3]
    final input = [
      List.generate(
        240,
        (y) => List.generate(
          240,
          (x) {
            final p = resized.getPixel(x, y);
            return [p.r / 255.0, p.g / 255.0, p.b / 255.0];
          },
        ),
      ),
    ];

    // Output tensor shape: [1, 14] — sigmoid multi-label
    final output = [List.filled(14, 0.0)];

    interpreter.run(input, output);

    final scores = List<double>.from(output[0]);

    // Pick label with highest sigmoid score
    int topIndex = 0;
    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > scores[topIndex]) topIndex = i;
    }

    final topScore = scores[topIndex];
    final diagnostic = labels[topIndex];

    // Severity based on confidence
    String severite;
    if (topScore >= 0.65) {
      severite = 'urgent';
    } else if (topScore >= 0.35) {
      severite = 'moyen';
    } else {
      severite = 'normal';
    }

    // Build JSON string with all 14 scores for ResultsScreen
    final buffer = StringBuffer('{');
    for (int i = 0; i < labels.length; i++) {
      if (i > 0) buffer.write(',');
      buffer.write('"${labels[i]}":${scores[i].toStringAsFixed(4)}');
    }
    buffer.write('}');

    return {
      'diagnostic': diagnostic,
      'confidence': topScore * 100, // stored as 0–100 in SQLite
      'severite': severite,
      'details': buffer.toString(),
    };
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
