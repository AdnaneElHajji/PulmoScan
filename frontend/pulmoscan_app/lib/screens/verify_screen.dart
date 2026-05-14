import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';

class VerifyScreen extends StatefulWidget {
  final String email;
  final String name;
  final String password;
  final String role;

  const VerifyScreen({
    super.key,
    required this.email,
    required this.name,
    required this.password,
    required this.role,
  });

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final AuthService _auth = AuthService();
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  String _error = '';

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_code.length < 6) {
      setState(() => _error = 'Entrez les 6 chiffres du code');
      return;
    }
    setState(() { _isLoading = true; _error = ''; });
    try {
      await _auth.verifyCode(widget.email, _code);
      await _auth.register(
        name: widget.name,
        email: widget.email,
        password: widget.password,
        role: widget.role,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte créé avec succès ! Connectez-vous.'),
            backgroundColor: Color(0xFF388E3C),
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    setState(() { _isResending = true; _error = ''; });
    try {
      await _auth.sendVerificationCode(widget.email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nouveau code envoyé'),
            backgroundColor: Color(0xFF0059FF),
          ),
        );
        for (var c in _controllers) c.clear();
        _focusNodes[0].requestFocus();
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEFF6FF), Color(0xFFEEF2FF)],
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
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icône
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0059FF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      size: 36,
                      color: Color(0xFF0059FF),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Vérification email',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    'Un code à 6 chiffres a été envoyé à\n${widget.email}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '(Si email non configuré, regardez le terminal du backend)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Champs OTP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (i) => _buildDigitField(i)),
                  ),
                  const SizedBox(height: 16),

                  // Erreur
                  if (_error.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Color(0xFFDC2626), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error,
                              style: const TextStyle(
                                  color: Color(0xFFDC2626), fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Bouton vérifier
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0059FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                              'Vérifier et créer le compte',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Renvoyer code
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Pas reçu ? ',
                        style:
                            TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                      ),
                      GestureDetector(
                        onTap: _isResending ? null : _resend,
                        child: Text(
                          _isResending ? 'Envoi...' : 'Renvoyer le code',
                          style: TextStyle(
                            fontSize: 14,
                            color: _isResending
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF0059FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      '← Modifier l\'email',
                      style:
                          TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDigitField(int index) {
    return SizedBox(
      width: 44,
      height: 56,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF111827),
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0xFF0059FF), width: 2),
          ),
        ),
        onChanged: (val) {
          if (val.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          }
          if (val.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() => _error = '');
        },
      ),
    );
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }
}
