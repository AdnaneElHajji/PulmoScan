// lib/screens/login.dart
import 'package:flutter/material.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEFF6FF),
              Color(0xFFEEF2FF),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 448),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0059FF),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Icon(
                        Icons.monitor_heart_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'PulmoScan IA',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Détection des maladies pulmonaires',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Message d'erreur
                    if (_errorMessage.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Color(0xFFDC2626), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style:
                                    const TextStyle(color: Color(0xFFDC2626)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Formulaire
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email
                          _buildChamp(
                            label: 'Email',
                            icone: Icons.mail_outline,
                            controller: _emailController,
                            hint: 'docteur@hopital.ma',
                            clavier: TextInputType.emailAddress,
                            validateur: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Email obligatoire';
                              }
                              if (!val.contains('@')) return 'Email invalide';
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Mot de passe
                          _buildChamp(
                            label: 'Mot de passe',
                            icone: Icons.lock_outline,
                            controller: _passwordController,
                            hint: '••••••••',
                            obscure: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 20,
                                color: const Color(0xFF9CA3AF),
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                            validateur: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Mot de passe obligatoire';
                              }
                              if (val.length < 6) return 'Minimum 6 caractères';
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Se souvenir + mot de passe oublié
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (val) =>
                                        setState(() => _rememberMe = val!),
                                    activeColor: const Color(0xFF0059FF),
                                  ),
                                  const Text(
                                    'Se souvenir de moi',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF6B7280)),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'Mot de passe oublié ?',
                                  style: TextStyle(
                                      fontSize: 14, color: Color(0xFF0059FF)),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Bouton connexion
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0059FF),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Se connecter',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Lien inscription
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Pas encore inscrit ? ',
                          style:
                              TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterScreen(
                                  onRegisterComplete: (success) {
                                    if (success) {
                                      Navigator.pop(context);
                                      widget.onLogin(context);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'S\'inscrire ici',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF0059FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Accès réservé aux professionnels de santé',
                      style:
                          TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChamp({
    required String label,
    required IconData icone,
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType clavier = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validateur,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: clavier,
          validator: validateur,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            prefixIcon: Icon(icone, color: const Color(0xFF9CA3AF), size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF0059FF), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authService = AuthService();
      await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      widget.onLogin(context);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}