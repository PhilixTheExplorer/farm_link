import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/farm_card.dart';
import '../components/app_drawer.dart';
import '../core/theme/app_colors.dart';
import '../core/router/app_router.dart';
import '../repositories/product_repository.dart';
import '../models/product.dart';

class BuyerMarketplaceView extends StatefulWidget {
  const BuyerMarketplaceView({super.key});

  @override
  State<BuyerMarketplaceView> createState() => _BuyerMarketplaceViewState();
}

class _BuyerMarketplaceViewState extends State<BuyerMarketplaceView> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  String? _errorMessage;
  String _sortOrder = 'none'; // 'none', 'price_asc', 'price_desc'
  List<Product> _products = [];
  final ProductRepository _productRepository = ProductRepository();

  // Categories mapped from ProductCategory enum
  final List<String> _categories = [
    'All',
    'Rice',
    'Fruits',
    'Vegetables',
    'Herbs',
    'Handmade',
    'Dairy',
    'Meat',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('Loading products from API...');
      final products = await _productRepository.getAllProducts();
      print('Loaded ${products.length} products');

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load products: ${e.toString()}';
      });
    }
  }

  Future<void> _refreshProducts() async {
    await _loadProducts();
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    var filtered =
        products.where((product) {
          // Category filter
          final categoryMatch =
              _selectedCategory == 'All' ||
              product.categoryDisplayName == _selectedCategory;

          // Search filter
          final searchMatch =
              _searchQuery.isEmpty ||
              product.title.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              product.description.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );

          // Only show available products
          final statusMatch = product.status == ProductStatus.available;

          return categoryMatch && searchMatch && statusMatch;
        }).toList();

    // Apply sorting
    if (_sortOrder == 'price_asc') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortOrder == 'price_desc') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: AppDrawer(currentRoute: AppRoutes.buyerMarketplace),
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProducts,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              context.push(AppRoutes.cart);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar and Filter
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bambooCream,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.palmAshGray.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Search Box
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.palmAshGray,
                        ),
                        suffixIcon:
                            _searchQuery.isNotEmpty
                                ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: AppColors.palmAshGray,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                                : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.palmAshGray,
                        ),
                      ),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Filter Button
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.ricePaddyGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // Show filter options
                        _showFilterBottomSheet(context);
                      },
                      icon: Icon(Icons.tune, color: Colors.white),
                      tooltip: 'Filter',
                    ),
                  ),
                ],
              ),
            ),

            // Category Filters - Use flexible height
            Container(
              constraints: const BoxConstraints(minHeight: 40, maxHeight: 60),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        }
                      },
                      backgroundColor: AppColors.bambooCream,
                      selectedColor: AppColors.ricePaddyGreen,
                      labelStyle: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            isSelected ? Colors.white : AppColors.charcoalBlack,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Products Grid/List
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.palmAshGray,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error Loading Products',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.palmAshGray,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.palmAshGray,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _refreshProducts,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                      : _buildProductsList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter & Sort Products',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Sort by Price',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _sortOrder = 'price_asc';
                            });
                            context.pop();
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                _sortOrder == 'price_asc'
                                    ? AppColors.ricePaddyGreen.withOpacity(0.1)
                                    : null,
                            side: BorderSide(
                              color:
                                  _sortOrder == 'price_asc'
                                      ? AppColors.ricePaddyGreen
                                      : AppColors.palmAshGray,
                            ),
                          ),
                          child: Text(
                            'Low to High',
                            style: TextStyle(
                              color:
                                  _sortOrder == 'price_asc'
                                      ? AppColors.ricePaddyGreen
                                      : null,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _sortOrder = 'price_desc';
                            });
                            context.pop();
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                _sortOrder == 'price_desc'
                                    ? AppColors.ricePaddyGreen.withOpacity(0.1)
                                    : null,
                            side: BorderSide(
                              color:
                                  _sortOrder == 'price_desc'
                                      ? AppColors.ricePaddyGreen
                                      : AppColors.palmAshGray,
                            ),
                          ),
                          child: Text(
                            'High to Low',
                            style: TextStyle(
                              color:
                                  _sortOrder == 'price_desc'
                                      ? AppColors.ricePaddyGreen
                                      : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _sortOrder = 'none';
                            });
                            context.pop();
                          },
                          child: Text('Clear Sort'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.pop();
                          },
                          child: Text('Done'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductsList() {
    final theme = Theme.of(context);
    final filteredProducts = _getFilteredProducts(_products);

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.palmAshGray,
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.palmAshGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'Try selecting a different category',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.palmAshGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return FarmCard(
            product: product,
            showDescription: false,
            onTap: () {
              // Navigate to product detail
              context.push(AppRoutes.productDetail, extra: product);
            },
          );
        },
      ),
    );
  }
}
