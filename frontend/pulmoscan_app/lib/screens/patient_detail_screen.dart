import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/exam.dart';
import '../models/result.dart';
import '../services/api_service.dart';
import '../theme/v4_theme.dart';
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
  final ApiService _api = ApiService();
  late TabController _tab;
  Patient? _patient;
  List<Exam> _examens = [];
  Map<int, Result?> _resultats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final pd =
          await _api.get('/patients/${widget.patientId}');
      final patient =
          Patient.fromJson(pd as Map<String, dynamic>);
      final ed =
          await _api.get('/exams/patient/${widget.patientId}');
      final examens = (ed as List)
          .map((e) => Exam.fromJson(e as Map<String, dynamic>))
          .toList();
      final Map<int, Result?> resultats = {};
      for (var ex in examens) {
        try {
          final rd = await _api.get('/results/exam/${ex.id}');
          final list = rd as List;
          resultats[ex.id!] = list.isNotEmpty
              ? Result.fromJson(list[0] as Map<String, dynamic>)
              : null;
        } catch (_) {
          resultats[ex.id!] = null;
        }
      }
      setState(() {
        _patient = patient;
        _examens = examens;
        _resultats = resultats;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  String _initials(Patient p) {
    final parts = p.nom.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return p.nom.substring(0, p.nom.length >= 2 ? 2 : 1).toUpperCase();
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: V4.bg,
        body: Center(child: CircularProgressIndicator(color: V4.teal)),
      );
    }
    if (_patient == null) {
      return Scaffold(
        backgroundColor: V4.bg,
        appBar: AppBar(title: const Text('Patient introuvable')),
        body: const Center(
            child: Text('Ce patient n\'existe pas',
                style: TextStyle(color: V4.inkSoft))),
      );
    }

    return Scaffold(
      backgroundColor: V4.bg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [_buildSliverHeader()],
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _buildInfoTab(),
                  _buildHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ExamScreen(patientPreSelectionne: _patient),
            ),
          );
          _load();
        },
        backgroundColor: V4.teal,
        foregroundColor: V4.bg,
        elevation: 0,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Nouvel examen',
            style:
                TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      ),
    );
  }

  Widget _buildSliverHeader() {
    final p = _patient!;
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: V4.bg,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: V4.inkSoft, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined,
              color: V4.blue, size: 20),
          onPressed: () async {
            final ok = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      AddPatientScreen(patientAModifier: p)),
            );
            if (ok == true) _load();
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: V4.bg,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: V4.coral.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: V4.coral.withValues(alpha: 0.3)),
                        ),
                        child: Center(
                          child: Text(
                            _initials(p),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: V4.coral,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.nom,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                                color: V4.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${p.age} ans · ${p.genre} · ${p.cin}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: V4.inkMuted,
                                fontFamily: 'monospace',
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _statPill('${_examens.length}', 'examens',
                          V4.teal),
                      const SizedBox(width: 8),
                      _statPill(p.age.toString(), 'ans', V4.blue),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statPill(String n, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(n,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
                fontFamily: 'monospace',
              )),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: V4.inkMuted)),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: V4.bg,
      child: TabBar(
        controller: _tab,
        tabs: [
          const Tab(text: 'Informations'),
          Tab(text: 'Historique (${_examens.length})'),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    final p = _patient!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoCard('Identité', [
          _row(Icons.person_outline_rounded, 'Nom', p.nom),
          _row(Icons.cake_outlined, 'Âge', '${p.age} ans'),
          _row(Icons.wc_outlined, 'Genre', p.genre),
          _row(Icons.badge_outlined, 'CIN', p.cin),
        ]),
        const SizedBox(height: 12),
        _infoCard('Contact', [
          _row(Icons.email_outlined, 'Email', p.email),
          _row(Icons.phone_outlined, 'Téléphone',
              p.telephone.isEmpty ? '—' : p.telephone),
        ]),
        const SizedBox(height: 12),
        _infoCard('Médical', [
          _row(
            Icons.medical_information_outlined,
            'Antécédents',
            p.antecedents.isEmpty
                ? 'Aucun antécédent renseigné'
                : p.antecedents,
          ),
          _row(Icons.calendar_today_outlined, 'Patient depuis',
              _fmtDate(p.dateCreation)),
        ]),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _infoCard(String title, List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: V4.surface1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: V4.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: V4.teal,
                letterSpacing: 0.4,
              ),
            ),
          ),
          Container(height: 1, color: V4.border),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: V4.inkMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: V4.inkMuted)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: V4.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_examens.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_outlined,
                size: 64, color: V4.surface3),
            SizedBox(height: 16),
            Text('Aucun examen effectué',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: V4.inkSoft)),
            SizedBox(height: 8),
            Text('Appuyez sur "Nouvel examen" pour commencer',
                style: TextStyle(
                    fontSize: 13, color: V4.inkMuted)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: _examens.length,
      itemBuilder: (_, i) =>
          _examCard(_examens[i], _resultats[_examens[i].id!]),
    );
  }

  Widget _examCard(Exam exam, Result? result) {
    final color = V4.severityColor(result?.severite);
    final label = V4.severityLabel(result?.severite);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: V4.surface1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: V4.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: result != null
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultsScreen(
                      examId: exam.id!,
                      patient: _patient!,
                      imagePath: exam.imagePath,
                    ),
                  ),
                )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _fmtDate(exam.dateExamen),
                    style: const TextStyle(
                        fontSize: 12,
                        color: V4.inkMuted,
                        fontFamily: 'monospace'),
                  ),
                  const Spacer(),
                  V4.chip(label, color),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                result?.diagnostic ?? 'Analyse en attente…',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: result != null ? V4.ink : V4.inkMuted,
                ),
              ),
              if (result != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Confiance ',
                        style: TextStyle(
                            fontSize: 12, color: V4.inkMuted)),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: result.confidence / 100,
                          backgroundColor: V4.surface3,
                          color: color,
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${result.confidence.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Voir les résultats →',
                        style: TextStyle(
                            fontSize: 12,
                            color: V4.teal,
                            fontWeight: FontWeight.w600)),
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
    _tab.dispose();
    super.dispose();
  }
}
