// 🔔 Notification Provider
import 'dart:async';
import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/services/fcm_service.dart';
import '../core/constants/api_constants.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  Timer? _pollTimer;
  StreamSubscription<Map<String, dynamic>>? _fcmSubscription;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  // Emite el data de un mensaje FCM con _opened:true para que la UI navegue.
  static final _navigationController = StreamController<Map<String, dynamic>>.broadcast();
  static Stream<Map<String, dynamic>> get onNavigate => _navigationController.stream;

  // Mensaje pendiente de navegación (app estaba cerrada cuando llegó el tap).
  static Map<String, dynamic>? _pendingNavigation;

  /// Retorna y borra el mensaje pendiente. MainScreen lo llama en initState.
  static Map<String, dynamic>? consumePendingNavigation() {
    final data = _pendingNavigation;
    _pendingNavigation = null;
    return data;
  }

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;

  /// Inicia polling (60 s) y escucha el stream de FCM para refrescar al instante.
  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 60), (_) => _silentFetch());

    _fcmSubscription?.cancel();
    _fcmSubscription = FcmService.onMessage.listen((data) {
      _silentFetch();
      if (data['_opened'] == true) {
        _pendingNavigation = data;
        _navigationController.add(data);
      }
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _fcmSubscription?.cancel();
    _fcmSubscription = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }

  /// Recarga sin spinner visible (solo actualiza badge).
  Future<void> _silentFetch() async {
    try {
      final response = await _apiService.get(ApiConstants.notifications);
      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        _notifications = data.map((json) => NotificationModel.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }
  
  // ============================================
  // FETCH NOTIFICATIONS
  // ============================================
  Future<void> fetchNotifications() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.get(ApiConstants.notifications);
      
      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        _notifications = data.map((json) => NotificationModel.fromJson(json)).toList();
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // ============================================
  // MARK AS READ
  // ============================================
  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _apiService.post(
        ApiConstants.markNotificationAsRead(notificationId),
      );
      
      if (response.data['success'] == true) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = NotificationModel.fromJson({
            ..._notifications[index].toJson(),
            'is_read': true,
          });
          notifyListeners();
        }
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // ============================================
  // MARK ALL AS READ
  // ============================================
  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiService.post(
        ApiConstants.markAllNotificationsAsRead,
      );
      
      if (response.data['success'] == true) {
        _notifications = _notifications.map((n) => NotificationModel.fromJson({
          ...n.toJson(),
          'is_read': true,
        })).toList();
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // ============================================
  // DELETE NOTIFICATION
  // ============================================
  Future<bool> deleteNotification(int notificationId) async {
    try {
      final response = await _apiService.delete(
        ApiConstants.deleteNotification(notificationId),
      );
      
      if (response.data['success'] == true) {
        _notifications.removeWhere((n) => n.id == notificationId);
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // ============================================
  // REFRESH
  // ============================================
  Future<void> refresh() async {
    await fetchNotifications();
  }
}
