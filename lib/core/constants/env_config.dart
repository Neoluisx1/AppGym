import 'dart:io';

// 🔧 Environment Configuration
// Configura aquí tu entorno de desarrollo

class EnvConfig {
  // ============================================
  // CONFIGURACIÓN DEL ENTORNO
  // ============================================
  
  // Cambia esto según tu necesidad:
  // - EnvType.emulator: Para emulador Android (10.0.2.2) o iOS (localhost)
  // - EnvType.physicalDevice: Para dispositivo físico (usa tu IP local)
  // - EnvType.production: Para servidor en producción
  static const EnvType environment = EnvType.production;
  
  // ============================================
  // IP PARA DISPOSITIVO FÍSICO
  // ============================================
  
  // Si usas un dispositivo físico, pon aquí la IP de tu computadora
  // Ejemplo: '192.168.1.100'
  // Para obtener tu IP:
  // - Windows: ipconfig (busca IPv4)
  // - Mac/Linux: ifconfig (busca inet)
  static const String localIp = '192.168.0.213';
  
  // ============================================
  // URL DE PRODUCCIÓN
  // ============================================
  
  static const String productionUrl = 'https://megalifegym.com/api/v1';
  
  // ============================================
  // OBTENER BASE URL
  // ============================================
  
  static String get baseUrl {
    switch (environment) {
      case EnvType.emulator:
        // Emulador: detecta automáticamente Android o iOS
        if (Platform.isAndroid) {
          return 'http://10.0.2.2:8000/api/v1';
        } else {
          return 'http://localhost:8000/api/v1';
        }
        
      case EnvType.physicalDevice:
        // Dispositivo físico: usa la IP local configurada
        return 'http://$localIp:8000/api/v1';
        
      case EnvType.production:
        // Producción: usa la URL de producción
        return productionUrl;
    }
  }
  
  // ============================================
  // INFORMACIÓN DE DEBUG
  // ============================================
  
  static String get environmentName {
    switch (environment) {
      case EnvType.emulator:
        return 'Emulador';
      case EnvType.physicalDevice:
        return 'Dispositivo Físico';
      case EnvType.production:
        return 'Producción';
    }
  }
}

// ============================================
// TIPOS DE ENTORNO
// ============================================

enum EnvType {
  emulator,
  physicalDevice,
  production,
}
