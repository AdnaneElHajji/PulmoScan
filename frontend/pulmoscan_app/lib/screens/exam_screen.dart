// lib/screens/exam_screen.dart
// Écran pour créer un nouvel examen avec import d'image

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/exam.dart';
import '../models/patient.dart';
import '../models/result.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart';
import 'results_screen.dart';

class ExamScreen extends StatefulWidget {
  final Patient? patientPreSelectionne; // Patient déjà sélectionné (optionnel)

  const ExamScreen({super.key, this.patientPreSelectionne});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final DatabaseService _db = DatabaseService();
  final _notesController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<Patient> _patients = [];
  Patient? _patientSelectionne;
  File? _imageSelectionnee;
  bool _isLoading = false;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _chargerPatients();
    // Si un patient est pré-sélectionné (depuis détail patient)
    if (widget.patientPreSelectionne != null) {
      _patientSelectionne = widget.patientPreSelectionne;
    }
  }

  Future<void> _chargerPatients() async {
    final patients = await _db.getTousLesPatients();
    setState(() => _patients = patients);
  }

  // Ouvre la galerie pour choisir une image
  Future<void> _choisirDepuisGalerie() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _imageSelectionnee = File(image.path));
    }
  }

  // Prend une photo avec la caméra
  Future<void> _prendrePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _imageSelectionnee = File(image.path));
    }
  }

  // Affiche le choix galerie/caméra
  void _afficherChoixImage() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choisir une image',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Galerie
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _choisirDepuisGalerie();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0059FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.photo_library_outlined,
                              size: 40, color: Color(0xFF0059FF)),
                          SizedBox(height: 8),
                          Text('Galerie',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0059FF))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Caméra
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _prendrePhoto();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF388E3C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              size: 40, color: Color(0xFF388E3C)),
                          SizedBox(height: 8),
                          Text('Caméra',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF388E3C))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Lance l'analyse IA (simulation pour BTS)
  Future<void> _lancerAnalyse() async {
    // Règle métier : patient obligatoire
    if (_patientSelectionne == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un patient'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
      return;
    }

    // Règle métier : image obligatoire
    if (_imageSelectionnee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une image radiologique est obligatoire'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      // Enregistre l'examen dans SQLite
      final exam = Exam(
        patientId: _patientSelectionne!.id!,
        imagePath: _imageSelectionnee!.path,
        notes: _notesController.text.trim(),
        dateExamen: DateTime.now(),
        statut: 'en_attente',
      );

      final examId = await _db.ajouterExamen(exam);

      // Run real EfficientNetB1 TFLite inference
      final aiService = AiService();
      final resultatIA = await aiService.analyzeImage(_imageSelectionnee!.path);

      final nouveauResultat = Result(
        examId: examId,
        diagnostic: resultatIA['diagnostic'] as String,
        confidence: resultatIA['confidence'] as double,
        severite: resultatIA['severite'] as String,
        details: resultatIA['details'] as String,
        dateAnalyse: DateTime.now(),
      );
      await _db.ajouterResultat(nouveauResultat);

      if (mounted) {
        setState(() => _isAnalyzing = false);
        // Navigue vers l'écran de résultats
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              examId: examId,
              patient: _patientSelectionne!,
              imagePath: _imageSelectionnee!.path,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isAnalyzing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nouvel examen',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: _isAnalyzing
          ? _buildEcranAnalyse()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Sélection patient ──
                  _buildSectionTitre('Sélectionner le patient'),
                  const SizedBox(height: 12),
                  _buildDropdownPatient(),
                  const SizedBox(height: 24),

                  // ── Image radiographie ──
                  _buildSectionTitre('Image radiologique *'),
                  const SizedBox(height: 12),
                  _buildZoneImage(),
                  const SizedBox(height: 24),

                  // ── Notes cliniques ──
                  _buildSectionTitre('Notes cliniques'),
                  const SizedBox(height: 12),
                  _buildChampNotes(),
                  const SizedBox(height: 32),

                  // ── Bouton analyser ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _lancerAnalyse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0059FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.psychology_outlined, size: 24),
                          SizedBox(width: 10),
                          Text(
                            'Analyser avec l\'IA',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  // Écran de chargement pendant l'analyse IA
  Widget _buildEcranAnalyse() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF0059FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                color: Color(0xFF0059FF),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Analyse IA en cours...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Les modèles EfficientNet et U-Net\nanalysent la radiographie',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 32),
          // Étapes de l'analyse
          _buildEtapeAnalyse('Prétraitement de l\'image', true),
          _buildEtapeAnalyse('Classification EfficientNet', true),
          _buildEtapeAnalyse('Segmentation U-Net', false),
        ],
      ),
    );
  }

  Widget _buildEtapeAnalyse(String label, bool termine) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 40),
      child: Row(
        children: [
          Icon(
            termine ? Icons.check_circle : Icons.radio_button_unchecked,
            color: termine ? const Color(0xFF388E3C) : const Color(0xFF9CA3AF),
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: termine ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
              fontWeight: termine ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitre(String titre) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF0059FF),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          titre,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  // Dropdown de sélection du patient
  Widget _buildDropdownPatient() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Patient>(
          isExpanded: true,
          hint: const Text(
            '-- Choisir un patient --',
            style: TextStyle(color: Color(0xFF9CA3AF)),
          ),
          value: _patientSelectionne,
          items: _patients.map((patient) {
            return DropdownMenuItem<Patient>(
              value: patient,
              child: Text('${patient.nom} (${patient.age} ans)'),
            );
          }).toList(),
          onChanged: (patient) {
            setState(() => _patientSelectionne = patient);
          },
        ),
      ),
    );
  }

  // Zone d'upload de l'image
  Widget _buildZoneImage() {
    return GestureDetector(
      onTap: _afficherChoixImage,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _imageSelectionnee != null
                ? const Color(0xFF0059FF)
                : const Color(0xFFD1D5DB),
            width: _imageSelectionnee != null ? 2 : 1,
            style: _imageSelectionnee != null
                ? BorderStyle.solid
                : BorderStyle.solid,
          ),
        ),
        child: _imageSelectionnee != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    Image.file(
                      _imageSelectionnee!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    // Bouton changer l'image
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _afficherChoixImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 52,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Appuyer pour ajouter une image',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'PNG, JPG jusqu\'à 10MB',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Champ notes cliniques
  Widget _buildChampNotes() {
    return TextFormField(
      controller: _notesController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Symptômes, observations cliniques...',
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0059FF), width: 2),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}