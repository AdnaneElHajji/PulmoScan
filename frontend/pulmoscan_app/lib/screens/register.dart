// lib/screens/register_screen_complete.dart
import 'package:flutter/material.dart';
import 'package:pulmoscan_app/services/auth_service.dart';

typedef RegisterScreen = RegisterScreenComplete;

class RegisterScreenComplete extends StatefulWidget {
  final Function(bool success) onRegisterComplete;

  const RegisterScreenComplete({super.key, required this.onRegisterComplete});

  @override
  State<RegisterScreenComplete> createState() => _RegisterScreenCompleteState();
}

class _RegisterScreenCompleteState extends State<RegisterScreenComplete> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _licenseController = TextEditingController();
  final _hospitalController = TextEditingController();
  
  String _selectedRole = '';
  bool _isLoading = false;
  String _errorMessage = ''; 
  bool _acceptedTerms = false;
  
  final List<Map<String, String>> _specialties = [
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEBF5FF),
              Color(0xFFE0E7FF),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 448),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      _buildHeader(),
                      
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
                      _buildForm(),
                      
                      SizedBox(height: 24),
                      
                      // Footer
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
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
        
        Text(
          'PulmoScan IA',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        
        SizedBox(height: 8),
        
        Text(
          'Créer un compte professionnel',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Full Name
          _buildTextField(
            label: 'Nom complet',
            icon: Icons.person_outline,
            controller: _nameController,
            hint: 'Dr. Nom Prénom',
            validator: _validateName,
          ),
          
          SizedBox(height: 16),
          
          // Email
          _buildTextField(
            label: 'Email professionnel',
            icon: Icons.mail_outline,
            controller: _emailController,
            hint: 'docteur@hopital.fr',
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          
          SizedBox(height: 16),
          
          // Role Dropdown
          _buildDropdownField(),
          
          SizedBox(height: 16),
          
          // License Number (optional)
          _buildTextField(
            label: 'Numéro de licence (optionnel)',
            icon: Icons.badge_outlined,
            controller: _licenseController,
            hint: 'LM12345',
            optional: true,
          ),
          
          SizedBox(height: 16),
          
          // Hospital Affiliation (optional)
          _buildTextField(
            label: 'Établissement (optionnel)',
            icon: Icons.business_outlined,
            controller: _hospitalController,
            hint: 'Hôpital X',
            optional: true,
          ),
          
          SizedBox(height: 16),
          
          // Password
          _buildTextField(
            label: 'Mot de passe',
            icon: Icons.lock_outline,
            controller: _passwordController,
            hint: '••••••••',
            obscureText: true,
            validator: _validatePassword,
          ),
          
          SizedBox(height: 16),
          
          // Confirm Password
          _buildTextField(
            label: 'Confirmer le mot de passe',
            icon: Icons.lock_outline,
            controller: _confirmPasswordController,
            hint: '••••••••',
            obscureText: true,
            validator: _validateConfirmPassword,
          ),
          
          SizedBox(height: 24),
          
          // Terms Checkbox
          _buildTermsCheckbox(),
          
          SizedBox(height: 24),
          
          // Register Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
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
                      'S\'inscrire',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    bool optional = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
            children: optional
                ? [
                    TextSpan(
                      text: ' (optionnel)',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ]
                : [],
          ),
        ),
        
        SizedBox(height: 8),
        
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFD1D5DB)),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: optional ? null : validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(
                icon,
                color: Color(0xFF9CA3AF),
                size: 20,
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spécialité / Rôle *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        
        SizedBox(height: 8),
        
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFD1D5DB)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedRole.isEmpty ? null : _selectedRole,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue ?? '';
                  });
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.work_outline,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                ),
                hint: Text(
                  'Sélectionner une spécialité',
                  style: TextStyle(color: Color(0xFF9CA3AF)),
                ),
                items: _specialties.map((specialty) {
                  return DropdownMenuItem<String>(
                    value: specialty['value'],
                    child: Text(specialty['label']!),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez sélectionner une spécialité';
                  }
                  return null;
                },
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF111827),
                ),
                isExpanded: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _acceptedTerms,
          onChanged: (value) {
            setState(() {
              _acceptedTerms = value ?? false;
            });
          },
          activeColor: Color(0xFF0059FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
              children: [
                TextSpan(text: 'J\'accepte les '),
                TextSpan(
                  text: 'conditions d\'utilisation',
                  style: TextStyle(
                    color: Color(0xFF0059FF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(text: ' et la '),
                TextSpan(
                  text: 'politique de confidentialité',
                  style: TextStyle(
                    color: Color(0xFF0059FF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Déjà inscrit ? ',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'Se connecter',
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
        
        Text(
          'Accès réservé aux professionnels de santé',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Validation methods
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre nom complet';
    }
    if (value.length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email professionnel';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    }
    if (value.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    if (value != _passwordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        final authService = AuthService();
        await authService.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        widget.onRegisterComplete(true);
      } catch (e) {
        setState(() {
          _errorMessage = 'Erreur lors de l\'inscription: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}