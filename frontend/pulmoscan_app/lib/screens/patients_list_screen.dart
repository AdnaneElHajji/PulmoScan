// lib/screens/patients_list_screen.dart
// Écran liste des patients avec recherche, filtres et navigation

import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/api_service.dart';
import 'add_patient_screen.dart';
import 'patient_detail_screen.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Patient> _patients = [];       // Tous les patients
  List<Patient> _patientsFiltres = []; // Patients après filtre/recherche
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerPatients();
  }

  // Charge les patients depuis l'API backend
  Future<void> _chargerPatients() async {
    setState(() => _isLoading = true);
    try {
      final query = _searchController.text.trim();
      final path = query.isNotEmpty
          ? '/patients?search=${Uri.encodeComponent(query)}'
          : '/patients';
      final data = await _api.get(path);
      final patients = (data as List)
          .map((e) => Patient.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _patients = patients;
        _patientsFiltres = patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _afficherErreur('Erreur lors du chargement des patients');
    }
  }

  // Déclenche une recherche via l'API
  void _filtrer() {
    _chargerPatients();
  }

  // Retourne la couleur selon l'âge (règle d'affichage)
  Color _couleurStatut(Patient patient) {
    if (patient.age > 60) return const Color(0xFFD32F2F); // Rouge = senior
    if (patient.age > 40) return const Color(0xFFD97706); // Orange = adulte
    return const Color(0xFF388E3C);                        // Vert = jeune
  }

  String _labelStatut(Patient patient) {
    if (patient.age > 60) return 'Sénior';
    if (patient.age > 40) return 'Adulte';
    return 'Jeune';
  }

  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFD32F2F),
      ),
    );
  }

  // Supprime un patient avec confirmation
  Future<void> _supprimerPatient(Patient patient) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le patient'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ${patient.nom} ?\n\nTous ses examens seront aussi supprimés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFD32F2F),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirme == true) {
      try {
        await _api.delete('/patients/${patient.id}');
        _chargerPatients(); // Recharge la liste
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${patient.nom} supprimé avec succès'),
              backgroundColor: const Color(0xFF388E3C),
            ),
          );
        }
      } catch (e) {
        _afficherErreur('Erreur lors de la suppression');
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patients',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            Text(
              '${_patients.length} patients au total',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Barre de recherche ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Champ recherche
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => _filtrer(),
                      decoration: const InputDecoration(
                        hintText: 'Rechercher un patient...',
                        hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF9CA3AF),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Bouton filtre
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.filter_list,
                      color: Color(0xFF6B7280),
                    ),
                     onSelected: (value) {
                        _filtrer();
                  },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'Tous', child: Text('Tous')),
                      const PopupMenuItem(value: 'Sénior', child: Text('Sénior (+60 ans)')),
                      const PopupMenuItem(value: 'Adulte', child: Text('Adulte (40-60 ans)')),
                      const PopupMenuItem(value: 'Jeune', child: Text('Jeune (-40 ans)')),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Liste des patients ──
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF0059FF),
                    ),
                  )
                : _patientsFiltres.isEmpty
                    ? _buildEtatVide()
                    : RefreshIndicator(
                        onRefresh: _chargerPatients,
                        color: const Color(0xFF0059FF),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _patientsFiltres.length,
                          itemBuilder: (context, index) {
                            return _buildCartePatient(_patientsFiltres[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),

      // ── Bouton flottant Nouveau patient ──
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigue vers l'écran d'ajout
          final resultat = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPatientScreen(),
            ),
          );
          // Si un patient a été ajouté, recharge la liste
          if (resultat == true) {
            _chargerPatients();
          }
        },
        backgroundColor: const Color(0xFF0059FF),
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }

  // Carte d'un patient dans la liste
  Widget _buildCartePatient(Patient patient) {
    final couleur = _couleurStatut(patient);
    final label = _labelStatut(patient);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          // Navigue vers le détail du patient
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDetailScreen(
                patientId: patient.id!,
              ),
            ),
          );
          _chargerPatients(); // Recharge au retour
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF0059FF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFF0059FF),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),

              // Infos patient
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.nom,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${patient.age} ans • ${patient.genre}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      patient.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Statut + menu
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Badge statut
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: couleur.withValues(alpha: 0.1),
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
                  const SizedBox(height: 8),
                  // Menu actions
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Color(0xFF9CA3AF),
                      size: 20,
                    ),
                    onSelected: (value) {
                      if (value == 'supprimer') {
                        _supprimerPatient(patient);
                      } else if (value == 'modifier') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddPatientScreen(
                              patientAModifier: patient,
                            ),
                          ),
                        ).then((_) => _chargerPatients());
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'modifier',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18, color: Color(0xFF0059FF)),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'supprimer',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Color(0xFFD32F2F)),
                            SizedBox(width: 8),
                            Text(
                              'Supprimer',
                              style: TextStyle(color: Color(0xFFD32F2F)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Affiché quand il n'y a aucun patient
  Widget _buildEtatVide() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'Aucun patient enregistré'
                : 'Aucun patient trouvé',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'Appuyez sur + pour ajouter un patient'
                : 'Essayez une autre recherche',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}