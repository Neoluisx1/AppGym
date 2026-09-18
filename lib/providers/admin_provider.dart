import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/admin_model.dart';

class AdminProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  AdminStats? _stats;
  List<AdminAttendanceRecord> _todayAttendance = [];
  List<AdminExpiringClient> _expiringClients = [];
  List<AdminSearchClient> _searchResults = [];
  AdminClientDetail? _clientDetail;
  List<AdminTrainerOption> _trainers = [];

  bool _loadingStats = false;
  bool _loadingAttendance = false;
  bool _loadingExpiring = false;
  bool _loadingSearch = false;
  bool _sendingPush = false;
  bool _loadingClientDetail = false;
  bool _loadingTrainers = false;
  bool _assigningTrainer = false;

  String? _statsError;
  String? _attendanceError;
  String? _clientDetailError;

  AdminStats? get stats => _stats;
  List<AdminAttendanceRecord> get todayAttendance => _todayAttendance;
  List<AdminExpiringClient> get expiringClients => _expiringClients;
  List<AdminSearchClient> get searchResults => _searchResults;
  AdminClientDetail? get clientDetail => _clientDetail;
  List<AdminTrainerOption> get trainers => _trainers;

  bool get loadingStats => _loadingStats;
  bool get loadingAttendance => _loadingAttendance;
  bool get loadingExpiring => _loadingExpiring;
  bool get loadingSearch => _loadingSearch;
  bool get sendingPush => _sendingPush;
  bool get loadingClientDetail => _loadingClientDetail;
  bool get loadingTrainers => _loadingTrainers;
  bool get assigningTrainer => _assigningTrainer;

  String? get statsError => _statsError;
  String? get attendanceError => _attendanceError;
  String? get clientDetailError => _clientDetailError;

  Future<void> fetchStats() async {
    _loadingStats = true;
    _statsError = null;
    notifyListeners();
    try {
      final res = await _api.get(ApiConstants.adminStats);
      if (res.data['success'] == true) {
        _stats = AdminStats.fromJson(res.data['data']);
      }
    } catch (e) {
      _statsError = 'Error al cargar estadísticas';
    } finally {
      _loadingStats = false;
      notifyListeners();
    }
  }

  Future<void> fetchTodayAttendance() async {
    _loadingAttendance = true;
    _attendanceError = null;
    notifyListeners();
    try {
      final res = await _api.get(ApiConstants.adminTodayAttendance);
      if (res.data['success'] == true) {
        _todayAttendance = (res.data['data'] as List)
            .map((e) => AdminAttendanceRecord.fromJson(e))
            .toList();
      }
    } catch (e) {
      _attendanceError = 'Error al cargar asistencias';
    } finally {
      _loadingAttendance = false;
      notifyListeners();
    }
  }

  Future<void> fetchExpiringMemberships({int days = 7}) async {
    _loadingExpiring = true;
    notifyListeners();
    try {
      final res = await _api.get(
        ApiConstants.adminExpiringMemberships,
        queryParameters: {'days': days},
      );
      if (res.data['success'] == true) {
        _expiringClients = (res.data['data'] as List)
            .map((e) => AdminExpiringClient.fromJson(e))
            .toList();
      }
    } catch (_) {
    } finally {
      _loadingExpiring = false;
      notifyListeners();
    }
  }

  Future<void> searchClients(String query) async {
    if (query.length < 2) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _loadingSearch = true;
    notifyListeners();
    try {
      final res = await _api.get(
        ApiConstants.adminClientsSearch,
        queryParameters: {'q': query},
      );
      if (res.data['success'] == true) {
        _searchResults = (res.data['data'] as List)
            .map((e) => AdminSearchClient.fromJson(e))
            .toList();
      }
    } catch (_) {
    } finally {
      _loadingSearch = false;
      notifyListeners();
    }
  }

  /// [target]: 'all' | 'expiring' | 'expired' | 'instructors'.
  /// [days] solo se usa cuando target == 'expiring'.
  Future<PushNotificationResult> sendPushNotification({
    required String title,
    required String message,
    String target = 'all',
    int? days,
  }) async {
    _sendingPush = true;
    notifyListeners();
    try {
      final res = await _api.post(
        ApiConstants.adminPushNotification,
        data: {
          'title': title,
          'message': message,
          'target': target,
          if (days != null) 'days': days,
        },
      );
      return PushNotificationResult(
        success: res.data['success'] == true,
        message: res.data['message'] as String?,
      );
    } catch (e) {
      return PushNotificationResult(success: false, message: e.toString());
    } finally {
      _sendingPush = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  // ============================================
  // DETALLE DE CLIENTE / ASIGNAR ENTRENADOR
  // ============================================

  Future<void> fetchClientDetail(int clientId) async {
    _loadingClientDetail = true;
    _clientDetailError = null;
    notifyListeners();
    try {
      final res = await _api.get(ApiConstants.adminClientDetail(clientId));
      if (res.data['success'] == true) {
        _clientDetail = AdminClientDetail.fromJson(res.data['data']);
      }
    } catch (e) {
      _clientDetailError = 'Error al cargar el cliente';
    } finally {
      _loadingClientDetail = false;
      notifyListeners();
    }
  }

  void clearClientDetail() {
    _clientDetail = null;
    _clientDetailError = null;
  }

  Future<void> fetchTrainers() async {
    _loadingTrainers = true;
    notifyListeners();
    try {
      final res = await _api.get(ApiConstants.adminTrainers);
      if (res.data['success'] == true) {
        _trainers = (res.data['data'] as List)
            .map((e) => AdminTrainerOption.fromJson(e))
            .toList();
      }
    } catch (_) {
    } finally {
      _loadingTrainers = false;
      notifyListeners();
    }
  }

  /// [trainerId] null para quitar el entrenador asignado.
  Future<bool> assignTrainer(int clientId, int? trainerId) async {
    _assigningTrainer = true;
    notifyListeners();
    try {
      final res = await _api.post(
        ApiConstants.adminAssignTrainer(clientId),
        data: {'trainer_id': trainerId},
      );
      final ok = res.data['success'] == true;
      if (ok) {
        await fetchClientDetail(clientId);
      }
      return ok;
    } catch (_) {
      return false;
    } finally {
      _assigningTrainer = false;
      notifyListeners();
    }
  }
}

class PushNotificationResult {
  final bool success;
  final String? message;

  PushNotificationResult({required this.success, this.message});
}
