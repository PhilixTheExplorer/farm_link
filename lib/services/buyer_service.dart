import 'package:flutter/foundation.dart';
import '../models/buyer.dart';
import 'api_service.dart';

class BuyerService extends ChangeNotifier {
  static final BuyerService _instance = BuyerService._internal();
  factory BuyerService() => _instance;
  BuyerService._internal();

  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Get all buyers with filters
  Future<List<Buyer>> getBuyers({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getBuyers(
        page: page,
        limit: limit,
        search: search,
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> buyersData = response['data']['buyers'];
        final buyers =
            buyersData.map((json) => _createBuyerFromJson(json)).toList();
        _isLoading = false;
        notifyListeners();
        return buyers;
      }
    } catch (e) {
      debugPrint('Get buyers error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return [];
  }

  // Get buyer by ID
  Future<Buyer?> getBuyerById(String buyerId) async {
    try {
      final response = await _apiService.getBuyerByUserId(buyerId);

      if (response != null && response['success'] == true) {
        return _createBuyerFromJson(response['data']);
      }
    } catch (e) {
      debugPrint('Get buyer by ID error: $e');
    }
    return null;
  }

  // Update buyer profile
  Future<bool> updateBuyerProfile(
    String buyerId,
    Map<String, dynamic> buyerData,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _apiService.updateBuyerProfile(buyerId, buyerData);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Update buyer profile error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get top buyers
  Future<List<Buyer>> getTopBuyers({int limit = 10}) async {
    try {
      final response = await _apiService.getTopBuyers(limit: limit);

      if (response != null && response['success'] == true) {
        final List<dynamic> buyersData = response['data'];
        return buyersData.map((json) => _createBuyerFromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Get top buyers error: $e');
    }
    return [];
  }

  // Get buyer statistics
  Future<Map<String, dynamic>?> getBuyerStats(String buyerId) async {
    try {
      final response = await _apiService.getBuyerStats(buyerId);

      if (response != null && response['success'] == true) {
        return response['data'];
      }
    } catch (e) {
      debugPrint('Get buyer stats error: $e');
    }
    return null;
  }

  // Delete buyer (Admin only)
  Future<bool> deleteBuyer(String buyerId) async {
    try {
      // Use the deleteUser method since buyers are users with buyer role
      return await _apiService.deleteUser(buyerId);
    } catch (e) {
      debugPrint('Delete buyer error: $e');
      return false;
    }
  }

  // Helper method to create Buyer object from JSON
  Buyer _createBuyerFromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? json;
    final profileData = json['profile'] ?? json;

    return Buyer(
      id: userData['id'],
      email: userData['email'],
      name: userData['name'],
      phone: userData['phone'] ?? '',
      location: userData['location'] ?? '',
      profileImageUrl: userData['profile_image_url'],
      totalSpent: (profileData['total_spent'] ?? 0).toDouble(),
      totalOrders: profileData['total_orders'] ?? 0,
      deliveryAddress: profileData['delivery_address'] ?? '',
    );
  }

  // Search buyers
  Future<List<Buyer>> searchBuyers(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    return await getBuyers(search: query, page: page, limit: limit);
  }

  // Format spending amount
  String formatSpending(double amount) {
    return '฿${amount.toStringAsFixed(0)}';
  }

  // Get buyer ranking based on spending
  Future<int?> getBuyerRanking(String buyerId) async {
    try {
      final topBuyers = await getTopBuyers(limit: 100);
      final index = topBuyers.indexWhere((buyer) => buyer.id == buyerId);
      return index != -1 ? index + 1 : null;
    } catch (e) {
      debugPrint('Get buyer ranking error: $e');
      return null;
    }
  }
}
