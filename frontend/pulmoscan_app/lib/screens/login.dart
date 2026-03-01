// lib/screens/login_page_exact.dart
import 'package:flutter/material.dart';
import 'package:pulmoscan_app/services/auth_service.dart';
import 'package:pulmoscan_app/screens/register.dart';

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEFF6FF), // blue-50
              Color(0xFFEEF2FF), // indigo-100
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(maxWidth: 448),
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 25,
                    spreadRadius: 0,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Color(0xFF0059FF),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Icon(
                        Icons.hearing,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Title
                    Text(
                      'PulmoScan IA',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        letterSpacing: -0.5,
                      ),
                    ),
                    
                    SizedBox(height: 8),
                    
                    // Subtitle
                    Text(
                      'Détection des maladies pulmonaires',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    
                    SizedBox(height: 32),
                    
                    // Error Message
                    if (_errorMessage.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: TextStyle(color: Color(0xFFDC2626)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_errorMessage.isNotEmpty) SizedBox(height: 16),
                    
                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email Field
                          _buildInputField(
                            label: 'Email',
                            icon: Icons.mail_outline,
                            controller: _emailController,
                            hintText: 'docteur@hopital.fr',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre email';
                              }
                              if (!value.contains('@')) {
                                return 'Email invalide';
                              }
                              return null;
                            },
                          ),
                          
                          SizedBox(height: 24),
                          
                          // Password Field
                          _buildInputField(
                            label: 'Mot de passe',
                            icon: Icons.lock_outline,
                            controller: _passwordController,
                            hintText: '••••••••',
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 20,
                                color: Color(0xFF9CA3AF),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre mot de passe';
                              }
                              if (value.length < 6) {
                                return 'Minimum 6 caractères';
                              }
                              return null;
                            },
                          ),
                          
                          SizedBox(height: 24),
                          
                          // Remember me & Forgot password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Checkbox
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value!;
                                      });
                                    },
                                    activeColor: Color(0xFF0059FF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  Text(
                                    'Se souvenir de moi',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Forgot password
                              TextButton(
                                onPressed: () {
                                  // TODO: Forgot password
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  'Mot de passe oublié ?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF0059FF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 24),
                          
                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF0059FF),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Se connecter',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 32),
                    
                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pas encore inscrit ? ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterScreenComplete(
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
                          child: Text(
                            'S\'inscrire ici',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF0059FF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Medical notice
                    Text(
                      'Accès réservé aux professionnels de santé',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
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

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        
        SizedBox(height: 8),
        
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF0059FF), width: 2),
            ),
            prefixIcon: Icon(
              icon,
              color: Color(0xFF9CA3AF),
              size: 20,
            ),
            suffixIcon: suffixIcon,
          ),
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  void _handleSubmit() async {
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

      // successful login -> call parent callback to navigate to dashboard
      widget.onLogin(context);
    } catch (e) {
      final err = e.toString();
      if (err.contains('Utilisateur non trouvé') || err.contains('Mot de passe incorrect')) {
        setState(() {
          _errorMessage = 'Email ou mot de passe incorrect';
        });
      } else {
        setState(() {
          _errorMessage = err.replaceFirst('Exception: ', '');
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}