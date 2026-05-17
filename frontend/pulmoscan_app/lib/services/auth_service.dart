import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static String? _token;
  static Map<String, dynamic>? _currentUser;

  final String baseUrl;

  AuthService({String? baseUrl}) : baseUrl = baseUrl ?? _defaultBaseUrl();

  static String _defaultBaseUrl() {
    return 'https://backend-production-0fdbb.up.railway.app/api';
  }

  static String? get token => _token;
  static Map<String, dynamic>? get currentUser => _currentUser;

  /// Logs in and stores the JWT token in memory.
  Future<void> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      _token = body['token'] as String?;
      _currentUser = body['user'] as Map<String, dynamic>?;
      return;
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

