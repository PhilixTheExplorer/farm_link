import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../components/thai_button.dart';
import '../components/thai_text_field.dart';
import '../components/app_drawer.dart';
import '../core/theme/app_colors.dart';
import '../core/router/app_router.dart';
import '../providers/cart_provider.dart';

class CartView extends ConsumerStatefulWidget {
  const CartView({super.key});

  @override
  ConsumerState<CartView> createState() => _CartViewState();
}

class _CartViewState extends ConsumerState<CartView>
    with WidgetsBindingObserver {
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh cart when this page becomes active (e.g., navigating back from product detail)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshCart();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh cart when app resumes (e.g., coming back from product detail)
      _refreshCart();
    }
  }

  Future<void> _refreshCart() async {
    debugPrint('CartView: Refreshing cart...');
    await ref.read(cartProvider.notifier).refreshCart();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notesController.dispose();
    super.dispose();
  }

  void _updateQuantity(String itemId, int newQuantity) async {
    if (newQuantity > 0) {
      final success = await ref
          .read(cartProvider.notifier)
          .updateQuantity(itemId, newQuantity);
      if (!success && mounted) {
        final errorMessage = ref.read(cartProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Failed to update quantity'),
            backgroundColor: AppColors.chilliRed,
          ),
        );
      }
    }
  }

  void _removeItem(String itemId) async {
    final success = await ref
        .read(cartProvider.notifier)
        .removeFromCart(itemId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item removed from cart'),
            backgroundColor: AppColors.tamarindBrown,
          ),
        );
      } else {
        final errorMessage = ref.read(cartProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Failed to remove item'),
            backgroundColor: AppColors.chilliRed,
          ),
        );
      }
    }
  }

  void _checkout() async {
    final cartState = ref.read(cartProvider);
    if (cartState.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          backgroundColor: AppColors.chilliRed,
        ),
      );
      return;
    }

    // Navigate to order confirmation with cart data
    context.go(
      AppRoutes.orderConfirmation,
      extra: {'cart': cartState.cart, 'notes': _notesController.text},
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      drawer: AppDrawer(currentRoute: AppRoutes.cart),
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          if (cartState.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                debugPrint('CartView: Manual refresh triggered');
                _refreshCart();
              },
              tooltip: 'Refresh Cart',
            ),
        ],
      ),
      body: _buildBody(context, cartState),
    );
  }

  Widget _buildBody(BuildContext context, CartState cartState) {
    final theme = Theme.of(context);

    if (cartState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cartState.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: AppColors.palmAshGray,
            ),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.palmAshGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some products to your cart',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.palmAshGray,
              ),
            ),
            const SizedBox(height: 24),
            ThaiButton(
              label: 'Continue Shopping',
              onPressed: () => context.go(AppRoutes.buyerMarketplace),
              variant: ThaiButtonVariant.secondary,
              icon: Icons.shopping_bag_outlined,
            ),
          ],
        ),
      );
    }

    final cart = cartState.cart!;
    return RefreshIndicator(
      onRefresh: () async {
        debugPrint('CartView: Pull-to-refresh triggered');
        await _refreshCart();
      },
      child: Column(
        children: [
          // Cart Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final cartItem = cart.items[index];
                final product = cartItem.product;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              product.imageUrl.isNotEmpty
                                  ? Image.network(
                                    product.imageUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        color: AppColors.bambooCream,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          color: AppColors.palmAshGray,
                                        ),
                                      );
                                    },
                                  )
                                  : Container(
                                    width: 80,
                                    height: 80,
                                    color: AppColors.bambooCream,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: AppColors.palmAshGray,
                                    ),
                                  ),
                        ),

                        const SizedBox(width: 16),

                        // Product Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'From ${product.farmerName}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.palmAshGray,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '฿${product.price.toStringAsFixed(0)}',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: AppColors.tamarindBrown,
                                        ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '฿${cartItem.subtotal.toStringAsFixed(0)}',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  // Quantity Controls
                                  _buildQuantityButton(
                                    Icons.remove,
                                    () => _updateQuantity(
                                      cartItem.id,
                                      cartItem.quantity - 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Text(
                                      cartItem.quantity.toString(),
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ),
                                  _buildQuantityButton(
                                    Icons.add,
                                    () => _updateQuantity(
                                      cartItem.id,
                                      cartItem.quantity + 1,
                                    ),
                                  ),

                                  const Spacer(),

                                  // Remove Button
                                  IconButton(
                                    onPressed: () => _removeItem(cartItem.id),
                                    icon: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.chilliRed.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.delete_outline,
                                        size: 16,
                                        color: AppColors.chilliRed,
                                      ),
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Order Notes and Checkout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bambooCream,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notes Field
                ThaiTextField(
                  label: 'Order Notes (Optional)',
                  hintText: 'E.g., "No plastic", "Please call at gate"',
                  controller: _notesController,
                  maxLines: 2,
                ),

                const SizedBox(height: 16),

                // Order Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total (${cart.summary.itemCount} items)',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      '฿${cart.total.toStringAsFixed(0)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.tamarindBrown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Checkout Button
                ThaiButton(
                  label: 'Checkout',
                  onPressed: _checkout,
                  variant: ThaiButtonVariant.secondary,
                  icon: Icons.shopping_cart_checkout,
                  isLoading: cartState.isPerformingAction,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.bambooCream,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.palmAshGray.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 16),
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
