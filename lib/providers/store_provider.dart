// 🛍️ Store Provider
import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../core/constants/api_constants.dart';
import '../models/product_model.dart';

class StoreProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<ProductModel> _products = [];
  List<RedemptionModel> _redemptions = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'all';
  
  List<ProductModel> get products => _products;
  List<RedemptionModel> get redemptions => _redemptions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  
  List<ProductModel> get filteredProducts {
    if (_selectedCategory == 'all') {
      return _products;
    }
    return _products.where((p) => p.category == _selectedCategory).toList();
  }
  
  List<ProductModel> get featuredProducts {
    return _products.where((p) => p.isFeatured).toList();
  }
  
  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList();
    cats.insert(0, 'all');
    return cats;
  }
  
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }
  
  // ============================================
  // FETCH PRODUCTS
  // ============================================
  Future<void> fetchProducts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.get(ApiConstants.storeProducts);
      
      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        _products = data.map((json) => ProductModel.fromJson(json)).toList();
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
  // FETCH REDEMPTIONS
  // ============================================
  Future<void> fetchRedemptions() async {
    try {
      final response = await _apiService.get(ApiConstants.myRedemptions);
      
      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        _redemptions = data.map((json) => RedemptionModel.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // ============================================
  // REDEEM PRODUCT WITH POINTS
  // ============================================
  Future<bool> redeemProduct(int productId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.post(
        ApiConstants.redeemProduct(productId),
      );
      
      _isLoading = false;
      
      if (response.data['success'] == true) {
        await fetchRedemptions();
        notifyListeners();
        return true;
      }
      
      _error = response.data['message'];
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // ============================================
  // BUY PRODUCT WITH MONEY
  // ============================================
  Future<bool> buyProduct(int productId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _apiService.post(
        ApiConstants.buyProduct(productId),
      );
      
      _isLoading = false;
      
      if (response.data['success'] == true) {
        notifyListeners();
        return true;
      }
      
      _error = response.data['message'];
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // ============================================
  // REFRESH
  // ============================================
  Future<void> refresh() async {
    await fetchProducts();
    await fetchRedemptions();
  }
}
