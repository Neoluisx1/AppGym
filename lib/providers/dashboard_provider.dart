// 📊 Dashboard Provider
import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/dashboard_model.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  DashboardModel? _dashboard;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  DashboardModel? get dashboard => _dashboard;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Fetch Dashboard
  Future<void> fetchDashboard() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.get(ApiConstants.clientDashboard);
      
      if (response.data['success'] == true) {
        _dashboard = DashboardModel.fromJson(response.data['data']);
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Refresh
  Future<void> refresh() async {
    await fetchDashboard();
  }
}
