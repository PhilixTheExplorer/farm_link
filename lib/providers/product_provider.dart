import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';

// Product Detail State
@immutable
class ProductDetailState {
  final Product? product;
  final int quantity;
  final bool isAddingToCart;
  final bool isPurchased; // For demo purposes to show farmer info
  final String? errorMessage;

  const ProductDetailState({
    this.product,
    this.quantity = 1,
    this.isAddingToCart = false,
    this.isPurchased = false,
    this.errorMessage,
  });

  ProductDetailState copyWith({
    Product? product,
    int? quantity,
    bool? isAddingToCart,
    bool? isPurchased,
    String? errorMessage,
  }) {
    return ProductDetailState(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      isAddingToCart: isAddingToCart ?? this.isAddingToCart,
      isPurchased: isPurchased ?? this.isPurchased,
      errorMessage: errorMessage,
    );
  }

  // Computed properties
  double get subtotal => (product?.price ?? 0.0) * quantity;
  bool get canIncrement => product != null && quantity < product!.quantity;
  bool get canDecrement => quantity > 1;
}

// Product Detail ViewModel
class ProductDetailViewModel extends StateNotifier<ProductDetailState> {
  final Ref _ref;

  ProductDetailViewModel(this._ref, Product? product)
    : super(ProductDetailState(product: product));

  // Default product for demo purposes
  static final Product _defaultProduct = Product(
    id: 'sample_1',
    farmerId: 'farmer_1',
    title: 'Organic Rice',
    description:
        'Freshly harvested jasmine rice from our farm in Chiang Mai. This premium quality rice is grown using traditional farming methods without chemical pesticides or fertilizers. Perfect for everyday meals or special occasions.',
    price: 120.0,
    category: ProductCategory.rice,
    quantity: 50,
    unit: 'kg',
    imageUrl:
        'https://images.unsplash.com/photo-1603833665858-e61d17a86224?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
    status: ProductStatus.available,
    createdDate: DateTime.now(),
    orderCount: 0,
  );

  // Initialize with product or default
  void initialize(Product? product) {
    state = state.copyWith(
      product: product ?? _defaultProduct,
      quantity: 1,
      isAddingToCart: false,
      isPurchased: false,
      errorMessage: null,
    );
  }

  // Increment quantity
  void incrementQuantity() {
    if (state.canIncrement) {
      state = state.copyWith(quantity: state.quantity + 1);
    }
  }

  // Decrement quantity
  void decrementQuantity() {
    if (state.canDecrement) {
      state = state.copyWith(quantity: state.quantity - 1);
    }
  }

  // Set specific quantity
  void setQuantity(int quantity) {
    if (quantity >= 1 &&
        state.product != null &&
        quantity <= state.product!.quantity) {
      state = state.copyWith(quantity: quantity);
    }
  }

  // Add to cart
  Future<bool> addToCart() async {
    if (state.product == null || state.isAddingToCart) {
      return false;
    }

    debugPrint('=== Add to Cart Debug Info ===');
    debugPrint('Product ID: ${state.product!.id}');
    debugPrint('Product ID length: ${state.product!.id.length}');
    debugPrint('Product ID type: ${state.product!.id.runtimeType}');
    debugPrint('Quantity: ${state.quantity}');

    // Additional validation
    if (state.product!.id.isEmpty) {
      debugPrint('ERROR: Product ID is empty!');
      state = state.copyWith(
        errorMessage: 'Invalid product - cannot add to cart',
      );
      return false;
    }

    state = state.copyWith(isAddingToCart: true, errorMessage: null);

    try {
      // Use cart provider to add item
      final cartViewModel = _ref.read(cartProvider.notifier);
      final success = await cartViewModel.addToCart(
        state.product!.id,
        state.quantity,
      );

      if (success) {
        // For demo purposes, set as purchased to show farmer info
        state = state.copyWith(isAddingToCart: false, isPurchased: true);
        debugPrint('ProductDetailViewModel: Item added successfully');
      } else {
        // Get error from cart provider
        final cartState = _ref.read(cartProvider);
        state = state.copyWith(
          isAddingToCart: false,
          errorMessage: cartState.errorMessage ?? 'Failed to add to cart',
        );
      }

      return success;
    } catch (e) {
      debugPrint('ProductDetailViewModel: Error adding to cart: $e');
      state = state.copyWith(
        isAddingToCart: false,
        errorMessage: 'Failed to add to cart: ${e.toString()}',
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

// Product Detail Provider Factory
final productDetailProvider = StateNotifierProvider.family<
  ProductDetailViewModel,
  ProductDetailState,
  Product?
>((ref, product) => ProductDetailViewModel(ref, product));
