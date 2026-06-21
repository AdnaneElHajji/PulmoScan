import 'dart:io';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class SegmentationResult {
  final Uint8List overlayBytes;      // PNG : radio + poumons surlignés en teal
  final double lungCoveragePercent;  // % de pixels poumon
  const SegmentationResult({
    required this.overlayBytes,
    required this.lungCoveragePercent,
  });
}

class SegmentationService {
  static final SegmentationService _instance = SegmentationService._internal();
  factory SegmentationService() => _instance;
  SegmentationService._internal();

  Interpreter? _interpreter;

  Future<Interpreter> _getInterpreter() async {
    _interpreter ??=
        await Interpreter.fromAsset('assets/models/unet_lung.tflite');
    return _interpreter!;
  }

  Future<SegmentationResult> segment(String imagePath) async {
    final interpreter = await _getInterpreter();

    final bytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) throw Exception('Impossible de décoder l\'image');

    // Entrée U-Net : [1,256,256,1] niveaux de gris, normalisé [0,1]
    final resized = img.copyResize(original, width: 256, height: 256);
    final input = List.generate(
      1,
      (_) => List.generate(
        256,
        (y) => List.generate(
          256,
          (x) { final p = resized.getPixel(x, y); return [(0.299 * p.r + 0.587 * p.g + 0.114 * p.b) / 255.0]; },
        ),
      ),
    );

    // Sortie : [1,256,256,1] masque sigmoïde
    final output = List.generate(
      1,
      (_) => List.generate(
        256,
        (_) => List.generate(256, (_) => [0.0]),
      ),
    );

    interpreter.run(input, output);

    final mask = output[0];
    int lungPixels = 0;
    const int total = 256 * 256;

    final overlay = img.copyResize(original, width: 256, height: 256);
    for (int y = 0; y < 256; y++) {
      for (int x = 0; x < 256; x++) {
        if (mask[y][x][0] > 0.5) {
          lungPixels++;
          final p = overlay.getPixel(x, y);
          // Mélange teal (0,180,170) à 40% sur le pixel d'origine
          overlay.setPixel(
            x,
            y,
            img.ColorRgb8(
              (p.r * 0.6).round(),
              (p.g * 0.6 + 180 * 0.4).round(),
              (p.b * 0.6 + 170 * 0.4).round(),
            ),
          );
        }
      }
    }

    return SegmentationResult(
      overlayBytes: Uint8List.fromList(img.encodePng(overlay)),
      lungCoveragePercent: (lungPixels / total) * 100,
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
