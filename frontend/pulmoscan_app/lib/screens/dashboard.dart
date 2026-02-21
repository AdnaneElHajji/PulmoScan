// lib/screens/dashboard_responsive.dart
import 'package:flutter/material.dart';

class DashboardResponsive extends StatelessWidget {
  DashboardResponsive({super.key});

  final List<Map<String, dynamic>> _stats = [
    {
      'label': 'Examens ce mois',
      'value': '247',
      'change': '+12%',
      'icon': Icons.description_outlined,
      'color': Colors.blue,
      'trend': 'up',
    },
    {
      'label': 'Patients actifs',
      'value': '189',
      'change': '+5%',
      'icon': Icons.people_outline,
      'color': Colors.green,
      'trend': 'up',
    },
    {
      'label': 'Détections positives',
      'value': '34',
      'change': '-8%',
      'icon': Icons.warning_amber_outlined,
      'color': Colors.orange,
      'trend': 'down',
    },
    {
      'label': 'Précision IA',
      'value': '94.2%',
      'change': '+2%',
      'icon': Icons.auto_graph_outlined,
      'color': Colors.purple,
      'trend': 'up',
    },
  ];

  final List<Map<String, dynamic>> _recentScans = [
    {
      'patient': 'Mohammed Bennani',
      'date': '2026-01-11 14:30',
      'diagnosis': 'Pneumonie détectée',
      'confidence': '92%',
      'severity': 'high',
      'severityColor': Color(0xFFDC2626),
      'severityBg': Color(0xFFFEE2E2),
    },
    {
      'patient': 'Fatima Alami',
      'date': '2026-01-11 13:15',
      'diagnosis': 'Normal',
      'confidence': '98%',
      'severity': 'normal',
      'severityColor': Color(0xFF059669),
      'severityBg': Color(0xFFD1FAE5),
    },
    {
      'patient': 'Hassan El Idrissi',
      'date': '2026-01-11 11:45',
      'diagnosis': 'Tuberculose suspectée',
      'confidence': '87%',
      'severity': 'high',
      'severityColor': Color(0xFFDC2626),
      'severityBg': Color(0xFFFEE2E2),
    },
    {
      'patient': 'Amina Tazi',
      'date': '2026-01-11 10:20',
      'diagnosis': 'Normal',
      'confidence': '96%',
      'severity': 'normal',
      'severityColor': Color(0xFF059669),
      'severityBg': Color(0xFFD1FAE5),
    },
    {
      'patient': 'Youssef Berrada',
      'date': '2026-01-10 16:50',
      'diagnosis': 'Fibrose détectée',
      'confidence': '89%',
      'severity': 'medium',
      'severityColor': Color(0xFFD97706),
      'severityBg': Color(0xFFFEF3C7),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
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
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Color(0xFF6B7280)),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.search, color: Color(0xFF6B7280)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: _stats.map((stat) => _buildStatCard(stat)).toList(),
            ),
            
            SizedBox(height: 24),
            
            // Recent Exams Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Color(0xFFF3F4F6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Examens récents',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Dernières analyses effectuées',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Table
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 600) {
                        return _buildMobileList();
                      } else {
                        return _buildDesktopTable();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to new exam
        },
        backgroundColor: Color(0xFF0059FF),
        child: Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: stat['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  stat['icon'],
                  color: stat['color'],
                  size: 20,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (stat['trend'] == 'up' ? Colors.green : Colors.red)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      stat['trend'] == 'up' 
                          ? Icons.trending_up 
                          : Icons.trending_down,
                      size: 12,
                      color: stat['trend'] == 'up' ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 4),
                    Text(
                      stat['change'],
                      style: TextStyle(
                        fontSize: 12,
                        color: stat['trend'] == 'up' ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat['label'],
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
              SizedBox(height: 4),
              Text(
                stat['value'],
                style: TextStyle(
                  fontSize: 20,
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

  Widget _buildMobileList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      itemCount: _recentScans.length,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final scan = _recentScans[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xFFF3F4F6)),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    scan['patient'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: scan['severityBg'],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          scan['severity'] == 'high'
                              ? Icons.warning_amber
                              : Icons.check_circle,
                          size: 12,
                          color: scan['severityColor'],
                        ),
                        SizedBox(width: 4),
                        Text(
                          scan['severity'] == 'high'
                              ? 'Urgent'
                              : scan['severity'] == 'medium'
                                  ? 'À surveiller'
                                  : 'Normal',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: scan['severityColor'],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Date and Diagnosis
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Color(0xFF9CA3AF)),
                  SizedBox(width: 8),
                  Text(
                    scan['date'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(Icons.medical_services, size: 14, color: Color(0xFF9CA3AF)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      scan['diagnosis'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 8),
              
              // Confidence
              Row(
                children: [
                  Icon(Icons.percent, size: 14, color: Color(0xFF9CA3AF)),
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getConfidenceColor(scan['confidence']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      scan['confidence'],
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 56,
        dataRowHeight: 64,
        horizontalMargin: 24,
        columnSpacing: 32,
        columns: [
          DataColumn(
            label: Text('Patient',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          DataColumn(
            label: Text('Date & Heure',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          DataColumn(
            label: Text('Diagnostic IA',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          DataColumn(
            label: Text('Confiance',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          DataColumn(
            label: Text('Statut',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
        rows: _recentScans.map((scan) {
          return DataRow(
            cells: [
              DataCell(
                Text(scan['patient'],
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ),
              DataCell(Text(scan['date'])),
              DataCell(Text(scan['diagnosis'])),
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(scan['confidence']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    scan['confidence'],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scan['severityBg'],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        scan['severity'] == 'high'
                            ? Icons.warning_amber
                            : Icons.check_circle,
                        size: 14,
                        color: scan['severityColor'],
                      ),
                      SizedBox(width: 6),
                      Text(
                        scan['severity'] == 'high'
                            ? 'Urgent'
                            : scan['severity'] == 'medium'
                                ? 'À surveiller'
                                : 'Normal',
                        style: TextStyle(
                          color: scan['severityColor'],
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _getConfidenceColor(String confidence) {
    final percent = int.tryParse(confidence.replaceAll('%', '')) ?? 0;
    if (percent >= 90) return Colors.green;
    if (percent >= 80) return Colors.orange;
    return Colors.red;
  }
}