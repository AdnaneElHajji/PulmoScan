import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<void> sendVerificationCode(String email) async {
    await _api.post('/send-code', {'email': email}, auth: false);
  }

  Future<void> verifyCode(String email, String code) async {
    await _api.post('/verify-code', {'email': email, 'code': code}, auth: false);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String role = 'medecin',
  }) async {
    await _api.post(
      '/register',
      {'name': name, 'email': email, 'password': password, 'role': role},
      auth: false,
    );
  }

  Future<void> login(String email, String password) async {
    final data = await _api.post(
      '/login',
      {'email': email, 'password': password},
      auth: false,
    );
    await _api.saveToken(data['token'] as String);
    if (data['user'] != null) {
      await _api.saveUser(data['user'] as Map<String, dynamic>);
    }
  }

  Future<void> logout() => _api.logout();
}
