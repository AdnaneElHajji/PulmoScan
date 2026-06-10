import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/v4_theme.dart';
import '../widgets/aperture_mark.dart';
import '../l10n/strings.dart';
import '../l10n/locale_provider.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileScreen({super.key, required this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _email = '';
  String _role = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService().getUser();
    if (mounted) {
      setState(() {
        _name = user['name'] ?? '';
        _email = user['email'] ?? '';
        _role = _formatRole(user['role'] ?? '');
      });
    }
  }

  String _formatRole(String role) {
    const labels = {
      'MEDECIN_GENERALISTE': 'Médecin généraliste',
      'PNEUMOLOGUE': 'Pneumologue',
      'RADIOLOGUE': 'Radiologue',
      'URGENTISTE': 'Urgentiste',
      'INTERNISTE': 'Interniste',
      'AUTRE': 'Médecin',
      'medecin': 'Médecin',
      '': 'Médecin',
    };
    return labels[role] ?? role;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: V4.bg,
      appBar: AppBar(
        backgroundColor: V4.bg,
        elevation: 0,
        title: Text(
          S.profile,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: V4.ink,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language_outlined, color: V4.inkSoft, size: 22),
            onPressed: _showLanguagePicker,
            tooltip: S.language,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: GridBackground())),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCarteProfil(),
                const SizedBox(height: 16),
                _buildSection(
                  titre: S.settings,
                  items: [
                    _buildItem(
                      icone: Icons.lock_outlined,
                      titre: S.changePassword,
                      sousTitre: S.secureAccount,
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                    _buildItem(
                      icone: Icons.notifications_outlined,
                      titre: S.notifications,
                      sousTitre: S.managePrefs,
                      onTap: () => _afficherBientot(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSection(
                  titre: S.about,
                  items: [
                    _buildItem(
                      icone: Icons.info_outline,
                      titre: S.appVersion,
                      sousTitre: 'PulmoScan IA v1.0.0',
                      onTap: null,
                      afficherChevron: false,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _confirmerDeconnexion(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: V4.coral.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: V4.coral, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          S.logout,
                          style: GoogleFonts.inter(
                            color: V4.coral,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarteProfil() {
    final initials = _name.isNotEmpty
        ? _name
            .trim()
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: V4.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: V4.borderStrong),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: V4.teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: V4.tealGlow, width: 1.5),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: V4.teal,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _name.isEmpty ? 'Chargement...' : _name,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: V4.ink,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _role,
            style: GoogleFonts.inter(fontSize: 13, color: V4.inkMuted),
          ),
          const SizedBox(height: 16),
          _buildInfoRapide(icone: Icons.email_outlined, valeur: _email),
        ],
      ),
    );
  }

  Widget _buildInfoRapide({required IconData icone, required String valeur}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: V4.surface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: V4.border),
      ),
      child: Row(
        children: [
          Icon(icone, size: 16, color: V4.inkMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              valeur.isEmpty ? '—' : valeur,
              style: GoogleFonts.inter(fontSize: 13, color: V4.inkSoft),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String titre, required List<Widget> items}) {
    return Container(
      decoration: BoxDecoration(
        color: V4.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: V4.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              titre,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: V4.inkMuted,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icone,
    required String titre,
    String? sousTitre,
    required VoidCallback? onTap,
    bool afficherChevron = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: V4.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: V4.border),
              ),
              child: Icon(icone, size: 18, color: V4.inkSoft),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: V4.ink,
                    ),
                  ),
                  if (sousTitre != null)
                    Text(
                      sousTitre,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: V4.inkMuted),
                    ),
                ],
              ),
            ),
            if (afficherChevron)
              Icon(Icons.chevron_right, color: V4.inkMuted, size: 18),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: V4.surface2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: V4.borderStrong),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: V4.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              S.language,
              style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w700, color: V4.ink),
            ),
            const SizedBox(height: 16),
            _langOption(ctx, 'fr', '🇫🇷', S.langFr),
            _langOption(ctx, 'en', '🇬🇧', S.langEn),
            _langOption(ctx, 'ar', '🇲🇦', S.langAr),
          ],
        ),
      ),
    );
  }

  Widget _langOption(BuildContext ctx, String code, String flag, String name) {
    final selected = S.locale.languageCode == code;
    return InkWell(
      onTap: () async {
        await LocaleProvider().setLocale(Locale(code));
        if (!ctx.mounted) return;
        Navigator.pop(ctx);
        setState(() {});
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? V4.teal.withValues(alpha: 0.10) : V4.surface1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? V4.teal.withValues(alpha: 0.4) : V4.border,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selected ? V4.teal : V4.ink,
              ),
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_rounded, color: V4.teal, size: 18),
          ],
        ),
      ),
    );
  }

  void _afficherBientot(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.comingSoon,
            style: GoogleFonts.inter(color: V4.ink)),
        backgroundColor: V4.surface2,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool loading = false;
    bool oldVisible = false;
    bool newVisible = false;
    bool confirmVisible = false;

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
            S.changePassword,
            style: GoogleFonts.inter(
                fontSize: 18, fontWeight: FontWeight.w700, color: V4.ink),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: oldPassCtrl,
                    obscureText: !oldVisible,
                    style: GoogleFonts.inter(fontSize: 14, color: V4.ink),
                    decoration: V4.inputDec(
                      label: S.currentPassword,
                      prefix: Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(
                          oldVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: V4.inkMuted,
                        ),
                        onPressed: () =>
                            setDialogState(() => oldVisible = !oldVisible),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return S.currentPasswordRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: newPassCtrl,
                    obscureText: !newVisible,
                    style: GoogleFonts.inter(fontSize: 14, color: V4.ink),
                    decoration: V4.inputDec(
                      label: S.newPassword,
                      prefix: Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(
                          newVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: V4.inkMuted,
                        ),
                        onPressed: () =>
                            setDialogState(() => newVisible = !newVisible),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return S.newPasswordRequired;
                      }
                      if (val.length < 8) return S.passwordMin8;
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: confirmCtrl,
                    obscureText: !confirmVisible,
                    style: GoogleFonts.inter(fontSize: 14, color: V4.ink),
                    decoration: V4.inputDec(
                      label: S.confirmPasswordLabel,
                      prefix: Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(
                          confirmVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: V4.inkMuted,
                        ),
                        onPressed: () => setDialogState(
                            () => confirmVisible = !confirmVisible),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return S.confirmRequired;
                      }
                      if (val != newPassCtrl.text) {
                        return S.passwordMismatch;
                      }
                      return null;
                    },
                  ),
                ],
              ),
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
                      setDialogState(() => loading = true);
                      try {
                        await AuthService().changePassword(
                          oldPassCtrl.text,
                          newPassCtrl.text,
                        );
                        if (!dialogContext.mounted) return;
                        Navigator.pop(dialogContext);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(S.passwordUpdated,
                                style: GoogleFonts.inter(color: V4.ink)),
                            backgroundColor: V4.tealDim,
                          ),
                        );
                      } catch (e) {
                        setDialogState(() => loading = false);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString().replaceFirst('Exception: ', ''),
                              style: GoogleFonts.inter(color: V4.ink),
                            ),
                            backgroundColor: V4.coral,
                          ),
                        );
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
                  : Text(S.confirm,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: V4.bg)),
            ),
          ],
        ),
      ),
    ).then((_) {
      oldPassCtrl.dispose();
      newPassCtrl.dispose();
      confirmCtrl.dispose();
    });
  }

  void _confirmerDeconnexion(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: V4.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: V4.borderStrong),
        ),
        title: Text(S.logout,
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: V4.ink)),
        content: Text(
          S.logoutConfirm,
          style: GoogleFonts.inter(fontSize: 14, color: V4.inkSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: V4.inkSoft),
            child: Text(S.cancel,
                style: GoogleFonts.inter(fontSize: 14, color: V4.inkSoft)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService().logout();
              widget.onLogout();
            },
            style: TextButton.styleFrom(foregroundColor: V4.coral),
            child: Text(S.logout,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: V4.coral)),
          ),
        ],
      ),
    );
  }
}
