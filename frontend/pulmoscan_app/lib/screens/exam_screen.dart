import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/patient.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart';
import '../theme/v4_theme.dart';
import '../widgets/aperture_mark.dart';
import 'results_screen.dart';

class ExamScreen extends StatefulWidget {
  final Patient? patientPreSelectionne;
  const ExamScreen({super.key, this.patientPreSelectionne});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final _notesCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<Patient> _patients = [];
  Patient? _selected;
  File? _image;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.patientPreSelectionne;
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await DatabaseService().getPatients();
      setState(() => _patients = patients);
    } catch (_) {}
  }

  Future<void> _pickGallery() async {
    final f = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85);
    if (f != null) setState(() => _image = File(f.path));
  }

  Future<void> _pickCamera() async {
    final f = await _picker.pickImage(
        source: ImageSource.camera, imageQuality: 85);
    if (f != null) setState(() => _image = File(f.path));
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: V4.surface2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: V4.border),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: V4.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choisir une radiographie',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: V4.ink,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickGallery();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: V4.blue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: V4.blue.withValues(alpha: 0.3)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.photo_library_outlined,
                              size: 36, color: V4.blue),
                          SizedBox(height: 8),
                          Text('Galerie',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: V4.blue,
                                  fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickCamera();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: V4.teal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: V4.teal.withValues(alpha: 0.3)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              size: 36, color: V4.teal),
                          SizedBox(height: 8),
                          Text('Caméra',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: V4.teal,
                                  fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _analyse() async {
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Veuillez sélectionner un patient')));
      return;
    }
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Une image radiologique est obligatoire')));
      return;
    }
    setState(() => _isAnalyzing = true);
    try {
      final db = DatabaseService();
      final examId = await db.createExam({
        'patient_id': _selected!.id,
        'image_path': _image!.path,
        'notes': _notesCtrl.text.trim(),
      });

      final prediction = await AiService().analyser(_image!);
      await db.createResultat({
        'exam_id': examId,
        'diagnostic': prediction['diagnostic'],
        'confidence': prediction['confidence'],
        'severite': prediction['severite'],
        'details': prediction['details'] ?? '',
      });

      if (mounted) {
        setState(() => _isAnalyzing = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultsScreen(
              examId: examId,
              patient: _selected!,
              imagePath: _image!.path,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isAnalyzing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: V4.coral,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V4.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: V4.inkSoft, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Nouvel examen'),
      ),
      body: _isAnalyzing
          ? _buildAnalysing()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Patient'),
                  const SizedBox(height: 8),
                  _patientDropdown(),
                  const SizedBox(height: 22),
                  _sectionLabel('Radiographie *'),
                  const SizedBox(height: 8),
                  _imageZone(),
                  const SizedBox(height: 22),
                  _sectionLabel('Notes cliniques'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 4,
                    style: const TextStyle(color: V4.ink, fontSize: 14),
                    decoration: V4.inputDec(
                        hint: 'Symptômes, observations cliniques…'),
                  ),
                  const SizedBox(height: 32),
                  V4.primaryBtn(
                    label: 'Analyser avec l\'IA',
                    onTap: _analyse,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
              color: V4.teal, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: V4.ink,
            )),
      ],
    );
  }

  Widget _patientDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: V4.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: V4.borderStrong),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Patient>(
          isExpanded: true,
          dropdownColor: V4.surface2,
          style: const TextStyle(color: V4.ink, fontSize: 14),
          hint: const Text('Choisir un patient…',
              style: TextStyle(color: V4.inkMuted)),
          value: _patients.contains(_selected) ? _selected : null,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: V4.inkMuted),
          items: _patients.map((p) {
            return DropdownMenuItem<Patient>(
              value: p,
              child: Text('${p.nom} · ${p.age} ans'),
            );
          }).toList(),
          onChanged: (p) => setState(() => _selected = p),
        ),
      ),
    );
  }

  Widget _imageZone() {
    return GestureDetector(
      onTap: _showImagePicker,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: V4.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _image != null
                ? V4.teal
                : V4.borderStrong,
            width: _image != null ? 2 : 1,
          ),
        ),
        child: _image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  children: [
                    Image.file(_image!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _showImagePicker,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.edit_rounded,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined,
                      size: 48, color: V4.inkMuted),
                  const SizedBox(height: 12),
                  const Text(
                    'Appuyer pour ajouter une radiographie',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: V4.inkSoft,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text('PNG, JPG',
                      style: TextStyle(
                          fontSize: 12, color: V4.inkMuted)),
                ],
              ),
      ),
    );
  }

  Widget _buildAnalysing() {
    return const _ScanningView();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }
}

// ── Cinematic scanning animation ──────────────────────────────────────────────
class _ScanningView extends StatefulWidget {
  const _ScanningView();

  @override
  State<_ScanningView> createState() => _ScanningViewState();
}

class _ScanningViewState extends State<_ScanningView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _unet;
  late final Animation<double> _effnet;

  static const _segOrder = [0, 2, 7, 11, 1, 4, 6, 8, 3, 5, 9, 10, 12, 13];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();
    _unet = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.50, curve: Curves.easeOut),
    );
    _effnet = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.05, 0.95, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: V4.bg,
      child: Stack(
        children: [
          // Background glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.2),
                  radius: 0.7,
                  colors: [Color(0x1A34E5C5), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  AnimatedApertureMark(
                    size: 150,
                    targetActive: _segOrder,
                    duration: const Duration(milliseconds: 2400),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Analyse IA en cours…',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: V4.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'DENSENET121 · 14 PATHOLOGIES',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 1.4,
                      color: V4.inkMuted,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 36),
                  _ProgressBar(
                    label: 'U-Net',
                    sublabel: 'Segmentation',
                    color: V4.teal,
                    animation: _unet,
                  ),
                  const SizedBox(height: 16),
                  _ProgressBar(
                    label: 'DenseNet121',
                    sublabel: 'Classification · 14 classes',
                    color: V4.blue,
                    animation: _effnet,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends AnimatedWidget {
  final String label;
  final String sublabel;
  final Color color;

  const _ProgressBar({
    required this.label,
    required this.sublabel,
    required this.color,
    required Animation<double> animation,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final value = (listenable as Animation<double>).value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$label  ',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: V4.inkSoft,
                        fontFamily: 'monospace',
                      ),
                    ),
                    TextSpan(
                      text: sublabel,
                      style: const TextStyle(
                        fontSize: 10,
                        color: V4.inkMuted,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: V4.surface3,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}
