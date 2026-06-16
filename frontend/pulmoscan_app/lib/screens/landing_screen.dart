import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';
import '../theme/v4_theme.dart';
import '../widgets/aperture_mark.dart';
import 'login.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  void _goToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPageExact(
          onLogin: (ctx) =>
              Navigator.pushNamedAndRemoveUntil(ctx, '/app', (_) => false),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V4.bg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: GridBackground())),
          // Teal glow top-right
          const Positioned(
            top: 0, left: 0, right: 0, height: 340,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.5, -0.5),
                  radius: 1.0,
                  colors: [Color(0x1A34E5C5), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 32),
                  _buildHero(context),
                  const SizedBox(height: 32),
                  _buildSpecialties(),
                  const SizedBox(height: 32),
                  _buildDoctors(),
                  const SizedBox(height: 32),
                  _AppointmentForm(),
                  const SizedBox(height: 32),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          const ApertureMark(size: 36, active: [1, 4, 7]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Centre Al Kendi',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: V4.ink,
                    letterSpacing: -0.3,
                  ),
                ),
                Text('Clinique médicale · Rabat', style: V4.monoLabel),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _goToLogin(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: V4.teal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: V4.teal.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Espace médecin',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: V4.teal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero ───────────────────────────────────────────────────────────────────
  Widget _buildHero(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon badge
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: V4.teal.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: V4.teal.withValues(alpha: 0.35)),
          ),
          child: const Icon(Icons.air_rounded, color: V4.teal, size: 28),
        ),
        const SizedBox(height: 20),
        Text(
          'Votre santé,\nnotre priorité.',
          style: GoogleFonts.inter(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: V4.ink,
            letterSpacing: -1.0,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Centre médical spécialisé en pneumologie et radiologie thoracique. '
          'Diagnostic IA DenseNet121 · 14 pathologies détectées.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: V4.inkSoft,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 28),
        // Stat pills
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            _statPill('+12K', 'Patients', V4.teal),
            _statPill('14', 'Pathologies IA', V4.blue),
            _statPill('98%', 'Satisfaction', V4.amber),
          ],
        ),
        const SizedBox(height: 28),
        // CTA buttons
        Row(
          children: [
            Expanded(
              child: V4.primaryBtn(
                label: 'Prendre rendez-vous',
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: V4.ghostBtn(
                label: 'Espace médecin',
                onTap: () => _goToLogin(context),
                color: V4.teal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statPill(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: V4.inkMuted),
          ),
        ],
      ),
    );
  }

  // ── Specialties ────────────────────────────────────────────────────────────
  static const _specs = [
    {'icon': Icons.air_rounded,               'title': 'Pneumologie',       'color': V4.teal},
    {'icon': Icons.monitor_heart_rounded,     'title': 'Radiologie IA',     'color': V4.blue},
    {'icon': Icons.favorite_rounded,          'title': 'Cardiologie',       'color': V4.coral},
    {'icon': Icons.medical_services_rounded,  'title': 'Médecine générale', 'color': V4.amber},
    {'icon': Icons.emergency_rounded,         'title': 'Urgences',          'color': V4.violet},
    {'icon': Icons.science_rounded,           'title': 'Biologie',          'color': V4.blue},
  ];

  Widget _buildSpecialties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('NOS SPÉCIALITÉS'),
        const SizedBox(height: 10),
        Text(
          'Une prise en charge complète',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: V4.ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.0,
          children: _specs.map((s) {
            final color = s['color'] as Color;
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: V4.surface1,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: V4.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(s['icon'] as IconData, color: color, size: 17),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      s['title'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: V4.ink,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Doctors ────────────────────────────────────────────────────────────────
  static const _doctors = [
    {'name': 'Dr. Kenza Foudali',    'spec': 'Pneumologue',      'exp': '12 ans', 'color': V4.teal},
    {'name': 'Dr. Adnane El Hajji', 'spec': 'Radiologue IA',    'exp': '8 ans',  'color': V4.blue},
    {'name': 'Dr. Fatima Benali',   'spec': 'Cardiologue',      'exp': '15 ans', 'color': V4.coral},
    {'name': 'Dr. Youssef Alami',   'spec': 'Méd. général',     'exp': '10 ans', 'color': V4.amber},
  ];

  Widget _buildDoctors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('NOTRE ÉQUIPE'),
        const SizedBox(height: 10),
        Text(
          'Des médecins experts',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: V4.ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _doctors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final d = _doctors[i];
              final color = d['color'] as Color;
              final parts = (d['name'] as String).split(' ');
              final initials = parts.length >= 3
                  ? '${parts[1][0]}${parts[2][0]}'
                  : parts.last.isNotEmpty ? parts.last[0] : '?';
              return Container(
                width: 140,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: V4.surface1,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: V4.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                      ),
                      child: Center(
                        child: Text(
                          initials.toUpperCase(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      d['name'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: V4.ink,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(d['spec'] as String,
                        style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w600)),
                    Text('${d['exp']} d\'exp.',
                        style: const TextStyle(
                            fontSize: 10, color: V4.inkMuted)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
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
          Row(
            children: [
              const ApertureMark(size: 28, active: [1, 4, 7]),
              const SizedBox(width: 8),
              Text(
                'Centre Al Kendi',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: V4.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _footerRow(Icons.location_on_outlined,
              'Rue Ibn Sina, Quartier Médical, Rabat 10000'),
          const SizedBox(height: 10),
          _footerRow(Icons.phone_outlined, '+212 5 37 00 00 00'),
          const SizedBox(height: 10),
          _footerRow(Icons.access_time_rounded,
              'Lun–Ven : 08h–19h  ·  Sam : 09h–14h'),
          const SizedBox(height: 10),
          _footerRow(Icons.email_outlined, 'contact@alkendi-centre.ma'),
          const SizedBox(height: 16),
          Container(height: 1, color: V4.border),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '© 2026 Centre Al Kendi',
                  style: const TextStyle(fontSize: 11, color: V4.inkMuted),
                ),
              ),
              V4.chip('PulmoScan AI', V4.teal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: V4.teal),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: V4.inkSoft, height: 1.5),
          ),
        ),
      ],
    );
  }

  // ── Helper ─────────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Text(text, style: V4.monoLabel);
  }
}

// ── Appointment form (stateful) ────────────────────────────────────────────────
class _AppointmentForm extends StatefulWidget {
  @override
  State<_AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<_AppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _cinCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  String _genre = 'Homme';
  String _specialite = 'Pneumologie';
  DateTime? _date;
  bool _loading = false;

  // "Urgences" retiré volontairement
  static const _specialites = [
    'Pneumologie', 'Radiologie', 'Cardiologie',
    'Médecine générale', 'Biologie',
  ];

  @override
  void dispose() {
    _nomCtrl.dispose();
    _cinCtrl.dispose();
    _ageCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
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
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir une date')),
      );
      return;
    }
    setState(() => _loading = true);

    final d = _date!;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    try {
      await DatabaseService().createPatient({
        'nom': _nomCtrl.text.trim(),
        'age': int.tryParse(_ageCtrl.text.trim()) ?? 0,
        'genre': _genre,
        'email': _emailCtrl.text.trim(),
        'telephone': _telCtrl.text.trim(),
        'cin': _cinCtrl.text.trim(),
        'antecedents':
            'Demande de RDV : $_specialite — souhaité le $dateStr (via site web)',
        'date_naissance': '',
      });

      if (!mounted) return;
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: V4.teal, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Demande enregistrée pour ${_nomCtrl.text.trim()} le $dateStr',
                  style: const TextStyle(color: V4.ink),
                ),
              ),
            ],
          ),
          backgroundColor: V4.surface2,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      _formKey.currentState!.reset();
      _nomCtrl.clear();
      _cinCtrl.clear();
      _ageCtrl.clear();
      _emailCtrl.clear();
      _telCtrl.clear();
      setState(() {
        _genre = 'Homme';
        _specialite = 'Pneumologie';
        _date = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg.contains('existe déjà')
              ? 'Un patient avec cet email existe déjà.'
              : 'Erreur : $msg'),
          backgroundColor: V4.coral,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _date == null
        ? 'Choisir une date'
        : '${_date!.day.toString().padLeft(2, '0')}/'
            '${_date!.month.toString().padLeft(2, '0')}/'
            '${_date!.year}';

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
          Text('RENDEZ-VOUS', style: V4.monoLabel),
          const SizedBox(height: 8),
          Text(
            'Prendre rendez-vous',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: V4.ink,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Vos informations sont transmises à notre équipe médicale.',
            style: TextStyle(fontSize: 13, color: V4.inkSoft),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nomCtrl,
                  style: const TextStyle(color: V4.ink, fontSize: 14),
                  decoration: V4.inputDec(
                    hint: 'Mohammed Alami',
                    label: 'NOM COMPLET',
                    prefix: Icons.person_outline_rounded,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nom obligatoire' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _cinCtrl,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(color: V4.ink, fontSize: 14),
                  decoration: V4.inputDec(
                    hint: 'AB123456',
                    label: 'CIN',
                    prefix: Icons.badge_outlined,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'CIN obligatoire' : null,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ageCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: V4.ink, fontSize: 14),
                        decoration: V4.inputDec(
                          hint: '45',
                          label: 'ÂGE',
                          prefix: Icons.cake_outlined,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Requis';
                          final n = int.tryParse(v.trim());
                          if (n == null || n <= 0 || n > 120) return 'Invalide';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: V4.surface1,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: V4.borderStrong),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            dropdownColor: V4.surface2,
                            value: _genre,
                            style: const TextStyle(color: V4.ink, fontSize: 14),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: V4.inkMuted),
                            items: const [
                              DropdownMenuItem(
                                  value: 'Homme', child: Text('Homme')),
                              DropdownMenuItem(
                                  value: 'Femme', child: Text('Femme')),
                            ],
                            onChanged: (v) => setState(() => _genre = v!),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: V4.ink, fontSize: 14),
                  decoration: V4.inputDec(
                    hint: 'patient@email.com',
                    label: 'EMAIL',
                    prefix: Icons.mail_outline_rounded,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email obligatoire';
                    if (!v.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _telCtrl,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: V4.ink, fontSize: 14),
                  decoration: V4.inputDec(
                    hint: '+212 6 12 34 56 78',
                    label: 'TÉLÉPHONE',
                    prefix: Icons.phone_outlined,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Téléphone obligatoire' : null,
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: V4.surface1,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: V4.borderStrong),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: V4.surface2,
                      value: _specialite,
                      style: const TextStyle(color: V4.ink, fontSize: 14),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: V4.inkMuted),
                      items: _specialites.map((s) {
                        return DropdownMenuItem(value: s, child: Text(s));
                      }).toList(),
                      onChanged: (v) => setState(() => _specialite = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: V4.surface1,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _date != null ? V4.teal : V4.borderStrong,
                        width: _date != null ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 18,
                            color: _date != null ? V4.teal : V4.inkMuted),
                        const SizedBox(width: 12),
                        Text(
                          dateLabel,
                          style: TextStyle(
                            fontSize: 14,
                            color: _date != null ? V4.ink : V4.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                V4.primaryBtn(
                  label: 'Confirmer le rendez-vous',
                  onTap: _loading ? null : _confirm,
                  loading: _loading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
