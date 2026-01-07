import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:patient_app/core/services/storage_service.dart';

class ApiClient {
  final Dio _dio;
  final StorageService _storage;

  ApiClient(this._dio, this._storage) {
    _dio.options = BaseOptions(
      baseUrl: 'https://api-gateway-zxsaiaxzjq-uc.a.run.app', // Cloud Run Gateway
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add Auth Token to header
          final token = await _storage.read('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Handle global errors (401, etc.)
          if (e.response?.statusCode == 401) {
            // Trigger logout or refresh
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get client => _dio;
}

final apiClientProvider = Provider((ref) {
  final storage = ref.watch(storageServiceProvider);
  final dio = Dio();
  return ApiClient(dio, storage);
});
