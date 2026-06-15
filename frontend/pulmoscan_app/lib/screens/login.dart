import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/v4_theme.dart';
import '../widgets/aperture_mark.dart';
import '../l10n/strings.dart';
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
      backgroundColor: V4.bg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: GridBackground())),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo mark
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: V4.surface2,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: V4.tealGlow, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: V4.teal.withValues(alpha: 0.18),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.monitor_heart_outlined,
                          color: V4.teal,
                          size: 30,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'PulmoScan IA',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: V4.ink,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        S.appSubtitle,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: V4.inkMuted,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Card
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: V4.surface1,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: V4.borderStrong),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Error banner
                            if (_errorMessage.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: V4.coral.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: V4.coral.withValues(alpha: 0.35)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: V4.coral, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage,
                                        style: GoogleFonts.inter(
                                            fontSize: 13, color: V4.coral),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: GoogleFonts.inter(
                                        fontSize: 14, color: V4.ink),
                                    decoration: V4.inputDec(
                                      label: S.email.toUpperCase(),
                                      hint: S.emailHint,
                                      prefix: Icons.mail_outline,
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return S.emailRequired;
                                      }
                                      if (!val.contains('@')) {
                                        return S.emailInvalid;
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: GoogleFonts.inter(
                                        fontSize: 14, color: V4.ink),
                                    decoration: V4.inputDec(
                                      label: S.password.toUpperCase(),
                                      hint: '••••••••',
                                      prefix: Icons.lock_outline,
                                      suffix: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          size: 18,
                                          color: V4.inkMuted,
                                        ),
                                        onPressed: () => setState(() =>
                                            _obscurePassword =
                                                !_obscurePassword),
                                      ),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return S.passwordRequired;
                                      }
                                      if (val.length < 6) {
                                        return S.passwordMin;
                                      }
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: 14),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Left: checkbox + label
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              onChanged: (val) => setState(
                                                  () => _rememberMe = val!),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            S.rememberMe,
                                            style: GoogleFonts.inter(
                                                fontSize: 13,
                                                color: V4.inkSoft),
                                          ),
                                        ],
                                      ),
                                      // Right: forgot password
                                      TextButton(
                                        onPressed: _showForgotPasswordDialog,
                                        style: TextButton.styleFrom(
                                          foregroundColor: V4.teal,
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          S.forgotPassword,
                                          style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: V4.teal,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  V4.primaryBtn(
                                    label: S.signIn,
                                    onTap: _isLoading ? null : _handleSubmit,
                                    loading: _isLoading,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            S.notRegistered,
                            style: GoogleFonts.inter(
                                fontSize: 13, color: V4.inkMuted),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RegisterScreen(
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
                              S.registerHere,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: V4.teal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Text(
                        S.reservedAccess,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: V4.inkMuted),
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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await AuthService().login(
        _emailController.text.trim(),
        _passwordController.text,
        rememberMe: _rememberMe,
      );
      if (!mounted) return;
      widget.onLogin(context);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool loading = false;
    String? message;
    bool isSuccess = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: V4.surface2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: V4.borderStrong),
          ),
          title: Text(
            S.forgotPasswordTitle,
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: V4.ink),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.forgotPasswordBody,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: V4.inkSoft),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.inter(fontSize: 14, color: V4.ink),
                  decoration: V4.inputDec(
                    label: 'EMAIL',
                    prefix: Icons.email_outlined,
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Email obligatoire';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) {
                      return 'Format email invalide';
                    }
                    return null;
                  },
                ),
                if (message != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSuccess
                          ? V4.teal.withValues(alpha: 0.10)
                          : V4.coral.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSuccess
                            ? V4.teal.withValues(alpha: 0.35)
                            : V4.coral.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSuccess
                              ? Icons.check_circle_outline
                              : Icons.error_outline,
                          color: isSuccess ? V4.teal : V4.coral,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            message!,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isSuccess ? V4.teal : V4.coral,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(foregroundColor: V4.inkSoft),
              child: Text(S.cancel,
                  style: GoogleFonts.inter(fontSize: 14, color: V4.inkSoft)),
            ),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() {
                        loading = true;
                        message = null;
                      });
                      try {
                        await AuthService()
                            .forgotPassword(emailCtrl.text.trim());
                        setDialogState(() {
                          loading = false;
                          isSuccess = true;
                          message = S.emailSentGeneric;
                        });
                      } catch (e) {
                        setDialogState(() {
                          loading = false;
                          isSuccess = false;
                          message =
                              e.toString().replaceFirst('Exception: ', '');
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: V4.teal,
                foregroundColor: V4.bg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: V4.bg),
                    )
                  : Text(S.send,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: V4.bg)),
            ),
          ],
        ),
      ),
    ).then((_) => emailCtrl.dispose());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
