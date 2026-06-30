import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/routine_model.dart';

class RoutineProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<RoutineModel> _routines = [];
  RoutineModel? _selectedRoutine;
  bool _isLoading = false;
  String? _error;

  // IDs of workout_exercises logged today
  final Set<int> _todayLoggedIds = {};

  List<RoutineModel> get routines => _routines;
  RoutineModel? get selectedRoutine => _selectedRoutine;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Set<int> get todayLoggedIds => _todayLoggedIds;
  bool isLogged(int workoutExerciseId) => _todayLoggedIds.contains(workoutExerciseId);

  // ── Routines ─────────────────────────────────────────────────────────────────

  Future<void> fetchRoutines() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get(ApiConstants.clientRoutines);

      if (response.data['success'] == true) {
        _routines = (response.data['data'] as List)
            .map((e) => RoutineModel.fromJson(e))
            .toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRoutineDetail(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get(ApiConstants.clientRoutineDetail(id));

      if (response.data['success'] == true) {
        _selectedRoutine = RoutineModel.fromJson(response.data['data']);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedRoutine() {
    _selectedRoutine = null;
    notifyListeners();
  }

  // ── Workout Logs ──────────────────────────────────────────────────────────────

  Future<void> fetchTodayLogs() async {
    try {
      final response = await _apiService.get(ApiConstants.workoutLogsToday);
      if (response.data['success'] == true) {
        _todayLoggedIds.clear();
        for (final item in response.data['data'] as List) {
          _todayLoggedIds.add(item['workout_exercise_id'] as int);
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> logExercise(
    int workoutExerciseId, {
    int? setsCompleted,
    int? repsCompleted,
    double? weightUsed,
  }) async {
    try {
      final response = await _apiService.post(ApiConstants.workoutLogs, data: {
        'workout_exercise_id': workoutExerciseId,
        if (setsCompleted != null) 'sets_completed': setsCompleted,
        if (repsCompleted != null) 'reps_completed': repsCompleted,
        if (weightUsed != null) 'weight_used': weightUsed,
      });
      if (response.data['success'] == true) {
        _todayLoggedIds.add(workoutExerciseId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unlogExercise(int workoutExerciseId) async {
    try {
      await _apiService.delete(ApiConstants.deleteWorkoutLog(workoutExerciseId));
      _todayLoggedIds.remove(workoutExerciseId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
