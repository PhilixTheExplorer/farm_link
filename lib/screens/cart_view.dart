import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/thai_button.dart';
import '../components/thai_text_field.dart';
import '../components/app_drawer.dart';
import '../core/theme/app_colors.dart';
import '../core/router/app_router.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final _notesController = TextEditingController();
  bool _isLoading = false;

  // Sample cart items
  final List<Map<String, dynamic>> _cartItems = [
    {
      'id': '1',
      'imageUrl':
          'https://images.unsplash.com/photo-1603833665858-e61d17a86224?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'title': 'Organic Rice',
      'price': 120,
      'quantity': 2,
      'farmer': 'Somchai',
    },
    {
      'id': '2',
      'imageUrl':
          'https://images.unsplash.com/photo-1518977676601-b53f82aba655?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'title': 'Fresh Mangoes',
      'price': 80,
      'quantity': 3,
      'farmer': 'Malee',
    },
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity > 0) {
      setState(() {
        _cartItems[index]['quantity'] = newQuantity;
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removed from cart'),
        backgroundColor: AppColors.tamarindBrown,
      ),
    );
  }

  int get _totalPrice {
    return 100;
    // return _cartItems.fold(0, (sum, item) => sum + (item["price"] * item['quantity']).toInt());
  }

  void _checkout() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      // Navigate to order confirmation
      context.go(AppRoutes.orderConfirmation);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: AppDrawer(currentRoute: AppRoutes.cart),
      appBar: AppBar(title: const Text('Your Cart')),
      body:
          _cartItems.isEmpty
              ? Center(
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
                      onPressed: () => context.pop(),
                      variant: ThaiButtonVariant.secondary,
                      icon: Icons.shopping_bag_outlined,
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // Cart Items
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        final subtotal = item['price'] * item['quantity'];

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
                                  child: Image.network(
                                    item['imageUrl'],
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Product Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'],
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        'From ${item['farmer']}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: AppColors.palmAshGray,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            '฿${item['price']}',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  color:
                                                      AppColors.tamarindBrown,
                                                ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            '฿$subtotal',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          // Quantity Controls
                                          IconButton(
                                            onPressed:
                                                () => _updateQuantity(
                                                  index,
                                                  item['quantity'] - 1,
                                                ),
                                            icon: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: AppColors.bambooCream,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: AppColors.palmAshGray
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.remove,
                                                size: 16,
                                              ),
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              item['quantity'].toString(),
                                              style:
                                                  theme.textTheme.titleMedium,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed:
                                                () => _updateQuantity(
                                                  index,
                                                  item['quantity'] + 1,
                                                ),
                                            icon: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: AppColors.bambooCream,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: AppColors.palmAshGray
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.add,
                                                size: 16,
                                              ),
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),

                                          const Spacer(),

                                          // Remove Button
                                          IconButton(
                                            onPressed: () => _removeItem(index),
                                            icon: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: AppColors.chilliRed
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
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

                  // Order Notes
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
                              'Total (${_cartItems.length} items)',
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              '฿$_totalPrice',
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
                          isLoading: _isLoading,
                          isFullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
