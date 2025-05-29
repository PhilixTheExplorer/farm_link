import 'package:flutter/material.dart';
import '../components/farm_card.dart';
import '../components/story_circle.dart';
import '../theme/app_colors.dart';

class BuyerMarketplaceView extends StatefulWidget {
  const BuyerMarketplaceView({Key? key}) : super(key: key);

  @override
  State<BuyerMarketplaceView> createState() => _BuyerMarketplaceViewState();
}

class _BuyerMarketplaceViewState extends State<BuyerMarketplaceView> {
  bool _isGridView = true;
  String _selectedCategory = 'All';

  // Sample categories
  final List<String> _categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Rice',
    'Handmade',
    'Organic',
  ];

  // Sample farmers for stories
  final List<Map<String, dynamic>> _farmers = [
    {
      'name': 'Somchai',
      'imageUrl':
          'https://images.unsplash.com/photo-1520466809213-7b9a56adcd45?ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80',
      'isViewed': false,
    },
    {
      'name': 'Malee',
      'imageUrl':
          'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80',
      'isViewed': true,
    },
    {
      'name': 'Chai',
      'imageUrl':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80',
      'isViewed': false,
    },
    {
      'name': 'Siri',
      'imageUrl':
          'https://images.unsplash.com/photo-1580489944761-15a19d654956?ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80',
      'isViewed': true,
    },
    {
      'name': 'Prem',
      'imageUrl':
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80',
      'isViewed': false,
    },
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter products by category
    final filteredProducts =
        _selectedCategory == 'All'
            ? _products
            : _products
                .where((product) => product['category'] == _selectedCategory)
                .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('FarmLink Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Open search
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              // Navigate to cart
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stories Section
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bambooCream,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.palmAshGray.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _farmers.length,
              itemBuilder: (context, index) {
                final farmer = _farmers[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: StoryCircle(
                    imageUrl: farmer['imageUrl'],
                    name: farmer['name'],
                    isViewed: farmer['isViewed'],
                    onTap: () {
                      // View farmer story
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Viewing ${farmer['name']}\'s story'),
                        ),
                      );
                    },
                  ),
                );
              },
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

          // View Toggle and Sort
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredProducts.length} Products',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.palmAshGray,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.grid_view,
                        color:
                            _isGridView
                                ? AppColors.tamarindBrown
                                : AppColors.palmAshGray,
                      ),
                      onPressed: () {
                        setState(() {
                          _isGridView = true;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.view_list,
                        color:
                            !_isGridView
                                ? AppColors.tamarindBrown
                                : AppColors.palmAshGray,
                      ),
                      onPressed: () {
                        setState(() {
                          _isGridView = false;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.sort),
                      onPressed: () {
                        // Show sort options
                      },
                    ),
                  ],
                ),
              ],
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
                    : _isGridView
                    ? GridView.builder(
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
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: FarmCard(
                            imageUrl: product['imageUrl']!,
                            title: product['title']!,
                            price: product['price']!,
                            description: product['description']!,
                            category: product['category']!,
                            quantity: product['quantity'],
                            unit: product['unit'],
                            onTap: () {
                              // Navigate to product detail
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Viewing ${product['title']}'),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to impact tracker
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Navigating to Impact Tracker')),
          );
        },
        backgroundColor: AppColors.bambooCream,
        child: const Icon(Icons.eco, color: AppColors.ricePaddyGreen),
      ),
    );
  }
}
