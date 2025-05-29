import '../models/cart.dart';
import '../models/order.dart';
import '../repositories/cart_repository.dart';
import '../repositories/product_repository.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final CartRepository _cartRepository = CartRepository();
  final ProductRepository _productRepository = ProductRepository();

  // Get or create active cart for buyer
  Future<Cart> getOrCreateActiveCart(String buyerId) async {
    Cart? activeCart = await _cartRepository.getActiveCart(buyerId);
    activeCart ??= await _cartRepository.createCart(buyerId);
    return activeCart;
  }

  // Add product to cart
  Future<bool> addProductToCart(
    String buyerId,
    String productId,
    int quantity,
  ) async {
    try {
      // Get product details to validate and get current price
      final product = await _productRepository.getProductById(productId);
      if (product == null || !product.isAvailable) {
        return false;
      }

      // Check if requested quantity is available
      if (quantity > product.quantity) {
        return false;
      }

      // Get or create active cart
      final cart = await getOrCreateActiveCart(buyerId);

      // Create cart item
      final cartItem = CartItem(
        id: 'cart_item_${DateTime.now().millisecondsSinceEpoch}',
        productId: productId,
        farmerId: product.farmerId,
        quantity: quantity,
        pricePerUnit: product.price, // Lock in current price
        addedDate: DateTime.now(),
      );

      // Add item to cart
      return await _cartRepository.addItemToCart(cart.id, cartItem);
    } catch (e) {
      return false;
    }
  }

  // Remove item from cart
  Future<bool> removeFromCart(String buyerId, String itemId) async {
    final cart = await _cartRepository.getActiveCart(buyerId);
    if (cart == null) return false;

    return await _cartRepository.removeItemFromCart(cart.id, itemId);
  }

  // Update item quantity in cart
  Future<bool> updateCartItemQuantity(
    String buyerId,
    String itemId,
    int newQuantity,
  ) async {
    final cart = await _cartRepository.getActiveCart(buyerId);
    if (cart == null) return false;

    return await _cartRepository.updateItemQuantity(
      cart.id,
      itemId,
      newQuantity,
    );
  }

  // Get buyer's active cart
  Future<Cart?> getBuyerActiveCart(String buyerId) async {
    return await _cartRepository.getActiveCart(buyerId);
  }

  // Clear cart
  Future<bool> clearCart(String buyerId) async {
    final cart = await _cartRepository.getActiveCart(buyerId);
    if (cart == null) return false;

    return await _cartRepository.clearCart(cart.id);
  }

  // Checkout cart
  Future<Order?> checkoutCart(
    String buyerId,
    String deliveryAddress, {
    String? notes,
  }) async {
    final cart = await _cartRepository.getActiveCart(buyerId);
    if (cart == null || cart.isEmpty) return null;

    return await _cartRepository.checkoutCart(
      cart.id,
      deliveryAddress,
      notes: notes,
    );
  }

  // Get cart with product details
  Future<Map<String, dynamic>?> getCartWithProductDetails(
    String buyerId,
  ) async {
    final cart = await _cartRepository.getActiveCart(buyerId);
    if (cart == null) return null;

    List<Map<String, dynamic>> itemsWithDetails = [];

    for (final item in cart.items) {
      final product = await _productRepository.getProductById(item.productId);
      if (product != null) {
        itemsWithDetails.add({
          'cartItem': item,
          'product': product,
          'subtotal': item.totalPrice,
        });
      }
    }

    return {
      'cart': cart,
      'items': itemsWithDetails,
      'summary': {
        'totalItems': cart.totalItems,
        'totalAmount': cart.totalAmount,
        'uniqueFarmers': cart.farmerIds.length,
        'itemsByFarmer': cart.itemsByFarmer,
      },
    };
  }

  // Get buyer order history
  Future<List<Order>> getBuyerOrderHistory(String buyerId) async {
    return await _cartRepository.getBuyerOrderHistory(buyerId);
  }

  // Get buyer statistics
  Future<Map<String, dynamic>> getBuyerStats(String buyerId) async {
    return await _cartRepository.getBuyerStats(buyerId);
  }

  // Validate cart before checkout
  Future<Map<String, dynamic>> validateCart(String buyerId) async {
    final cart = await _cartRepository.getActiveCart(buyerId);
    if (cart == null) {
      return {
        'isValid': false,
        'errors': ['No active cart found'],
      };
    }

    if (cart.isEmpty) {
      return {
        'isValid': false,
        'errors': ['Cart is empty'],
      };
    }

    List<String> errors = [];
    List<String> warnings = [];
    double updatedTotal = 0.0;

    for (final item in cart.items) {
      final product = await _productRepository.getProductById(item.productId);

      if (product == null) {
        errors.add('Product ${item.productId} is no longer available');
        continue;
      }

      if (!product.isAvailable) {
        errors.add('${product.title} is currently out of stock');
        continue;
      }

      if (item.quantity > product.quantity) {
        errors.add(
          'Only ${product.quantity} ${product.unit} of ${product.title} available (you have ${item.quantity} in cart)',
        );
        continue;
      }

      // Check for price changes
      if (item.pricePerUnit != product.price) {
        warnings.add(
          'Price of ${product.title} has changed from ฿${item.pricePerUnit} to ฿${product.price}',
        );
      }

      updatedTotal += product.price * item.quantity;
    }

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
      'warnings': warnings,
      'originalTotal': cart.totalAmount,
      'updatedTotal': updatedTotal,
      'hasChanges': warnings.isNotEmpty,
    };
  }

  // Get cart items grouped by farmer
  Future<Map<String, dynamic>?> getCartGroupedByFarmer(String buyerId) async {
    final cartData = await getCartWithProductDetails(buyerId);
    if (cartData == null) return null;

    final cart = cartData['cart'] as Cart;
    final items = cartData['items'] as List<Map<String, dynamic>>;

    Map<String, Map<String, dynamic>> groupedByFarmer = {};
    for (final itemData in items) {
      final cartItem = itemData['cartItem'] as CartItem;
      final farmerId = cartItem.farmerId;

      if (!groupedByFarmer.containsKey(farmerId)) {
        groupedByFarmer[farmerId] = {
          'farmerId': farmerId,
          'items': <Map<String, dynamic>>[],
          'total': 0.0,
        };
      }

      groupedByFarmer[farmerId]!['items'].add(itemData);
      groupedByFarmer[farmerId]!['total'] += itemData['subtotal'];
    }

    return {
      'cart': cart,
      'farmerGroups': groupedByFarmer.values.toList(),
      'summary': cartData['summary'],
    };
  }

  // Check if product is already in cart
  Future<CartItem?> getCartItemForProduct(
    String buyerId,
    String productId,
  ) async {
    final cart = await _cartRepository.getActiveCart(buyerId);
    if (cart == null) return null;

    try {
      return cart.items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  // Get cart item count for a specific product
  Future<int> getProductQuantityInCart(String buyerId, String productId) async {
    final cartItem = await getCartItemForProduct(buyerId, productId);
    return cartItem?.quantity ?? 0;
  }

  // Generate cart ID
  String generateCartId() {
    return 'cart_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Generate cart item ID
  String generateCartItemId() {
    return 'cart_item_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Format price for display
  String formatPrice(double price) {
    return '฿${price.toStringAsFixed(0)}';
  }

  // Calculate delivery fee (simple logic)
  double calculateDeliveryFee(double cartTotal) {
    if (cartTotal >= 500) {
      return 0.0; // Free delivery for orders over ฿500
    } else if (cartTotal >= 200) {
      return 30.0; // ฿30 for orders ฿200-499
    } else {
      return 50.0; // ฿50 for orders under ฿200
    }
  }

  // Get cart summary with delivery fee
  Future<Map<String, dynamic>?> getCartSummaryWithDelivery(
    String buyerId,
  ) async {
    final cartData = await getCartWithProductDetails(buyerId);
    if (cartData == null) return null;

    final cart = cartData['cart'] as Cart;
    final deliveryFee = calculateDeliveryFee(cart.totalAmount);
    final finalTotal = cart.totalAmount + deliveryFee;

    return {
      'cart': cart,
      'subtotal': cart.totalAmount,
      'deliveryFee': deliveryFee,
      'total': finalTotal,
      'itemCount': cart.totalItems,
      'farmerCount': cart.farmerIds.length,
      'freeDeliveryThreshold': 500.0,
      'amountForFreeDelivery':
          cart.totalAmount < 500 ? 500 - cart.totalAmount : 0.0,
    };
  }
}
