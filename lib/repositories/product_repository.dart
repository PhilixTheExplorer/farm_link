import '../models/product.dart';
import '../services/api_service.dart';
import '../core/di/service_locator.dart';

class ProductRepository {
  final ApiService _apiService = serviceLocator<ApiService>();

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
    final response = await _apiService.getProducts(
      page: page,
      limit: limit,
      search: search,
      category: category,
      status: status,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );

    if (response != null && response['success'] == true) {
      final List<dynamic> productsData = response['data'];
      return productsData.map((json) => Product.fromJson(json)).toList();
    }

    throw Exception('Failed to get products');
  }

  // Get products for a specific farmer
  Future<List<Product>> getProductsByFarmerId(
    String farmerId, {
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final response = await _apiService.getProductsByFarmer(
      farmerId,
      page: page,
      limit: limit,
      status: status,
    );

    if (response != null && response['success'] == true) {
      final List<dynamic> productsData = response['data'];
      return productsData.map((json) => Product.fromJson(json)).toList();
    }

    throw Exception('Failed to get farmer products');
  }

  // Get product by ID
  Future<Product?> getProductById(String productId) async {
    final response = await _apiService.getProductById(productId);

    if (response != null && response['success'] == true) {
      return Product.fromJson(response['data']);
    }

    return null;
  }

  // Add new product
  Future<Product> addProduct(Product product) async {
    final response = await _apiService.createProduct(product.toCreateJson());

    if (response != null && response['success'] == true) {
      return Product.fromJson(response['data']);
    }

    throw Exception('Failed to create product');
  }

  // Update product
  Future<Product> updateProduct(Product product) async {
    final success = await _apiService.updateProduct(
      product.id,
      product.toJson(),
    );

    if (!success) {
      throw Exception('Failed to update product');
    }

    return product;
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    final success = await _apiService.deleteProduct(productId);

    if (!success) {
      throw Exception('Failed to delete product');
    }
  }

  // Update product status
  Future<void> updateProductStatus(String productId, String status) async {
    final success = await _apiService.updateProductStatus(productId, status);

    if (!success) {
      throw Exception('Failed to update product status');
    }
  }

  // Update product quantity
  Future<void> updateProductQuantity(String productId, int quantity) async {
    final success = await _apiService.updateProductQuantity(
      productId,
      quantity,
    );

    if (!success) {
      throw Exception('Failed to update product quantity');
    }
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(
    String category, {
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    final response = await _apiService.getProductsByCategory(
      category,
      page: page,
      limit: limit,
      status: status,
    );

    if (response != null && response['success'] == true) {
      final List<dynamic> productsData = response['data']['products'];
      return productsData.map((json) => Product.fromJson(json)).toList();
    }

    throw Exception('Failed to get products by category');
  }

  // Get featured/popular products
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    final response = await _apiService.getFeaturedProducts(limit: limit);

    if (response != null && response['success'] == true) {
      final List<dynamic> productsData = response['data'];
      return productsData.map((json) => Product.fromJson(json)).toList();
    }

    return [];
  }

  // Get product categories
  Future<List<String>> getProductCategories() async {
    final categories = await _apiService.getProductCategories();
    return categories ?? [];
  }

  // Get product units
  Future<List<String>> getProductUnits() async {
    final units = await _apiService.getProductUnits();
    return units ?? [];
  }

  // Get farmer statistics
  Future<Map<String, dynamic>> getFarmerStats(String farmerId) async {
    // Get products to calculate stats
    final products = await getProductsByFarmerId(farmerId);

    int productCount = products.length;
    int totalOrders = 0;
    int availableProducts = 0;
    double totalRevenue = 0.0;

    for (final product in products) {
      totalOrders += product.orderCount;
      if (product.isAvailable) {
        availableProducts++;
      }
      totalRevenue += product.price * product.orderCount;
    }

    return {
      'productCount': productCount,
      'totalRevenue': totalRevenue,
      'totalOrders': totalOrders,
      'availableProducts': availableProducts,
    };
  }
}
