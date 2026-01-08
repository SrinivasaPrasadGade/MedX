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

  Future<bool> register({
    required String email, 
    required String password, 
    required String fullName,
    String? dob,
    String? gender,
    String? phone,
    String? address,
  }) async {
    try {
      final response = await _apiClient.client.post('/auth/register', 
        data: {
          'email': email, 
          'password': password,
          'full_name': fullName,
          'role': 'patient',
          'date_of_birth': dob,
          'gender': gender,
          'phone': phone,
          'address': address,
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

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await _apiClient.client.get('/auth/me'); // auth-service is behind gateway path? Assume /auth if configured, or just /me relative to auth service
      // Wait, API Gateway mapping check: 
      // If ApiClient base URL allows direct service access or via gateway.
      // Standard practice: Gateway routes /auth/* to Auth Service.
      // Backend added /me. So it should be /auth/me or just /me depending on routing.
      // Assuming existing /token was /auth/token.
      // Let's check logic: login uses /auth/token. So register uses /auth/register. So this is /auth/me.
      
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print("Get Profile Failed: $e");
      return null;
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
