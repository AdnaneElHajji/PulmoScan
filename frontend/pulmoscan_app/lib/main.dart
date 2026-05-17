import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login.dart';
import 'screens/dashboard.dart';
import 'screens/patients_list_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/exam_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PulmoScan IA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0059FF),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF6B7280)),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0059FF),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// ════════════════════════════════════════════════
// Auth gate — checks Remember Me on cold start
// ════════════════════════════════════════════════
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<bool> _authCheck;

  @override
  void initState() {
    super.initState();
    _authCheck = _isAutoLoginEnabled();
  }

  Future<bool> _isAutoLoginEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;
    final token = prefs.getString('jwt_token') ?? '';
    return rememberMe && token.isNotEmpty;
  }

  void _navigateToMain(BuildContext ctx) {
    Navigator.pushReplacement(
      ctx,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authCheck,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFFF9FAFB),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF0059FF)),
            ),
          );
        }
        if (snapshot.data == true) {
          return const MainNavigation();
        }
        return LoginPageExact(onLogin: _navigateToMain);
      },
    );
  }
}

// ════════════════════════════════════════════════
// Navigation principale avec barre du bas
// ════════════════════════════════════════════════
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _indexActuel = 0;

  late final List<Widget> _ecrans;

  @override
  void initState() {
    super.initState();
    _ecrans = [
      DashboardResponsive(),
      const PatientsListScreen(),
      ProfileScreen(onLogout: _seDeconnecter),
    ];
  }

  void _seDeconnecter() {
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
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indexActuel,
        children: _ecrans,
      ),
      floatingActionButton: _indexActuel != 2
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExamScreen()),
                );
              },
              backgroundColor: const Color(0xFF0059FF),
              child: const Icon(Icons.add, size: 28, color: Colors.white),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexActuel,
        onTap: (index) => setState(() => _indexActuel = index),
        selectedItemColor: const Color(0xFF0059FF),
        unselectedItemColor: const Color(0xFF9CA3AF),
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
