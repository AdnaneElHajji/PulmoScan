import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
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
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('saved_email');
    if (saved != null && saved.isNotEmpty) {
      setState(() {
        _emailController.text = saved;
        _rememberMe = true;
      });
    }
  }

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
                        padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
                        decoration: BoxDecoration(
                          color: V4.surface1,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: V4.borderStrong),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 32,
                              offset: const Offset(0, 8),
                            ),
                          ],
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

                                  const SizedBox(height: 16),

                                  // ── Se souvenir de moi ──────────
                                  GestureDetector(
                                    onTap: () => setState(
                                        () => _rememberMe = !_rememberMe),
                                    child: Row(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 200),
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: _rememberMe
                                                ? V4.teal
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                              color: _rememberMe
                                                  ? V4.teal
                                                  : V4.borderStrong,
                                              width: 2,
                                            ),
                                          ),
                                          child: _rememberMe
                                              ? const Icon(Icons.check_rounded,
                                                  color: V4.bg, size: 14)
                                              : null,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          S.rememberMe,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: _rememberMe
                                                ? V4.ink
                                                : V4.inkSoft,
                                            fontWeight: _rememberMe
                                                ? FontWeight.w500
                                                : FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // ── Mot de passe oublié ? ────────
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: _showForgotPasswordDialog,
                                        style: TextButton.styleFrom(
                                          foregroundColor: V4.teal,
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
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

                                  const SizedBox(height: 24),

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
      );
      // Save or clear email based on "Se souvenir de moi"
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setString('saved_email', _emailController.text.trim());
      } else {
        await prefs.remove('saved_email');
      }
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
    final newPwCtrl = TextEditingController();
    final confirmPwCtrl = TextEditingController();
    final formKey1 = GlobalKey<FormState>();
    final formKey2 = GlobalKey<FormState>();
    int step = 1; // 1 = email, 2 = new password, 3 = success
    bool loading = false;
    String? error;
    bool obscure1 = true;
    bool obscure2 = true;

    showDialog(
      context: context,
      barrierDismissible: !loading,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: V4.surface2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: V4.borderStrong),
            ),
            title: Text(
              step == 1
                  ? 'Mot de passe oublié'
                  : step == 2
                      ? 'Nouveau mot de passe'
                      : 'Mot de passe modifié',
              style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w700, color: V4.ink),
            ),
            content: step == 3
                // ── Success ───────────────────────────────────────────
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: V4.teal, size: 48),
                      const SizedBox(height: 14),
                      Text(
                        'Mot de passe réinitialisé avec succès.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 14, color: V4.inkSoft),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step == 1
                            ? 'Entrez votre adresse email pour réinitialiser votre mot de passe.'
                            : 'Choisissez un nouveau mot de passe pour ${emailCtrl.text.trim()}.',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: V4.inkSoft),
                      ),
                      const SizedBox(height: 16),
                      if (step == 1)
                        Form(
                          key: formKey1,
                          child: TextFormField(
                            controller: emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            autofocus: true,
                            style: GoogleFonts.inter(
                                fontSize: 14, color: V4.ink),
                            decoration: V4.inputDec(
                              label: 'EMAIL',
                              prefix: Icons.email_outlined,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Email obligatoire';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(v)) {
                                return 'Format invalide';
                              }
                              return null;
                            },
                          ),
                        )
                      else
                        Form(
                          key: formKey2,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: newPwCtrl,
                                obscureText: obscure1,
                                autofocus: true,
                                style: GoogleFonts.inter(
                                    fontSize: 14, color: V4.ink),
                                decoration: V4.inputDec(
                                  label: 'NOUVEAU MOT DE PASSE',
                                  prefix: Icons.lock_outline,
                                  suffix: IconButton(
                                    icon: Icon(
                                      obscure1
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 18,
                                      color: V4.inkMuted,
                                    ),
                                    onPressed: () => setDialogState(
                                        () => obscure1 = !obscure1),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Mot de passe obligatoire';
                                  }
                                  if (v.length < 6) {
                                    return 'Minimum 6 caractères';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: confirmPwCtrl,
                                obscureText: obscure2,
                                style: GoogleFonts.inter(
                                    fontSize: 14, color: V4.ink),
                                decoration: V4.inputDec(
                                  label: 'CONFIRMER',
                                  prefix: Icons.lock_outline,
                                  suffix: IconButton(
                                    icon: Icon(
                                      obscure2
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 18,
                                      color: V4.inkMuted,
                                    ),
                                    onPressed: () => setDialogState(
                                        () => obscure2 = !obscure2),
                                  ),
                                ),
                                validator: (v) {
                                  if (v != newPwCtrl.text) {
                                    return 'Les mots de passe ne correspondent pas';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      if (error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: V4.coral.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: V4.coral.withValues(alpha: 0.35)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: V4.coral, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(error!,
                                    style: GoogleFonts.inter(
                                        fontSize: 13, color: V4.coral)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
            actions: step == 3
                ? [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: V4.teal,
                        foregroundColor: V4.bg,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Se connecter',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: V4.bg)),
                    ),
                  ]
                : [
                    TextButton(
                      onPressed:
                          loading ? null : () => Navigator.pop(dialogContext),
                      style:
                          TextButton.styleFrom(foregroundColor: V4.inkSoft),
                      child: Text('Annuler',
                          style: GoogleFonts.inter(
                              fontSize: 14, color: V4.inkSoft)),
                    ),
                    ElevatedButton(
                      onPressed: loading
                          ? null
                          : () async {
                              setDialogState(() {
                                error = null;
                                loading = true;
                              });
                              try {
                                if (step == 1) {
                                  // Step 1 — verify email exists in SQLite
                                  if (!formKey1.currentState!.validate()) {
                                    setDialogState(() => loading = false);
                                    return;
                                  }
                                  final d = await DatabaseService().db;
                                  final rows = await d.query('users',
                                      where: 'email = ?',
                                      whereArgs: [emailCtrl.text.trim()]);
                                  if (rows.isEmpty) {
                                    throw Exception(
                                        'Aucun compte trouvé pour cet email');
                                  }
                                  setDialogState(() {
                                    step = 2;
                                    loading = false;
                                  });
                                } else {
                                  // Step 2 — update password in SQLite
                                  if (!formKey2.currentState!.validate()) {
                                    setDialogState(() => loading = false);
                                    return;
                                  }
                                  final d = await DatabaseService().db;
                                  final hash = DatabaseService.hashPassword(
                                      newPwCtrl.text);
                                  await d.update(
                                    'users',
                                    {'password': hash},
                                    where: 'email = ?',
                                    whereArgs: [emailCtrl.text.trim()],
                                  );
                                  setDialogState(() {
                                    step = 3;
                                    loading = false;
                                  });
                                }
                              } catch (e) {
                                setDialogState(() {
                                  error = e
                                      .toString()
                                      .replaceFirst('Exception: ', '');
                                  loading = false;
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
                          : Text(step == 1 ? 'Continuer' : 'Réinitialiser',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: V4.bg)),
                    ),
                  ],
          );
        },
      ),
    ).then((_) {
      emailCtrl.dispose();
      newPwCtrl.dispose();
      confirmPwCtrl.dispose();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
