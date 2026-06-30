import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/nutrition_model.dart';

class NutritionProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<NutritionPlanModel> _plans = [];
  NutritionPlanModel? _activePlan;
  bool _isLoading = false;
  String? _error;

  List<NutritionPlanModel> get plans => _plans;
  NutritionPlanModel? get activePlan => _activePlan;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPlans() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get(ApiConstants.nutritionPlans);
      if (response.data['success'] == true) {
        _plans = (response.data['data'] as List)
            .map((e) => NutritionPlanModel.fromJson(e))
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

  Future<void> fetchPlanDetail(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.get(ApiConstants.nutritionPlanDetail(id));
      if (response.data['success'] == true) {
        _activePlan = NutritionPlanModel.fromJson(response.data['data']);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => fetchPlans();
}
