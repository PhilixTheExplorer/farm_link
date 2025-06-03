import 'package:flutter/foundation.dart';
import '../models/product.dart';
import 'api_service.dart';

// Cart item model for local representation
class CartItem {
  final String id;
  final String productId;
  final Product product;
  final int quantity;
  final DateTime addedDate;

  CartItem({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.addedDate,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['product_id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
      addedDate: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product': product.toJson(),
      'quantity': quantity,
      'created_at': addedDate.toIso8601String(),
    };
  }

  double get subtotal => product.price * quantity;

  CartItem copyWith({
    String? id,
    String? productId,
    Product? product,
    int? quantity,
    DateTime? addedDate,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedDate: addedDate ?? this.addedDate,
    );
  }
}

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final ApiService _apiService = ApiService();

  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  double _totalAmount = 0.0;
  int _totalItems = 0;

  // Getters
  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  double get totalAmount => _totalAmount;
  int get totalItems => _totalItems;
  int get itemCount => _cartItems.length;
  bool get isEmpty => _cartItems.isEmpty;
  bool get isNotEmpty => _cartItems.isNotEmpty;

  // Load cart items from backend
  Future<void> loadCartItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getCartItems();

      if (response != null && response['success'] == true) {
        final List<dynamic> itemsData = response['data']['items'];
        _cartItems = itemsData.map((json) => CartItem.fromJson(json)).toList();
        _calculateTotals();
      }
    } catch (e) {
      debugPrint('Load cart items error: $e');
      _cartItems = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add item to cart
  Future<bool> addToCart(String productId, int quantity) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.addToCart(productId, quantity);

      if (response != null && response['success'] == true) {
        // Reload cart to get updated data
        await loadCartItems();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Add to cart error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Update cart item quantity
  Future<bool> updateItemQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      return await removeFromCart(itemId);
    }

    try {
      final success = await _apiService.updateCartItemQuantity(
        itemId,
        quantity,
      );

      if (success) {
        // Update local state
        final itemIndex = _cartItems.indexWhere((item) => item.id == itemId);
        if (itemIndex != -1) {
          _cartItems[itemIndex] = _cartItems[itemIndex].copyWith(
            quantity: quantity,
          );
          _calculateTotals();
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      debugPrint('Update cart item quantity error: $e');
    }
    return false;
  }

  // Remove item from cart
  Future<bool> removeFromCart(String itemId) async {
    try {
      final success = await _apiService.removeFromCart(itemId);

      if (success) {
        // Update local state
        _cartItems.removeWhere((item) => item.id == itemId);
        _calculateTotals();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Remove from cart error: $e');
    }
    return false;
  }

  // Clear entire cart
  Future<bool> clearCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _apiService.clearCart();

      if (success) {
        _cartItems.clear();
        _calculateTotals();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Clear cart error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Get cart summary
  Future<Map<String, dynamic>?> getCartSummary() async {
    try {
      final response = await _apiService.getCartSummary();

      if (response != null && response['success'] == true) {
        return response['data'];
      }
    } catch (e) {
      debugPrint('Get cart summary error: $e');
    }
    return null;
  }

  // Checkout (create order from cart)
  Future<Map<String, dynamic>?> checkout({
    required String deliveryAddress,
    required String paymentMethod,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.checkout(
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      if (response != null && response['success'] == true) {
        // Clear cart after successful checkout
        _cartItems.clear();
        _calculateTotals();
        _isLoading = false;
        notifyListeners();
        return response['data'];
      }
    } catch (e) {
      debugPrint('Checkout error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  // Check if product is in cart
  bool isProductInCart(String productId) {
    return _cartItems.any((item) => item.productId == productId);
  }

  // Get cart item for a specific product
  CartItem? getCartItem(String productId) {
    try {
      return _cartItems.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  // Get quantity of a specific product in cart
  int getProductQuantityInCart(String productId) {
    final cartItem = getCartItem(productId);
    return cartItem?.quantity ?? 0;
  }

  // Calculate totals
  void _calculateTotals() {
    _totalAmount = _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);
    _totalItems = _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  // Format price helper
  String formatPrice(double price) {
    return '฿${price.toStringAsFixed(0)}';
  }

  // Get formatted total
  String get formattedTotal => formatPrice(_totalAmount);
}
