import 'package:flutter/material.dart';
import 'login.dart';

// ── Design tokens (light theme) ───────────────────────────────────────────────
const _blue = Color(0xFF0059FF);
const _blueLight = Color(0xFFEBF3FF);
const _bgWhite = Color(0xFFFFFFFF);
const _bgGrey = Color(0xFFF8FAFC);
const _textDark = Color(0xFF0F172A);
const _textMid = Color(0xFF475569);
const _textLight = Color(0xFF94A3B8);
const _border = Color(0xFFE2E8F0);

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
      backgroundColor: _bgWhite,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroSection(onLoginTap: () => _goToLogin(context)),
            const _SpecialtiesSection(),
            const _DoctorsSection(),
            _AppointmentSection(),
            const _FooterSection(),
          ],
        ),
      ),
    );
  }
}

// ── Hero ──────────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final VoidCallback onLoginTap;
  const _HeroSection({required this.onLoginTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF003CC5), Color(0xFF0059FF), Color(0xFF2E80FF)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_hospital_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Centre Al Kendi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onLoginTap,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.4)),
                      ),
                    ),
                    child: const Text('Connexion',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Lung icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                ),
                child: const Icon(Icons.air_rounded,
                    color: Colors.white, size: 36),
              ),

              const SizedBox(height: 24),

              const Text(
                'Votre santé,\nnotre priorité.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'Centre médical spécialisé en pneumologie et radiologie '
                'thoracique. Diagnostic IA avancé, soins personnalisés.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.80),
                  fontSize: 15,
                  height: 1.55,
                ),
              ),

              const SizedBox(height: 36),

              // CTA buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Scroll to appointment section
                      },
                      icon: const Icon(Icons.calendar_month_rounded, size: 18),
                      label: const Text('Prendre rendez-vous'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onLoginTap,
                      icon: const Icon(Icons.medical_services_rounded, size: 18),
                      label: const Text('Espace médecin'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Stats row
              Row(
                children: const [
                  _StatBadge(value: '+12K', label: 'Patients'),
                  SizedBox(width: 24),
                  _StatBadge(value: '14', label: 'Pathologies IA'),
                  SizedBox(width: 24),
                  _StatBadge(value: '98%', label: 'Satisfaction'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  const _StatBadge({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            )),
        Text(label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 11,
            )),
      ],
    );
  }
}

// ── Specialties ───────────────────────────────────────────────────────────────
class _SpecialtiesSection extends StatelessWidget {
  const _SpecialtiesSection();

