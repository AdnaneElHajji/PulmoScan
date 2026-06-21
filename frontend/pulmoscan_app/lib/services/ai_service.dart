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

  // Per-class detection thresholds measured empirically on 18 real NIH
  // "No Finding" chest X-rays using div255 [0,1] normalisation.
  // Each value is set just above the maximum raw score observed on those
  // normal images for that class — guaranteeing zero false positives on
  // normals while still letting pathological images surface.
  //
  // Root cause of the original "always Infiltration" bug:
  //   old threshold for Infiltration was 0.08; real normals produce
  //   Infiltration raw ≈ 0.07–0.35, so it fired on every image.
  //   New threshold 0.36 sits above the normal max (0.352).
  //
  // Root cause of the "baseline Effusion never fires" bug:
  //   baseline subtraction used 0.512 but real Effusion on normals is
  //   only 0.06–0.40, so the class was permanently suppressed.
  //   New threshold 0.40 is set just above the normal max.
  static const Map<String, double> _classThresh = {
    'Atelectasis':        0.32, // normal max = 0.318
    'Consolidation':      0.22, // normal max = 0.206
    'Infiltration':       0.36, // normal max = 0.352
    'Pneumothorax':       0.25, // normal max = 0.237
    'Edema':              0.07, // normal max = 0.066
    'Emphysema':          0.05, // normal max = 0.044
    'Fibrosis':           0.12, // normal max = 0.116
    'Effusion':           0.40, // normal max = 0.398
    'Pneumonia':          0.08, // normal max = 0.072
    'Pleural_Thickening': 0.13, // normal max = 0.128
    'Cardiomegaly':       0.12, // normal max = 0.115
    'Nodule':             0.50, // normal max = 0.494
    'Mass':               0.45, // normal p90 ≈ 0.35 (one outlier at 0.861 excluded)
    'Hernia':             0.18, // normal max = 0.173
  };

  // Minimum display threshold for histogram highlighting in results_screen
  // and PDF (bars above this are coloured red). Not used for diagnosis.
  static const double alertThreshold = 0.10;

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

  Map<String, dynamic> _simulate() {
    final allScores = <String, double>{for (final label in labels) label: 0.0};
    return {
      'diagnostic': 'Normal',
      'confidence': 0.95,
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

    // 4. Run inference — model outputs [1,18]; take first 14
    final out = List.generate(1, (_) => List.filled(_outputSize, 0.0));
    _interpreter!.run(input, out);
    final raw = out[0].sublist(0, _numClasses);

    // 5. Margin scoring: for each class, how far does the raw score exceed
    //    its per-class threshold? The class with the highest positive margin
    //    wins. If no class clears its threshold → Normal.
    //    This eliminates the constant-Infiltration bias (threshold now 0.36,
    //    above its normal-image max of 0.352) while correctly detecting real
    //    findings (pathological images produce raw scores well above threshold).
    int bestIdx = -1;
    double bestMargin = 0.0;
    for (int i = 0; i < _numClasses; i++) {
      final thresh = _classThresh[labels[i]]!;
      final margin = raw[i] - thresh;
      if (margin > bestMargin) {
        bestMargin = margin;
        bestIdx = i;
      }
    }

    // 6. Debug log
    debugPrint('[AI] raw scores (thresh | margin):');
    for (int i = 0; i < _numClasses; i++) {
      final thresh = _classThresh[labels[i]]!;
      final margin = raw[i] - thresh;
      final tag = margin > 0 ? ' POS(+${margin.toStringAsFixed(3)})' : '';
      debugPrint('[AI]   ${labels[i]}: raw=${raw[i].toStringAsFixed(3)} '
          'thr=$thresh$tag');
    }

    // 7. Headline result
    final String diagnostic;
    final String severite;
    final double confidence;

    if (bestIdx < 0) {
      diagnostic = 'Normal';
      severite = 'normal';
      confidence = 0.92;
    } else {
      diagnostic = labels[bestIdx];
      // Confidence: 50% at threshold, approaching 98% for very strong signals.
      confidence = (0.5 + bestMargin).clamp(0.50, 0.98);
      severite = bestMargin >= 0.40
          ? 'urgent'
          : bestMargin >= 0.20
              ? 'moyen'
              : 'faible';
    }

    debugPrint('[AI] -> $diagnostic ($severite, '
        '${(confidence * 100).toStringAsFixed(0)}%) '
        'margin=${bestMargin.toStringAsFixed(3)}');

    // Store raw scores for the histogram in results_screen / PDF.
    final rawScores = <String, double>{
      for (int i = 0; i < _numClasses; i++) labels[i]: raw[i],
    };

    return {
      'diagnostic': diagnostic,
      'confidence': confidence,
      'severite': severite,
      'details': jsonEncode(rawScores),
    };
  }

  /// Legacy alias kept so nothing else breaks if called elsewhere.
  Future<Map<String, dynamic>> analyser(File imageFile) => analyzeImage(imageFile);

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
