import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/farmer.dart';
import '../services/user_service.dart';
import '../services/product_service.dart';
import '../core/di/service_locator.dart';

class FarmerDashboardViewModel extends ChangeNotifier {
  final UserService _userService = serviceLocator<UserService>();
  final ProductService _productService = serviceLocator<ProductService>();

  List<Product> _products = [];
  Map<String, dynamic> _farmerStats = {};
  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  List<Product> get products => _products;
  Map<String, dynamic> get farmerStats => _farmerStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Farmer? get farmer => _userService.farmerData;
  bool get hasFarmer => farmer != null;

  // Initialize the dashboard
  Future<void> initialize() async {
    await loadFarmerData();
  }

  // Load farmer data including products and stats
  Future<void> loadFarmerData() async {
    if (!hasFarmer) {
      _setLoading(false);
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final farmerId = farmer!.id;

      // Load products and stats in parallel
      final results = await Future.wait([
        _productService.getFarmerProducts(farmerId),
        _productService.getFarmerStats(farmerId),
      ]);

      _products = results[0] as List<Product>;
      _farmerStats = results[1] as Map<String, dynamic>;

      debugPrint('Loaded ${_products.length} products for farmer $farmerId');
      debugPrint('Farmer stats: $_farmerStats');
    } catch (e) {
      _setError('Failed to load farmer data: ${e.toString()}');
      debugPrint('Error loading farmer data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh data (pull-to-refresh or manual refresh)
  Future<void> refresh() async {
    await loadFarmerData();
  }

  // Get product count
  int get productCount => _products.length;

  // Get available products count
  int get availableProductsCount =>
      _products.where((p) => p.status == ProductStatus.available).length;

  // Get total revenue from stats
  double get totalRevenue => (_farmerStats['totalRevenue'] ?? 0.0).toDouble();

  // Get total orders from stats
  int get totalOrders => _farmerStats['totalOrders'] ?? 0;

  // Check if farmer has products
  bool get hasProducts => _products.isNotEmpty;

  // Get welcome message
  String get welcomeMessage {
    final firstName = farmer?.name?.split(' ').first ?? 'Farmer';
    return 'Welcome, $firstName!';
  }

  // Get products summary message
  String get productsSummaryMessage {
    final count = productCount;
    if (count == 0) {
      return 'No products listed yet';
    } else if (count == 1) {
      return 'You have 1 product listed';
    } else {
      return 'You have $count products listed';
    }
  }

  // Filter products by status
  List<Product> getProductsByStatus(ProductStatus status) {
    return _products.where((p) => p.status == status).toList();
  }

  // Get recent products (last 5)
  List<Product> get recentProducts {
    final sorted = List<Product>.from(_products);
    sorted.sort((a, b) => b.createdDate.compareTo(a.createdDate));
    return sorted.take(5).toList();
  }

  // Search products
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;

    final lowercaseQuery = query.toLowerCase();
    return _products.where((product) {
      return product.title.toLowerCase().contains(lowercaseQuery) ||
          product.description.toLowerCase().contains(lowercaseQuery) ||
          product.category.toString().toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Sort products
  void sortProducts(ProductSortType sortType) {
    switch (sortType) {
      case ProductSortType.name:
        _products.sort((a, b) => a.title.compareTo(b.title));
        break;
      case ProductSortType.price:
        _products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortType.quantity:
        _products.sort((a, b) => a.quantity.compareTo(b.quantity));
        break;
      case ProductSortType.dateCreated:
        _products.sort((a, b) => b.createdDate.compareTo(a.createdDate));
        break;
      case ProductSortType.status:
        _products.sort(
          (a, b) => a.status.toString().compareTo(b.status.toString()),
        );
        break;
    }
    notifyListeners();
  }

  // Add a new product to the local list (for immediate UI update)
  void addProductToList(Product product) {
    _products.insert(0, product); // Add to beginning of list
    notifyListeners();
  }

  // Remove a product from the local list
  void removeProductFromList(String productId) {
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  // Update a product in the local list
  void updateProductInList(Product updatedProduct) {
    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      notifyListeners();
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Handle product upload completion (call this after successful upload)
  Future<void> onProductUploaded() async {
    debugPrint('Product uploaded successfully, refreshing dashboard...');
    await refresh();
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Enum for product sorting
enum ProductSortType { name, price, quantity, dateCreated, status }
