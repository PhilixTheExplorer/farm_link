import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/farmer.dart';
import '../models/buyer.dart';
import '../repositories/user_repository.dart';
import 'api_service.dart';

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
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final UserRepository _userRepository = UserRepository();
  final ApiService _apiService = ApiService();
  User? _currentUser;
  bool _isLoading = false;
  String? _authToken;
  User? get currentUser => _currentUser;
  UserRole get currentUserRole => _currentUser?.role ?? UserRole.buyer;
  String get userName => _currentUser?.name ?? 'User';
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String get userRoleString =>
      currentUserRole == UserRole.farmer ? 'farmer' : 'buyer';
  String? get authToken => _authToken;

  // Get specific user data
  Farmer? get farmerData =>
      _currentUser is Farmer ? _currentUser as Farmer : null;
  Buyer? get buyerData => _currentUser is Buyer ? _currentUser as Buyer : null;
  Future<LoginResult> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Use API login only
      final loginResponse = await _apiService.login(email, password);
      if (loginResponse != null) {
        // Store the auth token
        _authToken = loginResponse['token'];

        // The login response already contains user and profile data
        // Parse the backend response structure you provided
        final userData = loginResponse['user']; // User data from backend
        final profileData =
            loginResponse['profile']; // Profile data from backend

        // Create user object based on the role from the backend response
        if (loginResponse['role']?.toString().toLowerCase() == 'farmer') {
          _currentUser = Farmer(
            id: userData['id'],
            email: userData['email'],
            name: userData['name'],
            phone: userData['phone'] ?? '',
            location: userData['location'] ?? '',
            profileImageUrl: userData['profile_image_url'],
            farmName: profileData['farm_name'] ?? '',
            farmAddress: profileData['farm_address'] ?? '',
            totalSales: profileData['total_sales'] ?? 0,
            isVerified: profileData['is_verified'] ?? false,
          );
        } else {
          _currentUser = Buyer(
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

        // Update the repository
        _userRepository.setCurrentUser(_currentUser);

        _isLoading = false;
        notifyListeners();
        return LoginResult.success();
      }
    } catch (e) {
      debugPrint('API login failed: $e');
      _isLoading = false;
      notifyListeners();

      // Parse error message for better user feedback
      String errorMessage = 'Login failed';
      if (e.toString().contains('Invalid email or password')) {
        errorMessage = 'Invalid email or password';
      } else if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      }

      return LoginResult.failure(errorMessage);
    }

    _isLoading = false;
    notifyListeners();
    return LoginResult.failure('Login failed');
  }

  Future<RegisterResult> register(
    String email,
    String password,
    String role,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final registerData = await _apiService.register(email, password, role);
      if (registerData != null) {
        // Store the auth token
        _authToken = registerData['token'];

        // Create user object based on role from backend response
        if (registerData['role']?.toString().toLowerCase() == 'farmer') {
          _currentUser = Farmer(
            id: registerData['user']['id'],
            email: registerData['user']['email'],
            name: registerData['user']['name'],
            phone: registerData['user']['phone'] ?? '',
            location: registerData['user']['location'] ?? '',
            profileImageUrl: registerData['user']['profile_image_url'],
            farmName: registerData['profile']['farm_name'] ?? '',
            farmAddress: registerData['profile']['farm_address'] ?? '',
            totalSales: registerData['profile']['total_sales'] ?? 0,
            isVerified: registerData['profile']['is_verified'] ?? false,
          );
        } else {
          _currentUser = Buyer(
            id: registerData['user']['id'],
            email: registerData['user']['email'],
            name: registerData['user']['name'],
            phone: registerData['user']['phone'] ?? '',
            location: registerData['user']['location'] ?? '',
            profileImageUrl: registerData['user']['profile_image_url'],
            totalSpent:
                (registerData['profile']['total_spent'] ?? 0).toDouble(),
            totalOrders: registerData['profile']['total_orders'] ?? 0,
            deliveryAddress: registerData['profile']['delivery_address'] ?? '',
          );
        }

        // Update the repository
        _userRepository.setCurrentUser(_currentUser);

        _isLoading = false;
        notifyListeners();
        return RegisterResult.success();
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      _isLoading = false;
      notifyListeners();

      // Parse error message
      String errorMessage = 'Registration failed';
      if (e.toString().contains('Email already exists')) {
        errorMessage = 'Email already exists';
      } else if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      }

      return RegisterResult.failure(errorMessage);
    }

    _isLoading = false;
    notifyListeners();
    return RegisterResult.failure('Registration failed');
  }

  Future<bool> updateProfile(User updatedUser) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Use API update only
      final success = await _apiService.updateProfile(
        updatedUser.toJson(),
        _authToken,
      );
      if (success) {
        _currentUser = updatedUser;
        _userRepository.setCurrentUser(_currentUser);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('API update profile error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() {
    _currentUser = null;
    _authToken = null;
    _userRepository.logout();
    notifyListeners();
  }

  // Helper methods to check if user can access specific features
  bool canAccessFarmerDashboard() => currentUserRole == UserRole.farmer;
  bool canAccessCart() => currentUserRole == UserRole.buyer;
  bool canAccessImpactTracker() => currentUserRole == UserRole.buyer;

  // Test backend connection
  Future<bool> testConnection() async {
    return await _apiService.testConnection();
  }
}
