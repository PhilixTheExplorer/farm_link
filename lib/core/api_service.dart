import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  // Base URL for your backend API
  // Update this to match your backend server URL
  static const String baseUrl = 'http://localhost:3000/api';

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
  }; // Login method that calls your backend API
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final uri = Uri.parse('$baseUrl/users/login');
      print('Attempting login to: $uri'); // Debug log

      final response = await http.post(
        uri,
        headers: _headers,
        body: json.encode({'email': email, 'password': password}),
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Check if the response indicates success
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
        // Invalid credentials
        throw Exception('Invalid email or password');
      } else {
        // Other error
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Login error: $e'); // Debug log
      throw Exception('Network error: $e');
    }
  }

  // Register method for new users
  Future<Map<String, dynamic>?> register(
    String email,
    String password,
    String role,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/users/register');

      final response = await http.post(
        uri,
        headers: _headers,
        body: json.encode({
          'email': email,
          'password': password,
          'role': role, // 'farmer' or 'buyer'
        }),
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

  // Update user profile
  Future<bool> updateProfile(
    Map<String, dynamic> userData,
    String? authToken,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/users/profile');

      final headers = Map<String, String>.from(_headers);
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode(userData),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get user profile by ID
  Future<Map<String, dynamic>?> getUserProfile(
    String userId,
    String? authToken,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId');

      final headers = Map<String, String>.from(_headers);
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Logout method - simply clear the auth token
  Future<bool> logout(String? authToken) async {
    // Clear the stored authentication token
    _authToken = null;
    return true;
  }

  // Test connection to backend
  Future<bool> testConnection() async {
    try {
      final uri = Uri.parse(
        '$baseUrl/health',
      ); // or whatever health check endpoint you have

      final response = await http.get(uri, headers: _headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Test different base URLs to find the working one
  Future<String?> findWorkingBaseUrl() async {
    final testUrls = [
      'http://localhost:3000/api',
      'http://10.0.2.2:3000/api',
      'http://127.0.0.1:3000/api',
    ];

    for (String url in testUrls) {
      try {
        print('Testing URL: $url');
        final uri = Uri.parse('$url/health');
        final response = await http.get(uri, headers: _headers);
        print('Response for $url: ${response.statusCode}');

        if (response.statusCode == 200) {
          print('Working URL found: $url');
          return url;
        }
      } catch (e) {
        print('Failed to connect to $url: $e');
        continue;
      }
    }
    return null;
  }

  // Generic GET request
  Future<Map<String, dynamic>?> get(
    String endpoint, {
    String? authToken,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      final headers = Map<String, String>.from(_headers);
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
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

  // Generic POST request
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
