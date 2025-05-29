import 'package:flutter/material.dart';
import '../components/thai_button.dart';
import '../theme/app_colors.dart';

class ProductDetailView extends StatefulWidget {
  final Map<String, dynamic>? product;

  const ProductDetailView({
    super.key,
    this.product,
  });

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  int _quantity = 1;
  bool _isPurchased = false;

  // Sample product data if none provided
  final Map<String, dynamic> _defaultProduct = {
    'imageUrl': 'https://images.unsplash.com/photo-1603833665858-e61d17a86224?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
    'title': 'Organic Rice',
    'price': '120',
    'description': 'Freshly harvested jasmine rice from our farm in Chiang Mai. This premium quality rice is grown using traditional farming methods without chemical pesticides or fertilizers. Perfect for everyday meals or special occasions.',
    'category': 'Rice',
    'stock': 50,
    'farmer': {
      'name': 'Somchai',
      'location': 'Chiang Mai',
      'phone': '+66 81 234 5678',
      'email': 'somchai@farmlink.com',
    },
  };

  Map<String, dynamic> get _product => widget.product ?? _defaultProduct;

  void _incrementQuantity() {
    if (_quantity < _product['stock']) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _addToCart() {
    // Simulate adding to cart
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_quantity}x ${_product['title']} added to cart'),
        backgroundColor: AppColors.ricePaddyGreen,
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to cart
            Navigator.pushNamed(context, '/cart');
          },
        ),
      ),
    );
    
    // For demo purposes, set as purchased to show farmer info
    setState(() {
      _isPurchased = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtotal = int.parse(_product['price']) * _quantity;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                _product['imageUrl'],
                fit: BoxFit.cover,
              ),
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
              onPressed: () => Navigator.pop(context),
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
                  // Share product
                },
              ),
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
                  // Add to favorites
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
                    label: Text(_product['category']),
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
                          _product['title'],
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '฿${_product['price']}',
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
                        '${_product['stock']} available',
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
                  Text(
                    _product['description'],
                    style: theme.textTheme.bodyMedium,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Farmer Info (visible only if purchased)
                  if (_isPurchased) ...[
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
                                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1520466809213-7b9a56adcd45?ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80'),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _product['farmer']['name'],
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _product['farmer']['location'],
                                      style: theme.textTheme.bodyMedium?.copyWith(
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
                                    // Call farmer
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.tamarindBrown,
                                    side: const BorderSide(color: AppColors.tamarindBrown),
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
                                    // Email farmer
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.tamarindBrown,
                                    side: const BorderSide(color: AppColors.tamarindBrown),
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
                  
                  // Quantity Selector
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
                        onPressed: _decrementQuantity,
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.bambooCream,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.palmAshGray.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          _quantity.toString(),
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        onPressed: _incrementQuantity,
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
                        'Subtotal: ฿$subtotal',
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
                    onPressed: _addToCart,
                    variant: ThaiButtonVariant.secondary,
                    icon: Icons.shopping_cart_outlined,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
