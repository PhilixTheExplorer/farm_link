import 'package:flutter/foundation.dart';
import '../models/buyer.dart';
import '../repositories/buyer_repository.dart';
import '../core/di/service_locator.dart';

class BuyerService extends ChangeNotifier {
  final BuyerRepository _buyerRepository = serviceLocator<BuyerRepository>();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Get all buyers with filters
  Future<List<Buyer>> getBuyers({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    _setLoading(true);

    try {
      final buyers = await _buyerRepository.getBuyers(
        page: page,
        limit: limit,
        search: search,
      );

      _setLoading(false);
      return buyers;
    } catch (e) {
      debugPrint('Get buyers error: $e');
      _setLoading(false);
      return [];
    }
  }

  // Get buyer by ID
  Future<Buyer?> getBuyerById(String buyerId) async {
    try {
      return await _buyerRepository.getBuyerById(buyerId);
    } catch (e) {
      debugPrint('Get buyer by ID error: $e');
      return null;
    }
  }

  // Update buyer profile
  Future<bool> updateBuyerProfile(
    String buyerId,
    Map<String, dynamic> buyerData,
  ) async {
    _setLoading(true);

    try {
      await _buyerRepository.updateBuyerProfile(buyerId, buyerData);
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Update buyer profile error: $e');
      _setLoading(false);
      return false;
    }
  }

  // Get top buyers
  Future<List<Buyer>> getTopBuyers({int limit = 10}) async {
    try {
      return await _buyerRepository.getTopBuyers(limit: limit);
    } catch (e) {
      debugPrint('Get top buyers error: $e');
      return [];
    }
  }

  // Get buyer statistics
  Future<Map<String, dynamic>?> getBuyerStats(String buyerId) async {
    try {
      return await _buyerRepository.getBuyerStats(buyerId);
    } catch (e) {
      debugPrint('Get buyer stats error: $e');
      return null;
    }
  }

  // Delete buyer (Admin only)
  Future<bool> deleteBuyer(String buyerId) async {
    try {
      await _buyerRepository.deleteBuyer(buyerId);
      return true;
    } catch (e) {
      debugPrint('Delete buyer error: $e');
      return false;
    }
  }

  // Search buyers
  Future<List<Buyer>> searchBuyers(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    return await getBuyers(search: query, page: page, limit: limit);
  }

  // Business logic helper methods
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

  String getBuyerTier(double totalSpent) {
    if (totalSpent >= 10000) {
      return 'Gold';
    } else if (totalSpent >= 5000) {
      return 'Silver';
    } else if (totalSpent >= 1000) {
      return 'Bronze';
    } else {
      return 'Basic';
    }
  }

  bool isActiveCustomer(Buyer buyer) {
    return buyer.totalOrders > 0 && buyer.totalSpent > 0;
  }

  double getAverageOrderValue(Buyer buyer) {
    if (buyer.totalOrders == 0) return 0.0;
    return buyer.totalSpent / buyer.totalOrders;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
