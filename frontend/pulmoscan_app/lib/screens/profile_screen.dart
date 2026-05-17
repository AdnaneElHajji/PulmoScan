import 'package:flutter/material.dart';
import '../theme/v4_theme.dart';
import '../widgets/aperture_mark.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const ProfileScreen({super.key, required this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _api = ApiService();
  String _name = '';
  String _email = '';
  String _role = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await _api.getUser();
    if (mounted) {
      setState(() {
        _name = user['name'] ?? '';
        _email = user['email'] ?? '';
        _role = _formatRole(user['role'] ?? '');
      });
    }
  }

  String _formatRole(String r) {
    const labels = {
      'MEDECIN_GENERALISTE': 'Médecin généraliste',
      'PNEUMOLOGUE': 'Pneumologue',
      'RADIOLOGUE': 'Radiologue',
      'URGENTISTE': 'Urgentiste',
      'INTERNISTE': 'Interniste',
      'AUTRE': 'Médecin',
      'medecin': 'Médecin',
      '': 'Médecin',
    };
    return labels[r] ?? r;
  }

  String get _initials {
    if (_name.isEmpty) return '?';
    final parts = _name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return _name.substring(0, _name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V4.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                children: [
                  const Text(
                    'Profil',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                      color: V4.ink,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(
                            content: Text(
                                'Édition bientôt disponible'))),
                    child: const Text('Éditer',
                        style: TextStyle(
                            color: V4.teal,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Avatar card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: V4.surface1,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: V4.border),
                ),
                child: Row(
                  children: [
                    // Avatar circle
                    Stack(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: V4.teal,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: V4.teal.withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _initials,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: V4.bg,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: -10,
                          top: -10,
                          child: Opacity(
                            opacity: 0.15,
                            child: ApertureMark(
                                size: 60,
                                active: const [1, 4, 7, 11]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _name.isEmpty ? 'Chargement…' : _name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: V4.ink,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _role,
                            style: const TextStyle(
                                fontSize: 13, color: V4.inkSoft),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              V4.chip('vérifié', V4.teal, filled: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Email info row
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: V4.surface1,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: V4.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mail_outline_rounded,
                        color: V4.inkMuted, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _email.isEmpty ? '—' : _email,
                        style: const TextStyle(
                            fontSize: 13, color: V4.inkSoft),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // AI models section
              _sectionTitle('Modèles IA'),
              const SizedBox(height: 10),
              _settingItem(
                icon: '◐',
                iconColor: V4.teal,
                title: 'EfficientNetB1',
                sub: 'Classification · 14 classes · AUC 0.91',
              ),
              const SizedBox(height: 8),
              _settingItem(
                icon: '⬡',
                iconColor: V4.blue,
                title: 'NIH ChestX-ray14',
                sub: 'Dataset · 112 120 images · TFLite on-device',
              ),
              const SizedBox(height: 24),

              _sectionTitle('Paramètres'),
              const SizedBox(height: 10),
              _settingItem(
                icon: '⌾',
                iconColor: V4.blue,
                title: 'Sécurité',
                sub: 'Changer le mot de passe',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Bientôt disponible'))),
              ),
              const SizedBox(height: 8),
              _settingItem(
                icon: 'ⓘ',
                iconColor: V4.inkSoft,
                title: 'À propos',
                sub: 'PulmoScan AI v1.0.0 · CC-BY-NC · BTS 2026',
              ),
              const SizedBox(height: 32),

              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _confirmLogout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: V4.coral,
                    side: BorderSide(
                        color: V4.coral.withValues(alpha: 0.35)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Se déconnecter',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: V4.monoLabel.copyWith(
          fontSize: 11,
          letterSpacing: 1.6,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget _settingItem({
    required String icon,
    required Color iconColor,
    required String title,
    required String sub,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: V4.surface1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: V4.border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(icon,
                    style: TextStyle(
                        color: iconColor, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: V4.ink,
                      )),
                  const SizedBox(height: 2),
                  Text(sub,
                      style: const TextStyle(
                          fontSize: 11, color: V4.inkSoft)),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right_rounded,
                  color: V4.inkMuted, size: 18),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text(
            'Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler',
                style: TextStyle(color: V4.inkMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService().logout();
              widget.onLogout();
            },
            child: const Text('Déconnexion',
                style: TextStyle(color: V4.coral)),
          ),
        ],
      ),
    );
  }
}
