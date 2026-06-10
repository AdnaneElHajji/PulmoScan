import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

/// Background sync to Railway — always fire-and-forget.
/// The app never waits for this and never shows errors from it.
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  static const String _baseUrl =
      'https://backend-production-0fdbb.up.railway.app/api';
  static const Duration _timeout = Duration(seconds: 8);

  Future<Map<String, String>> _headers() async {
    final token = await AuthService().getRailwayToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Call this after creating a patient locally. Non-blocking.
  void syncPatient(Map<String, dynamic> body) {
    _post('/patients', body);
  }

  /// Call this after creating an exam locally. Non-blocking.
  void syncExam(Map<String, dynamic> body) {
    _post('/exams', body);
  }

  /// Call this after creating a result locally. Non-blocking.
  void syncResult(Map<String, dynamic> body) {
    _post('/results', body);
  }

  /// Fire-and-forget POST — swallows all errors silently.
  void _post(String path, Map<String, dynamic> body) {
    Future(() async {
      try {
        final headers = await _headers();
        await http
            .post(
              Uri.parse('$_baseUrl$path'),
              headers: headers,
              body: jsonEncode(body),
            )
            .timeout(_timeout);
      } catch (_) {
        // Silently ignored — sync is optional
      }
    });
  }
}
