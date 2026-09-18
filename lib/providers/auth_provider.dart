import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/services/fcm_service.dart';
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  UserModel? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;
  String? _errorType;    // 'not_found' | 'membership_expired' | 'inactive' | 'error'
  String? _errorWhatsapp;

  // Verificación en dos pasos (solo admin/entrenador, login por documento)
  bool _requiresTwoFactor = false;
  String? _twoFactorChallenge;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;
  String? get errorType => _errorType;
  String? get errorWhatsapp => _errorWhatsapp;
  bool get isClient => _user?.client != null;
  bool get isTrainer => _user?.trainer != null || _user?.role?.name == 'instructor';
  bool get isAdmin => _user?.role?.name == 'admin';
  bool get requiresTwoFactor => _requiresTwoFactor;
  
  // ============================================
  // LOGIN
  // ============================================
  
  Future<bool> login({
    required String email,
    required String password,
    String? deviceName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
          'device_name': deviceName ?? 'mobile-app',
        },
      );
      
      if (response.data['success'] == true) {
        final data = response.data['data'];

        // Guardar token
        await _apiService.saveToken(data['token']);

        // Guardar usuario
        _user = UserModel.fromJson(data['user']);
        _isAuthenticated = true;

        _isLoading = false;
        notifyListeners();

        _registerFcm();
        return true;
      }

      throw Exception('Login failed');
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }
  
  // ============================================
  // LOGIN POR DOCUMENTO
  // ============================================
  
  Future<bool> loginByDocument({
    required String document,
    String? deviceName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      _errorType = null;
      _errorWhatsapp = null;
      notifyListeners();

      final response = await _apiService.post(
        ApiConstants.loginByDocument,
        data: {
          'document': document,
          'device_name': deviceName ?? 'mobile-app',
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        await _apiService.saveToken(data['token']);
        _user = UserModel.fromJson(data['user']);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        _registerFcm();
        return true;
      }

      throw Exception('Login failed');
    } on Exception catch (e) {
      // Try to extract structured error from DioException response body
      final raw = e.toString();
      // DioException wraps response data as string; parse if possible
      _error = raw;
      _errorType = null;
      _errorWhatsapp = null;

      // ApiService._handleError returns a plain string, so we need to
      // intercept BEFORE it converts. Use a separate try below.
      _isLoading = false;
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  /// Login por documento con manejo estructurado de errores del backend.
  Future<bool> loginByDocumentSafe({
    required String document,
    String? deviceName,
  }) async {
    _isLoading = true;
    _error = null;
    _errorType = null;
    _errorWhatsapp = null;
    _requiresTwoFactor = false;
    _twoFactorChallenge = null;
    notifyListeners();

    try {
      // Usar dio directamente para preservar el DioException con el body del 422
      final response = await _apiService.dio.post(
        ApiConstants.loginByDocument,
        data: {
          'document': document,
          'device_name': deviceName ?? 'mobile-app',
        },
      );

      if (response.data['success'] == true) {
        // Cuentas de administrador/entrenador: el backend no entrega el token
        // todavía, sino un desafío que hay que confirmar con el código de
        // verificación en dos pasos.
        if (response.data['requires_2fa'] == true) {
          final data = response.data['data'] as Map?;
          _twoFactorChallenge = data?['challenge'] as String?;
          _requiresTwoFactor = true;
          _isLoading = false;
          notifyListeners();
          return false;
        }

        final data = response.data['data'];
        await _apiService.saveToken(data['token']);
        _user = UserModel.fromJson(data['user']);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        _registerFcm();
        return true;
      }

      _error = 'Error de autenticación';
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map) {
        _error       = data['message'] as String? ?? 'Error al iniciar sesión';
        _errorType   = (data['error_type'] as String?) ?? _inferErrorType(_error ?? '');
        _errorWhatsapp = data['whatsapp'] as String?;
      } else if (e.type == DioExceptionType.unknown ||
                 e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.sendTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        _error = 'Error de conexión. Verifica tu internet.';
      } else {
        _error = 'Error al iniciar sesión.';
      }
    } catch (e) {
      _error = 'Error inesperado. Intenta de nuevo.';
    }

    _isLoading = false;
    _isAuthenticated = false;
    notifyListeners();
    return false;
  }

  String? _inferErrorType(String message) {
    final m = message.toLowerCase();
    if (m.contains('document') || m.contains('encontr') || m.contains('registr')) return 'not_found';
    if (m.contains('membres') || m.contains('vencid') || m.contains('renov')) return 'membership_expired';
    if (m.contains('inactiv')) return 'inactive';
    return null;
  }

  // ============================================
  // VERIFICACIÓN EN DOS PASOS (admin/entrenador)
  // ============================================

  /// Confirma el código de verificación en dos pasos del desafío generado por
  /// [loginByDocumentSafe] y, si es correcto, completa el login.
  Future<bool> verifyTwoFactor({
    required String code,
    String? deviceName,
  }) async {
    _isLoading = true;
    _error = null;
    _errorType = null;
    notifyListeners();

    final challenge = _twoFactorChallenge;
    if (challenge == null) {
      _error = 'La verificación expiró. Vuelve a iniciar sesión.';
      _isLoading = false;
      _requiresTwoFactor = false;
      notifyListeners();
      return false;
    }

    try {
      final response = await _apiService.dio.post(
        ApiConstants.verifyStaffTwoFactor,
        data: {
          'challenge': challenge,
          'code': code,
          'device_name': deviceName ?? 'mobile-app',
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        await _apiService.saveToken(data['token']);
        _user = UserModel.fromJson(data['user']);
        _isAuthenticated = true;
        _requiresTwoFactor = false;
        _twoFactorChallenge = null;
        _isLoading = false;
        notifyListeners();
        _registerFcm();
        return true;
      }

      _error = 'No se pudo verificar el código.';
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map) {
        _error = data['message'] as String? ?? 'Código inválido.';
        _errorType = data['error_type'] as String?;
        // Si el desafío expiró, hay que reiniciar el login desde cero.
        if (_errorType == 'challenge_expired') {
          _requiresTwoFactor = false;
          _twoFactorChallenge = null;
        }
      } else if (e.type == DioExceptionType.unknown ||
                 e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.sendTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        _error = 'Error de conexión. Verifica tu internet.';
      } else {
        _error = 'No se pudo verificar el código.';
      }
    } catch (e) {
      _error = 'Error inesperado. Intenta de nuevo.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Cancela el desafío de verificación en dos pasos en curso (p. ej. si el
  /// usuario vuelve atrás desde la pantalla del código).
  void cancelTwoFactor() {
    _requiresTwoFactor = false;
    _twoFactorChallenge = null;
    _error = null;
    _errorType = null;
    notifyListeners();
  }

  // ============================================
  // LOGOUT
  // ============================================
  
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();
      await FcmService().unregisterToken();
      await _apiService.post(ApiConstants.logout);
    } catch (e) {
      debugPrint('Error en logout: $e');
    } finally {
      await _apiService.deleteToken();
      _user = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // ============================================
  // CHECK AUTH (Verificar si hay sesión activa)
  // ============================================
  
  Future<bool> checkAuth() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Verificar si hay token
      final hasToken = await _apiService.hasToken();
      
      if (!hasToken) {
        _isAuthenticated = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // Obtener datos del usuario
      final response = await _apiService.get(ApiConstants.me);
      
      if (response.data['success'] == true) {
        _user = UserModel.fromJson(response.data['data']);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      throw Exception('Auth check failed');
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _isLoading = false;
      await _apiService.deleteToken(); // Limpiar token inválido
      notifyListeners();
      return false;
    }
  }
  
  // ============================================
  // REFRESH USER DATA
  // ============================================
  
  Future<void> refreshUser() async {
    try {
      final response = await _apiService.get(ApiConstants.me);
      
      if (response.data['success'] == true) {
        _user = UserModel.fromJson(response.data['data']);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing user: $e');
    }
  }
  
  Future<void> fetchUserData() => refreshUser();
  
  // ============================================
  // UPDATE PROFILE
  // ============================================
  
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (address != null) data['address'] = address;
      
      final response = await _apiService.put(
        ApiConstants.clientProfile,
        data: data,
      );
      
      if (response.data['success'] == true) {
        // Actualizar usuario local
        await refreshUser();
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      throw Exception('Update failed');
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // ============================================
  // UPDATE PROFILE PHOTO
  // ============================================
  
  Future<bool> updateProfilePhoto(String filePath) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.uploadFile(
        ApiConstants.clientProfilePhoto,
        filePath: filePath,
        fieldName: 'photo',
      );

      if (response.data['success'] == true) {
        await refreshUser();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      throw Exception('Upload failed: ${response.data}');
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // ============================================
  // CLEAR ERROR
  // ============================================
  
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── FCM helpers ──────────────────────────────────────────────────────────────

  void _registerFcm() {
    FcmService().initialize().then((_) => FcmService().registerToken());
  }
}
