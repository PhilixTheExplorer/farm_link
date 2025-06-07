import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

// State class for buyer marketplace
class BuyerMarketplaceState {
  final List<Product> products;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final String selectedCategory;
  final String searchQuery;
  final String sortOrder;
  final int currentPage;
  final bool hasMoreProducts;

  const BuyerMarketplaceState({
    this.products = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.errorMessage,
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.sortOrder = 'none',
    this.currentPage = 1,
    this.hasMoreProducts = true,
  });

  BuyerMarketplaceState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    String? selectedCategory,
    String? searchQuery,
    String? sortOrder,
    int? currentPage,
    bool? hasMoreProducts,
  }) {
    return BuyerMarketplaceState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOrder: sortOrder ?? this.sortOrder,
      currentPage: currentPage ?? this.currentPage,
      hasMoreProducts: hasMoreProducts ?? this.hasMoreProducts,
    );
  }

  // Computed property for filtered products
  List<Product> get filteredProducts {
    var filtered =
        products.where((product) {
          // Category filter
          final categoryMatch =
              selectedCategory == 'All' ||
              product.categoryDisplayName == selectedCategory;

          // Search filter
          final searchMatch =
              searchQuery.isEmpty ||
              product.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              product.description.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );

          // Only show available products
          final statusMatch = product.status == ProductStatus.available;

          return categoryMatch && searchMatch && statusMatch;
        }).toList();

    // Apply sorting
    if (sortOrder == 'price_asc') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortOrder == 'price_desc') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    return filtered;
  }
}

// Notifier class for buyer marketplace
class BuyerMarketplaceNotifier extends StateNotifier<BuyerMarketplaceState> {
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
  BuyerMarketplaceNotifier() : super(const BuyerMarketplaceState()) {
    loadProducts(resetPage: true);
  }

  // Getters
  List<String> get categories => _categories; // Load products from repository
  Future<void> loadProducts({bool resetPage = true}) async {
    try {
      int pageToLoad;
      if (resetPage) {
        state = state.copyWith(
          isLoading: true,
          errorMessage: null,
          currentPage: 1,
          hasMoreProducts: true,
        );
        pageToLoad = 1;
      } else {
        state = state.copyWith(isLoadingMore: true);
        pageToLoad = state.currentPage + 1; // Load the next page
      }

      debugPrint('Loading products from API... Page: $pageToLoad');
      final newProducts = await _productRepository.getAllProducts(
        page: pageToLoad,
        limit: 20, // Load 20 products per page
      );
      debugPrint('Loaded ${newProducts.length} products');

      if (resetPage) {
        // Replace products for initial load or refresh
        state = state.copyWith(
          products: newProducts,
          isLoading: false,
          hasMoreProducts: newProducts.length >= 20,
        );
      } else {
        // Append products for pagination
        final updatedProducts = List<Product>.from(state.products)
          ..addAll(newProducts);
        state = state.copyWith(
          products: updatedProducts,
          isLoadingMore: false,
          currentPage: pageToLoad, // Update to the page we just loaded
          hasMoreProducts: newProducts.length >= 20,
        );
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: 'Failed to load products: ${e.toString()}',
      );
    }
  }

  // Load more products for pagination
  Future<void> loadMoreProducts() async {
    if (state.isLoadingMore || !state.hasMoreProducts) {
      return;
    }
    await loadProducts(resetPage: false);
  }

  // Refresh products
  Future<void> refreshProducts() async {
    await loadProducts(resetPage: true);
  }

  // Update search query
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // Clear search query
  void clearSearchQuery() {
    state = state.copyWith(searchQuery: '');
  }

  // Update selected category
  void updateSelectedCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  // Update sort order
  void updateSortOrder(String sortOrder) {
    state = state.copyWith(sortOrder: sortOrder);
  }

  // Clear sort order
  void clearSortOrder() {
    state = state.copyWith(sortOrder: 'none');
  }
}

// Provider for buyer marketplace
final buyerMarketplaceProvider =
    StateNotifierProvider<BuyerMarketplaceNotifier, BuyerMarketplaceState>(
      (ref) => BuyerMarketplaceNotifier(),
    );
