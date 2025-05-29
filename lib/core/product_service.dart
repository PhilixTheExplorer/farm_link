import '../models/product.dart';
import '../repositories/product_repository.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final ProductRepository _productRepository = ProductRepository();

  // Get all products
  Future<List<Product>> getAllProducts() async {
    return await _productRepository.getAllProducts();
  }

  // Get products for a specific farmer
  Future<List<Product>> getFarmerProducts(String farmerId) async {
    return await _productRepository.getProductsByFarmerId(farmerId);
  }

  // Get product by ID
  Future<Product?> getProductById(String productId) async {
    return await _productRepository.getProductById(productId);
  }

  // Add new product
  Future<bool> addProduct(Product product) async {
    return await _productRepository.addProduct(product);
  }

  // Update product
  Future<bool> updateProduct(Product product) async {
    return await _productRepository.updateProduct(product);
  }

  // Delete product
  Future<bool> deleteProduct(String productId) async {
    return await _productRepository.deleteProduct(productId);
  }

  // Search products
  Future<List<Product>> searchProducts(String query) async {
    return await _productRepository.searchProducts(query);
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(ProductCategory category) async {
    return await _productRepository.getProductsByCategory(category);
  }

  // Get farmer statistics
  Future<Map<String, dynamic>> getFarmerStats(String farmerId) async {
    final productCount = await _productRepository.getFarmerProductCount(
      farmerId,
    );
    final totalRevenue = await _productRepository.getFarmerTotalRevenue(
      farmerId,
    );
    final averageRating = await _productRepository.getFarmerAverageRating(
      farmerId,
    );
    final products = await _productRepository.getProductsByFarmerId(farmerId);

    int totalOrders = 0;
    int availableProducts = 0;

    for (final product in products) {
      totalOrders += product.orderCount;
      if (product.isAvailable) {
        availableProducts++;
      }
    }

    return {
      'productCount': productCount,
      'totalRevenue': totalRevenue,
      'averageRating': averageRating,
      'totalOrders': totalOrders,
      'availableProducts': availableProducts,
    };
  }

  // Generate product ID
  String generateProductId() {
    return 'prod_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Helper method to format price
  String formatPrice(double price) {
    return '฿${price.toStringAsFixed(0)}';
  }

  // Helper method to get category icon
  String getCategoryIcon(ProductCategory category) {
    switch (category) {
      case ProductCategory.rice:
        return '🌾';
      case ProductCategory.fruits:
        return '🍎';
      case ProductCategory.vegetables:
        return '🥬';
      case ProductCategory.herbs:
        return '🌿';
      case ProductCategory.handmade:
        return '🧺';
      case ProductCategory.dairy:
        return '🥛';
      case ProductCategory.meat:
        return '🥩';
      case ProductCategory.other:
        return '📦';
    }
  }
}
