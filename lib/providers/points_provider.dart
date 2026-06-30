import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/point_transaction_model.dart';

class PointsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<PointTransactionModel> _transactions = [];
  int _totalPoints = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  List<PointTransactionModel> get transactions => _transactions;
  int get totalPoints => _totalPoints;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Future<void> fetchTransactions({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _transactions = [];
      _currentPage = 1;
      _hasMore = true;
    }
    if (!_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get(
        '${ApiConstants.clientPointTransactions}?page=$_currentPage',
      );
      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        _totalPoints = data['total_points'] ?? 0;
        final newItems = (data['transactions'] as List)
            .map((e) => PointTransactionModel.fromJson(e))
            .toList();
        _transactions.addAll(newItems);
        final meta = data['meta'] as Map<String, dynamic>;
        _hasMore = (meta['current_page'] ?? 1) < (meta['last_page'] ?? 1);
        _currentPage++;
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => fetchTransactions(refresh: true);
}
