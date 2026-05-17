import 'package:flutter/material.dart';
import '../theme/v4_theme.dart';
import '../widgets/aperture_mark.dart';
import '../services/auth_service.dart';
import 'verify_screen.dart';

class RegisterScreen extends StatefulWidget {
  final Function(bool success) onRegisterComplete;
  const RegisterScreen({super.key, required this.onRegisterComplete});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String _role = '';
  bool _isLoading = false;
  String _error = '';
  bool _obscurePwd = true;
  bool _obscureConfirm = true;

  static const List<Map<String, String>> _specialites = [
    {'value': 'MEDECIN_GENERALISTE', 'label': 'Médecin généraliste'},
    {'value': 'PNEUMOLOGUE', 'label': 'Pneumologue'},
    {'value': 'RADIOLOGUE', 'label': 'Radiologue'},
    {'value': 'URGENTISTE', 'label': 'Urgentiste'},
    {'value': 'INTERNISTE', 'label': 'Interniste'},
    {'value': 'AUTRE', 'label': 'Autre spécialité'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V4.bg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: GridBackground())),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.6, -0.4),
                  radius: 0.85,
                  colors: [Color(0x1E34E5C5), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: V4.inkSoft, size: 18),
                        ),
                        const Spacer(),
                        const Wordmark(size: 20),
                        const Spacer(),
                        const SizedBox(width: 40),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        color: V4.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Accès réservé aux professionnels de santé.',
                      style: TextStyle(fontSize: 13, color: V4.inkSoft),
                    ),
                    const SizedBox(height: 28),

                    // Error
                    if (_error.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: V4.coral.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: V4.coral.withValues(alpha: 0.30)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: V4.coral, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_error,
                                  style: const TextStyle(
                                      color: V4.coral, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    _label('Nom complet'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nomCtrl,
                      style: const TextStyle(color: V4.ink),
                      decoration: V4.inputDec(
                          hint: 'Dr. Nom Prénom',
                          prefix: Icons.person_outline_rounded),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Nom obligatoire';
                        if (v.length < 2) return 'Minimum 2 caractères';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _label('Email professionnel'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: V4.ink),
                      decoration: V4.inputDec(
                          hint: 'docteur@hopital.ma',
                          prefix: Icons.mail_outline_rounded),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Email obligatoire';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _label('Spécialité'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _role.isEmpty ? null : _role,
                      dropdownColor: V4.surface2,
                      style: const TextStyle(color: V4.ink, fontSize: 14),
                      hint: const Text('Sélectionner',
                          style: TextStyle(color: V4.inkMuted)),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: V4.inkMuted),
                      decoration: V4.inputDec(
                          prefix: Icons.work_outline_rounded),
                      items: _specialites
                          .map((s) => DropdownMenuItem<String>(
                                value: s['value'],
                                child: Text(s['label']!),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _role = v ?? ''),
                      validator: (v) =>
                          (v == null || v.isEmpty)
                              ? 'Spécialité obligatoire'
                              : null,
                    ),
                    const SizedBox(height: 16),

                    _label('Mot de passe'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _pwdCtrl,
                      obscureText: _obscurePwd,
                      style: const TextStyle(color: V4.ink),
                      decoration: V4.inputDec(
                        hint: '••••••••',
                        prefix: Icons.lock_outline_rounded,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePwd
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: V4.inkMuted,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePwd = !_obscurePwd),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Mot de passe obligatoire';
                        }
                        if (v.length < 8) return 'Minimum 8 caractères';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _label('Confirmer le mot de passe'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: _obscureConfirm,
                      style: const TextStyle(color: V4.ink),
                      decoration: V4.inputDec(
                        hint: '••••••••',
                        prefix: Icons.lock_outline_rounded,
                        suffix: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: V4.inkMuted,
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Confirmation obligatoire';
                        }
                        if (v != _pwdCtrl.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    V4.primaryBtn(
                      label: 'S\'inscrire',
                      onTap: _isLoading ? null : _submit,
                      loading: _isLoading,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Flexible(
                          child: Text(
                            'Déjà inscrit ? ',
                            style: TextStyle(
                                color: V4.inkMuted, fontSize: 13),
                          ),
                        ),
                        Flexible(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text(
                              'Se connecter',
                              style: TextStyle(
                                color: V4.teal,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: V4.inkSoft,
        ),
      );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _error = ''; });
    try {
      await AuthService()
          .sendVerificationCode(_emailCtrl.text.trim());
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyScreen(
              email: _emailCtrl.text.trim(),
              name: _nomCtrl.text.trim(),
              password: _pwdCtrl.text,
              role: _role.isEmpty ? 'medecin' : _role,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() =>
          _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }
}
