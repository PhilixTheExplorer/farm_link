// filepath: c:\Users\kshin\Desktop\CAMPUS\farm_link\lib\repositories\farmer_repository.dart
import '../models/farmer.dart';
import '../services/api_service.dart';
import '../core/di/service_locator.dart';

class FarmerRepository {
  final ApiService _apiService = serviceLocator<ApiService>();

  // Get all farmers with filters
  Future<List<Farmer>> getFarmers({
    int page = 1,
    int limit = 10,
    String? search,
    bool? verified,
  }) async {
    final response = await _apiService.getFarmers(
      page: page,
      limit: limit,
      search: search,
      verified: verified,
    );

    if (response != null && response['success'] == true) {
      final List<dynamic> farmersData = response['data']['farmers'];
      return farmersData.map((json) => _createFarmerFromJson(json)).toList();
    }

    throw Exception('Failed to get farmers');
  }

  // Get farmer by ID
  Future<Farmer?> getFarmerById(String farmerId) async {
    final response = await _apiService.getFarmerById(farmerId);

    if (response != null && response['success'] == true) {
      return _createFarmerFromJson(response['data']);
    }

    return null;
  }

  // Update farmer profile
  Future<Farmer> updateFarmerProfile(
    String farmerId,
    Map<String, dynamic> farmerData,
  ) async {
    final success = await _apiService.updateFarmerProfile(farmerId, farmerData);

    if (!success) {
      throw Exception('Failed to update farmer profile');
    }

    // Get updated farmer data
    final updatedFarmer = await getFarmerById(farmerId);
    if (updatedFarmer == null) {
      throw Exception('Failed to retrieve updated farmer data');
    }

    return updatedFarmer;
  }

  // Update farmer verification status
  Future<void> updateVerificationStatus(
    String farmerId,
    bool isVerified,
  ) async {
    final success = await _apiService.verifyFarmer(farmerId, isVerified);

    if (!success) {
      throw Exception('Failed to update farmer verification status');
    }
  }

  // Get farmer statistics
  Future<Map<String, dynamic>?> getFarmerStats(String farmerId) async {
    final response = await _apiService.getFarmerStats(farmerId);

    if (response != null && response['success'] == true) {
      return response['data'];
    }

    return null;
  }

  // Delete farmer
  Future<void> deleteFarmer(String farmerId) async {
    final success = await _apiService.deleteUser(farmerId);

    if (!success) {
      throw Exception('Failed to delete farmer');
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
}
