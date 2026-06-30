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

  bool _loadingStats = false;
  bool _loadingAttendance = false;
  bool _loadingExpiring = false;
  bool _loadingSearch = false;
  bool _sendingPush = false;

  String? _statsError;
  String? _attendanceError;

  AdminStats? get stats => _stats;
  List<AdminAttendanceRecord> get todayAttendance => _todayAttendance;
  List<AdminExpiringClient> get expiringClients => _expiringClients;
  List<AdminSearchClient> get searchResults => _searchResults;

  bool get loadingStats => _loadingStats;
  bool get loadingAttendance => _loadingAttendance;
  bool get loadingExpiring => _loadingExpiring;
  bool get loadingSearch => _loadingSearch;
  bool get sendingPush => _sendingPush;

  String? get statsError => _statsError;
  String? get attendanceError => _attendanceError;

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

  Future<bool> sendPushNotification({
    required String title,
    required String message,
  }) async {
    _sendingPush = true;
    notifyListeners();
    try {
      final res = await _api.post(
        ApiConstants.adminPushNotification,
        data: {'title': title, 'message': message},
      );
      return res.data['success'] == true;
    } catch (_) {
      return false;
    } finally {
      _sendingPush = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}
