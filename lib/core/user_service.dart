import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/farmer.dart';
import '../models/buyer.dart';
import '../repositories/user_repository.dart';

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final UserRepository _userRepository = UserRepository();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  UserRole get currentUserRole => _currentUser?.role ?? UserRole.buyer;
  String get userName => _currentUser?.name ?? 'User';
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String get userRoleString =>
      currentUserRole == UserRole.farmer ? 'farmer' : 'buyer';

  // Get specific user data
  Farmer? get farmerData =>
      _currentUser is Farmer ? _currentUser as Farmer : null;
  Buyer? get buyerData => _currentUser is Buyer ? _currentUser as Buyer : null;
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _userRepository.login(email, password);
      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateProfile(User updatedUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _userRepository.updateUserProfile(updatedUser);
      if (success) {
        _currentUser = updatedUser;
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Update profile error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _userRepository.logout();
    notifyListeners();
  }

  // For demo purposes - switch between roles
  void switchUserRole(UserRole newRole) {
    _userRepository.switchUserRole(newRole);
    _currentUser = _userRepository.currentUser;
    notifyListeners();
  }

  // Helper methods to check if user can access specific features
  bool canAccessFarmerDashboard() => currentUserRole == UserRole.farmer;
  bool canAccessCart() => currentUserRole == UserRole.buyer;
  bool canAccessImpactTracker() => currentUserRole == UserRole.buyer;
}
