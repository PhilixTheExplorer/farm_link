// filepath: c:\Users\kshin\Desktop\CAMPUS\farm_link\lib\repositories\buyer_repository.dart
import '../models/buyer.dart';
import '../services/api_service.dart';
import '../core/di/service_locator.dart';

class BuyerRepository {
  final ApiService _apiService = serviceLocator<ApiService>();

  // Get all buyers with filters
  Future<List<Buyer>> getBuyers({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    final response = await _apiService.getBuyers(
      page: page,
      limit: limit,
      search: search,
    );

    if (response != null && response['success'] == true) {
      final List<dynamic> buyersData = response['data']['buyers'];
      return buyersData.map((json) => _createBuyerFromJson(json)).toList();
    }

    throw Exception('Failed to get buyers');
  }

  // Get buyer by ID
  Future<Buyer?> getBuyerById(String buyerId) async {
    final response = await _apiService.getBuyerByUserId(buyerId);

    if (response != null && response['success'] == true) {
      return _createBuyerFromJson(response['data']);
    }

    return null;
  }

  // Update buyer profile
  Future<Buyer> updateBuyerProfile(
    String buyerId,
    Map<String, dynamic> buyerData,
  ) async {
    final success = await _apiService.updateBuyerProfile(buyerId, buyerData);

    if (!success) {
      throw Exception('Failed to update buyer profile');
    }

    // Get updated buyer data
    final updatedBuyer = await getBuyerById(buyerId);
    if (updatedBuyer == null) {
      throw Exception('Failed to retrieve updated buyer data');
    }

    return updatedBuyer;
  }

  // Get top buyers
  Future<List<Buyer>> getTopBuyers({int limit = 10}) async {
    final response = await _apiService.getTopBuyers(limit: limit);

    if (response != null && response['success'] == true) {
      final List<dynamic> buyersData = response['data'];
      return buyersData.map((json) => _createBuyerFromJson(json)).toList();
    }

    return [];
  }

  // Get buyer statistics
  Future<Map<String, dynamic>?> getBuyerStats(String buyerId) async {
    final response = await _apiService.getBuyerStats(buyerId);

    if (response != null && response['success'] == true) {
      return response['data'];
    }

    return null;
  }

  // Delete buyer
  Future<void> deleteBuyer(String buyerId) async {
    final success = await _apiService.deleteUser(buyerId);

    if (!success) {
      throw Exception('Failed to delete buyer');
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
}
