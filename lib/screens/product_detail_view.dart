import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../components/thai_button.dart';
import '../core/theme/app_colors.dart';
import '../core/router/app_router.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../providers/product_provider.dart';
import '../services/user_service.dart';
import '../core/di/service_locator.dart';

class ProductDetailView extends ConsumerStatefulWidget {
  final Product? product;

  const ProductDetailView({super.key, this.product});

  @override
  ConsumerState<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends ConsumerState<ProductDetailView> {
  final UserService _userService = serviceLocator<UserService>();

  @override
  void initState() {
    super.initState();
    // Initialize the product provider with the provided product
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(productDetailProvider(widget.product).notifier)
          .initialize(widget.product);
    });
  }

  void _addToCart() async {
    final success =
        await ref
            .read(productDetailProvider(widget.product).notifier)
            .addToCart();
    final productState = ref.read(productDetailProvider(widget.product));

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${productState.quantity}x ${productState.product!.title} added to cart',
          ),
          backgroundColor: AppColors.ricePaddyGreen,
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.white,
            onPressed: () {
              context.push(AppRoutes.cart);
            },
          ),
        ),
      );
    } else if (mounted && !success) {
      final errorMessage = productState.errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Failed to add to cart'),
          backgroundColor: AppColors.chilliRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productState = ref.watch(productDetailProvider(widget.product));

    // If product is not initialized, show loading
    if (productState.product == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final product = productState.product!;
    final subtotal = productState.subtotal;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(product.imageUrl, fit: BoxFit.cover),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.bambooCream.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.bambooCream.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_border),
                ),
                onPressed: () {
                  // Add to favorites
                },
              ),
              // Only show cart icon for buyers
              if (serviceLocator<UserService>().currentUserRole ==
                  UserRole.buyer)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.bambooCream.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_cart),
                  ),
                  onPressed: () {
                    context.push(AppRoutes.cart);
                  },
                ),
            ],
          ),

          // Product Details
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Chip
                  Chip(
                    label: Text(product.categoryDisplayName),
                    backgroundColor: AppColors.ricePaddyGreen.withOpacity(0.2),
                    labelStyle: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.ricePaddyGreen,
                      fontWeight: FontWeight.bold,
                    ),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),

                  const SizedBox(height: 8),

                  // Title and Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '฿${product.price.toStringAsFixed(0)}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppColors.tamarindBrown,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Stock
                  Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 16,
                        color: AppColors.palmAshGray,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${product.quantity} ${product.unit} available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.palmAshGray,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(product.description, style: theme.textTheme.bodyMedium),

                  const SizedBox(height: 24),

                  // Farmer Info (visible only if purchased)
                  if (productState.isPurchased) ...[
                    Text(
                      'Farmer Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bambooCream,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.palmAshGray.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(
                                  'https://images.unsplash.com/photo-1520466809213-7b9a56adcd45?ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Farmer Info',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      'Farmer ID: ${product.farmerId}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: AppColors.palmAshGray,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.phone),
                                  label: const Text('Call'),
                                  onPressed: () {
                                    // Call farmer - would need farmer service
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.tamarindBrown,
                                    side: const BorderSide(
                                      color: AppColors.tamarindBrown,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.email),
                                  label: const Text('Email'),
                                  onPressed: () {
                                    // Email farmer - would need farmer service
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.tamarindBrown,
                                    side: const BorderSide(
                                      color: AppColors.tamarindBrown,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Quantity Selector - visible only for buyers
                  if (_userService.currentUserRole == UserRole.buyer) ...[
                    Text(
                      'Quantity',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed:
                              productState.canDecrement
                                  ? () =>
                                      ref
                                          .read(
                                            productDetailProvider(
                                              widget.product,
                                            ).notifier,
                                          )
                                          .decrementQuantity()
                                  : null,
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.bambooCream,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.palmAshGray.withOpacity(0.3),
                              ),
                            ),
                            child: const Icon(Icons.remove, size: 16),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bambooCream,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.palmAshGray.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            productState.quantity.toString(),
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          onPressed:
                              productState.canIncrement
                                  ? () =>
                                      ref
                                          .read(
                                            productDetailProvider(
                                              widget.product,
                                            ).notifier,
                                          )
                                          .incrementQuantity()
                                  : null,
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.bambooCream,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.palmAshGray.withOpacity(0.3),
                              ),
                            ),
                            child: const Icon(Icons.add, size: 16),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Subtotal: ฿${subtotal.toStringAsFixed(0)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Add to Cart Button
                    ThaiButton(
                      label: 'Add to Cart',
                      onPressed:
                          productState.isAddingToCart ? null : _addToCart,
                      variant: ThaiButtonVariant.secondary,
                      icon: Icons.shopping_cart_outlined,
                      isLoading: productState.isAddingToCart,
                      isFullWidth: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
