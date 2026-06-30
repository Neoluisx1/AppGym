// ⚙️ Settings Provider - Configuración Dinámica del Servidor
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _keyServerUrl = 'server_url';
  static const String _keyConfigPassword = 'config_password';
  static const String _defaultUrl = 'http://10.0.2.2:8000/api/v1'; // Emulador por defecto
  static const String _defaultPassword = 'admin123'; // Contraseña por defecto
  
  String _serverUrl = _defaultUrl;
  String _configPassword = _defaultPassword;
  bool _isLoading = false;
  
  // Getters
  String get serverUrl => _serverUrl;
  String get configPassword => _configPassword;
  bool get isLoading => _isLoading;
  bool get isConfigured => _serverUrl != _defaultUrl;
  
  // ============================================
  // INICIALIZAR - Cargar configuración guardada
  // ============================================
  
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final prefs = await SharedPreferences.getInstance();
      
      // Cargar URL del servidor
      _serverUrl = prefs.getString(_keyServerUrl) ?? _defaultUrl;
      
      // Cargar contraseña de configuración
      _configPassword = prefs.getString(_keyConfigPassword) ?? _defaultPassword;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // ============================================
  // GUARDAR URL DEL SERVIDOR
  // ============================================
  
  Future<bool> saveServerUrl(String url) async {
    try {
      // Validar URL
      if (url.isEmpty) {
        return false;
      }
      
      // Asegurar que termine con /api/v1
      String cleanUrl = url.trim();
      if (!cleanUrl.endsWith('/api/v1')) {
        if (cleanUrl.endsWith('/')) {
          cleanUrl = '${cleanUrl}api/v1';
        } else {
          cleanUrl = '$cleanUrl/api/v1';
        }
      }
      
      // Guardar
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyServerUrl, cleanUrl);
      
      _serverUrl = cleanUrl;
      notifyListeners();
      
      return true;
    } catch (e) {
      debugPrint('Error saving server URL: $e');
      return false;
    }
  }
  
  // ============================================
  // CAMBIAR CONTRASEÑA DE CONFIGURACIÓN
  // ============================================
  
  Future<bool> changeConfigPassword(String currentPassword, String newPassword) async {
    try {
      // Verificar contraseña actual
      if (currentPassword != _configPassword) {
        return false;
      }
      
      // Validar nueva contraseña
      if (newPassword.isEmpty || newPassword.length < 6) {
        return false;
      }
      
      // Guardar
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyConfigPassword, newPassword);
      
      _configPassword = newPassword;
      notifyListeners();
      
      return true;
    } catch (e) {
      debugPrint('Error changing password: $e');
      return false;
    }
  }
  
  // ============================================
  // VERIFICAR CONTRASEÑA
  // ============================================
  
  bool verifyPassword(String password) {
    return password == _configPassword;
  }
  
  // ============================================
  // RESETEAR A VALORES POR DEFECTO
  // ============================================
  
  Future<void> resetToDefaults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyServerUrl);
      await prefs.remove(_keyConfigPassword);
      
      _serverUrl = _defaultUrl;
      _configPassword = _defaultPassword;
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting settings: $e');
    }
  }
  
  // ============================================
  // OBTENER CONFIGURACIÓN SUGERIDA
  // ============================================
  
  Map<String, String> getSuggestedConfigs() {
    return {
      'Emulador Android': 'http://10.0.2.2:8000',
      'Localhost (iOS/Web)': 'http://localhost:8000',
      'Producción': 'https://tu-servidor.com',
      'Red Local': 'http://192.168.0.213:8000',
    };
  }
}
