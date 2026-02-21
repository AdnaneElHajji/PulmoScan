import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// Simple AuthService for logging in against the backend API.
///
/// - Picks a sensible default base URL depending on platform:
///   - Android emulator -> 10.0.2.2
///   - Web / desktop / iOS simulator -> localhost
class AuthService {
  final String baseUrl;

  AuthService({String? baseUrl}) : baseUrl = baseUrl ?? _defaultBaseUrl();

  static String _defaultBaseUrl() {
    if (kIsWeb) return 'http://localhost:3000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/api';
    return 'http://localhost:3000/api';
  }

  /// Attempts to log in with [email] and [password].
  ///
  /// Returns void on success; throws an [Exception] with a friendly message on failure.
  Future<void> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return; // success
    }

    String msg = 'Erreur de connexion';
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['message'] != null) {
        msg = body['message'].toString();
      }
    } catch (_) {}

    throw Exception(msg);
  }

  /// Register a new user with [name], [email], and [password].
  /// Throws an [Exception] with a friendly message on failure.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      return; // success
    }

    String msg = 'Erreur lors de l\'inscription';
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['message'] != null) {
        msg = body['message'].toString();
      }
    } catch (_) {}

    throw Exception(msg);
  }
}

