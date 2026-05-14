// lib/screens/register.dart
import 'package:flutter/material.dart';
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
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = '';
  bool _isLoading = false;
  String _errorMessage = '';
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final List<Map<String, String>> _specialites = [
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEBF5FF), Color(0xFFE0E7FF)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 448),
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
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Créer un compte professionnel',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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
                            child: Text(_errorMessage,
                                style: const TextStyle(
                                    color: Color(0xFFDC2626))),
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
                        _buildChamp(
                          label: 'Nom complet *',
                          icone: Icons.person_outline,
                          controller: _nomController,
                          hint: 'Dr. Nom Prénom',
                          validateur: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Nom obligatoire';
                            }
                            if (val.length < 2) return 'Minimum 2 caractères';
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildChamp(
                          label: 'Email professionnel *',
                          icone: Icons.mail_outline,
                          controller: _emailController,
                          hint: 'docteur@hopital.ma',
                          clavier: TextInputType.emailAddress,
                          validateur: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Email obligatoire';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(val)) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Dropdown spécialité
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Spécialité *',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF374151),
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedRole.isEmpty
                                  ? null
                                  : _selectedRole,
                              hint: const Text(
                                'Sélectionner une spécialité',
                                style: TextStyle(color: Color(0xFF9CA3AF)),
                              ),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.work_outline,
                                    color: Color(0xFF9CA3AF), size: 20),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFD1D5DB)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFD1D5DB)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                      color: Color(0xFF0059FF), width: 2),
                                ),
                              ),
                              items: _specialites.map((s) {
                                return DropdownMenuItem<String>(
                                  value: s['value'],
                                  child: Text(s['label']!),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedRole = val ?? ''),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Spécialité obligatoire';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _buildChamp(
                          label: 'Mot de passe *',
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
                            if (val.length < 8) return 'Minimum 8 caractères';
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildChamp(
                          label: 'Confirmer le mot de passe *',
                          icone: Icons.lock_outline,
                          controller: _confirmPasswordController,
                          hint: '••••••••',
                          obscure: _obscureConfirm,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 20,
                              color: const Color(0xFF9CA3AF),
                            ),
                            onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          ),
                          validateur: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Confirmation obligatoire';
                            }
                            if (val != _passwordController.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Bouton inscription
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
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
                                    'S\'inscrire',
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

                  // Lien connexion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Déjà inscrit ? ',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Se connecter',
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
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
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

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; _errorMessage = ''; });

    try {
      final authService = AuthService();
      // Envoie le code de vérification par email
      await authService.sendVerificationCode(_emailController.text.trim());

      if (mounted) {
        // Navigue vers l'écran de vérification
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyScreen(
              email: _emailController.text.trim(),
              name: _nomController.text.trim(),
              password: _passwordController.text,
              role: _selectedRole.isEmpty ? 'medecin' : _selectedRole,
            ),
          ),
        );
      }
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
    _nomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}