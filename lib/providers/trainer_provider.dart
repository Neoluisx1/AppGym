import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/trainer_model.dart';

class TrainerProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  TrainerDashboardModel? _dashboard;
  List<TrainerClientModel> _clients = [];
  TrainerClientDetailModel? _selectedClient;

  List<PhysicalEvaluationModel> _evaluations = [];
  List<GoalModel> _goals = [];
  List<ProgressModel> _progressRecords = [];
  List<RoutineModel> _routines = [];

  bool _loadingDashboard = false;
  bool _loadingClients = false;
  bool _loadingDetail = false;
  bool _loadingEvaluations = false;
  bool _loadingGoals = false;
  bool _loadingProgress = false;
  bool _loadingRoutines = false;
  bool _submitting = false;
  String? _error;

  TrainerDashboardModel? get dashboard => _dashboard;
  List<TrainerClientModel> get clients => _clients;
  TrainerClientDetailModel? get selectedClient => _selectedClient;
  List<PhysicalEvaluationModel> get evaluations => _evaluations;
  List<GoalModel> get goals => _goals;
  List<ProgressModel> get progressRecords => _progressRecords;
  List<RoutineModel> get routines => _routines;
  bool get loadingDashboard => _loadingDashboard;
  bool get loadingClients => _loadingClients;
  bool get loadingDetail => _loadingDetail;
  bool get loadingEvaluations => _loadingEvaluations;
  bool get loadingGoals => _loadingGoals;
  bool get loadingProgress => _loadingProgress;
  bool get loadingRoutines => _loadingRoutines;
  bool get submitting => _submitting;
  String? get error => _error;

  Future<void> fetchDashboard() async {
    _loadingDashboard = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get(ApiConstants.trainerDashboard);
      if (response.data['success'] == true) {
        _dashboard = TrainerDashboardModel.fromJson(response.data['data']);
      }
    } catch (e) {
      _error = 'Error al cargar el dashboard.';
    }
    _loadingDashboard = false;
    notifyListeners();
  }

  Future<void> fetchClients({String? search}) async {
    _loadingClients = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get(
        ApiConstants.trainerClients,
        queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
      );
      if (response.data['success'] == true) {
        _clients = (response.data['data'] as List)
            .map((e) => TrainerClientModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      _error = 'Error al cargar los clientes.';
    }
    _loadingClients = false;
    notifyListeners();
  }

  Future<void> fetchClientDetail(int clientId) async {
    _loadingDetail = true;
    _selectedClient = null;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get(ApiConstants.trainerClientDetail(clientId));
      if (response.data['success'] == true) {
        _selectedClient = TrainerClientDetailModel.fromJson(response.data['data']);
      }
    } catch (e) {
      _error = 'Error al cargar el cliente.';
    }
    _loadingDetail = false;
    notifyListeners();
  }

  // ── Evaluaciones ─────────────────────────────────────────────────────────────

  Future<void> fetchEvaluations(int clientId) async {
    _loadingEvaluations = true;
    notifyListeners();
    try {
      final response = await _api.get(ApiConstants.trainerClientEvaluations(clientId));
      if (response.data['success'] == true) {
        _evaluations = (response.data['data'] as List)
            .map((e) => PhysicalEvaluationModel.fromJson(e))
            .toList();
      }
    } catch (_) {
      _evaluations = [];
    }
    _loadingEvaluations = false;
    notifyListeners();
  }

  Future<bool> createEvaluation(int clientId, Map<String, dynamic> data) async {
    _submitting = true;
    notifyListeners();
    try {
      final response = await _api.post(ApiConstants.trainerClientEvaluations(clientId), data: data);
      if (response.data['success'] == true) {
        await fetchEvaluations(clientId);
        _submitting = false;
        notifyListeners();
        return true;
      }
    } catch (_) {}
    _submitting = false;
    notifyListeners();
    return false;
  }

  // ── Metas ─────────────────────────────────────────────────────────────────────

  Future<void> fetchGoals(int clientId) async {
    _loadingGoals = true;
    notifyListeners();
    try {
      final response = await _api.get(ApiConstants.trainerClientGoals(clientId));
      if (response.data['success'] == true) {
        _goals = (response.data['data'] as List)
            .map((e) => GoalModel.fromJson(e))
            .toList();
      }
    } catch (_) {
      _goals = [];
    }
    _loadingGoals = false;
    notifyListeners();
  }

  Future<bool> createGoal(int clientId, Map<String, dynamic> data) async {
    _submitting = true;
    notifyListeners();
    try {
      final response = await _api.post(ApiConstants.trainerClientGoals(clientId), data: data);
      if (response.data['success'] == true) {
        await fetchGoals(clientId);
        _submitting = false;
        notifyListeners();
        return true;
      }
    } catch (_) {}
    _submitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateGoalProgress(int clientId, int goalId, double value) async {
    _submitting = true;
    notifyListeners();
    try {
      final response = await _api.put(
        ApiConstants.trainerUpdateGoalProgress(clientId, goalId),
        data: {'current_value': value},
      );
      if (response.data['success'] == true) {
        await fetchGoals(clientId);
        _submitting = false;
        notifyListeners();
        return true;
      }
    } catch (_) {}
    _submitting = false;
    notifyListeners();
    return false;
  }

  // ── Progreso / Medidas ────────────────────────────────────────────────────────

  Future<void> fetchClientProgress(int clientId) async {
    _loadingProgress = true;
    notifyListeners();
    try {
      final response = await _api.get(ApiConstants.trainerClientProgress(clientId));
      if (response.data['success'] == true) {
        _progressRecords = (response.data['data'] as List)
            .map((e) => ProgressModel.fromJson(e))
            .toList();
      }
    } catch (_) {
      _progressRecords = [];
    }
    _loadingProgress = false;
    notifyListeners();
  }

  Future<bool> createProgress(
    int clientId,
    Map<String, dynamic> data, {
    String? photoFrontPath,
    String? photoSidePath,
    String? photoBackPath,
  }) async {
    _submitting = true;
    notifyListeners();
    try {
      final hasPhotos = photoFrontPath != null || photoSidePath != null || photoBackPath != null;

      dynamic body;
      if (hasPhotos) {
        final map = <String, dynamic>{...data};
        if (photoFrontPath != null) {
          map['photo_front'] = await MultipartFile.fromFile(photoFrontPath, filename: 'front.jpg');
        }
        if (photoSidePath != null) {
          map['photo_side'] = await MultipartFile.fromFile(photoSidePath, filename: 'side.jpg');
        }
        if (photoBackPath != null) {
          map['photo_back'] = await MultipartFile.fromFile(photoBackPath, filename: 'back.jpg');
        }
        body = FormData.fromMap(map);
      } else {
        body = data;
      }

      final response = await _api.post(ApiConstants.trainerClientProgress(clientId), data: body);
      if (response.data['success'] == true) {
        await fetchClientProgress(clientId);
        _submitting = false;
        notifyListeners();
        return true;
      }
    } catch (_) {}
    _submitting = false;
    notifyListeners();
    return false;
  }

  // ── Rutinas ───────────────────────────────────────────────────────────────────

  Future<void> fetchRoutines(int clientId) async {
    _loadingRoutines = true;
    notifyListeners();
    try {
      final response = await _api.get(ApiConstants.trainerClientRoutines(clientId));
      if (response.data['success'] == true) {
        _routines = (response.data['data'] as List)
            .map((e) => RoutineModel.fromJson(e))
            .toList();
      }
    } catch (_) {
      _routines = [];
    }
    _loadingRoutines = false;
    notifyListeners();
  }

  Future<bool> createRoutine(int clientId, Map<String, dynamic> data) async {
    _submitting = true;
    notifyListeners();
    try {
      final response = await _api.post(ApiConstants.trainerClientRoutines(clientId), data: data);
      if (response.data['success'] == true) {
        await fetchRoutines(clientId);
        _submitting = false;
        notifyListeners();
        return true;
      }
    } catch (_) {}
    _submitting = false;
    notifyListeners();
    return false;
  }

  Future<bool> toggleRoutine(int clientId, int routineId) async {
    try {
      final response = await _api.patch(
        ApiConstants.trainerToggleRoutine(clientId, routineId),
        data: {},
      );
      if (response.data['success'] == true) {
        final idx = _routines.indexWhere((r) => r.id == routineId);
        if (idx >= 0) {
          final old = _routines[idx];
          _routines[idx] = RoutineModel(
            id: old.id,
            name: old.name,
            description: old.description,
            startDate: old.startDate,
            endDate: old.endDate,
            isActive: !old.isActive,
            days: old.days,
          );
          notifyListeners();
        }
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> addRoutineDay(int clientId, int routineId, Map<String, dynamic> data) async {
    try {
      final response = await _api.post(
        ApiConstants.trainerAddRoutineDay(clientId, routineId),
        data: data,
      );
      if (response.data['success'] == true) {
        final updated = RoutineModel.fromJson(response.data['data']);
        final idx = _routines.indexWhere((r) => r.id == routineId);
        if (idx >= 0) _routines[idx] = updated;
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> removeRoutineDay(int clientId, int routineId, int dayId) async {
    try {
      final response = await _api.delete(
        ApiConstants.trainerRemoveRoutineDay(clientId, routineId, dayId),
      );
      if (response.data['success'] == true) {
        final updated = RoutineModel.fromJson(response.data['data']);
        final idx = _routines.indexWhere((r) => r.id == routineId);
        if (idx >= 0) _routines[idx] = updated;
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> refreshDashboard() => fetchDashboard();
  Future<void> refreshClients() => fetchClients();

  void clearSelectedClient() {
    _selectedClient = null;
    _evaluations = [];
    _goals = [];
    _progressRecords = [];
    _routines = [];
    notifyListeners();
  }
}
