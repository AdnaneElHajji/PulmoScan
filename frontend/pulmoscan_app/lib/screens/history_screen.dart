import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';
import '../theme/v4_theme.dart';
import 'patient_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _exams = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await DatabaseService().getAllExamsWithPatient();
      setState(() {
        _exams = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V4.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Historique',
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                            color: V4.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Examens récents · PulmoScan AI',
                            style: V4.monoLabel),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _load,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: V4.surface1,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: V4.border),
                      ),
                      child: const Icon(Icons.refresh_rounded,
                          color: V4.inkMuted, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: V4.teal))
                  : _exams.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.history_rounded,
                                  size: 56, color: V4.surface3),
                              const SizedBox(height: 14),
                              Text('Aucun examen',
                                  style: GoogleFonts.inter(
                                      color: V4.inkSoft, fontSize: 14)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          color: V4.teal,
                          backgroundColor: V4.surface2,
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            itemCount: _exams.length,
                            itemBuilder: (context, i) => _ExamTile(
                              exam: _exams[i],
                              onTap: () async {
                                final raw = _exams[i]['patient_id'];
                                if (raw == null) return;
                                final pid = raw is int ? raw : int.tryParse(raw.toString());
                                if (pid == null) return;
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PatientDetailScreen(patientId: pid),
                                  ),
                                );
                                _load();
                              },
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamTile extends StatelessWidget {
  final Map<String, dynamic> exam;
  final VoidCallback? onTap;
  const _ExamTile({required this.exam, this.onTap});

  @override
  Widget build(BuildContext context) {
    final id = exam['id'];
    final statut = exam['statut'] as String? ?? '';
    final raw = exam['date_examen'] as String? ?? exam['created_at'] as String? ?? '';
    final date = raw.length >= 10 ? raw.substring(0, 10) : raw;
    final notes = exam['notes'] as String? ?? '';
    final patientNom = exam['patient_nom'] as String? ?? '';

    Color color;
    String statusLabel;
    IconData statusIcon;
    switch (statut) {
      case 'termine':
        color = V4.teal;
        statusLabel = 'Terminé';
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case 'analyse':
        color = V4.blue;
        statusLabel = 'Analyse';
        statusIcon = Icons.pending_outlined;
        break;
      case 'en_cours':
        color = V4.blue;
        statusLabel = 'En cours';
        statusIcon = Icons.autorenew_rounded;
        break;
      default:
        color = V4.amber;
        statusLabel = 'Attente';
        statusIcon = Icons.schedule_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: V4.surface1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: V4.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'EX-${id.toString().padLeft(5, '0')}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: V4.ink,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (patientNom.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          const Text('·',
                              style: TextStyle(fontSize: 12, color: V4.inkMuted)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              patientNom,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12, color: V4.inkSoft),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    if (notes.isNotEmpty)
                      Text(
                        notes.substring(0, math.min(40, notes.length)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(fontSize: 12, color: V4.inkSoft),
                      ),
                    Text(date, style: V4.monoLabel),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  V4.chip(statusLabel, color),
                  if (onTap != null) ...[
                    const SizedBox(height: 4),
                    const Icon(Icons.chevron_right,
                        color: V4.inkMuted, size: 16),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
