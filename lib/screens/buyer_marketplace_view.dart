import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../components/farm_card.dart';
import '../components/app_drawer.dart';
import '../core/theme/app_colors.dart';
import '../core/router/app_router.dart';
import '../viewmodels/buyer_marketplace_viewmodel.dart';
import '../services/cart_service.dart';
import '../core/di/service_locator.dart';

class BuyerMarketplaceView extends ConsumerStatefulWidget {
  const BuyerMarketplaceView({super.key});

  @override
  ConsumerState<BuyerMarketplaceView> createState() =>
      _BuyerMarketplaceViewState();
}

class _BuyerMarketplaceViewState extends ConsumerState<BuyerMarketplaceView> {
  final TextEditingController _searchController = TextEditingController();
  late final CartService _cartService;

  @override
  void initState() {
    super.initState();
    _cartService = serviceLocator<CartService>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(buyerMarketplaceProvider);
    final notifier = ref.read(buyerMarketplaceProvider.notifier);

    // Update search controller when state changes
    if (_searchController.text != state.searchQuery) {
      _searchController.text = state.searchQuery;
    }

    return Scaffold(
      drawer: AppDrawer(currentRoute: AppRoutes.buyerMarketplace),
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.refreshProducts(),
            tooltip: 'Refresh',
          ),
          ListenableBuilder(
            listenable: _cartService,
            builder: (context, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      context.push(AppRoutes.cart);
                    },
                  ),
                  if (_cartService.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.chilliRed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${_cartService.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
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
                        notifier.updateSearchQuery(value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.palmAshGray,
                        ),
                        suffixIcon:
                            state.searchQuery.isNotEmpty
                                ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: AppColors.palmAshGray,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    notifier.clearSearchQuery();
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
                        _showFilterBottomSheet(context, state, notifier);
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
                itemCount: notifier.categories.length,
                itemBuilder: (context, index) {
                  final category = notifier.categories[index];
                  final isSelected = category == state.selectedCategory;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          notifier.updateSelectedCategory(category);
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
                  state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.errorMessage != null
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
                              state.errorMessage!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.palmAshGray,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => notifier.refreshProducts(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                      : _buildProductsList(state, notifier),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    BuyerMarketplaceState state,
    BuyerMarketplaceNotifier notifier,
  ) {
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
                'Filter & Sort Products',
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
                        notifier.updateSortOrder('price_asc');
                        context.pop();
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            state.sortOrder == 'price_asc'
                                ? AppColors.ricePaddyGreen.withOpacity(0.1)
                                : null,
                        side: BorderSide(
                          color:
                              state.sortOrder == 'price_asc'
                                  ? AppColors.ricePaddyGreen
                                  : AppColors.palmAshGray,
                        ),
                      ),
                      child: Text(
                        'Low to High',
                        style: TextStyle(
                          color:
                              state.sortOrder == 'price_asc'
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
                        notifier.updateSortOrder('price_desc');
                        context.pop();
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            state.sortOrder == 'price_desc'
                                ? AppColors.ricePaddyGreen.withOpacity(0.1)
                                : null,
                        side: BorderSide(
                          color:
                              state.sortOrder == 'price_desc'
                                  ? AppColors.ricePaddyGreen
                                  : AppColors.palmAshGray,
                        ),
                      ),
                      child: Text(
                        'High to Low',
                        style: TextStyle(
                          color:
                              state.sortOrder == 'price_desc'
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
                        notifier.clearSortOrder();
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
  }

  Widget _buildProductsList(
    BuyerMarketplaceState state,
    BuyerMarketplaceNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final filteredProducts = state.filteredProducts;

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
              state.searchQuery.isNotEmpty
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
      onRefresh: () => notifier.refreshProducts(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          // Check if we've reached near the end of the list
          if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent * 0.8 &&
              !state.isLoadingMore &&
              state.hasMoreProducts) {
            // Load more products when user scrolls to 80% of the list
            notifier.loadMoreProducts();
          }
          return true;
        },
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          // Add extra items for loading indicator if we're loading more or have more products
          itemCount:
              filteredProducts.length +
              (state.hasMoreProducts || state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            // Show loading indicator at the end if loading more
            if (index >= filteredProducts.length) {
              if (state.isLoadingMore) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (state.hasMoreProducts) {
                // Show a message that more products are available
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Scroll to load more...'),
                  ),
                );
              }
              return const SizedBox.shrink();
            }

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
      ),
    );
  }
}
