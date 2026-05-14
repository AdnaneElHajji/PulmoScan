import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardResponsive extends StatefulWidget {
  const DashboardResponsive({super.key});

  @override
  State<DashboardResponsive> createState() => _DashboardResponsiveState();
}

class _DashboardResponsiveState extends State<DashboardResponsive> {
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
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
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
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tableau de bord',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Vue d\'ensemble de vos examens pulmonaires',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF6B7280)),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0059FF)))
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadStats,
                  color: const Color(0xFF0059FF),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildStatsGrid(),
                        const SizedBox(height: 24),
                        _buildStatutCard(),
                        const SizedBox(height: 16),
                        _buildTopDiagnosticsCard(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFFD32F2F)),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadStats,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0059FF),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {
        'label': 'Total examens',
        'value': '$_totalExamens',
        'icon': Icons.description_outlined,
        'color': Colors.blue,
      },
      {
        'label': 'Patients actifs',
        'value': '$_totalPatients',
        'icon': Icons.people_outline,
        'color': Colors.green,
      },
      {
        'label': 'Résultats analysés',
        'value': '$_totalResultats',
        'icon': Icons.analytics_outlined,
        'color': Colors.orange,
      },
      {
        'label': 'Précision IA',
        'value': '94.2%',
        'icon': Icons.auto_graph_outlined,
        'color': Colors.purple,
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: stats.map(_buildStatCard).toList(),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (stat['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(stat['icon'] as IconData,
                color: stat['color'] as Color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat['label'] as String,
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 2),
              Text(
                stat['value'] as String,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatutCard() {
    if (_examensParStatut.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFF3F4F6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Examens par statut',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            ..._examensParStatut.map((item) {
              final statut = item['statut'] as String? ?? '';
              final total = item['total'].toString();
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _statutColor(statut),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _statutLabel(statut),
                        style:
                            const TextStyle(fontSize: 14, color: Color(0xFF374151)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statutColor(statut).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        total,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _statutColor(statut),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTopDiagnosticsCard() {
    if (_topDiagnostics.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFF3F4F6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top diagnostics IA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pathologies les plus détectées',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            ..._topDiagnostics.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final diag = item['diagnostic'] as String? ?? '';
              final total = item['total'].toString();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0059FF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0059FF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        diag,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF111827)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0059FF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$total cas',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0059FF),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _statutColor(String statut) {
    switch (statut) {
      case 'termine':
        return const Color(0xFF059669);
      case 'analyse':
        return const Color(0xFF0059FF);
      case 'en_attente':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _statutLabel(String statut) {
    switch (statut) {
      case 'termine':
        return 'Terminé';
      case 'analyse':
        return 'En analyse';
      case 'en_attente':
        return 'En attente';
      default:
        return statut;
    }
  }
}
