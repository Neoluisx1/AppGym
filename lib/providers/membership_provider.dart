// 💳 Membership Provider
import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/membership_plan_model.dart';

class MembershipProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<MembershipPlanModel> _plans = [];
  bool _isLoading = false;
  String? _error;
  
  List<MembershipPlanModel> get plans => _plans;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // ============================================
  // FETCH MEMBERSHIP PLANS
  // ============================================
  Future<void> fetchPlans() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.get(ApiConstants.membershipPlans);
      
      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        _plans = data.map((json) => MembershipPlanModel.fromJson(json)).toList();
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
  // RENEW MEMBERSHIP
  // ============================================
  Future<bool> renewMembership(int planId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.post(
        ApiConstants.clientRenewMembership,
        data: {'membership_plan_id': planId},
      );
      
      _isLoading = false;
      notifyListeners();
      
      return response.data['success'] == true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
