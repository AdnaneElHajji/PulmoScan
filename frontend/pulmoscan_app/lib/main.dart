// lib/main.dart — VERSION CORRIGÉE
// Gère la navigation principale avec barre du bas (Dashboard, Patients, Profil)

import 'package:flutter/material.dart';
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
      debugShowCheckedModeBanner: false, // Cache le bandeau "DEBUG"
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
      // Démarre sur l'écran de connexion
      home: LoginPageExact(
        onLogin: (context) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainNavigation(),
            ),
          );
        },
      ),
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
  int _indexActuel = 0; // Onglet actif (0=Dashboard, 1=Patients, 2=Profil)

  // Les 3 écrans principaux
  late final List<Widget> _ecrans;

  @override
  void initState() {
    super.initState();
    _ecrans = [
       DashboardResponsive(),
      const PatientsListScreen(),
      ProfileScreen(
        onLogout: _seDeconnecter,
      ),
    ];
  }

  // Déconnecte et retourne à l'écran de login
  void _seDeconnecter() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPageExact(
          onLogin: (context) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainNavigation(),
              ),
            );
          },
        ),
      ),
      (route) => false, // Supprime tout l'historique de navigation
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Affiche l'écran selon l'onglet actif
      body: IndexedStack(
        index: _indexActuel,
        children: _ecrans,
      ),

      // Bouton flottant "Nouvel examen" visible sur Dashboard et Patients
      floatingActionButton: _indexActuel != 2
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExamScreen(),
                  ),
                );
              },
              backgroundColor: const Color(0xFF0059FF),
              child: const Icon(Icons.add, size: 28, color: Colors.white),
            )
          : null,

      // Barre de navigation du bas
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexActuel,
        onTap: (index) => setState(() => _indexActuel = index),
        selectedItemColor: const Color(0xFF0059FF),
        unselectedItemColor: const Color(0xFF9CA3AF),
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
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