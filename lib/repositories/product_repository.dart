import '../models/product.dart';
import '../services/product_service.dart';

class ProductRepository {
  static final ProductRepository _instance = ProductRepository._internal();
  factory ProductRepository() => _instance;
  ProductRepository._internal();

  final ProductService _productService = ProductService();
  // Get all products
  Future<List<Product>> getAllProducts() async {
    return await _productService.getAllProducts();
  }

  // Get products by farmer ID
  Future<List<Product>> getProductsByFarmerId(String farmerId) async {
    return await _productService.getFarmerProducts(farmerId);
  }

  // Get product by ID
  Future<Product?> getProductById(String productId) async {
    return await _productService.getProductById(productId);
  }

  // Add new product
  Future<bool> addProduct(Product product) async {
    return await _productService.addProduct(product);
  }

  // Update product
  Future<bool> updateProduct(Product updatedProduct) async {
    return await _productService.updateProduct(updatedProduct);
  }

  // Delete product
  Future<bool> deleteProduct(String productId) async {
    return await _productService.deleteProduct(productId);
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(ProductCategory category) async {
    return await _productService.getProductsByCategory(
      category.toString().split('.').last,
    );
  }

  // Search products
  Future<List<Product>> searchProducts(String query) async {
    return await _productService.searchProducts(query);
  }

  // Get farmer's total products count
  Future<int> getFarmerProductCount(String farmerId) async {
    final products = await _productService.getFarmerProducts(farmerId);
    return products.length;
  }

  // Get farmer's total revenue (sum of all orders)
  Future<double> getFarmerTotalRevenue(String farmerId) async {
    final stats = await _productService.getFarmerStats(farmerId);
    return stats['totalRevenue'] ?? 0.0;
  }

  // Get featured products
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    return await _productService.getFeaturedProducts(limit: limit);
  }

  // Update product status
  Future<bool> updateProductStatus(String productId, String status) async {
    return await _productService.updateProductStatus(productId, status);
  }

  // Update product quantity
  Future<bool> updateProductQuantity(String productId, int quantity) async {
    return await _productService.updateProductQuantity(productId, quantity);
  }

  // Get product categories
  Future<List<String>> getProductCategories() async {
    return await _productService.getProductCategories();
  }

  // Get product units
  Future<List<String>> getProductUnits() async {
    return await _productService.getProductUnits();
  }
}
