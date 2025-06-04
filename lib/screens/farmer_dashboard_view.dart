import 'package:flutter/material.dart';
import '../components/farm_card.dart';
import '../components/app_drawer.dart';
import '../theme/app_colors.dart';
import '../core/user_service.dart';
import '../core/product_service.dart';
import '../models/product.dart';

class FarmerDashboardView extends StatefulWidget {
  const FarmerDashboardView({super.key});

  @override
  State<FarmerDashboardView> createState() => _FarmerDashboardViewState();
}

class _FarmerDashboardViewState extends State<FarmerDashboardView> {
  final UserService _userService = UserService();
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  Map<String, dynamic> _farmerStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFarmerData();
  }

  Future<void> _loadFarmerData() async {
    if (_userService.farmerData != null) {
      try {
        final products = await _productService.getFarmerProducts(
          _userService.farmerData!.id,
        );
        final stats = await _productService.getFarmerStats(
          _userService.farmerData!.id,
        );

        setState(() {
          _products = products;
          _farmerStats = stats;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final farmer = _userService.farmerData;

    if (farmer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Farmer Dashboard')),
        body: const Center(
          child: Text('Please login as a farmer to access this page.'),
        ),
      );
    }

    return Scaffold(
      drawer: AppDrawer(currentRoute: '/farmer-dashboard'),
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/profile-settings');
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section with Stats
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
                    child: Column(
                      children: [
                        // User Info Row
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage:
                                  farmer.profileImageUrl != null
                                      ? NetworkImage(farmer.profileImageUrl!)
                                      : null,
                              backgroundColor: AppColors.ricePaddyGreen,
                              child:
                                  farmer.profileImageUrl == null
                                      ? const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      )
                                      : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome, ${farmer.name?.split(' ').first}!',
                                    style: theme.textTheme.titleLarge,
                                  ),
                                  Text(
                                    'You have ${_farmerStats['productCount'] ?? 0} products listed',
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

                        // Stats Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total Revenue',
                                '฿${(_farmerStats['totalRevenue'] ?? 0.0).toStringAsFixed(0)}',
                                Icons.attach_money,
                                AppColors.ricePaddyGreen,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Total Orders',
                                '${_farmerStats['totalOrders'] ?? 0}',
                                Icons.shopping_bag,
                                AppColors.tamarindBrown,
                              ),
                            ),                          
                          ],
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
                    child:
                        _products.isEmpty
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
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _products.length,
                              itemBuilder: (context, index) {
                                final product = _products[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: FarmCard(
                                    product: product,
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
          Navigator.pushNamed(context, '/product-upload');
        },
        backgroundColor: AppColors.bambooCream,
        child: const Icon(Icons.add, color: AppColors.chilliRed),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: AppColors.palmAshGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
