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
        farmDescription:
            profileData['farm_description'] ?? profileData['description'],
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
        deliveryInstructions: profileData['delivery_instructions'],
        preferences:
            profileData['preferred_payment_methods'] != null
                ? List<String>.from(profileData['preferred_payment_methods'])
                : null,
        loyaltyPoints: profileData['loyalty_points'],
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
        farmDescription:
            profileData['farm_description'] ?? profileData['description'],
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
        deliveryInstructions: profileData['delivery_instructions'],
        preferences:
            profileData['preferred_payment_methods'] != null
                ? List<String>.from(profileData['preferred_payment_methods'])
                : null,
        loyaltyPoints: profileData['loyalty_points'],
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
  } // Method for login/register - fetches user by ID from generic endpoint

  Future<User?> getUserById(String userId) async {
    final response = await _apiService.getUserById(userId);
    if (response == null || response['success'] != true) {
      return null;
    }

    final userData = response['data']['user'];
    final role = userData['role']?.toString().toLowerCase();

    if (role == 'farmer') {
      return Farmer(
        id: userData['id'],
        email: userData['email'],
        name: userData['name'],
        phone: userData['phone'] ?? '',
        location: userData['location'] ?? '',
        profileImageUrl: userData['profile_image_url'],
        farmName: '',
        farmAddress: null,
        farmDescription: null,
        totalSales: 0,
        isVerified: false,
      );
    } else {
      return Buyer(
        id: userData['id'],
        email: userData['email'],
        name: userData['name'],
        phone: userData['phone'] ?? '',
        location: userData['location'] ?? '',
        profileImageUrl: userData['profile_image_url'],
        totalSpent: 0.0,
        totalOrders: 0,
        deliveryAddress: '',
        deliveryInstructions: null,
        preferences: null,
        loyaltyPoints: 0,
      );
    }
  }

  // Method for refreshing farmer data - calls farmer-specific endpoint
  Future<Farmer?> refreshFarmerData(String userId) async {
    final response = await _apiService.getFarmerByUserId(userId);
    if (response == null || response['success'] != true) {
      return null;
    }

    final data = response['data'];
    final userData = data['users'];

    final farmer = Farmer(
      id: userData['id'],
      email: userData['email'],
      name: userData['name'],
      phone: userData['phone'] ?? '',
      location: userData['location'] ?? '',
      profileImageUrl: userData['profile_image_url'],
      farmName: data['farm_name'] ?? '',
      farmAddress: data['farm_address'],
      farmDescription: data['farm_description'],
      totalSales: data['total_sales'] ?? 0,
      isVerified: data['is_verified'] ?? false,
    );

    // Update cached user
    _currentUser = farmer;
    return farmer;
  }

  // Method for refreshing buyer data - calls buyer-specific endpoint
  Future<Buyer?> refreshBuyerData(String userId) async {
    final response = await _apiService.getBuyerByUserId(userId);
    if (response == null || response['success'] != true) {
      return null;
    }

    final data = response['data'];
    final userData = data['users'];

    final buyer = Buyer(
      id: userData['id'],
      email: userData['email'],
      name: userData['name'],
      phone: userData['phone'] ?? '',
      location: userData['location'] ?? '',
      profileImageUrl: userData['profile_image_url'],
      totalSpent: (data['total_spent'] ?? 0).toDouble(),
      totalOrders: data['total_orders'] ?? 0,
      deliveryAddress: data['delivery_address'] ?? '',
      deliveryInstructions: data['delivery_instructions'],
      preferences:
          data['preferred_payment_methods'] != null
              ? List<String>.from(data['preferred_payment_methods'])
              : null,
      loyaltyPoints: data['loyalty_points'] ?? 0,
    );

    // Update cached user
    _currentUser = buyer;
    return buyer;
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
