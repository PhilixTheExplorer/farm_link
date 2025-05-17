import 'package:flutter/material.dart';
import '../components/farm_card.dart';
import '../components/thai_button.dart';
import '../theme/app_colors.dart';

class FarmerDashboardView extends StatelessWidget {
  const FarmerDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Sample product data
    final products = [
      {
        'imageUrl': 'https://images.unsplash.com/photo-1603833665858-e61d17a86224?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        'title': 'Organic Rice',
        'price': '120',
        'description': 'Freshly harvested jasmine rice from our farm in Chiang Mai.',
        'category': 'Rice',
      },
      {
        'imageUrl': 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        'title': 'Fresh Mangoes',
        'price': '80',
        'description': 'Sweet and juicy mangoes, perfect for desserts or eating fresh.',
        'category': 'Fruits',
      },
      {
        'imageUrl': 'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
        'title': 'Handmade Basket',
        'price': '250',
        'description': 'Traditional Thai bamboo basket, handcrafted by local artisans.',
        'category': 'Handmade',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // Navigate to profile
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
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
                        'Welcome, Somchai!',
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        'You have 3 products listed',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.palmAshGray,
                        ),
                      ),
                    ],
                  ),
                ),
                ThaiButton(
                  label: 'Sales',
                  onPressed: () {
                    // Navigate to sales summary
                  },
                  variant: ThaiButtonVariant.secondary,
                  icon: Icons.bar_chart,
                ),
              ],
            ),
          ),
          
          // Products Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Products',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Filter products
                  },
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.tamarindBrown,
                  ),
                ),
              ],
            ),
          ),
          
          // Product List
          Expanded(
            child: products.isEmpty
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
                          'No products yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.palmAshGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first product by clicking the + button',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.palmAshGray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: FarmCard(
                          imageUrl: product['imageUrl']!,
                          title: product['title']!,
                          price: product['price']!,
                          description: product['description']!,
                          category: product['category']!,
                          onTap: () {
                            // Navigate to product detail/edit
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
          // Navigate to product upload
        },
        backgroundColor: AppColors.bambooCream,
        child: const Icon(Icons.add, color: AppColors.chilliRed),
      ),
    );
  }
}
