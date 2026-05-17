import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const _tokenKey = 'jwt_token';
  static const _rememberMeKey = 'remember_me';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _userRoleKey = 'user_role';

  String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    try {
      if (Platform.isAndroid) return 'http://192.168.1.3:3000/api';
    } catch (_) {}
    return 'http://localhost:3000/api';
  }

  // ── Token ──────────────────────────────────────────────────────────────────

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ── Remember Me ────────────────────────────────────────────────────────────

  Future<void> saveRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, value);
  }

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  Future<void> clearRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberMeKey);
  }

  // ── User info ──────────────────────────────────────────────────────────────

  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, user['name']?.toString() ?? '');
    await prefs.setString(_userEmailKey, user['email']?.toString() ?? '');
    await prefs.setString(_userRoleKey, user['role']?.toString() ?? '');
  }

  Future<Map<String, String>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_userNameKey) ?? '',
      'email': prefs.getString(_userEmailKey) ?? '',
      'role': prefs.getString(_userRoleKey) ?? '',
    };
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userRoleKey);
  }

  Future<void> logout() async {
    await clearToken();
    await clearUser();
    await clearRememberMe();
  }

  // ── HTTP helpers ───────────────────────────────────────────────────────────

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  dynamic _handle(http.Response res) {
    dynamic body;
    try {
      body = jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {
      body = {'message': 'Réponse invalide du serveur'};
    }
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    final msg = (body is Map && body['message'] != null)
        ? body['message'].toString()
        : 'Erreur ${res.statusCode}';
    throw Exception(msg);
  }

  Future<dynamic> get(String path) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl$path'), headers: await _headers())
          .timeout(const Duration(seconds: 15));
      return _handle(res);
    } on Exception catch (e) {
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception('Impossible de contacter le serveur');
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: await _headers(auth: auth),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      return _handle(res);
    } on Exception catch (e) {
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception('Impossible de contacter le serveur');
    }
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .put(
            Uri.parse('$baseUrl$path'),
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      return _handle(res);
    } on Exception catch (e) {
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception('Impossible de contacter le serveur');
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final res = await http
          .delete(Uri.parse('$baseUrl$path'), headers: await _headers())
          .timeout(const Duration(seconds: 15));
      return _handle(res);
    } on Exception catch (e) {
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception('Impossible de contacter le serveur');
    }
  }
}
