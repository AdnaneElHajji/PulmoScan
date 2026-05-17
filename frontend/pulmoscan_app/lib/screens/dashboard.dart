import 'package:flutter/material.dart';
import '../theme/v4_theme.dart';
import '../widgets/aperture_mark.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  String? _error;
  int _totalPatients = 0;
  int _totalExamens = 0;
  int _totalResultats = 0;
  List<Map<String, dynamic>> _topDiagnostics = [];
  List<Map<String, dynamic>> _examensParStatut = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _api.get('/stats');
      setState(() {
        _totalPatients = data['total_patients'] ?? 0;
        _totalExamens = data['total_examens'] ?? 0;
        _totalResultats = data['total_resultats'] ?? 0;
        _topDiagnostics =
            List<Map<String, dynamic>>.from(data['top_diagnostics'] ?? []);
        _examensParStatut =
            List<Map<String, dynamic>>.from(data['examens_par_statut'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V4.bg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: GridBackground())),
          const Positioned(
            top: 0, left: 0, right: 0,
            height: 320,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.6, -0.6),
                  radius: 1.0,
                  colors: [Color(0x1E34E5C5), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: V4.teal))
                : _error != null
                    ? _buildError()
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: V4.teal,
                        backgroundColor: V4.surface2,
                        child: _buildContent(),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildStatsRow(),
        const SizedBox(height: 20),
        _buildMarkSection(),
        const SizedBox(height: 20),
        if (_examensParStatut.isNotEmpty) _buildStatusCard(),
        if (_examensParStatut.isNotEmpty) const SizedBox(height: 16),
        if (_topDiagnostics.isNotEmpty) _buildTopDiagCard(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tableau de bord',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                    color: V4.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vue d\'ensemble · PulmoScan AI',
                  style: V4.monoLabel,
                ),
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
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      {'n': '$_totalExamens', 'l': 'examens', 'c': V4.blue},
      {'n': '$_totalPatients', 'l': 'patients', 'c': V4.teal},
      {'n': '$_totalResultats', 'l': 'résultats', 'c': V4.amber},
      {'n': '0.91', 'l': 'AUC', 'c': V4.violet},
    ];

    return Row(
      children: stats.asMap().entries.map((e) {
        final s = e.value;
        final color = s['c'] as Color;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(left: e.key == 0 ? 0 : 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: V4.surface1,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: V4.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s['n'] as String,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  (s['l'] as String).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.2,
                    color: V4.inkMuted,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMarkSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: V4.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: V4.border),
      ),
      child: Row(
        children: [
          const ApertureMark(size: 80, active: [1, 4, 7, 11]),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '14 pathologies',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: V4.ink,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'EfficientNetB1 · TFLite',
                  style: TextStyle(
                    fontSize: 11,
                    color: V4.inkMuted,
                    fontFamily: 'monospace',
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _pillStat('AUC', '0.91', V4.teal),
                    const SizedBox(width: 8),
                    _pillStat('NIH', '112K', V4.blue),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillStat(String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label $val',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          fontFamily: 'monospace',
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: V4.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: V4.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Examens par statut',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: V4.ink,
            ),
          ),
          const SizedBox(height: 16),
          ..._examensParStatut.map((item) {
            final statut = item['statut'] as String? ?? '';
            final total = item['total'].toString();
            final color = _statutColor(statut);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(_statutLabel(statut),
                        style:
                            const TextStyle(fontSize: 13, color: V4.inkSoft)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      total,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTopDiagCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: V4.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: V4.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top diagnostics IA',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: V4.ink,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pathologies les plus détectées',
            style: TextStyle(fontSize: 12, color: V4.inkMuted),
          ),
          const SizedBox(height: 16),
          ..._topDiagnostics.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final diag = item['diagnostic'] as String? ?? '';
            final total = item['total'].toString();
            final color = i < V4.pathColors.length
                ? V4.pathColors[i]
                : V4.teal;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(diag,
                        style: const TextStyle(
                            fontSize: 14, color: V4.inkSoft)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$total cas',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 60, color: V4.inkMuted),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: V4.inkSoft, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            V4.primaryBtn(label: 'Réessayer', onTap: _load, fullWidth: false),
          ],
        ),
      ),
    );
  }

  Color _statutColor(String s) {
    switch (s) {
      case 'termine': return V4.teal;
      case 'analyse': return V4.blue;
      case 'en_attente': return V4.amber;
      default: return V4.inkMuted;
    }
  }

  String _statutLabel(String s) {
    switch (s) {
      case 'termine': return 'Terminé';
      case 'analyse': return 'En analyse';
      case 'en_attente': return 'En attente';
      default: return s;
    }
  }
}
