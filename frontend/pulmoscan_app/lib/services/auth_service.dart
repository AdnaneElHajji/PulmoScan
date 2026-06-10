import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static Map<String, dynamic>? currentUser;

  // ── LOGIN — pure SQLite + SHA-256 ─────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password,
      {bool rememberMe = false}) async {
    final localUser = await DatabaseService().login(email, password);
    if (localUser == null) {
      throw Exception('Email ou mot de passe incorrect');
    }

    final user = {
      'name': localUser['name']?.toString() ?? '',
      'email': localUser['email']?.toString() ?? '',
      'role': localUser['role']?.toString() ?? 'medecin',
    };

    currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', user['name'] as String);
    await prefs.setString('user_email', user['email'] as String);
    await prefs.setString('user_role', user['role'] as String);
    await prefs.setBool('is_logged_in', true);
    return currentUser!;
  }

  // ── REGISTER — pure SQLite ────────────────────────────────────────────────

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String role = 'medecin',
  }) async {
    final ok = await DatabaseService().register(name, email, password, role: role);
    if (!ok) {
      throw Exception('Cet email est déjà utilisé');
    }
  }

  // ── VERIFY / FORGOT PASSWORD (offline bypass) ─────────────────────────────

  Future<void> sendVerificationCode(String email) async {
    final d = await DatabaseService().db;
    final rows = await d.query('users', where: 'email = ?', whereArgs: [email]);
    if (rows.isNotEmpty) {
      throw Exception('Cet email est déjà utilisé');
    }
  }

  Future<void> verifyCode(String email, String code) async {
    if (code.length != 6) throw Exception('Code invalide (6 chiffres requis)');
  }

  Future<void> forgotPassword(String email) async {
    final d = await DatabaseService().db;
    final rows = await d.query('users', where: 'email = ?', whereArgs: [email]);
    if (rows.isEmpty) {
      throw Exception('Aucun compte trouvé pour cet email');
    }
    throw Exception('Réinitialisation par email non disponible en mode hors ligne.');
  }

  // ── LOGOUT ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    await prefs.setBool('is_logged_in', false);
  }

  // ── SESSION ────────────────────────────────────────────────────────────────

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('is_logged_in') ?? false;
    if (loggedIn && currentUser == null) {
      currentUser = {
        'name': prefs.getString('user_name') ?? '',
        'email': prefs.getString('user_email') ?? '',
        'role': prefs.getString('user_role') ?? '',
      };
    }
    return loggedIn;
  }

  Future<Map<String, String>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name') ?? '',
      'email': prefs.getString('user_email') ?? '',
      'role': prefs.getString('user_role') ?? '',
    };
  }

  // ── CHANGE PASSWORD ────────────────────────────────────────────────────────

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email') ?? '';
    final ok = await DatabaseService().changePassword(email, oldPassword, newPassword);
    if (!ok) throw Exception('Mot de passe actuel incorrect');
    return true;
  }
}
