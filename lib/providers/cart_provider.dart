import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';
import '../core/di/service_locator.dart';

// Cart State class
@immutable
class CartState {
  final Cart? cart;
  final bool isLoading;
  final bool isPerformingAction; // For add/update/remove operations
  final String? errorMessage;

  const CartState({
    this.cart,
    this.isLoading = false,
    this.isPerformingAction = false,
    this.errorMessage,
  });

  CartState copyWith({
    Cart? cart,
    bool? isLoading,
    bool? isPerformingAction,
    String? errorMessage,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      isLoading: isLoading ?? this.isLoading,
      isPerformingAction: isPerformingAction ?? this.isPerformingAction,
      errorMessage: errorMessage,
    );
  }

  // Computed properties
  bool get isEmpty => cart?.isEmpty ?? true;
  bool get isNotEmpty => cart?.isNotEmpty ?? false;
  int get itemCount => cart?.itemCount ?? 0;
  double get total => cart?.total ?? 0.0;
}

// Cart ViewModel (Notifier)
class CartViewModel extends StateNotifier<CartState> {
  final CartService _cartService = serviceLocator<CartService>();

  CartViewModel() : super(const CartState()) {
    // Initialize by loading cart
    _loadCart();
  }

  // Load cart data
  Future<void> _loadCart() async {
    if (state.isLoading) return; // Prevent multiple simultaneous loads

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      debugPrint('CartViewModel: Loading cart...');
      await _cartService.loadCart();

      state = state.copyWith(cart: _cartService.cart, isLoading: false);

      debugPrint(
        'CartViewModel: Cart loaded successfully, items: ${state.itemCount}',
      );
    } catch (e) {
      debugPrint('CartViewModel: Error loading cart: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load cart: ${e.toString()}',
      );
    }
  }

  // Refresh cart (for pull-to-refresh)
  Future<void> refreshCart() async {
    await _loadCart();
  }

  // Add item to cart
  Future<bool> addToCart(String productId, int quantity) async {
    if (state.isPerformingAction) return false;

    state = state.copyWith(isPerformingAction: true, errorMessage: null);

    try {
      debugPrint(
        'CartViewModel: Adding to cart - Product: $productId, Quantity: $quantity',
      );
      final success = await _cartService.addToCart(productId, quantity);

      if (success) {
        // Reload cart to get updated data
        await _cartService.loadCart();
        state = state.copyWith(
          cart: _cartService.cart,
          isPerformingAction: false,
        );
        debugPrint('CartViewModel: Item added successfully');
      } else {
        state = state.copyWith(
          isPerformingAction: false,
          errorMessage:
              _cartService.errorMessage ?? 'Failed to add item to cart',
        );
      }

      return success;
    } catch (e) {
      debugPrint('CartViewModel: Error adding to cart: $e');
      state = state.copyWith(
        isPerformingAction: false,
        errorMessage: 'Failed to add item to cart: ${e.toString()}',
      );
      return false;
    }
  }

  // Update item quantity
  Future<bool> updateQuantity(String cartItemId, int newQuantity) async {
    if (state.isPerformingAction) return false;

    state = state.copyWith(isPerformingAction: true, errorMessage: null);

    try {
      debugPrint(
        'CartViewModel: Updating quantity - Item: $cartItemId, Quantity: $newQuantity',
      );
      final success = await _cartService.updateCartItem(
        cartItemId,
        newQuantity,
      );

      if (success) {
        // Reload cart to get updated data
        await _cartService.loadCart();
        state = state.copyWith(
          cart: _cartService.cart,
          isPerformingAction: false,
        );
        debugPrint('CartViewModel: Quantity updated successfully');
      } else {
        state = state.copyWith(
          isPerformingAction: false,
          errorMessage:
              _cartService.errorMessage ?? 'Failed to update quantity',
        );
      }

      return success;
    } catch (e) {
      debugPrint('CartViewModel: Error updating quantity: $e');
      state = state.copyWith(
        isPerformingAction: false,
        errorMessage: 'Failed to update quantity: ${e.toString()}',
      );
      return false;
    }
  }

  // Remove item from cart
  Future<bool> removeFromCart(String cartItemId) async {
    if (state.isPerformingAction) return false;

    state = state.copyWith(isPerformingAction: true, errorMessage: null);

    try {
      debugPrint('CartViewModel: Removing from cart - Item: $cartItemId');
      final success = await _cartService.removeFromCart(cartItemId);

      if (success) {
        // Reload cart to get updated data
        await _cartService.loadCart();
        state = state.copyWith(
          cart: _cartService.cart,
          isPerformingAction: false,
        );
        debugPrint('CartViewModel: Item removed successfully');
      } else {
        state = state.copyWith(
          isPerformingAction: false,
          errorMessage: _cartService.errorMessage ?? 'Failed to remove item',
        );
      }

      return success;
    } catch (e) {
      debugPrint('CartViewModel: Error removing from cart: $e');
      state = state.copyWith(
        isPerformingAction: false,
        errorMessage: 'Failed to remove item: ${e.toString()}',
      );
      return false;
    }
  }

  // Clear entire cart
  Future<bool> clearCart() async {
    if (state.isPerformingAction) return false;

    state = state.copyWith(isPerformingAction: true, errorMessage: null);

    try {
      debugPrint('CartViewModel: Clearing cart');
      final success = await _cartService.clearCart();

      if (success) {
        // Reload cart to get updated data
        await _cartService.loadCart();
        state = state.copyWith(
          cart: _cartService.cart,
          isPerformingAction: false,
        );
        debugPrint('CartViewModel: Cart cleared successfully');
      } else {
        state = state.copyWith(
          isPerformingAction: false,
          errorMessage: _cartService.errorMessage ?? 'Failed to clear cart',
        );
      }

      return success;
    } catch (e) {
      debugPrint('CartViewModel: Error clearing cart: $e');
      state = state.copyWith(
        isPerformingAction: false,
        errorMessage: 'Failed to clear cart: ${e.toString()}',
      );
      return false;
    }
  }

  // Clear error message
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}

// Cart Provider
final cartProvider = StateNotifierProvider<CartViewModel, CartState>((ref) {
  return CartViewModel();
});

// Convenience providers for commonly used values
final cartItemCountProvider = Provider<int>((ref) {
  final cartState = ref.watch(cartProvider);
  return cartState.itemCount;
});

final cartTotalProvider = Provider<double>((ref) {
  final cartState = ref.watch(cartProvider);
  return cartState.total;
});

final cartIsEmptyProvider = Provider<bool>((ref) {
  final cartState = ref.watch(cartProvider);
  return cartState.isEmpty;
});
