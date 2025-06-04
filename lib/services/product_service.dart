import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

class ProductService extends ChangeNotifier {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final ProductRepository _productRepository = ProductRepository();
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
    double? minPrice,
    double? maxPrice,
  }) async {
    _setLoading(true);

    try {
      final products = await _productRepository.getAllProducts(
        page: page,
        limit: limit,
        search: search,
        category: category,
        status: status,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );

      _products = products;
      _setLoading(false);
      return products;
    } catch (e) {
      debugPrint('Get all products error: $e');
      _setLoading(false);
      return [];
    }
  }

  // Get products for a specific farmer
  Future<List<Product>> getFarmerProducts(
    String farmerId, {
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    _setLoading(true);

    try {
      final products = await _productRepository.getProductsByFarmerId(
        farmerId,
        page: page,
        limit: limit,
        status: status,
      );

      _setLoading(false);
      return products;
    } catch (e) {
      debugPrint('Get farmer products error: $e');
      _setLoading(false);
      return [];
    }
  }

  // Get product by ID
  Future<Product?> getProductById(String productId) async {
    try {
      return await _productRepository.getProductById(productId);
    } catch (e) {
      debugPrint('Get product by ID error: $e');
      return null;
    }
  }

  // Add new product
  Future<bool> addProduct(Product product) async {
    _setLoading(true);

    try {
      await _productRepository.addProduct(product);
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Add product error: $e');
      _setLoading(false);
      return false;
    }
  }

  // Update product
  Future<bool> updateProduct(Product product) async {
    _setLoading(true);

    try {
      await _productRepository.updateProduct(product);
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Update product error: $e');
      _setLoading(false);
      return false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(String productId) async {
    _setLoading(true);

    try {
      await _productRepository.deleteProduct(productId);
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Delete product error: $e');
      _setLoading(false);
      return false;
    }
  }

  // Update product status
  Future<bool> updateProductStatus(String productId, String status) async {
    try {
      await _productRepository.updateProductStatus(productId, status);
      return true;
    } catch (e) {
      debugPrint('Update product status error: $e');
      return false;
    }
  }

  // Update product quantity
  Future<bool> updateProductQuantity(String productId, int quantity) async {
    try {
      await _productRepository.updateProductQuantity(productId, quantity);
      return true;
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
    _setLoading(true);

    try {
      final products = await _productRepository.getProductsByCategory(
        category,
        page: page,
        limit: limit,
        status: status,
      );

      _setLoading(false);
      return products;
    } catch (e) {
      debugPrint('Get products by category error: $e');
      _setLoading(false);
      return [];
    }
  }

  // Get featured/popular products
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    try {
      return await _productRepository.getFeaturedProducts(limit: limit);
    } catch (e) {
      debugPrint('Get featured products error: $e');
      return [];
    }
  }

  // Get product categories
  Future<List<String>> getProductCategories() async {
    try {
      return await _productRepository.getProductCategories();
    } catch (e) {
      debugPrint('Get product categories error: $e');
      return [];
    }
  }

  // Get product units
  Future<List<String>> getProductUnits() async {
    try {
      return await _productRepository.getProductUnits();
    } catch (e) {
      debugPrint('Get product units error: $e');
      return [];
    }
  }

  // Get farmer statistics
  Future<Map<String, dynamic>> getFarmerStats(String farmerId) async {
    try {
      return await _productRepository.getFarmerStats(farmerId);
    } catch (e) {
      debugPrint('Get farmer stats error: $e');
      return {
        'productCount': 0,
        'totalRevenue': 0.0,
        'totalOrders': 0,
        'availableProducts': 0,
      };
    }
  }

  // Business logic helpers
  String generateProductId() {
    return 'prod_${DateTime.now().millisecondsSinceEpoch}';
  }

  String formatPrice(double price) {
    return '฿${price.toStringAsFixed(0)}';
  }

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

  bool validateProduct(Product product) {
    return product.title.isNotEmpty &&
        product.price > 0 &&
        product.quantity >= 0 &&
        product.farmerId.isNotEmpty;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
