import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../components/farm_card.dart';
import '../components/app_drawer.dart';
import '../core/theme/app_colors.dart';
import '../core/router/app_router.dart';
import '../viewmodels/farmer_dashboard_viewmodel.dart';
import '../core/di/service_locator.dart';

class FarmerDashboardView extends StatefulWidget {
  const FarmerDashboardView({super.key});

  @override
  State<FarmerDashboardView> createState() => _FarmerDashboardViewState();
}

class _FarmerDashboardViewState extends State<FarmerDashboardView>
    with RouteAware {
  late FarmerDashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = serviceLocator<FarmerDashboardViewModel>();
    _viewModel.initialize();
  }

  @override
  void didPopNext() {
    // Called when a route has been popped and this screen is now visible again
    // This triggers when returning from product upload or other screens
    super.didPopNext();
    _viewModel.refresh();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        if (!_viewModel.hasFarmer) {
          return Scaffold(
            appBar: AppBar(title: const Text('Farmer Dashboard')),
            body: const Center(
              child: Text('Please login as a farmer to access this page.'),
            ),
          );
        }

        return Scaffold(
          drawer: AppDrawer(currentRoute: AppRoutes.farmerDashboard),
          appBar: AppBar(
            title: const Text('Farmer Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _viewModel.refresh,
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: () {
                  context.push(AppRoutes.profileSettings);
                },
              ),
            ],
          ),
          body:
              _viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildDashboardContent(theme),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              // Navigate to product upload and refresh on return
              await context.push(AppRoutes.productUpload);
              // Refresh the dashboard when returning from product upload
              _viewModel.refresh();
            },
            backgroundColor: AppColors.bambooCream,
            child: const Icon(Icons.add, color: AppColors.chilliRed),
          ),
        );
      },
    );
  }

  Widget _buildDashboardContent(ThemeData theme) {
    if (_viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${_viewModel.errorMessage}',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _viewModel.refresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _viewModel.refresh,
      child: Column(
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
                          _viewModel.farmer?.profileImageUrl != null
                              ? NetworkImage(
                                _viewModel.farmer!.profileImageUrl!,
                              )
                              : null,
                      backgroundColor: AppColors.ricePaddyGreen,
                      child:
                          _viewModel.farmer?.profileImageUrl == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _viewModel.welcomeMessage,
                            style: theme.textTheme.titleLarge,
                          ),
                          Text(
                            _viewModel.productsSummaryMessage,
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
                        '฿${_viewModel.totalRevenue.toStringAsFixed(0)}',
                        Icons.attach_money,
                        AppColors.ricePaddyGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Total Orders',
                        '${_viewModel.totalOrders}',
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
                    // TODO: Implement filter/sort functionality
                    _showSortOptions();
                  },
                  icon: const Icon(Icons.sort),
                  label: const Text('Sort'),
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
                _viewModel.hasProducts
                    ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.of(context).size.width > 600 ? 3 : 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _viewModel.products.length,
                      itemBuilder: (context, index) {
                        final product = _viewModel.products[index];
                        return FarmCard(
                          product: product,
                          showDescription: false,
                          onTap: () {
                            context.push(
                              AppRoutes.productDetail,
                              extra: product,
                            );
                          },
                        );
                      },
                    )
                    : Center(
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
                    ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sort Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('By Name'),
                onTap: () {
                  _viewModel.sortProducts(ProductSortType.name);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('By Price'),
                onTap: () {
                  _viewModel.sortProducts(ProductSortType.price);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.inventory),
                title: const Text('By Quantity'),
                onTap: () {
                  _viewModel.sortProducts(ProductSortType.quantity);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('By Date Created'),
                onTap: () {
                  _viewModel.sortProducts(ProductSortType.dateCreated);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.label),
                title: const Text('By Status'),
                onTap: () {
                  _viewModel.sortProducts(ProductSortType.status);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
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
