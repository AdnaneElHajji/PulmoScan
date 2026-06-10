import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/v4_theme.dart';
import 'widgets/aperture_mark.dart';
import 'l10n/locale_provider.dart';
import 'l10n/strings.dart';
import 'services/ai_service.dart';
import 'services/auth_service.dart';
import 'screens/login.dart';
import 'screens/onboarding.dart';
import 'screens/dashboard.dart';
import 'screens/patients_list_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/exam_screen.dart';
import 'screens/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocaleProvider().load();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const PulmoApp());
}

class PulmoApp extends StatefulWidget {
  const PulmoApp({super.key});

  @override
  State<PulmoApp> createState() => _PulmoAppState();
}

class _PulmoAppState extends State<PulmoApp> with WidgetsBindingObserver {
  final _localeProvider = LocaleProvider();

  void _onLocaleChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _localeProvider.addListener(_onLocaleChanged);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      AiService().dispose();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _localeProvider.removeListener(_onLocaleChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PulmoScan AI',
      debugShowCheckedModeBanner: false,
      theme: V4.theme(),
      locale: _localeProvider.locale,
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}

// ══════════════════════════════════════════════════════════
// SPLASH SCREEN
// ══════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_v2_done') ?? false;

    if (!mounted) return;
    if (!onboardingDone) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OnboardingScreen(onDone: _goToLogin)),
      );
      return;
    }

    // Auto-login: skip login screen if user is already logged in (SQLite-based)
    final loggedIn = await AuthService().isLoggedIn();
    if (!mounted) return;
    if (loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
      return;
    }

    _goToLogin(context);
  }

  void _goToLogin(BuildContext ctx) {
    Navigator.pushReplacement(
      ctx,
      MaterialPageRoute(
        builder: (_) => LoginPageExact(
          onLogin: (loginCtx) => Navigator.pushReplacement(
            loginCtx,
            MaterialPageRoute(builder: (_) => const MainNavigation()),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
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
                  center: Alignment(0, -0.3),
                  radius: 0.85,
                  colors: [Color(0x3434E5C5), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.7, 0.7),
                  radius: 0.6,
                  colors: [Color(0x165A9BFF), Colors.transparent],
                ),
              ),
            ),
          ),
          FadeTransition(
            opacity: _fade,
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  const ApertureMark(size: 168, active: [1, 4, 7, 11]),
                  const SizedBox(height: 32),
                  const Wordmark(size: 32),
                  const SizedBox(height: 14),
                  Text(
                    'quatorze pathologies,\nune radiographie.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      color: V4.inkSoft,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _dot(V4.teal),
                      const SizedBox(width: 4),
                      _dot(V4.teal),
                      const SizedBox(width: 4),
                      _dot(V4.surface3),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '2 MODÈLES · 14 PATHOLOGIES',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      letterSpacing: 1.8,
                      color: V4.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Foudali Kenza · El Hajji Adnnane · BTS 2026',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 1.4,
                      color: V4.inkMuted.withValues(alpha: 0.55),
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: 18,
        height: 3,
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
      );
}

// ══════════════════════════════════════════════════════════
// MAIN NAVIGATION
// ══════════════════════════════════════════════════════════
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const PatientsListScreen(),
      const HistoryScreen(),
      ProfileScreen(onLogout: _logout),
    ];
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPageExact(
          onLogin: (ctx) => Navigator.pushReplacement(
            ctx,
            MaterialPageRoute(builder: (_) => const MainNavigation()),
          ),
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ExamScreen()),
        ),
        backgroundColor: V4.teal,
        foregroundColor: V4.bg,
        elevation: 0,
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomBar(
        index: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const _BottomBar({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return BottomAppBar(
      color: V4.surface1,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 0, 8, bottomPad > 0 ? bottomPad : 4),
        child: Row(
          children: [
            _item(0, Icons.dashboard_outlined, Icons.dashboard, S.navHome),
            _item(1, Icons.people_outline, Icons.people, S.navPatients),
            const Expanded(child: SizedBox()),
            const Expanded(child: SizedBox()),
            _item(2, Icons.history_outlined, Icons.history_rounded, S.navHistory),
            _item(3, Icons.person_outline, Icons.person, S.navProfile),
          ],
        ),
      ),
    );
  }

  Widget _item(int idx, IconData icon, IconData activeIcon, String label) {
    final on = index == idx;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(idx),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(on ? activeIcon : icon,
                  color: on ? V4.teal : V4.inkMuted, size: 20),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: on ? FontWeight.w700 : FontWeight.w400,
                  color: on ? V4.teal : V4.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
