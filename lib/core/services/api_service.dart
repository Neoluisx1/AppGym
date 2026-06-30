// 🌐 API Service - Cliente HTTP con Dio
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  late Dio _dio;
  final _storage = const FlutterSecureStorage();
  String _currentBaseUrl = '';
  
  ApiService._internal() {
    _initializeDio(ApiConstants.baseUrl);
  }
  
  // Inicializar o actualizar Dio con nueva URL
  void _initializeDio(String baseUrl) {
    _currentBaseUrl = baseUrl;
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    // Interceptor para agregar token automáticamente
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expirado - podrías implementar refresh aquí
            await deleteToken();
          }
          return handler.next(error);
        },
      ),
    );
    
    // Interceptor para logs (solo en debug)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }
  
  // Getter para acceder al Dio instance
  Dio get dio => _dio;
  
  // Actualizar URL base (cuando cambia configuración)
  void updateBaseUrl(String newBaseUrl) {
    if (_currentBaseUrl != newBaseUrl) {
      _initializeDio(newBaseUrl);
    }
  }
  
  // ============================================
  // TOKEN MANAGEMENT
  // ============================================
  
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
  
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  // ============================================
  // HTTP METHODS
  // ============================================
  
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response> uploadFile(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath, filename: fileName),
        ...?additionalData,
      });
      return await _dio.post(
        path,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetches gym branding config (logo, name, tour video URL).
  /// Returns null silently if the endpoint doesn't exist yet.
  Future<Map<String, dynamic>?> fetchGymConfig() async {
    try {
      final response = await _dio.get(ApiConstants.gymConfig);
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
  
  // ============================================
  // ERROR HANDLING
  // ============================================
  
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Timeout - Verifica tu conexión a internet';
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'];
        
        if (statusCode == 401) {
          return 'No autorizado - Inicia sesión nuevamente';
        } else if (statusCode == 403) {
          return 'No tienes permiso para realizar esta acción';
        } else if (statusCode == 404) {
          return 'Recurso no encontrado';
        } else if (statusCode == 422) {
          // Errores de validación
          final errors = error.response?.data['errors'];
          if (errors is Map) {
            return errors.values.first[0].toString();
          }
          return message ?? 'Error de validación';
        } else if (statusCode == 500) {
          return 'Error del servidor - Intenta más tarde';
        }
        
        return message ?? 'Error desconocido';
      
      case DioExceptionType.cancel:
        return 'Petición cancelada';
      
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return 'Sin conexión a internet';
        }
        return 'Error de conexión - Verifica tu internet';
      
      default:
        return 'Error desconocido';
    }
  }
}
