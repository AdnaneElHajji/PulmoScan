// lib/screens/patient_detail_screen.dart
// Écran détail d'un patient avec 2 onglets : Informations + Historique examens

import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/exam.dart';
import '../models/result.dart';
import '../services/database_service.dart';
import 'add_patient_screen.dart';
import 'exam_screen.dart';
import 'results_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final int patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _db = DatabaseService();
  late TabController _tabController;

  Patient? _patient;
  List<Exam> _examens = [];
  Map<int, Result?> _resultats = {}; // examId -> Result
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _chargerDonnees();
  }

  Future<void> _chargerDonnees() async {
    setState(() => _isLoading = true);
    try {
      final patient = await _db.getPatientParId(widget.patientId);
      final examens = await _db.getExamensParPatient(widget.patientId);

      // Charge les résultats de chaque examen
      final Map<int, Result?> resultats = {};
      for (var exam in examens) {
        resultats[exam.id!] = await _db.getResultatParExam(exam.id!);
      }

      setState(() {
        _patient = patient;
        _examens = examens;
        _resultats = resultats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Couleurs selon sévérité
  Color _couleurSeverite(String? severite) {
    switch (severite) {
      case 'urgent':
        return const Color(0xFFD32F2F);
      case 'moyen':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF388E3C);
    }
  }

  Color _bgSeverite(String? severite) {
    switch (severite) {
      case 'urgent':
        return const Color(0xFFFEE2E2);
      case 'moyen':
        return const Color(0xFFFEF3C7);
      default:
        return const Color(0xFFD1FAE5);
    }
  }

  String _labelSeverite(String? severite) {
    switch (severite) {
      case 'urgent':
        return 'Urgent';
      case 'moyen':
        return 'À surveiller';
      default:
        return 'Normal';
    }
  }

  // Formate la date
  String _formaterDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0059FF)),
        ),
      );
    }

    if (_patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Patient introuvable')),
        body: const Center(child: Text('Ce patient n\'existe pas')),
      );
    }

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
          'Détails du patient',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          // Bouton modifier
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF0059FF)),
            onPressed: () async {
              final resultat = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddPatientScreen(
                    patientAModifier: _patient,
                  ),
                ),
              );
              if (resultat == true) _chargerDonnees();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Carte patient en haut ──
          _buildCartePatient(),

          // ── Onglets ──
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF0059FF),
              unselectedLabelColor: const Color(0xFF6B7280),
              indicatorColor: const Color(0xFF0059FF),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: [
                Tab(
                  text: 'Informations',
                  icon: const Icon(Icons.person_outline, size: 20),
                  iconMargin: const EdgeInsets.only(bottom: 2),
                ),
                Tab(
                  text: 'Historique (${_examens.length})',
                  icon: const Icon(Icons.history, size: 20),
                  iconMargin: const EdgeInsets.only(bottom: 2),
                ),
              ],
            ),
          ),

          // ── Contenu des onglets ──
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOngletInfos(),
                _buildOngletHistorique(),
              ],
            ),
          ),
        ],
      ),

      // Bouton flottant nouvel examen
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExamScreen(
                patientPreSelectionne: _patient,
              ),
            ),
          );
          _chargerDonnees(); // Recharge après examen
        },
        backgroundColor: const Color(0xFF0059FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nouvel examen',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Carte résumé en haut de l'écran
  Widget _buildCartePatient() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF0059FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: const Icon(
              Icons.person,
              color: Color(0xFF0059FF),
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _patient!.nom,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  '${_patient!.age} ans • ${_patient!.genre}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                Text(
                  '${_examens.length} examen${_examens.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Onglet 1 : Informations du patient
  Widget _buildOngletInfos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildCarteInfo('Informations personnelles', [
            _buildLigne(Icons.person_outline, 'Nom complet', _patient!.nom),
            _buildLigne(Icons.cake_outlined, 'Âge', '${_patient!.age} ans'),
            _buildLigne(Icons.wc_outlined, 'Genre', _patient!.genre),
            _buildLigne(Icons.badge_outlined, 'CIN', _patient!.cin),
          ]),
          const SizedBox(height: 16),
          _buildCarteInfo('Contact', [
            _buildLigne(Icons.email_outlined, 'Email', _patient!.email),
            _buildLigne(Icons.phone_outlined, 'Téléphone', _patient!.telephone),
          ]),
          const SizedBox(height: 16),
          _buildCarteInfo('Informations médicales', [
            _buildLigne(
              Icons.medical_information_outlined,
              'Antécédents',
              _patient!.antecedents.isEmpty
                  ? 'Aucun antécédent renseigné'
                  : _patient!.antecedents,
            ),
            _buildLigne(
              Icons.calendar_today_outlined,
              'Patient depuis',
              _formaterDate(_patient!.dateCreation).split(' ')[0],
            ),
          ]),
          const SizedBox(height: 80), // Espace pour le FAB
        ],
      ),
    );
  }

  Widget _buildCarteInfo(String titre, List<Widget> lignes) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              titre,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          ...lignes,
        ],
      ),
    );
  }

  Widget _buildLigne(IconData icone, String label, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icone, size: 20, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valeur,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Onglet 2 : Historique des examens
  Widget _buildOngletHistorique() {
    if (_examens.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_outlined,
                size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Aucun examen effectué',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Appuyez sur "Nouvel examen" pour commencer',
              style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _examens.length,
      itemBuilder: (context, index) {
        final exam = _examens[index];
        final result = _resultats[exam.id];
        return _buildCarteExamen(exam, result);
      },
    );
  }

  Widget _buildCarteExamen(Exam exam, Result? result) {
    final couleur = _couleurSeverite(result?.severite);
    final bg = _bgSeverite(result?.severite);
    final label = _labelSeverite(result?.severite);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: result != null
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultsScreen(
                      examId: exam.id!,
                      patient: _patient!,
                      imagePath: exam.imagePath,
                    ),
                  ),
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête : date + badge statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 16, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 6),
                      Text(
                        _formaterDate(exam.dateExamen),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: couleur,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Diagnostic
              Text(
                result?.diagnostic ?? 'Analyse en attente...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: result != null
                      ? const Color(0xFF111827)
                      : const Color(0xFF9CA3AF),
                ),
              ),

              if (result != null) ...[
                const SizedBox(height: 8),
                // Barre de confiance
                Row(
                  children: [
                    const Text(
                      'Confiance : ',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: result.confidence / 100,
                          backgroundColor: const Color(0xFFE5E7EB),
                          color: couleur,
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${result.confidence.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: couleur,
                      ),
                    ),
                  ],
                ),
              ],

              if (exam.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  exam.notes,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              if (result != null) ...[
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Voir les résultats',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF0059FF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward,
                        size: 14, color: Color(0xFF0059FF)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}