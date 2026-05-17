import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  Interpreter? _interpreter;

  static const List<String> labels = [
    'Atelectasis', 'Cardiomegaly', 'Effusion', 'Infiltration', 'Mass',
    'Nodule', 'Pneumonia', 'Pneumothorax', 'Consolidation', 'Edema',
    'Emphysema', 'Fibrosis', 'Pleural_Thickening', 'Hernia',
  ];
  static const int imageSize = 240;

  Future<void> _chargerModele() async {
    if (_interpreter != null) return;
    final modelData = await rootBundle.load('assets/models/pulmoscan_model.tflite');
    final bytes = modelData.buffer.asUint8List(
      modelData.offsetInBytes,
      modelData.lengthInBytes,
    );
    _interpreter = Interpreter.fromBuffer(bytes);
  }

  Future<Map<String, dynamic>> analyser(File imageFile) async {
    await _chargerModele();

    final bytes = await imageFile.readAsBytes();
    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('Image illisible');
    final resized = img.copyResize(decoded, width: imageSize, height: imageSize);

    final inputData = Float32List(1 * imageSize * imageSize * 3);
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
    final outputData = List.generate(1, (_) => List.filled(labels.length, 0.0));

    _interpreter!.run(input, outputData);

    final scores = outputData[0];

    int maxIndex = 0;
    double maxScore = scores[0];
    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > maxScore) {
        maxScore = scores[i];
        maxIndex = i;
      }
    }

    final confidence = maxScore.clamp(0.0, 1.0);

    String severite;
    if (confidence > 0.75) {
      severite = 'severe';
    } else if (confidence > 0.50) {
      severite = 'modere';
    } else {
      severite = 'faible';
    }

    final allScores = <String, double>{};
    for (int i = 0; i < labels.length; i++) {
      allScores[labels[i]] = scores[i].clamp(0.0, 1.0);
    }

    return {
      'diagnostic': labels[maxIndex],
      'confidence': confidence,
      'severite': severite,
      'details': jsonEncode(allScores),
    };
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
