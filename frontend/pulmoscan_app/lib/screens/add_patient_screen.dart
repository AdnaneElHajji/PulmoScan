import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/database_service.dart';
import '../theme/v4_theme.dart';

class AddPatientScreen extends StatefulWidget {
  final Patient? patientAModifier;
  const AddPatientScreen({super.key, this.patientAModifier});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _nomCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _cinCtrl = TextEditingController();
  final _antCtrl = TextEditingController();
  String _genre = 'Homme';
  DateTime? _dateNaissance;

  bool get _isEdit => widget.patientAModifier != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final p = widget.patientAModifier!;
      _nomCtrl.text = p.nom;
      _ageCtrl.text = p.age.toString();
      _emailCtrl.text = p.email;
      _telCtrl.text = p.telephone;
      _cinCtrl.text = p.cin;
      _antCtrl.text = p.antecedents;
      _genre = p.genre;
      _dateNaissance = p.dateNaissance;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final body = {
        'nom': _nomCtrl.text.trim(),
        'age': int.parse(_ageCtrl.text.trim()),
        'genre': _genre,
        'email': _emailCtrl.text.trim(),
        'telephone': _telCtrl.text.trim(),
        'cin': _cinCtrl.text.trim(),
        'antecedents': _antCtrl.text.trim(),
        if (_dateNaissance != null)
          'date_naissance':
              '${_dateNaissance!.year.toString().padLeft(4, '0')}-'
              '${_dateNaissance!.month.toString().padLeft(2, '0')}-'
              '${_dateNaissance!.day.toString().padLeft(2, '0')}',
      };
      if (_isEdit) {
        await DatabaseService()
            .updatePatient(widget.patientAModifier!.id!, body);
      } else {
        await DatabaseService().createPatient(body);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEdit
              ? 'Patient modifié avec succès'
              : 'Patient ajouté avec succès'),
        ));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: V4.coral,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: Text(
          _isEdit ? 'Modifier le patient' : 'Nouveau patient',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('Informations personnelles'),
              const SizedBox(height: 14),

              _field('Nom complet *', _nomCtrl,
                  prefix: Icons.person_outline_rounded,
                  hint: 'Mohammed Bennani',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Nom obligatoire';
                    }
                    if (v.trim().length < 3) {
                      return 'Minimum 3 caractères';
                    }
                    return null;
                  }),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _field('Âge *', _ageCtrl,
                        prefix: Icons.cake_outlined,
                        hint: '45',
                        keyboard: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Obligatoire';
                          }
                          final a = int.tryParse(v.trim());
                          if (a == null || a < 0 || a > 120) {
                            return 'Invalide';
                          }
                          return null;
                        }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _genreDropdown()),
                ],
              ),
              const SizedBox(height: 14),

              _field('CIN *', _cinCtrl,
                  prefix: Icons.badge_outlined,
                  hint: 'AB123456',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty)
                          ? 'CIN obligatoire'
                          : null),
              const SizedBox(height: 14),

              _datePicker(),
              const SizedBox(height: 24),

              _section('Contact'),
              const SizedBox(height: 14),

              _field('Email *', _emailCtrl,
                  prefix: Icons.email_outlined,
                  hint: 'patient@email.ma',
                  keyboard: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email obligatoire';
                    }
                    if (!v.contains('@')) return 'Email invalide';
                    return null;
                  }),
              const SizedBox(height: 14),

              _field('Téléphone', _telCtrl,
                  prefix: Icons.phone_outlined,
                  hint: '+212 6 12 34 56 78',
                  keyboard: TextInputType.phone),
              const SizedBox(height: 24),

              _section('Informations médicales'),
              const SizedBox(height: 14),

              _multiField('Antécédents médicaux', _antCtrl,
                  hint: 'Tabagisme, allergies, maladies chroniques…'),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: V4.ghostBtn(
                      label: 'Annuler',
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: V4.primaryBtn(
                      label: _isEdit
                          ? 'Enregistrer'
                          : 'Créer le patient',
                      onTap: _isLoading ? null : _submit,
                      loading: _isLoading,
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

  Widget _section(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: V4.teal,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: V4.ink,
          ),
        ),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    IconData? prefix,
    String? hint,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: V4.inkSoft)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboard,
          validator: validator,
          style: const TextStyle(color: V4.ink, fontSize: 14),
          decoration: V4.inputDec(hint: hint, prefix: prefix),
        ),
      ],
    );
  }

  Widget _multiField(String label, TextEditingController ctrl,
      {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: V4.inkSoft)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          maxLines: 4,
          style: const TextStyle(color: V4.ink, fontSize: 14),
          decoration: V4.inputDec(hint: hint),
        ),
      ],
    );
  }

  Widget _genreDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Genre *',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: V4.inkSoft)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: _genre,
          dropdownColor: V4.surface2,
          style: const TextStyle(color: V4.ink, fontSize: 14),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: V4.inkMuted),
          decoration: V4.inputDec(prefix: Icons.wc_outlined),
          items: const [
            DropdownMenuItem(value: 'Homme', child: Text('Homme')),
            DropdownMenuItem(value: 'Femme', child: Text('Femme')),
            DropdownMenuItem(value: 'Autre', child: Text('Autre')),
          ],
          onChanged: (v) => setState(() => _genre = v!),
        ),
      ],
    );
  }

  Widget _datePicker() {
    final label = _dateNaissance == null
        ? 'Non renseignée'
        : '${_dateNaissance!.day.toString().padLeft(2, '0')}/'
            '${_dateNaissance!.month.toString().padLeft(2, '0')}/'
            '${_dateNaissance!.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date de naissance',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: V4.inkSoft)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _dateNaissance ??
                  DateTime.now().subtract(const Duration(days: 365 * 30)),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: V4.teal,
                    surface: V4.surface2,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) setState(() => _dateNaissance = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: V4.surface2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: V4.borderStrong),
            ),
            child: Row(
              children: [
                const Icon(Icons.cake_outlined, size: 18, color: V4.inkMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: _dateNaissance == null ? V4.inkMuted : V4.ink,
                    ),
                  ),
                ),
                if (_dateNaissance != null)
                  GestureDetector(
                    onTap: () => setState(() => _dateNaissance = null),
                    child: const Icon(Icons.close, size: 16, color: V4.inkMuted),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _ageCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    _cinCtrl.dispose();
    _antCtrl.dispose();
    super.dispose();
  }
}
