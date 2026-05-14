// lib/screens/results_screen.dart
// Écran des résultats de l'analyse IA - basé sur le design Figma ScanDetails

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/result.dart';
import '../services/api_service.dart';

class ResultsScreen extends StatefulWidget {
  final int examId;
  final Patient patient;
  final String imagePath;

  const ResultsScreen({
    super.key,
    required this.examId,
    required this.patient,
    required this.imagePath,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final ApiService _api = ApiService();
  Result? _resultat;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _genererEtSauvegarderResultat();
  }

  // Récupère ou génère le résultat via le backend
  Future<void> _genererEtSauvegarderResultat() async {
    try {
      // Vérifie si un résultat existe déjà
      final existing = await _api.get('/results/exam/${widget.examId}');
      final list = existing as List;
      if (list.isNotEmpty) {
        setState(() {
          _resultat = Result.fromJson(list[0] as Map<String, dynamic>);
          _isLoading = false;
        });
        return;
      }

      // Appelle l'IA via le backend
      final prediction = await _api.post(
        '/predict',
        {'image_path': widget.imagePath},
      );

      // Sauvegarde le résultat (confidence 0-1 pour le backend)
      final saved = await _api.post('/results', {
        'exam_id': widget.examId,
        'diagnostic': prediction['diagnostic'],
        'confidence': prediction['confidence'], // 0-1
        'severite': prediction['severite'],
        'details': prediction['details'] ?? '',
      });

      setState(() {
        _resultat = Result.fromJson(saved as Map<String, dynamic>);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  bool _isUrgent(String s) => s == 'urgent' || s == 'severe';
  bool _isMoyen(String s) => s == 'moyen' || s == 'modere';

  Color _couleurSeverite(String severite) {
    if (_isUrgent(severite)) return const Color(0xFFD32F2F);
    if (_isMoyen(severite)) return const Color(0xFFD97706);
    return const Color(0xFF388E3C);
  }

  Color _bgSeverite(String severite) {
    if (_isUrgent(severite)) return const Color(0xFFFEE2E2);
    if (_isMoyen(severite)) return const Color(0xFFFEF3C7);
    return const Color(0xFFD1FAE5);
  }

  String _labelSeverite(String severite) {
    if (_isUrgent(severite)) return 'Priorité élevée';
    if (_isMoyen(severite)) return 'À surveiller';
    return 'Normal';
  }

  IconData _iconeSeverite(String severite) {
    if (_isUrgent(severite)) return Icons.warning_amber_rounded;
    if (_isMoyen(severite)) return Icons.info_outline;
    return Icons.check_circle_outline;
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
          'Résultats de l\'examen',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF6B7280)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export PDF bientôt disponible')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0059FF)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Infos patient ──
                  _buildCartePatient(),
                  const SizedBox(height: 16),

                  // ── Diagnostic principal ──
                  _buildDiagnosticPrincipal(),
                  const SizedBox(height: 16),

                  // ── Image radiographie ──
                  _buildImageRadio(),
                  const SizedBox(height: 16),

                  // ── Modèles IA ──
                  _buildModelesIA(),
                  const SizedBox(height: 16),

                  // ── Recommandations ──
                  _buildRecommandations(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  // Carte infos patient
  Widget _buildCartePatient() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0059FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.person, color: Color(0xFF0059FF), size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.patient.nom,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  '${widget.patient.age} ans • ${widget.patient.genre}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          // Date examen
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Date',
                style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
              ),
              Text(
                '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Carte diagnostic principal
  Widget _buildDiagnosticPrincipal() {
    if (_resultat == null) return const SizedBox();

    final couleur = _couleurSeverite(_resultat!.severite);
    final bg = _bgSeverite(_resultat!.severite);
    final label = _labelSeverite(_resultat!.severite);
    final icone = _iconeSeverite(_resultat!.severite);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre + badge sévérité
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Diagnostic IA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(icone, size: 14, color: couleur),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: couleur,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Diagnostic
          Text(
            _resultat!.diagnostic,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),

          // Barre de confiance
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _resultat!.confidence / 100,
                    backgroundColor: const Color(0xFFE5E7EB),
                    color: couleur,
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_resultat!.confidence.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: couleur,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Niveau de confiance',
            style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }

  // Image de la radiographie
  Widget _buildImageRadio() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Image radiologique',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: File(widget.imagePath).existsSync()
                ? Image.file(
                    File(widget.imagePath),
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: 220,
                    color: const Color(0xFFF3F4F6),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined,
                            size: 60, color: Color(0xFF9CA3AF)),
                        SizedBox(height: 8),
                        Text('Image radiographique',
                            style: TextStyle(color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Résultats des modèles IA
  Widget _buildModelesIA() {
    if (_resultat == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Détail des modèles IA',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // EfficientNet
              Expanded(
                child: _buildCarteModele(
                  nom: 'EfficientNet',
                  description: 'Classification',
                  confidence: _resultat!.confidence,
                  temps: '1.2s',
                  couleur: const Color(0xFF0059FF),
                  bgCouleur: const Color(0xFFEFF6FF),
                  icone: Icons.psychology_outlined,
                ),
              ),
              const SizedBox(width: 12),
              // U-Net
              Expanded(
                child: _buildCarteModele(
                  nom: 'U-Net',
                  description: 'Segmentation',
                  confidence: _resultat!.confidence - 2,
                  temps: '0.8s',
                  couleur: const Color(0xFF7C3AED),
                  bgCouleur: const Color(0xFFF5F3FF),
                  icone: Icons.account_tree_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarteModele({
    required String nom,
    required String description,
    required double confidence,
    required String temps,
    required Color couleur,
    required Color bgCouleur,
    required IconData icone,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgCouleur,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 20, color: couleur),
              const SizedBox(width: 6),
              Text(
                nom,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: couleur,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${confidence.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: couleur,
                  fontSize: 18,
                ),
              ),
              Text(
                temps,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Recommandations selon le diagnostic
  Widget _buildRecommandations() {
    if (_resultat == null) return const SizedBox();

    List<String> recommandations;
    if (_resultat!.severite == 'urgent') {
      recommandations = [
        'Consultation médicale urgente recommandée',
        'Antibiothérapie à envisager',
        'Suivi radiologique dans 48-72h',
        'Bilan biologique complet',
      ];
    } else if (_resultat!.severite == 'moyen') {
      recommandations = [
        'Suivi médical recommandé',
        'Contrôle radiologique dans 1 mois',
        'Surveillance des symptômes',
      ];
    } else {
      recommandations = [
        'Résultat normal - pas d\'anomalie détectée',
        'Contrôle annuel recommandé',
        'Maintenir un mode de vie sain',
      ];
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommandations',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 14),
          ...recommandations.map(
            (rec) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Color(0xFF388E3C),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      rec,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}