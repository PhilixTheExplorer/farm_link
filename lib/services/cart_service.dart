import 'package:flutter/foundation.dart';
import '../models/cart.dart';
import '../services/api_service.dart';
import '../core/di/service_locator.dart';

class CartService extends ChangeNotifier {
  final ApiService _apiService = serviceLocator<ApiService>();
  Cart? _cart;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Cart? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _cart?.isEmpty ?? true;
  bool get isNotEmpty => _cart?.isNotEmpty ?? false;
  int get itemCount => _cart?.itemCount ?? 0;
  double get total => _cart?.total ?? 0.0;
  // Get cart items
  Future<void> loadCart() async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('CartService: Calling API getCart...');
      final response = await _apiService.getCart();
      debugPrint('CartService: API response: $response');
      if (response != null && response['success'] == true) {
        _cart = Cart.fromJson(response);
        debugPrint('Cart loaded: ${_cart!.itemCount} items');
      } else {
        // Empty cart or error - but don't treat as error if response is null (could be empty cart)
        debugPrint(
          'CartService: Empty cart or null response, setting empty cart',
        );
        _cart = const Cart(
          items: [],
          summary: CartSummary(itemCount: 0, subtotal: 0.0, total: 0.0),
        );
      }
    } catch (e) {
      debugPrint('Load cart error: $e');
      _setError('Failed to load cart: ${e.toString()}');
      // Set empty cart on error
      _cart = const Cart(
        items: [],
        summary: CartSummary(itemCount: 0, subtotal: 0.0, total: 0.0),
      );
    } finally {
      _setLoading(false);
    }
  }

  // Add item to cart
  Future<bool> addToCart(String productId, int quantity) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('Adding to cart: productId=$productId, quantity=$quantity');
      final response = await _apiService.addToCart(productId, quantity);
      debugPrint('Add to cart response: $response');

      if (response != null && response['success'] == true) {
        // Reload cart to get updated data
        await loadCart();
        debugPrint('Item added to cart successfully, cart reloaded');
        return true;
      } else {
        final errorMsg = response?['message'] ?? 'Failed to add item to cart';
        debugPrint('Add to cart failed: $errorMsg');
        _setError(errorMsg);
        return false;
      }
    } catch (e) {
      debugPrint('Add to cart error: $e');
      _setError('Failed to add item to cart: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update cart item quantity
  Future<bool> updateCartItem(String itemId, int quantity) async {
    if (quantity <= 0) {
      return await removeFromCart(itemId);
    }

    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.updateCartItem(itemId, quantity);

      if (response != null && response['success'] == true) {
        // Update local cart item
        if (_cart != null) {
          final updatedItems =
              _cart!.items.map((item) {
                if (item.id == itemId) {
                  return item.copyWith(quantity: quantity);
                }
                return item;
              }).toList();

          // Recalculate summary
          final newSubtotal = updatedItems.fold<double>(
            0.0,
            (sum, item) => sum + item.subtotal,
          );

          final newSummary = CartSummary(
            itemCount: updatedItems.length,
            subtotal: newSubtotal,
            total: newSubtotal,
          );

          _cart = Cart(items: updatedItems, summary: newSummary);
          notifyListeners();
        }

        debugPrint('Cart item updated');
        return true;
      } else {
        _setError('Failed to update cart item');
        return false;
      }
    } catch (e) {
      debugPrint('Update cart item error: $e');
      _setError('Failed to update cart item: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Remove item from cart
  Future<bool> removeFromCart(String itemId) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _apiService.removeFromCart(itemId);

      if (success) {
        // Remove item from local cart
        if (_cart != null) {
          final updatedItems =
              _cart!.items.where((item) => item.id != itemId).toList();

          // Recalculate summary
          final newSubtotal = updatedItems.fold<double>(
            0.0,
            (sum, item) => sum + item.subtotal,
          );

          final newSummary = CartSummary(
            itemCount: updatedItems.length,
            subtotal: newSubtotal,
            total: newSubtotal,
          );

          _cart = Cart(items: updatedItems, summary: newSummary);
          notifyListeners();
        }

        debugPrint('Item removed from cart');
        return true;
      } else {
        _setError('Failed to remove item from cart');
        return false;
      }
    } catch (e) {
      debugPrint('Remove from cart error: $e');
      _setError('Failed to remove item from cart: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Clear entire cart
  Future<bool> clearCart() async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _apiService.clearCart();

      if (success) {
        _cart = const Cart(
          items: [],
          summary: CartSummary(itemCount: 0, subtotal: 0.0, total: 0.0),
        );
        notifyListeners();
        debugPrint('Cart cleared');
        return true;
      } else {
        _setError('Failed to clear cart');
        return false;
      }
    } catch (e) {
      debugPrint('Clear cart error: $e');
      _setError('Failed to clear cart: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get cart summary
  Future<CartSummary?> getCartSummary() async {
    try {
      final response = await _apiService.getCartSummary();

      if (response != null && response['success'] == true) {
        return CartSummary.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Get cart summary error: $e');
      return null;
    }
  }

  // Checkout - Create order from cart
  Future<Map<String, dynamic>?> checkout({
    required String deliveryAddress,
    required String paymentMethod,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('CartService: Processing checkout...');
      final response = await _apiService.checkout(
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      debugPrint('CartService: Checkout response: $response');

      if (response != null && response['success'] == true) {
        // Clear cart after successful checkout
        _cart = const Cart(
          items: [],
          summary: CartSummary(itemCount: 0, subtotal: 0.0, total: 0.0),
        );
        notifyListeners();
        debugPrint('CartService: Checkout successful, cart cleared');
        return response;
      } else {
        final errorMsg = response?['message'] ?? 'Checkout failed';
        debugPrint('CartService: Checkout failed: $errorMsg');
        _setError(errorMsg);
        return response;
      }
    } catch (e) {
      debugPrint('CartService: Checkout error: $e');
      _setError('Checkout failed: ${e.toString()}');
      return {'success': false, 'message': 'Checkout failed: ${e.toString()}'};
    } finally {
      _setLoading(false);
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

  // Reset cart state
  void reset() {
    _cart = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
