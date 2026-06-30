// 🏋️ Group Class Provider
import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/group_class_model.dart';

class GroupClassProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<GroupClassModel> _classes = [];
  bool _isLoading = false;
  String? _error;
  
  List<GroupClassModel> get classes => _classes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // ============================================
  // FETCH GROUP CLASSES
  // ============================================
  Future<void> fetchClasses() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.get(ApiConstants.groupClasses);
      
      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        _classes = data.map((json) => GroupClassModel.fromJson(json)).toList();
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
  // ENROLL IN CLASS
  // ============================================
  Future<bool> enrollInClass(int classId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.post(
        ApiConstants.enrollGroupClass(classId),
      );
      
      _isLoading = false;
      notifyListeners();
      
      if (response.data['success'] == true) {
        await fetchClasses();
        return true;
      }
      
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
