import 'package:flutter/material.dart';
import '../theme/v4_theme.dart';
import '../widgets/aperture_mark.dart';
import '../services/auth_service.dart';
import 'register.dart';

class LoginPageExact extends StatefulWidget {
  final Function(BuildContext) onLogin;
  const LoginPageExact({super.key, required this.onLogin});

  @override
  State<LoginPageExact> createState() => _LoginPageExactState();
}

class _LoginPageExactState extends State<LoginPageExact> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  String _error = '';

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
                  center: Alignment(-0.5, -0.5),
                  radius: 0.9,
                  colors: [Color(0x2634E5C5), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Brand
                      const Center(
                          child: ApertureMark(
                              size: 72, active: [1, 4, 7, 11])),
                      const SizedBox(height: 20),
                      const Center(child: Wordmark(size: 28)),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          'quatorze pathologies, une radiographie.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: V4.inkSoft,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Error banner
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

                      // Email
                      _label('Email'),
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
                          if (!v.contains('@')) return 'Email invalide';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Password
                      _label('Mot de passe'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _pwdCtrl,
                        obscureText: _obscure,
                        style: const TextStyle(color: V4.ink),
                        decoration: V4.inputDec(
                          hint: '••••••••',
                          prefix: Icons.lock_outline_rounded,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: V4.inkMuted,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Mot de passe obligatoire';
                          }
                          if (v.length < 6) return 'Minimum 6 caractères';
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Submit
                      V4.primaryBtn(
                        label: 'Se connecter',
                        onTap: _isLoading ? null : _submit,
                        loading: _isLoading,
                      ),
                      const SizedBox(height: 24),

                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Pas encore inscrit ? ',
                            style: TextStyle(
                                color: V4.inkMuted, fontSize: 13),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RegisterScreen(
                                  onRegisterComplete: (ok) {
                                    if (ok) {
                                      Navigator.pop(context);
                                      widget.onLogin(context);
                                    }
                                  },
                                ),
                              ),
                            ),
                            child: const Text(
                              'S\'inscrire',
                              style: TextStyle(
                                color: V4.teal,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Accès réservé aux professionnels de santé',
                          style: TextStyle(
                              fontSize: 11, color: V4.inkMuted),
                        ),
                      ),
                    ],
                  ),
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
          .login(_emailCtrl.text.trim(), _pwdCtrl.text);
      if (mounted) widget.onLogin(context);
    } catch (e) {
      setState(() =>
          _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }
}
