import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_app/core/services/storage_service.dart';
import 'package:patient_app/core/services/api_client.dart';

class AuthService {
  final StorageService _storage;
  final ApiClient _apiClient;
  
  String? _authToken;

  AuthService(this._storage, this._apiClient);

  bool get isAuthenticated => _authToken != null;

  Future<void> stop() async {
    // Cleanup if needed
  }

  Future<bool> checkAuth() async {
    _authToken = await _storage.read('auth_token');
    return _authToken != null;
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiClient.client.post('/auth/token', 
        data: {'username': email, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType)
      );

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        _authToken = token;
        await _storage.write('auth_token', token);
        return true;
      }
      return false;
    } catch (e) {
      print("Login Failed: $e");
      return false;
    }
  }

  Future<bool> register(String email, String password, String fullName) async {
    try {
      final response = await _apiClient.client.post('/auth/register', 
        data: {
          'email': email, 
          'password': password,
          'full_name': fullName,
          'role': 'patient'
        },
      );

      if (response.statusCode == 200) {
        // Registration successful AND returns a token, so we can log them in directly
        final token = response.data['access_token'];
        _authToken = token;
        await _storage.write('auth_token', token);
        return true;
      }
      return false;
    } catch (e) {
      print("Registration Failed: $e");
      return false;
    }
  }

  Future<void> logout() async {
    _authToken = null;
    await _storage.delete('auth_token');
  }
}

// Provider
final authServiceProvider = Provider((ref) {
  final storage = ref.watch(storageServiceProvider);
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(storage, apiClient);
});
