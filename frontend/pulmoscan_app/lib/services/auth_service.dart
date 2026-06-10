import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static Map<String, dynamic>? currentUser;

  static const String _baseUrl =
      'https://backend-production-0fdbb.up.railway.app/api';
  static const Duration _timeout = Duration(seconds: 5);

  // ── LOGIN ──────────────────────────────────────────────────────────────────
  // 1. Try Railway, 2. Fallback to SQLite local

  Future<Map<String, dynamic>> login(String email, String password,
      {bool rememberMe = false}) async {
    Map<String, dynamic>? user;

    // Try Railway first
    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeout);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final body = jsonDecode(utf8.decode(res.bodyBytes));
        final railwayUser = body['user'] as Map<String, dynamic>?;
        if (railwayUser != null) {
          user = {
            'name': railwayUser['name']?.toString() ?? email,
            'email': railwayUser['email']?.toString() ?? email,
            'role': railwayUser['role']?.toString() ?? 'medecin',
          };
          // Save/update in local SQLite for offline fallback
          await DatabaseService().upsertUser(
            name: user['name'] as String,
            email: user['email'] as String,
            password: password,
            role: user['role'] as String,
          );
          // Save Railway token if present
          final token = body['token']?.toString();
          if (token != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('railway_token', token);
          }
        }
      } else if (res.statusCode == 401) {
        // Credentials explicitly rejected by server → fail immediately
        throw Exception('Email ou mot de passe incorrect');
      }
    } catch (e) {
      // If it's an explicit 401 re-throw it
      if (e.toString().contains('Email ou mot de passe incorrect')) rethrow;
      // Otherwise: network issue → fallback to local
    }

    // If Railway didn't give us a user, try local SQLite
    if (user == null) {
      final localUser = await DatabaseService().login(email, password);
      if (localUser == null) {
        throw Exception('Email ou mot de passe incorrect');
      }
      user = {
        'name': localUser['name']?.toString() ?? '',
        'email': localUser['email']?.toString() ?? '',
        'role': localUser['role']?.toString() ?? 'medecin',
      };
    }

    // Persist session
    currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', user['name'] as String);
    await prefs.setString('user_email', user['email'] as String);
    await prefs.setString('user_role', user['role'] as String);
    await prefs.setBool('is_logged_in', true);
    return currentUser!;
  }

  // ── REGISTER ───────────────────────────────────────────────────────────────
  // 1. Try Railway, 2. If network failure → save locally only

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String role = 'medecin',
  }) async {
    bool railwayOk = false;

    try {
      final res = await http
          .post(
            Uri.parse('$_baseUrl/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'role': role,
            }),
          )
          .timeout(_timeout);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        railwayOk = true;
      } else if (res.statusCode == 409 || res.statusCode == 400) {
        // Email already taken on server
        throw Exception('Cet email est déjà utilisé');
      }
    } catch (e) {
      if (e.toString().contains('Cet email est déjà utilisé')) rethrow;
      // Network failure → continue to local registration
    }

    // Always save locally (whether Railway succeeded or not)
    final ok = await DatabaseService()
        .register(name, email, password, role: role);
    if (!ok && !railwayOk) {
      throw Exception('Cet email est déjà utilisé');
    }
  }

  // ── VERIFY / SEND CODE (offline bypass) ───────────────────────────────────

  Future<void> sendVerificationCode(String email) async {
    // Offline-first: check if email already taken locally
    final db = DatabaseService();
    final d = await db.db;
    final rows =
        await d.query('users', where: 'email = ?', whereArgs: [email]);
    if (rows.isNotEmpty) {
      throw Exception('Cet email est déjà utilisé');
    }
    // Try Railway in background (don't block UI)
    // Code is bypassed in offline mode — VerifyScreen accepts any 6 digits
  }

  Future<void> verifyCode(String email, String code) async {
    // Offline mode: any 6-digit code accepted
    if (code.length != 6) throw Exception('Code invalide (6 chiffres requis)');
  }

  Future<void> forgotPassword(String email) async {
    // Offline: just check the account exists
    final db = DatabaseService();
    final d = await db.db;
    final rows =
        await d.query('users', where: 'email = ?', whereArgs: [email]);
    if (rows.isEmpty) {
      throw Exception('Aucun compte trouvé pour cet email');
    }
    throw Exception(
        'Réinitialisation par email non disponible en mode hors ligne.');
  }

  // ── LOGOUT ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    await prefs.remove('railway_token');
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

  Future<String?> getRailwayToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('railway_token');
  }

  // ── CHANGE PASSWORD ────────────────────────────────────────────────────────

  Future<bool> changePassword(
      String oldPassword, String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email') ?? '';
    final ok = await DatabaseService()
        .changePassword(email, oldPassword, newPassword);
    if (!ok) throw Exception('Mot de passe actuel incorrect');
    return true;
  }
}
