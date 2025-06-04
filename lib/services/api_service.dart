import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Base URL for your backend API
  // Update this to match your backend server URL
  static String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:3000/api';

  // For Android emulator, you might need to use 10.0.2.2 instead of localhost
  // static const String baseUrl = 'http://10.0.2.2:3000/api';

  // For physical device, use your computer's IP address
  // static const String baseUrl = 'http://192.168.1.xxx:3000/api';

  // Store the authentication token
  String? _authToken;

  // Getter for auth token
  String? get authToken => _authToken;

  // Default headers for API requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers with authentication
  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // Set authentication token
  void setAuthToken(String? token) {
    _authToken = token;
  }

  // =================================================================
  // SYSTEM ENDPOINTS
  // =================================================================

  /// Health check endpoint
  Future<Map<String, dynamic>?> healthCheck() async {
    try {
      final uri = Uri.parse('$baseUrl/../health');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Health check error: $e');
      return null;
    }
  }

  /// Test database connection
  Future<bool> testConnection() async {
    try {
      final uri = Uri.parse('$baseUrl/../test-db');
      final response = await http.get(uri, headers: _headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // =================================================================
  // AUTHENTICATION ENDPOINTS
  // =================================================================

  /// Login method that calls your backend API
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final uri = Uri.parse('$baseUrl/users/login');
      debugPrint('Attempting login to: $uri');

      final response = await http.post(
        uri,
        headers: _headers,
        body: json.encode({'email': email, 'password': password}),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          // Store the authentication token
          _authToken = responseData['data']['token'];

          // Return full data structure from backend
          return {
            'token': responseData['data']['token'],
            'role': responseData['data']['user']['role'],
            'user': responseData['data']['user'],
            'profile': responseData['data']['profile'],
          };
        } else {
          throw Exception(responseData['message'] ?? 'Login failed');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Login error: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Register method for new users
  Future<Map<String, dynamic>?> register(
    String email,
    String password,
    String role, {
    String? name,
    String? phone,
    String? location,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/users/register');

      final requestBody = {
        'email': email,
        'password': password,
        'role': role, // 'farmer' or 'buyer'
      };

      if (name != null) requestBody['name'] = name;
      if (phone != null) requestBody['phone'] = phone;
      if (location != null) requestBody['location'] = location;

      final response = await http.post(
        uri,
        headers: _headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          // Store the authentication token
          _authToken = responseData['data']['token'];

          // Return full data structure from backend
          return {
            'token': responseData['data']['token'],
            'role': responseData['data']['user']['role'],
            'user': responseData['data']['user'],
            'profile': responseData['data']['profile'],
          };
        } else {
          throw Exception(responseData['message'] ?? 'Registration failed');
        }
      } else if (response.statusCode == 409) {
        throw Exception('Email already exists');
      } else {
        final responseData = json.decode(response.body);
        throw Exception(responseData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // =================================================================
  // USER MANAGEMENT ENDPOINTS
  // =================================================================

  /// Get all users (Admin only)
  Future<Map<String, dynamic>?> getUsers({
    int page = 1,
    int limit = 10,
    String? search,
    String? role,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null) queryParams['search'] = search;
      if (role != null) queryParams['role'] = role;

      final uri = Uri.parse(
        '$baseUrl/users',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _authHeaders);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get users error: $e');
      return null;
    }
  }

  /// Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId');
      final response = await http.get(uri, headers: _authHeaders);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get user by ID error: $e');
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId');
      final response = await http.put(
        uri,
        headers: _authHeaders,
        body: json.encode(userData),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update user error: $e');
      return false;
    }
  }

  /// Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId');
      final response = await http.delete(uri, headers: _authHeaders);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Delete user error: $e');
      return false;
    }
  }

  // =================================================================
  // FARMER MANAGEMENT ENDPOINTS
  // =================================================================

  /// Get all farmers
  Future<Map<String, dynamic>?> getFarmers({
    int page = 1,
    int limit = 10,
    String? search,
    bool? verified,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null) queryParams['search'] = search;
      if (verified != null) queryParams['verified'] = verified.toString();

      final uri = Uri.parse(
        '$baseUrl/farmers',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get farmers error: $e');
      return null;
    }
  }

  /// Get farmer by ID
  Future<Map<String, dynamic>?> getFarmerById(String farmerId) async {
    try {
      final uri = Uri.parse('$baseUrl/farmers/$farmerId');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get farmer by ID error: $e');
      return null;
    }
  }

  /// Get farmer by user ID
  Future<Map<String, dynamic>?> getFarmerByUserId(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/farmers/user/$userId');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get farmer by user ID error: $e');
      return null;
    }
  }

  /// Update farmer profile
  Future<bool> updateFarmerProfile(
    String userId,
    Map<String, dynamic> farmerData,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/farmers/$userId');
      final response = await http.put(
        uri,
        headers: _authHeaders,
        body: json.encode(farmerData),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update farmer profile error: $e');
      return false;
    }
  }

  /// Verify farmer (Admin only)
  Future<bool> verifyFarmer(String userId, bool isVerified) async {
    try {
      final uri = Uri.parse('$baseUrl/farmers/$userId/verify');
      final response = await http.patch(
        uri,
        headers: _authHeaders,
        body: json.encode({'is_verified': isVerified}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Verify farmer error: $e');
      return false;
    }
  }

  /// Get farmer statistics
  Future<Map<String, dynamic>?> getFarmerStats(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/farmers/$userId/stats');
      final response = await http.get(uri, headers: _authHeaders);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get farmer stats error: $e');
      return null;
    }
  }

  // =================================================================
  // BUYER MANAGEMENT ENDPOINTS
  // =================================================================

  /// Get all buyers
  Future<Map<String, dynamic>?> getBuyers({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse(
        '$baseUrl/buyers',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get buyers error: $e');
      return null;
    }
  }

  /// Get buyer by user ID
  Future<Map<String, dynamic>?> getBuyerByUserId(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/buyers/user/$userId');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get buyer by user ID error: $e');
      return null;
    }
  }

  /// Update buyer profile
  Future<bool> updateBuyerProfile(
    String userId,
    Map<String, dynamic> buyerData,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/buyers/$userId');
      final response = await http.put(
        uri,
        headers: _authHeaders,
        body: json.encode(buyerData),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update buyer profile error: $e');
      return false;
    }
  }

  /// Get buyer statistics
  Future<Map<String, dynamic>?> getBuyerStats(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/buyers/$userId/stats');
      final response = await http.get(uri, headers: _authHeaders);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get buyer stats error: $e');
      return null;
    }
  }

  /// Get top buyers
  Future<Map<String, dynamic>?> getTopBuyers({int limit = 10}) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/buyers/top/spenders',
      ).replace(queryParameters: {'limit': limit.toString()});
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get top buyers error: $e');
      return null;
    }
  }

  // =================================================================
  // PRODUCT MANAGEMENT ENDPOINTS
  // =================================================================

  /// Get all products with filters
  Future<Map<String, dynamic>?> getProducts({
    int page = 1,
    int limit = 10,
    String? search,
    String? category,
    String? status,
    String? farmerId,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null) queryParams['search'] = search;
      if (category != null) queryParams['category'] = category;
      if (status != null) queryParams['status'] = status;
      if (farmerId != null) queryParams['farmer_id'] = farmerId;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();

      final uri = Uri.parse(
        '$baseUrl/products',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get products error: $e');
      return null;
    }
  }

  /// Get product by ID
  Future<Map<String, dynamic>?> getProductById(String productId) async {
    try {
      final uri = Uri.parse('$baseUrl/products/$productId');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get product by ID error: $e');
      return null;
    }
  }

  /// Get products by farmer
  Future<Map<String, dynamic>?> getProductsByFarmer(
    String farmerId, {
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse(
        '$baseUrl/products/farmer/$farmerId',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get products by farmer error: $e');
      return null;
    }
  }

  /// Get products by category
  Future<Map<String, dynamic>?> getProductsByCategory(
    String category, {
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse(
        '$baseUrl/products/category/$category',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get products by category error: $e');
      return null;
    }
  }

  /// Get popular/featured products
  Future<Map<String, dynamic>?> getFeaturedProducts({int limit = 10}) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/products/featured/popular',
      ).replace(queryParameters: {'limit': limit.toString()});
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get featured products error: $e');
      return null;
    }
  }

  /// Get product categories
  Future<List<String>?> getProductCategories() async {
    try {
      final uri = Uri.parse('$baseUrl/products/meta/categories');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return List<String>.from(responseData['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Get product categories error: $e');
      return null;
    }
  }

  /// Get product units
  Future<List<String>?> getProductUnits() async {
    try {
      final uri = Uri.parse('$baseUrl/products/meta/units');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return List<String>.from(responseData['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Get product units error: $e');
      return null;
    }
  }

  /// Create product (Farmer only)
  Future<Map<String, dynamic>?> createProduct(
    Map<String, dynamic> productData,
  ) async {
    try {
      debugPrint('ApiService: Creating product with data: $productData');
      debugPrint(
        'ApiService: Auth token: ${_authToken != null ? 'Available' : 'Missing'}',
      );
      debugPrint('ApiService: Auth headers: $_authHeaders');

      final uri = Uri.parse('$baseUrl/products');
      final response = await http.post(
        uri,
        headers: _authHeaders,
        body: json.encode(productData),
      );

      debugPrint(
        'ApiService: Create product response status: ${response.statusCode}',
      );
      debugPrint('ApiService: Create product response body: ${response.body}');

      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Create product error: $e');
      return null;
    }
  }

  /// Update product (Farmer only)
  Future<bool> updateProduct(
    String productId,
    Map<String, dynamic> productData,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/products/$productId');
      final response = await http.put(
        uri,
        headers: _authHeaders,
        body: json.encode(productData),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update product error: $e');
      return false;
    }
  }

  /// Update product status (Farmer only)
  Future<bool> updateProductStatus(String productId, String status) async {
    try {
      final uri = Uri.parse('$baseUrl/products/$productId/status');
      final response = await http.patch(
        uri,
        headers: _authHeaders,
        body: json.encode({'status': status}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update product status error: $e');
      return false;
    }
  }

  /// Update product quantity (Farmer only)
  Future<bool> updateProductQuantity(String productId, int quantity) async {
    try {
      final uri = Uri.parse('$baseUrl/products/$productId/quantity');
      final response = await http.patch(
        uri,
        headers: _authHeaders,
        body: json.encode({'quantity': quantity}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update product quantity error: $e');
      return false;
    }
  }

  /// Delete product (Farmer only)
  Future<bool> deleteProduct(String productId) async {
    try {
      final uri = Uri.parse('$baseUrl/products/$productId');
      final response = await http.delete(uri, headers: _authHeaders);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Delete product error: $e');
      return false;
    }
  }

  // =================================================================
  // CART MANAGEMENT ENDPOINTS
  // =================================================================

  /// Get cart items (Buyer only)
  Future<Map<String, dynamic>?> getCartItems() async {
    try {
      final uri = Uri.parse('$baseUrl/cart');
      final response = await http.get(uri, headers: _authHeaders);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get cart items error: $e');
      return null;
    }
  }

  /// Add item to cart (Buyer only)
  Future<Map<String, dynamic>?> addToCart(
    String productId,
    int quantity,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/cart/items');
      final response = await http.post(
        uri,
        headers: _authHeaders,
        body: json.encode({'product_id': productId, 'quantity': quantity}),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Add to cart error: $e');
      return null;
    }
  }

  /// Update cart item quantity (Buyer only)
  Future<bool> updateCartItemQuantity(String itemId, int quantity) async {
    try {
      final uri = Uri.parse('$baseUrl/cart/items/$itemId');
      final response = await http.put(
        uri,
        headers: _authHeaders,
        body: json.encode({'quantity': quantity}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update cart item quantity error: $e');
      return false;
    }
  }

  /// Remove item from cart (Buyer only)
  Future<bool> removeFromCart(String itemId) async {
    try {
      final uri = Uri.parse('$baseUrl/cart/items/$itemId');
      final response = await http.delete(uri, headers: _authHeaders);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Remove from cart error: $e');
      return false;
    }
  }

  /// Clear cart (Buyer only)
  Future<bool> clearCart() async {
    try {
      final uri = Uri.parse('$baseUrl/cart/clear');
      final response = await http.delete(uri, headers: _authHeaders);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Clear cart error: $e');
      return false;
    }
  }

  /// Get cart summary (Buyer only)
  Future<Map<String, dynamic>?> getCartSummary() async {
    try {
      final uri = Uri.parse('$baseUrl/cart/summary');
      final response = await http.get(uri, headers: _authHeaders);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get cart summary error: $e');
      return null;
    }
  }

  // =================================================================
  // ORDER MANAGEMENT ENDPOINTS
  // =================================================================

  /// Get orders
  Future<Map<String, dynamic>?> getOrders({
    int page = 1,
    int limit = 10,
    String? status,
    String? farmerId,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) queryParams['status'] = status;
      if (farmerId != null) queryParams['farmer_id'] = farmerId;

      final uri = Uri.parse(
        '$baseUrl/orders',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _authHeaders);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get orders error: $e');
      return null;
    }
  }

  /// Get order by ID
  Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    try {
      final uri = Uri.parse('$baseUrl/orders/$orderId');
      final response = await http.get(uri, headers: _authHeaders);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get order by ID error: $e');
      return null;
    }
  }

  /// Checkout (Create order from cart)
  Future<Map<String, dynamic>?> checkout({
    required String deliveryAddress,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/orders/checkout');
      final response = await http.post(
        uri,
        headers: _authHeaders,
        body: json.encode({
          'delivery_address': deliveryAddress,
          'payment_method': paymentMethod,
          if (notes != null) 'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Checkout error: $e');
      return null;
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final uri = Uri.parse('$baseUrl/orders/$orderId/status');
      final response = await http.patch(
        uri,
        headers: _authHeaders,
        body: json.encode({'status': status}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update order status error: $e');
      return false;
    }
  }

  /// Update payment status (Admin only)
  Future<bool> updatePaymentStatus(String orderId, String paymentStatus) async {
    try {
      final uri = Uri.parse('$baseUrl/orders/$orderId/payment');
      final response = await http.patch(
        uri,
        headers: _authHeaders,
        body: json.encode({'payment_status': paymentStatus}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update payment status error: $e');
      return false;
    }
  }

  /// Get order statistics
  Future<Map<String, dynamic>?> getOrderStats() async {
    try {
      final uri = Uri.parse('$baseUrl/orders/stats/summary');
      final response = await http.get(uri, headers: _authHeaders);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get order stats error: $e');
      return null;
    }
  }

  // =================================================================
  // LEGACY METHODS (for backward compatibility)
  // =================================================================

  /// Legacy update profile method
  Future<bool> updateProfile(
    Map<String, dynamic> userData,
    String? authToken,
  ) async {
    if (authToken != null) {
      setAuthToken(authToken);
    }
    // Assumes userData contains an 'id' field
    if (userData['id'] != null) {
      return updateUser(userData['id'], userData);
    }
    return false;
  }

  /// Get user profile by ID (legacy)
  Future<Map<String, dynamic>?> getUserProfile(
    String userId,
    String? authToken,
  ) async {
    if (authToken != null) {
      setAuthToken(authToken);
    }
    return getUserById(userId);
  }

  /// Logout method
  Future<bool> logout(String? authToken) async {
    _authToken = null;
    return true;
  }

  // =================================================================
  // UTILITY METHODS
  // =================================================================

  /// Test different base URLs to find the working one
  Future<String?> findWorkingBaseUrl() async {
    final testUrls = [
      'http://localhost:3000/api',
      'http://10.0.2.2:3000/api',
      'http://127.0.0.1:3000/api',
    ];

    for (String url in testUrls) {
      try {
        debugPrint('Testing URL: $url');
        final uri = Uri.parse('$url/../health');
        final response = await http.get(uri, headers: _headers);
        debugPrint('Response for $url: ${response.statusCode}');

        if (response.statusCode == 200) {
          debugPrint('Working URL found: $url');
          return url;
        }
      } catch (e) {
        debugPrint('Failed to connect to $url: $e');
        continue;
      }
    }
    return null;
  }

  /// Generic GET request
  Future<Map<String, dynamic>?> get(
    String endpoint, {
    String? authToken,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = Map<String, String>.from(_headers);

      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      } else if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  /// Generic POST request
  Future<Map<String, dynamic>?> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? authToken,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = Map<String, String>.from(_headers);

      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      } else if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }
}
