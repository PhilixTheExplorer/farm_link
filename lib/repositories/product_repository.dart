import '../models/product.dart';

class ProductRepository {
  static final ProductRepository _instance = ProductRepository._internal();
  factory ProductRepository() => _instance;
  ProductRepository._internal();

  // Sample product data for farmers
  static final List<Product> _sampleProducts = [
    // Products for farmer_001 (Somchai)
    Product(
      id: 'prod_001',
      farmerId: 'farmer_001',
      title: 'Organic Jasmine Rice',
      description:
          'Premium quality jasmine rice grown organically in the fertile fields of Chiang Mai. Fragrant and perfect for Thai cuisine.',
      price: 120.0,
      category: ProductCategory.rice,
      quantity: 50,
      unit: 'kg',
      imageUrl:
          'https://images.unsplash.com/photo-1603833665858-e61d17a86224?w=400&h=300&fit=crop',
      createdDate: DateTime(2023, 10, 15),
      isOrganic: true,
      orderCount: 23,
      rating: 4.8,
      reviewCount: 15,
    ),
    Product(
      id: 'prod_002',
      farmerId: 'farmer_001',
      title: 'Fresh Thai Herbs Mix',
      description:
          'A mix of fresh Thai herbs including basil, cilantro, and mint. Perfect for authentic Thai cooking.',
      price: 45.0,
      category: ProductCategory.herbs,
      quantity: 20,
      unit: 'bunch',
      imageUrl:
          'https://images.unsplash.com/photo-1566402176825-c4d4c24e9b3e?w=400&h=300&fit=crop',
      createdDate: DateTime(2023, 11, 2),
      isOrganic: true,
      orderCount: 18,
      rating: 4.6,
      reviewCount: 12,
    ),
    Product(
      id: 'prod_003',
      farmerId: 'farmer_001',
      title: 'Organic Brown Rice',
      description:
          'Nutritious brown rice with high fiber content. Grown without pesticides in our organic farm.',
      price: 95.0,
      category: ProductCategory.rice,
      quantity: 30,
      unit: 'kg',
      imageUrl:
          'https://images.unsplash.com/photo-1596797038530-2c107229654b?w=400&h=300&fit=crop',
      createdDate: DateTime(2023, 9, 28),
      isOrganic: true,
      orderCount: 12,
      rating: 4.5,
      reviewCount: 8,
    ),

    // Products for farmer_002 (Malee)
    Product(
      id: 'prod_004',
      farmerId: 'farmer_002',
      title: 'Hydroponic Lettuce',
      description:
          'Crisp and fresh lettuce grown using advanced hydroponic methods. Clean and chemical-free.',
      price: 35.0,
      category: ProductCategory.vegetables,
      quantity: 40,
      unit: 'head',
      imageUrl:
          'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400&h=300&fit=crop',
      createdDate: DateTime(2023, 11, 10),
      isOrganic: false,
      orderCount: 31,
      rating: 4.7,
      reviewCount: 22,
    ),
    Product(
      id: 'prod_005',
      farmerId: 'farmer_002',
      title: 'Baby Spinach',
      description:
          'Tender baby spinach leaves, perfect for salads and smoothies. Grown in controlled hydroponic environment.',
      price: 40.0,
      category: ProductCategory.vegetables,
      quantity: 25,
      unit: 'bag',
      imageUrl:
          'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400&h=300&fit=crop',
      createdDate: DateTime(2023, 11, 8),
      isOrganic: false,
      orderCount: 19,
      rating: 4.4,
      reviewCount: 14,
    ),
    Product(
      id: 'prod_006',
      farmerId: 'farmer_002',
      title: 'Cherry Tomatoes',
      description:
          'Sweet and juicy cherry tomatoes grown in our hydroponic greenhouse. Perfect for snacking or salads.',
      price: 80.0,
      category: ProductCategory.vegetables,
      quantity: 15,
      unit: 'kg',
      imageUrl:
          'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400&h=300&fit=crop',
      createdDate: DateTime(2023, 10, 25),
      isOrganic: false,
      orderCount: 27,
      rating: 4.9,
      reviewCount: 20,
    ),
    Product(
      id: 'prod_007',
      farmerId: 'farmer_002',
      title: 'Kale Leaves',
      description:
          'Nutrient-rich kale leaves, perfect for healthy smoothies and salads. Freshly harvested daily.',
      price: 55.0,
      category: ProductCategory.vegetables,
      quantity: 18,
      unit: 'bunch',
      imageUrl:
          'https://images.unsplash.com/photo-1579952363873-27d3bfad9c0d?w=400&h=300&fit=crop',
      createdDate: DateTime(2023, 11, 5),
      isOrganic: false,
      orderCount: 14,
      rating: 4.3,
      reviewCount: 9,
    ),
  ];

  // Get all products
  Future<List<Product>> getAllProducts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_sampleProducts);
  }

  // Get products by farmer ID
  Future<List<Product>> getProductsByFarmerId(String farmerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _sampleProducts
        .where((product) => product.farmerId == farmerId)
        .toList();
  }

  // Get product by ID
  Future<Product?> getProductById(String productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _sampleProducts.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Add new product
  Future<bool> addProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _sampleProducts.add(product);
    return true;
  }

  // Update product
  Future<bool> updateProduct(Product updatedProduct) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final index = _sampleProducts.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _sampleProducts[index] = updatedProduct;
      return true;
    }
    return false;
  }

  // Delete product
  Future<bool> deleteProduct(String productId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _sampleProducts.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _sampleProducts.removeAt(index);
      return true;
    }
    return false;
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(ProductCategory category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _sampleProducts
        .where((product) => product.category == category)
        .toList();
  }

  // Search products
  Future<List<Product>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final lowerQuery = query.toLowerCase();
    return _sampleProducts.where((product) {
      return product.title.toLowerCase().contains(lowerQuery) ||
          product.description.toLowerCase().contains(lowerQuery) ||
          product.categoryDisplayName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Get farmer's total products count
  Future<int> getFarmerProductCount(String farmerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _sampleProducts
        .where((product) => product.farmerId == farmerId)
        .length;
  }

  // Get farmer's total revenue (sum of all orders)
  Future<double> getFarmerTotalRevenue(String farmerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final farmerProducts = _sampleProducts.where(
      (product) => product.farmerId == farmerId,
    );
    double totalRevenue = 0;
    for (final product in farmerProducts) {
      totalRevenue += product.price * product.orderCount;
    }
    return totalRevenue;
  }

  // Get farmer's average product rating
  Future<double> getFarmerAverageRating(String farmerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final farmerProducts =
        _sampleProducts
            .where((product) => product.farmerId == farmerId)
            .toList();
    if (farmerProducts.isEmpty) return 0.0;

    double totalRating = 0;
    int totalReviews = 0;
    for (final product in farmerProducts) {
      totalRating += product.rating * product.reviewCount;
      totalReviews += product.reviewCount;
    }

    return totalReviews > 0 ? totalRating / totalReviews : 0.0;
  }
}