  static const _specs = [
    {'icon': Icons.air_rounded, 'title': 'Pneumologie', 'desc': 'Maladies respiratoires et pulmonaires'},
    {'icon': Icons.monitor_heart_rounded, 'title': 'Radiologie', 'desc': 'Imagerie médicale avancée'},
    {'icon': Icons.favorite_rounded, 'title': 'Cardiologie', 'desc': 'Santé cardiovasculaire'},
    {'icon': Icons.medical_services_rounded, 'title': 'Médecine générale', 'desc': 'Soins primaires et prévention'},
    {'icon': Icons.emergency_rounded, 'title': 'Urgences', 'desc': 'Prise en charge rapide 24h/24'},
    {'icon': Icons.science_rounded, 'title': 'Biologie', 'desc': 'Analyses et bilans biologiques'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgGrey,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(label: 'NOS SPÉCIALITÉS'),
          const SizedBox(height: 8),
          const Text(
            'Une prise en charge complète',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: _specs.map((s) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _bgWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _blueLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(s['icon'] as IconData,
                          color: _blue, size: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      s['title'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      s['desc'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: _textLight,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Doctors ───────────────────────────────────────────────────────────────────
class _DoctorsSection extends StatelessWidget {
  const _DoctorsSection();

  static const _doctors = [
    {'name': 'Dr. Kenza Foudali', 'spec': 'Pneumologue', 'exp': '12 ans', 'color': 0xFF0059FF},
    {'name': 'Dr. Adnane El Hajji', 'spec': 'Radiologue IA', 'exp': '8 ans', 'color': 0xFF7C3AED},
    {'name': 'Dr. Fatima Benali', 'spec': 'Cardiologue', 'exp': '15 ans', 'color': 0xFF059669},
    {'name': 'Dr. Youssef Alami', 'spec': 'Médecin général', 'exp': '10 ans', 'color': 0xFFD97706},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgWhite,
      padding: const EdgeInsets.fromLTRB(24, 40, 0, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(label: 'NOTRE ÉQUIPE'),
                const SizedBox(height: 8),
                const Text(
                  'Des médecins experts\nà votre service',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(right: 24),
              itemCount: _doctors.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final d = _doctors[i];
                final color = Color(d['color'] as int);
                final initials = (d['name'] as String)
                    .split(' ')
                    .where((p) => p.startsWith('Dr') == false && p.isNotEmpty)
                    .take(2)
                    .map((p) => p[0])
                    .join();
                return Container(
                  width: 148,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _bgGrey,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: color.withValues(alpha: 0.3)),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: TextStyle(
                              fontSize: 16,
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
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        d['spec'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${d['exp']} d\'expérience',
                        style: const TextStyle(
                            fontSize: 10, color: _textLight),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Appointment Form ──────────────────────────────────────────────────────────
class _AppointmentSection extends StatefulWidget {
  @override
  State<_AppointmentSection> createState() => _AppointmentSectionState();
}

class _AppointmentSectionState extends State<_AppointmentSection> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  String _specialite = 'Pneumologie';
  DateTime? _date;
  bool _loading = false;

  static const _specialites = [
    'Pneumologie', 'Radiologie', 'Cardiologie',
    'Médecine générale', 'Urgences', 'Biologie',
  ];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _blue),
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
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Rendez-vous confirmé pour ${_nomCtrl.text.trim()} '
                'le ${_date!.day.toString().padLeft(2, '0')}/'
                '${_date!.month.toString().padLeft(2, '0')}/'
                '${_date!.year}',
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    _nomCtrl.clear();
    _telCtrl.clear();
    setState(() {
      _specialite = 'Pneumologie';
      _date = null;
    });
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _date == null
        ? 'Choisir une date'
        : '${_date!.day.toString().padLeft(2, '0')}/'
            '${_date!.month.toString().padLeft(2, '0')}/'
            '${_date!.year}';

    return Container(
      color: _blueLight,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(label: 'RENDEZ-VOUS'),
          const SizedBox(height: 8),
          const Text(
            'Prendre rendez-vous',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Remplissez le formulaire, nous vous confirmons\nla disponibilité sous 24h.',
            style: TextStyle(fontSize: 13, color: _textMid, height: 1.5),
          ),
          const SizedBox(height: 28),

          Form(
            key: _formKey,
            child: Column(
              children: [
                _LandingField(
                  controller: _nomCtrl,
                  label: 'Nom complet',
                  hint: 'Mohammed Alami',
                  icon: Icons.person_outline_rounded,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nom obligatoire' : null,
                ),
                const SizedBox(height: 14),
                _LandingField(
                  controller: _telCtrl,
                  label: 'Téléphone',
                  hint: '+212 6 12 34 56 78',
                  icon: Icons.phone_outlined,
                  keyboard: TextInputType.phone,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Téléphone obligatoire' : null,
                ),
                const SizedBox(height: 14),

                // Specialty dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Spécialité',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _textMid)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: _bgWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _specialite,
                          dropdownColor: _bgWhite,
                          style: const TextStyle(
                              color: _textDark, fontSize: 14),
                          icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: _textLight),
                          items: _specialites.map((s) {
                            return DropdownMenuItem(
                                value: s, child: Text(s));
                          }).toList(),
                          onChanged: (v) =>
                              setState(() => _specialite = v!),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Date picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Date souhaitée',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _textMid)),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: _bgWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: _date != null ? _blue : _border),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 18,
                                color:
                                    _date != null ? _blue : _textLight),
                            const SizedBox(width: 12),
                            Text(
                              dateLabel,
                              style: TextStyle(
                                fontSize: 14,
                                color: _date != null
                                    ? _textDark
                                    : _textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _blue.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Confirmer le rendez-vous',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboard;
  final String? Function(String?)? validator;

  const _LandingField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboard = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: _textMid)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboard,
          validator: validator,
          style: const TextStyle(color: _textDark, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _textLight),
            prefixIcon: Icon(icon, color: _textLight, size: 20),
            filled: true,
            fillColor: _bgWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _blue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────
class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_hospital_rounded,
                    color: _blue, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Centre Al Kendi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _footerRow(Icons.location_on_outlined,
              'Rue Ibn Sina, Quartier Médical, Rabat 10000'),
          const SizedBox(height: 12),
          _footerRow(Icons.phone_outlined, '+212 5 37 00 00 00'),
          const SizedBox(height: 12),
          _footerRow(Icons.access_time_rounded,
              'Lun–Ven : 08h–19h  |  Sam : 09h–14h'),
          const SizedBox(height: 12),
          _footerRow(Icons.email_outlined, 'contact@alkendi-centre.ma'),
          const SizedBox(height: 32),
          Divider(color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  '© 2026 Centre Al Kendi. Tous droits réservés.',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PulmoScan AI',
                  style: TextStyle(
                      color: _blue,
                      fontSize: 10,
                      fontWeight: FontWeight.w700),
                ),
              ),
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
        Icon(icon, color: _blue, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _blueLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _blue.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: _blue,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
