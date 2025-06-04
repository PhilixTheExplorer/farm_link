import 'package:flutter/foundation.dart';
import '../models/farmer.dart';
import 'api_service.dart';

class FarmerService extends ChangeNotifier {
  static final FarmerService _instance = FarmerService._internal();
  factory FarmerService() => _instance;
  FarmerService._internal();

  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Get all farmers with filters
  Future<List<Farmer>> getFarmers({
    int page = 1,
    int limit = 10,
    String? search,
    bool? verified,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getFarmers(
        page: page,
        limit: limit,
        search: search,
        verified: verified,
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> farmersData = response['data']['farmers'];
        final farmers =
            farmersData.map((json) => _createFarmerFromJson(json)).toList();
        _isLoading = false;
        notifyListeners();
        return farmers;
      }
    } catch (e) {
      debugPrint('Get farmers error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return [];
  }

  // Get farmer by ID
  Future<Farmer?> getFarmerById(String farmerId) async {
    try {
      final response = await _apiService.getFarmerById(farmerId);

      if (response != null && response['success'] == true) {
        return _createFarmerFromJson(response['data']);
      }
    } catch (e) {
      debugPrint('Get farmer by ID error: $e');
    }
    return null;
  }

  // Update farmer profile
  Future<bool> updateFarmerProfile(
    String farmerId,
    Map<String, dynamic> farmerData,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _apiService.updateFarmerProfile(
        farmerId,
        farmerData,
      );
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Update farmer profile error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update farmer verification status (Admin only)
  Future<bool> updateVerificationStatus(
    String farmerId,
    bool isVerified,
  ) async {
    try {
      return await _apiService.verifyFarmer(farmerId, isVerified);
    } catch (e) {
      debugPrint('Update farmer verification error: $e');
      return false;
    }
  }

  // Get top farmers
  Future<List<Farmer>> getTopFarmers({int limit = 10}) async {
    try {
      // Use the existing getFarmers method with verified farmers only
      final response = await _apiService.getFarmers(
        page: 1,
        limit: limit,
        verified: true,
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> farmersData = response['data']['farmers'];
        return farmersData.map((json) => _createFarmerFromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Get top farmers error: $e');
    }
    return [];
  }

  // Get farmer statistics
  Future<Map<String, dynamic>?> getFarmerStats(String farmerId) async {
    try {
      final response = await _apiService.getFarmerStats(farmerId);

      if (response != null && response['success'] == true) {
        return response['data'];
      }
    } catch (e) {
      debugPrint('Get farmer stats error: $e');
    }
    return null;
  }

  // Delete farmer (Admin only)
  Future<bool> deleteFarmer(String farmerId) async {
    try {
      // Use the deleteUser method since farmers are users with farmer role
      return await _apiService.deleteUser(farmerId);
    } catch (e) {
      debugPrint('Delete farmer error: $e');
      return false;
    }
  }

  // Helper method to create Farmer object from JSON
  Farmer _createFarmerFromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? json;
    final profileData = json['profile'] ?? json;

    return Farmer(
      id: userData['id'],
      email: userData['email'],
      name: userData['name'],
      phone: userData['phone'] ?? '',
      location: userData['location'] ?? '',
      profileImageUrl: userData['profile_image_url'],
      farmName: profileData['farm_name'] ?? '',
      farmAddress: profileData['farm_address'] ?? '',
      totalSales: (profileData['total_sales'] ?? 0).toDouble(),
      isVerified: profileData['is_verified'] ?? false,
    );
  }

  // Search farmers
  Future<List<Farmer>> searchFarmers(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    return await getFarmers(search: query, page: page, limit: limit);
  }

  // Get verified farmers only
  Future<List<Farmer>> getVerifiedFarmers({
    int page = 1,
    int limit = 10,
  }) async {
    return await getFarmers(verified: true, page: page, limit: limit);
  }

  // Format sales amount
  String formatSales(double amount) {
    return '฿${amount.toStringAsFixed(0)}';
  }
}
