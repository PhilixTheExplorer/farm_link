import 'package:flutter/foundation.dart';
import '../models/farmer.dart';
import '../repositories/farmer_repository.dart';
import '../services/user_service.dart';
import '../core/di/service_locator.dart';

class FarmerService extends ChangeNotifier {
  final FarmerRepository _farmerRepository = serviceLocator<FarmerRepository>();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Get all farmers with filters
  Future<List<Farmer>> getFarmers({
    int page = 1,
    int limit = 10,
    String? search,
    bool? verified,
  }) async {
    _setLoading(true);

    try {
      final farmers = await _farmerRepository.getFarmers(
        page: page,
        limit: limit,
        search: search,
        verified: verified,
      );

      _setLoading(false);
      return farmers;
    } catch (e) {
      debugPrint('Get farmers error: $e');
      _setLoading(false);
      return [];
    }
  }

  // Get farmer by ID
  Future<Farmer?> getFarmerById(String farmerId) async {
    try {
      return await _farmerRepository.getFarmerById(farmerId);
    } catch (e) {
      debugPrint('Get farmer by ID error: $e');
      return null;
    }
  }

  // Update farmer profile
  Future<bool> updateFarmerProfile(
    String farmerId,
    Map<String, dynamic> farmerData,
  ) async {
    _setLoading(true);

    try {
      await _farmerRepository.updateFarmerProfile(farmerId, farmerData);

      // Refresh current user data to reflect changes in UI
      final userService = serviceLocator<UserService>();
      await userService.refreshCurrentUser();

      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Update farmer profile error: $e');
      _setLoading(false);
      return false;
    }
  }

  // Update farmer verification status (Admin only)
  Future<bool> updateVerificationStatus(
    String farmerId,
    bool isVerified,
  ) async {
    try {
      await _farmerRepository.updateVerificationStatus(farmerId, isVerified);
      return true;
    } catch (e) {
      debugPrint('Update farmer verification error: $e');
      return false;
    }
  }

  // Get top farmers
  Future<List<Farmer>> getTopFarmers({int limit = 10}) async {
    try {
      return await _farmerRepository.getFarmers(
        page: 1,
        limit: limit,
        verified: true,
      );
    } catch (e) {
      debugPrint('Get top farmers error: $e');
      return [];
    }
  }

  // Get farmer statistics
  Future<Map<String, dynamic>?> getFarmerStats(String farmerId) async {
    try {
      return await _farmerRepository.getFarmerStats(farmerId);
    } catch (e) {
      debugPrint('Get farmer stats error: $e');
      return null;
    }
  }

  // Delete farmer (Admin only)
  Future<bool> deleteFarmer(String farmerId) async {
    try {
      await _farmerRepository.deleteFarmer(farmerId);
      return true;
    } catch (e) {
      debugPrint('Delete farmer error: $e');
      return false;
    }
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

  // Business logic helper methods
  String formatSales(double amount) {
    return '฿${amount.toStringAsFixed(0)}';
  }

  bool isEligibleForVerification(Farmer farmer) {
    return (farmer.farmName?.isNotEmpty ?? false) &&
        (farmer.farmAddress?.isNotEmpty ?? false) &&
        farmer.totalSales > 0;
  }

  String getVerificationStatusText(bool isVerified) {
    return isVerified ? 'Verified' : 'Pending Verification';
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
