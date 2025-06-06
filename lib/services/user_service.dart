import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/farmer.dart';
import '../models/buyer.dart';
import '../repositories/user_repository.dart';
import '../core/di/service_locator.dart';

// Result classes for better error handling
class LoginResult {
  final bool isSuccess;
  final String? errorMessage;

  LoginResult._(this.isSuccess, this.errorMessage);

  factory LoginResult.success() => LoginResult._(true, null);
  factory LoginResult.failure(String error) => LoginResult._(false, error);
}

class RegisterResult {
  final bool isSuccess;
  final String? errorMessage;

  RegisterResult._(this.isSuccess, this.errorMessage);

  factory RegisterResult.success() => RegisterResult._(true, null);
  factory RegisterResult.failure(String error) =>
      RegisterResult._(false, error);
}

class UserService extends ChangeNotifier {
  final UserRepository _userRepository = serviceLocator<UserRepository>();
  bool _isLoading = false;

  // Initialize service (called by service locator)
  Future<void> initialize() async {
    // Any initialization logic can go here
    debugPrint('UserService initialized');
  }

  // Getters
  User? get currentUser => _userRepository.currentUser;
  UserRole get currentUserRole => currentUser?.role ?? UserRole.buyer;
  String get userName => currentUser?.name ?? 'User';
  bool get isLoggedIn => currentUser != null;
  bool get isLoading => _isLoading;
  String get userRoleString =>
      currentUserRole == UserRole.farmer ? 'farmer' : 'buyer';
  String? get authToken => _userRepository.authToken;

  // Get specific user data
  Farmer? get farmerData =>
      currentUser is Farmer ? currentUser as Farmer : null;
  Buyer? get buyerData => currentUser is Buyer ? currentUser as Buyer : null;

  Future<LoginResult> login(String email, String password) async {
    _setLoading(true);

    try {
      await _userRepository.login(email, password);
      _setLoading(false);
      return LoginResult.success();
    } catch (e) {
      debugPrint('Login failed: $e');
      _setLoading(false);

      // Parse error message for better user feedback
      String errorMessage = _parseErrorMessage(e.toString(), 'Login failed');
      return LoginResult.failure(errorMessage);
    }
  }

  Future<RegisterResult> register(
    String email,
    String password,
    String role,
  ) async {
    _setLoading(true);

    try {
      await _userRepository.register(email, password, role);
      _setLoading(false);
      return RegisterResult.success();
    } catch (e) {
      debugPrint('Registration error: $e');
      _setLoading(false);

      // Parse error message
      String errorMessage = _parseErrorMessage(
        e.toString(),
        'Registration failed',
      );
      return RegisterResult.failure(errorMessage);
    }
  }

  Future<bool> updateProfile(User updatedUser) async {
    _setLoading(true);

    try {
      await _userRepository.updateUser(updatedUser);
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Update profile error: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<User?> getUserById(String userId) async {
    try {
      return await _userRepository.getUserById(userId);
    } catch (e) {
      debugPrint('Get user by ID error: $e');
      return null;
    }
  }

  void logout() {
    _userRepository.logout();
    notifyListeners();
  }

  // Helper methods to check if user can access specific features
  bool canAccessFarmerDashboard() => currentUserRole == UserRole.farmer;
  bool canAccessCart() => currentUserRole == UserRole.buyer;
  bool canAccessImpactTracker() => currentUserRole == UserRole.buyer;

  // Test backend connection
  Future<bool> testConnection() async {
    return await _userRepository.testConnection();
  }

  // Refresh current user data from API
  Future<bool> refreshCurrentUser() async {
    if (currentUser == null) {
      return false;
    }

    _setLoading(true);

    try {
      final refreshedUser = await _userRepository.getUserById(currentUser!.id);
      if (refreshedUser != null) {
        _userRepository.setCurrentUser(refreshedUser);
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      debugPrint('Refresh current user error: $e');
      _setLoading(false);
      return false;
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  String _parseErrorMessage(String error, String defaultMessage) {
    if (error.contains('Invalid email or password')) {
      return 'Invalid email or password';
    } else if (error.contains('Email already exists')) {
      return 'Email already exists';
    } else if (error.contains('Network error')) {
      return 'Network error. Please check your connection.';
    }
    return defaultMessage;
  }
}
