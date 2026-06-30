import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/referral_model.dart';

class ReferralProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  ReferralModel? _data;
  bool _isLoading = false;
  String? _error;

  ReferralModel? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchReferrals() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get(ApiConstants.clientReferrals);

      if (response.data['success'] == true) {
        _data = ReferralModel.fromJson(response.data['data']);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => fetchReferrals();
}
