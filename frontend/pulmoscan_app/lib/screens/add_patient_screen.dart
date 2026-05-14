// lib/screens/add_patient_screen.dart
// Écran formulaire pour ajouter OU modifier un patient
// Si on passe un patientAModifier, le formulaire se remplit automatiquement

import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/api_service.dart';

class AddPatientScreen extends StatefulWidget {
  final Patient? patientAModifier; // null = mode ajout, sinon = mode modification

  const AddPatientScreen({super.key, this.patientAModifier});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();
  bool _isLoading = false;

  // Contrôleurs pour chaque champ du formulaire
  final _nomController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _cinController = TextEditingController();
  final _antecedentsController = TextEditingController();

  String _genre = 'Homme'; // Valeur par défaut

  // Détermine si on est en mode modification
  bool get _estModification => widget.patientAModifier != null;

  @override
  void initState() {
    super.initState();
    // Si modification : pré-remplir les champs avec les données existantes
    if (_estModification) {
      final p = widget.patientAModifier!;
      _nomController.text = p.nom;
      _ageController.text = p.age.toString();
      _emailController.text = p.email;
      _telephoneController.text = p.telephone;
      _cinController.text = p.cin;
      _antecedentsController.text = p.antecedents;
      _genre = p.genre;
    }
  }

  // Soumet le formulaire (ajout ou modification)
  Future<void> _soumettre() async {
    // Vérifie que tous les champs obligatoires sont remplis
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final body = {
        'nom': _nomController.text.trim(),
        'age': int.parse(_ageController.text.trim()),
        'genre': _genre,
        'email': _emailController.text.trim(),
        'telephone': _telephoneController.text.trim(),
        'cin': _cinController.text.trim(),
        'antecedents': _antecedentsController.text.trim(),
      };

      if (_estModification) {
        await _api.put('/patients/${widget.patientAModifier!.id}', body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Patient modifié avec succès ✓'),
              backgroundColor: Color(0xFF388E3C),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        await _api.post('/patients', body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Patient ajouté avec succès ✓'),
              backgroundColor: Color(0xFF388E3C),
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      // Affiche l'erreur (ex: email déjà existant)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: Text(
          _estModification ? 'Modifier le patient' : 'Nouveau patient',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section Informations personnelles ──
              _buildSectionTitre('Informations personnelles'),
              const SizedBox(height: 16),

              // Nom complet
              _buildChamp(
                label: 'Nom complet *',
                controller: _nomController,
                icone: Icons.person_outline,
                hint: 'Ex: Mohammed Bennani',
                validateur: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Le nom est obligatoire';
                  }
                  if (val.trim().length < 3) {
                    return 'Le nom doit contenir au moins 3 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Âge et Genre sur la même ligne
              Row(
                children: [
                  // Âge
                  Expanded(
                    child: _buildChamp(
                      label: 'Âge *',
                      controller: _ageController,
                      icone: Icons.cake_outlined,
                      hint: 'Ex: 45',
                      clavier: TextInputType.number,
                      validateur: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Âge obligatoire';
                        }
                        final age = int.tryParse(val.trim());
                        if (age == null || age < 0 || age > 120) {
                          return 'Âge invalide';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Genre
                  Expanded(
                    child: _buildDropdownGenre(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // CIN
              _buildChamp(
                label: 'CIN *',
                controller: _cinController,
                icone: Icons.badge_outlined,
                hint: 'Ex: AB123456',
                validateur: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'La CIN est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ── Section Contact ──
              _buildSectionTitre('Contact'),
              const SizedBox(height: 16),

              // Email
              _buildChamp(
                label: 'Email *',
                controller: _emailController,
                icone: Icons.email_outlined,
                hint: 'Ex: patient@email.ma',
                clavier: TextInputType.emailAddress,
                validateur: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'L\'email est obligatoire';
                  }
                  if (!val.contains('@') || !val.contains('.')) {
                    return 'Email invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Téléphone
              _buildChamp(
                label: 'Téléphone',
                controller: _telephoneController,
                icone: Icons.phone_outlined,
                hint: 'Ex: +212 6 12 34 56 78',
                clavier: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // ── Section Médical ──
              _buildSectionTitre('Informations médicales'),
              const SizedBox(height: 16),

              // Antécédents médicaux
              _buildChampMultiLigne(
                label: 'Antécédents médicaux',
                controller: _antecedentsController,
                hint: 'Tabagisme, allergies, maladies chroniques...',
              ),
              const SizedBox(height: 32),

              // ── Boutons ──
              Row(
                children: [
                  // Bouton Annuler
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Bouton Enregistrer
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _soumettre,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0059FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _estModification
                                      ? Icons.save_outlined
                                      : Icons.person_add_outlined,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _estModification
                                      ? 'Enregistrer'
                                      : 'Créer le patient',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widgets réutilisables ──

  // Titre de section
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

  // Champ de texte standard
  Widget _buildChamp({
    required String label,
    required TextEditingController controller,
    required IconData icone,
    required String hint,
    TextInputType clavier = TextInputType.text,
    String? Function(String?)? validateur,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: clavier,
          validator: validateur,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            prefixIcon: Icon(icone, color: const Color(0xFF9CA3AF), size: 20),
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
              borderSide: const BorderSide(
                color: Color(0xFF0059FF),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD32F2F)),
            ),
          ),
        ),
      ],
    );
  }

  // Champ multi-lignes pour les antécédents
  Widget _buildChampMultiLigne({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: hint,
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
              borderSide: const BorderSide(
                color: Color(0xFF0059FF),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Dropdown pour le genre
  Widget _buildDropdownGenre() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Genre *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD1D5DB)),
          ),
          child: DropdownButtonFormField<String>(
            value: _genre,
            decoration: const InputDecoration(
              prefixIcon: Icon(
                Icons.wc_outlined,
                color: Color(0xFF9CA3AF),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 4),
            ),
            items: const [
              DropdownMenuItem(value: 'Homme', child: Text('Homme')),
              DropdownMenuItem(value: 'Femme', child: Text('Femme')),
              DropdownMenuItem(value: 'Autre', child: Text('Autre')),
            ],
            onChanged: (val) => setState(() => _genre = val!),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _cinController.dispose();
    _antecedentsController.dispose();
    super.dispose();
  }
}