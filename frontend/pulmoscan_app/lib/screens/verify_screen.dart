import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/v4_theme.dart';
import '../widgets/aperture_mark.dart';
import '../services/auth_service.dart';
import '../l10n/strings.dart';
import 'login.dart';

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
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  String _error = '';

  String get _code => _ctrls.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_code.length < 6) {
      setState(() => _error = S.enterSixDigits);
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
          SnackBar(
            content: Text(S.accountCreated),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => LoginPageExact(
              onLogin: (ctx) =>
                  Navigator.pushNamedAndRemoveUntil(ctx, '/app', (_) => false),
            ),
          ),
          (_) => false,
        );
      }
    } catch (e) {
      setState(() =>
          _error = e.toString().replaceFirst('Exception: ', ''));
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
          SnackBar(content: Text(S.codeSent)),
        );
        for (var c in _ctrls) { c.clear(); }
        _nodes[0].requestFocus();
      }
    } catch (e) {
      setState(() =>
          _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

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
                  center: Alignment(0, -0.4),
                  radius: 0.8,
                  colors: [Color(0x1E34E5C5), Colors.transparent],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: V4.teal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                            color: V4.teal.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(
                          Icons.mark_email_read_outlined,
                          size: 34,
                          color: V4.teal),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      S.emailVerification,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: V4.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${S.codeSentTo}\n${widget.email}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 14, color: V4.inkSoft, height: 1.5),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '(Si email non configuré, regardez le terminal du backend)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: V4.inkMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // OTP fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, _buildDigit),
                    ),
                    const SizedBox(height: 16),

                    // Error
                    if (_error.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
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

                    const SizedBox(height: 8),
                    V4.primaryBtn(
                      label: S.verifyCreate,
                      onTap: _isLoading ? null : _verify,
                      loading: _isLoading,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(S.notReceived,
                              style: const TextStyle(fontSize: 13, color: V4.inkMuted)),
                        ),
                        Flexible(
                          child: GestureDetector(
                            onTap: _isResending ? null : _resend,
                            child: Text(
                              _isResending ? S.sending : S.resendCode,
                              style: TextStyle(
                                fontSize: 13,
                                color: _isResending
                                    ? V4.inkMuted
                                    : V4.teal,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        S.modifyEmail,
                        style: const TextStyle(
                            fontSize: 13, color: V4.inkMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigit(int i) {
    return SizedBox(
      width: 44,
      height: 54,
      child: TextFormField(
        controller: _ctrls[i],
        focusNode: _nodes[i],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: V4.ink,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: V4.surface2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: V4.borderStrong),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: V4.borderStrong),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: V4.teal, width: 2),
          ),
        ),
        onChanged: (val) {
          if (val.isNotEmpty && i < 5) _nodes[i + 1].requestFocus();
          if (val.isEmpty && i > 0) _nodes[i - 1].requestFocus();
          setState(() => _error = '');
        },
      ),
    );
  }

  @override
  void dispose() {
    for (var c in _ctrls) { c.dispose(); }
    for (var n in _nodes) { n.dispose(); }
    super.dispose();
  }
}
