// 📈 Progress Provider
import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/progress_model.dart';

class ProgressProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<ProgressModel> _progressList = [];
  List<GoalModel> _goals = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<ProgressModel> get progressList => _progressList;
  List<GoalModel> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Fetch Progress List
  Future<void> fetchProgress() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.get(ApiConstants.clientProgress);
      
      if (response.data['success'] == true) {
        _progressList = (response.data['data'] as List)
            .map((e) => ProgressModel.fromJson(e))
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
  
  // Add Progress
  Future<bool> addProgress(ProgressModel progress) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final response = await _apiService.post(
        ApiConstants.clientProgress,
        data: progress.toJson(),
      );
      
      if (response.data['success'] == true) {
        await fetchProgress(); // Refresh list
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      throw Exception('Failed to add progress');
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Fetch Goals
  Future<void> fetchGoals() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.get(ApiConstants.clientGoals);
      
      if (response.data['success'] == true) {
        _goals = (response.data['data'] as List)
            .map((e) => GoalModel.fromJson(e))
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
  
  // Add Goal
  Future<bool> addGoal(GoalModel goal) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final response = await _apiService.post(
        ApiConstants.clientGoals,
        data: goal.toJson(),
      );
      
      if (response.data['success'] == true) {
        await fetchGoals(); // Refresh list
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      throw Exception('Failed to add goal');
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Update Goal Progress
  Future<bool> updateGoalProgress(int goalId, double currentValue) async {
    try {
      final response = await _apiService.post(
        ApiConstants.clientGoalUpdateProgress(goalId),
        data: {'current_value': currentValue},
      );
      
      if (response.data['success'] == true) {
        await fetchGoals(); // Refresh list
        return true;
      }
      
      throw Exception('Failed to update goal');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Delete Goal
  Future<bool> deleteGoal(int goalId) async {
    try {
      final response = await _apiService.delete(
        ApiConstants.clientGoalDetail(goalId),
      );
      
      if (response.data['success'] == true) {
        await fetchGoals(); // Refresh list
        return true;
      }
      
      throw Exception('Failed to delete goal');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Accept Goal
  Future<bool> acceptGoal(int goalId) async {
    try {
      final response = await _apiService.post(
        ApiConstants.acceptGoal(goalId),
      );
      
      if (response.data['success'] == true) {
        await fetchGoals(); // Refresh list
        return true;
      }
      
      throw Exception('Failed to accept goal');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Reject Goal
  Future<bool> rejectGoal(int goalId) async {
    try {
      final response = await _apiService.post(
        ApiConstants.rejectGoal(goalId),
      );
      
      if (response.data['success'] == true) {
        await fetchGoals(); // Refresh list
        return true;
      }
      
      throw Exception('Failed to reject goal');
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
