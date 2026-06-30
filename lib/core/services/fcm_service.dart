import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';

// Manejador de mensajes en background (debe ser top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('[FCM] Background message: ${message.notification?.title}');
}

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'megalife_gym_channel';
  static const _channelName = 'Megalife Gym';
  static const _channelDesc = 'Notificaciones de Megalife Gym';

  /// Stream que emite el tipo de notificación recibida (foreground o tap desde background).
  /// Suscribirse en el provider/widget que necesite reaccionar.
  static final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  static Stream<Map<String, dynamic>> get onMessage => _messageController.stream;

  /// Inicializa Firebase Messaging. Llamar una sola vez desde main().
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  }

  /// Configura permisos, canal de notificaciones y listeners.
  /// Llamar después del login para registrar el token en el backend.
  Future<void> initialize() async {
    await _requestPermissions();
    await _setupLocalNotifications();
    _setupForegroundListener();
    _setupOpenedAppListener();
  }

  // ── Permisos ────────────────────────────────────────────────────────────────

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[FCM] Permisos: ${settings.authorizationStatus}');
  }

  // ── Canal de notificaciones local (Android) ─────────────────────────────────

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (details) {
        debugPrint('[FCM] Notificación tocada: ${details.payload}');
      },
    );

    // Crear canal en Android
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
        playSound: true,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  // ── Listener foreground ─────────────────────────────────────────────────────

  void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        debugPrint('[FCM] Foreground: ${notification.title}');
        _showLocalNotification(notification, message.data);
      }
      _messageController.add(message.data);
    });
  }

  void _setupOpenedAppListener() {
    // App en background → tocó la notificación → abre app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] App abierta desde notificación: ${message.data}');
      _messageController.add({...message.data, '_opened': true});
    });
  }

  /// Llama desde main() para manejar el tap que abrió la app desde estado terminado.
  static Future<void> handleInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      debugPrint('[FCM] Initial message: ${message.data}');
      _messageController.add({...message.data, '_opened': true});
    }
  }

  Future<void> _showLocalNotification(
      RemoteNotification notification, Map<String, dynamic> data) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFFF6B00),
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: data['type'],
    );
  }

  // ── Registro de token en backend ────────────────────────────────────────────

  Future<void> registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      debugPrint('[FCM] Token: ${token.substring(0, 20)}...');

      await ApiService().post(
        '/device-tokens/register',
        data: {
          'token': token,
          'device_type': Platform.isIOS ? 'ios' : 'android',
          'device_name': 'Mobile App',
        },
      );

      // Escuchar renovación de token
      _messaging.onTokenRefresh.listen((newToken) {
        ApiService().post(
          '/device-tokens/register',
          data: {
            'token': newToken,
            'device_type': Platform.isIOS ? 'ios' : 'android',
            'device_name': 'Mobile App',
          },
        );
      });
    } catch (e) {
      debugPrint('[FCM] Error al registrar token: $e');
    }
  }

  Future<void> unregisterToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      await ApiService().post(
        '/device-tokens/unregister',
        data: {'token': token},
      );

      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('[FCM] Error al desregistrar token: $e');
    }
  }

  // ── Utilidad ────────────────────────────────────────────────────────────────

  Future<String?> getToken() => _messaging.getToken();
}
