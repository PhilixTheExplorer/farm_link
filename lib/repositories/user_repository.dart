import '../models/user.dart';
import '../models/farmer.dart';
import '../models/buyer.dart';
import '../services/api_service.dart';
import '../core/di/service_locator.dart';

// Result classes for repository operations
class UserLoginData {
  final User user;
  final String token;

  UserLoginData({required this.user, required this.token});
}

class UserRepository {
  final ApiService _apiService = serviceLocator<ApiService>();

  // Current user cache
  User? _currentUser;
  String? _authToken;

  // Getters
  User? get currentUser => _currentUser;
  String? get authToken => _authToken;

  // Authentication methods
  Future<UserLoginData> login(String email, String password) async {
    final loginResponse = await _apiService.login(email, password);

    if (loginResponse == null) {
      throw Exception('Login failed');
    }

    // Parse backend response and create user object
    final userData = loginResponse['user'];
    final profileData = loginResponse['profile'];
    final token = loginResponse['token'];

    User user;
    if (loginResponse['role']?.toString().toLowerCase() == 'farmer') {
      user = Farmer(
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
      user = Buyer(
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

    // Cache the user and token
    _currentUser = user;
    _authToken = token;
    _apiService.setAuthToken(token);

    return UserLoginData(user: user, token: token);
  }

  Future<UserLoginData> register(
    String email,
    String password,
    String role,
  ) async {
    final registerResponse = await _apiService.register(email, password, role);

    if (registerResponse == null) {
      throw Exception('Registration failed');
    }

    // Parse backend response and create user object
    final userData = registerResponse['user'];
    final profileData = registerResponse['profile'];
    final token = registerResponse['token'];

    User user;
    if (registerResponse['role']?.toString().toLowerCase() == 'farmer') {
      user = Farmer(
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
      user = Buyer(
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

    // Cache the user and token
    _currentUser = user;
    _authToken = token;
    _apiService.setAuthToken(token);

    return UserLoginData(user: user, token: token);
  }

  Future<User> updateUser(User user) async {
    final success = await _apiService.updateUser(user.id, user.toJson());

    if (!success) {
      throw Exception('Failed to update user profile');
    }

    // Update cached user
    _currentUser = user;
    return user;
  }

  Future<User?> getUserById(String userId) async {
    final response = await _apiService.getUserById(userId);

    if (response == null) {
      return null;
    }

    // Parse response and create user object
    final userData = response['data']['user'];
    final profileData = response['data']['profile'];

    if (userData['role']?.toString().toLowerCase() == 'farmer') {
      return Farmer(
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

  // Cache management methods
  void setCurrentUser(User? user) {
    _currentUser = user;
  }

  void setAuthToken(String? token) {
    _authToken = token;
    _apiService.setAuthToken(token);
  }

  void logout() {
    _currentUser = null;
    _authToken = null;
    _apiService.setAuthToken(null);
  }

  // Test connection method
  Future<bool> testConnection() async {
    return await _apiService.testConnection();
  }
}
