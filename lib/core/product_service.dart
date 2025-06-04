import 'package:flutter/foundation.dart';
import '../models/product.dart';
import 'api_service.dart';

class ProductService extends ChangeNotifier {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  List<Product> _products = [];

  bool get isLoading => _isLoading;
  List<Product> get products => _products;
  // Get all products with optional filters
  Future<List<Product>> getAllProducts({
    int page = 1,
    int limit = 10,
    String? search,
    String? category,
    String? status,
    bool? isOrganic,
    double? minPrice,
    double? maxPrice,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getProducts(
        page: page,
        limit: limit,
        search: search,
        category: category,
        status: status,
        isOrganic: isOrganic,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> productsData = response['data']['products'];
        final products =
            productsData.map((json) => Product.fromJson(json)).toList();
        _products = products;
        _isLoading = false;
        notifyListeners();
        return products;
      }
    } catch (e) {
      debugPrint('Get all products error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return [];
  }

  // Get products for a specific farmer
  Future<List<Product>> getFarmerProducts(
    String farmerId, {
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getProductsByFarmer(
        farmerId,
        page: page,
        limit: limit,
        status: status,
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> productsData = response['data']['products'];
        final products =
            productsData.map((json) => Product.fromJson(json)).toList();
        _isLoading = false;
        notifyListeners();
        return products;
      }
    } catch (e) {
      debugPrint('Get farmer products error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return [];
  }

  // Get product by ID
  Future<Product?> getProductById(String productId) async {
    try {
      final response = await _apiService.getProductById(productId);

      if (response != null && response['success'] == true) {
        return Product.fromJson(response['data']);
      }
    } catch (e) {
      debugPrint('Get product by ID error: $e');
    }
    return null;
  }

  // Add new product
  Future<bool> addProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.createProduct(product.toJson());
      _isLoading = false;
      notifyListeners();
      return response != null && response['success'] == true;
    } catch (e) {
      debugPrint('Add product error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update product
  Future<bool> updateProduct(Product product) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _apiService.updateProduct(
        product.id,
        product.toJson(),
      );
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Update product error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(String productId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _apiService.deleteProduct(productId);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Delete product error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update product status
  Future<bool> updateProductStatus(String productId, String status) async {
    try {
      return await _apiService.updateProductStatus(productId, status);
    } catch (e) {
      debugPrint('Update product status error: $e');
      return false;
    }
  }

  // Update product quantity
  Future<bool> updateProductQuantity(String productId, int quantity) async {
    try {
      return await _apiService.updateProductQuantity(productId, quantity);
    } catch (e) {
      debugPrint('Update product quantity error: $e');
      return false;
    }
  }

  // Search products
  Future<List<Product>> searchProducts(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    return await getAllProducts(search: query, page: page, limit: limit);
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(
    String category, {
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getProductsByCategory(
        category,
        page: page,
        limit: limit,
        status: status,
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> productsData = response['data']['products'];
        final products =
            productsData.map((json) => Product.fromJson(json)).toList();
        _isLoading = false;
        notifyListeners();
        return products;
      }
    } catch (e) {
      debugPrint('Get products by category error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return [];
  }

  // Get featured/popular products
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    try {
      final response = await _apiService.getFeaturedProducts(limit: limit);

      if (response != null && response['success'] == true) {
        final List<dynamic> productsData = response['data'];
        return productsData.map((json) => Product.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Get featured products error: $e');
    }
    return [];
  }

  // Get product categories
  Future<List<String>> getProductCategories() async {
    try {
      final categories = await _apiService.getProductCategories();
      return categories ?? [];
    } catch (e) {
      debugPrint('Get product categories error: $e');
      return [];
    }
  }

  // Get product units
  Future<List<String>> getProductUnits() async {
    try {
      final units = await _apiService.getProductUnits();
      return units ?? [];
    } catch (e) {
      debugPrint('Get product units error: $e');
      return [];
    }
  }

  // Get farmer statistics (using API aggregation)
  Future<Map<String, dynamic>> getFarmerStats(String farmerId) async {
    try {
      // This would ideally be a dedicated API endpoint for farmer stats
      // For now, we'll calculate from available data
      final products = await getFarmerProducts(farmerId);

      int productCount = products.length;
      int totalOrders = 0;
      int availableProducts = 0;
      double totalRevenue = 0.0;
      double totalRating = 0.0;
      int reviewCount = 0;

      for (final product in products) {
        totalOrders += product.orderCount;
        if (product.isAvailable) {
          availableProducts++;
        }
        totalRevenue += product.price * product.orderCount;
        totalRating += product.rating * product.reviewCount;
        reviewCount += product.reviewCount;
      }

      double averageRating = reviewCount > 0 ? totalRating / reviewCount : 0.0;

      return {
        'productCount': productCount,
        'totalRevenue': totalRevenue,
        'averageRating': averageRating,
        'totalOrders': totalOrders,
        'availableProducts': availableProducts,
      };
    } catch (e) {
      debugPrint('Get farmer stats error: $e');
      return {
        'productCount': 0,
        'totalRevenue': 0.0,
        'averageRating': 0.0,
        'totalOrders': 0,
        'availableProducts': 0,
      };
    }
  }

  // Generate product ID (this might be handled by backend now)
  String generateProductId() {
    return 'prod_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Helper method to format price
  String formatPrice(double price) {
    return '฿${price.toStringAsFixed(0)}';
  }

  // Helper method to get category icon
  String getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'rice':
        return '🌾';
      case 'fruits':
        return '🍎';
      case 'vegetables':
        return '🥬';
      case 'herbs':
        return '🌿';
      case 'handmade':
        return '🧺';
      case 'dairy':
        return '🥛';
      case 'meat':
        return '🥩';
      default:
        return '📦';
    }
  }
}
