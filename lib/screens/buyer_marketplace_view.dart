import 'package:flutter/material.dart';
import '../components/farm_card.dart';
import '../components/app_drawer.dart';
import '../theme/app_colors.dart';

class BuyerMarketplaceView extends StatefulWidget {
  const BuyerMarketplaceView({super.key});

  @override
  State<BuyerMarketplaceView> createState() => _BuyerMarketplaceViewState();
}

class _BuyerMarketplaceViewState extends State<BuyerMarketplaceView> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sample categories
  final List<String> _categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Rice',
    'Handmade',
    'Organic',
  ];

  // Sample products
  final List<Map<String, dynamic>> _products = [
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1603833665858-e61d17a86224?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'title': 'Organic Rice',
      'price': '120',
      'description':
          'Freshly harvested jasmine rice from our farm in Chiang Mai.',
      'category': 'Rice',
      'quantity': '5',
      'unit': 'kg',
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1518977676601-b53f82aba655?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'title': 'Fresh Mangoes',
      'price': '80',
      'description':
          'Sweet and juicy mangoes, perfect for desserts or eating fresh.',
      'category': 'Fruits',
      'quantity': '10',
      'unit': 'pcs',
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'title': 'Handmade Basket',
      'price': '250',
      'description':
          'Traditional Thai bamboo basket, handcrafted by local artisans.',
      'category': 'Handmade',
      'quantity': '3',
      'unit': 'pcs',
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'title': 'Fresh Vegetables',
      'price': '60',
      'description':
          'Locally grown vegetables, pesticide-free and harvested daily.',
      'category': 'Vegetables',
      'quantity': '2',
      'unit': 'kg',
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1597362925123-77861d3fbac7?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'title': 'Organic Eggs',
      'price': '45',
      'description': 'Free-range eggs from our farm in Chiang Rai.',
      'category': 'Organic',
      'quantity': '1',
      'unit': 'dozen',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter products by category and search query
    final filteredProducts =
        _products.where((product) {
          final categoryMatch =
              _selectedCategory == 'All' ||
              product['category'] == _selectedCategory;
          final searchMatch =
              _searchQuery.isEmpty ||
              product['title']!.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              product['description']!.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
          return categoryMatch && searchMatch;
        }).toList();

    return Scaffold(
      drawer: AppDrawer(currentRoute: '/buyer-marketplace'),
      appBar: AppBar(
        title: const Text('FarmLink Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              // Navigate to cart
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: Column(
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

          // Category Filters
          Container(
            height: 56,
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
                filteredProducts.isEmpty
                    ? Center(
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
                            'Try selecting a different category',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.palmAshGray,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return FarmCard(
                          imageUrl: product['imageUrl']!,
                          title: product['title']!,
                          price: product['price']!,
                          description: product['description']!,
                          category: product['category']!,
                          quantity: product['quantity'],
                          unit: product['unit'],
                          showDescription: false,
                          onTap: () {
                            // Navigate to product detail
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Viewing ${product['title']}'),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
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
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Products',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                        // Sort by price low to high
                        Navigator.pop(context);
                      },
                      child: Text('Low to High'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Sort by price high to low
                        Navigator.pop(context);
                      },
                      child: Text('High to Low'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Apply Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
