import 'dart:async';

import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../services/database_service.dart';
import '../theme/v4_theme.dart';
import '../widgets/aperture_mark.dart';
import 'add_patient_screen.dart';
import 'patient_detail_screen.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;
  List<Patient> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final q = _search.text.trim();
      final patients = await DatabaseService().getPatients(search: q);
      setState(() {
        _patients = patients;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _delete(Patient p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le patient'),
        content:
            Text('Supprimer ${p.nom} ? Ses examens seront aussi supprimés.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler',
                style: TextStyle(color: V4.inkMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer',
                style: TextStyle(color: V4.coral)),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await DatabaseService().deletePatient(p.id!);
        _load();
      } catch (_) {}
    }
  }

  // Derive initials + colour from patient
  String _initials(Patient p) {
    final parts = p.nom.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return p.nom.substring(0, p.nom.length >= 2 ? 2 : 1).toUpperCase();
  }

  Color _avatarColor(Patient p) {
    if (p.age > 60) return V4.coral;
    if (p.age > 40) return V4.amber;
    return V4.teal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V4.bg,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          const SizedBox(height: 4),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: V4.teal))
                : _patients.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: V4.teal,
                        backgroundColor: V4.surface2,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          itemCount: _patients.length,
                          itemBuilder: (_, i) =>
                              _buildCard(_patients[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: V4.bg,
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Patients',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                    color: V4.ink,
                  ),
                ),
                Text(
                  '${_patients.length} patients au total',
                  style: V4.monoLabel,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final ok = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddPatientScreen()),
              );
              if (ok == true) _load();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: V4.teal,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: V4.teal.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: V4.bg, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: V4.surface1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: V4.border),
        ),
        child: TextField(
          controller: _search,
          onChanged: (_) {
            _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 300), _load);
          },
          style: const TextStyle(color: V4.ink, fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Rechercher par nom, email…',
            hintStyle: TextStyle(color: V4.inkMuted),
            prefixIcon:
                Icon(Icons.search_rounded, color: V4.inkMuted, size: 20),
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Patient p) {
    final color = _avatarColor(p);
    final initials = _initials(p);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: V4.surface1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: V4.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PatientDetailScreen(patientId: p.id!),
            ),
          );
          _load();
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: color.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.nom,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: V4.ink,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${p.age} ans · ${p.genre} · ${p.cin}',
                      style: const TextStyle(
                          fontSize: 12, color: V4.inkMuted,
                          fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),

              // Menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    color: V4.inkMuted, size: 20),
                onSelected: (v) {
                  if (v == 'delete') {
                    _delete(p);
                  } else if (v == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddPatientScreen(patientAModifier: p),
                      ),
                    ).then((_) => _load());
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined,
                            size: 18, color: V4.blue),
                        SizedBox(width: 8),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18, color: V4.coral),
                        SizedBox(width: 8),
                        Text('Supprimer',
                            style: TextStyle(color: V4.coral)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ApertureMark(size: 80, active: []),
          const SizedBox(height: 20),
          Text(
            _search.text.isEmpty
                ? 'Aucun patient enregistré'
                : 'Aucun résultat',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: V4.inkSoft,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _search.text.isEmpty
                ? 'Appuyez sur + pour ajouter un patient'
                : 'Essayez une autre recherche',
            style: const TextStyle(fontSize: 13, color: V4.inkMuted),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }
}
