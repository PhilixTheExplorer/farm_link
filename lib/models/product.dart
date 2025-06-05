enum ProductCategory {
  rice,
  fruits,
  vegetables,
  herbs,
  handmade,
  dairy,
  meat,
  other,
}

enum ProductStatus { available, outOfStock, discontinued }

class Product {
  final String id;
  final String farmerId;
  final String title;
  final String description;
  final double price; // price per unit in THB
  final ProductCategory category;
  final int quantity;
  final String unit; // kg, pcs, liter, etc.
  final String imageUrl;
  final ProductStatus status;
  final DateTime createdDate;
  final DateTime? lastUpdated;
  final int orderCount; // number of times this product was ordered

  Product({
    required this.id,
    required this.farmerId,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.imageUrl,
    this.status = ProductStatus.available,
    required this.createdDate,
    this.lastUpdated,
    this.orderCount = 0,
  });
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      farmerId: json['farmer_id'] ?? json['farmerId'], // Support both formats
      title: json['title'] ?? json['name'], // Support both formats
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      category: _parseCategoryFromString(json['category']),
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? 'pcs',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      status: _parseStatusFromString(json['status']),
      createdDate: DateTime.parse(json['created_at'] ?? json['createdDate']),
      lastUpdated:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : (json['lastUpdated'] != null
                  ? DateTime.parse(json['lastUpdated'])
                  : null),
      orderCount: json['order_count'] ?? json['orderCount'] ?? 0,
    );
  } // Factory method for cart API response format
  factory Product.fromCartJson(Map<String, dynamic> json) {
    final farmerUser = json['farmer_user'] ?? {};
    final farmers = farmerUser['farmers'] ?? {};

    final product = Product(
      id: json['id'],
      farmerId: farmerUser['id'] ?? '',
      title: json['title'],
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      category: _parseCategoryFromString(json['category']),
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? 'pcs',
      imageUrl: json['image_url'] ?? '',
      status: _parseStatusFromString(json['status']),
      createdDate: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      lastUpdated:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      orderCount: json['order_count'] ?? 0,
    );

    // Set farmer info from the cart response
    product.setFarmerInfo(farmerUser['name'], farmers['farm_name']);

    return product;
  }

  // Store farmer info for cart items
  String? _farmerName;
  String? _farmName;

  // Setters for farmer info (used when creating from cart JSON)
  void setFarmerInfo(String? farmerName, String? farmName) {
    _farmerName = farmerName;
    _farmName = farmName;
  }

  // Getters for farmer info
  String get farmerName => _farmerName ?? 'Unknown Farmer';
  String get farmName => _farmName ?? 'Unknown Farm';

  // Helper method to parse category from string
  static ProductCategory _parseCategoryFromString(String? category) {
    if (category == null) return ProductCategory.other;

    switch (category.toLowerCase()) {
      case 'rice':
        return ProductCategory.rice;
      case 'fruits':
        return ProductCategory.fruits;
      case 'vegetables':
        return ProductCategory.vegetables;
      case 'herbs':
        return ProductCategory.herbs;
      case 'handmade':
        return ProductCategory.handmade;
      case 'dairy':
        return ProductCategory.dairy;
      case 'meat':
        return ProductCategory.meat;
      default:
        return ProductCategory.other;
    }
  }

  // Helper method to parse status from string
  static ProductStatus _parseStatusFromString(String? status) {
    if (status == null) return ProductStatus.available;

    switch (status.toLowerCase()) {
      case 'available':
        return ProductStatus.available;
      case 'out_of_stock':
      case 'outofstock':
        return ProductStatus.outOfStock;
      case 'discontinued':
        return ProductStatus.discontinued;
      default:
        return ProductStatus.available;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmer_id': farmerId,
      'title': title,
      'description': description,
      'price': price,
      'category': category.toString().split('.').last,
      'quantity': quantity,
      'unit': unit,
      'image_url': imageUrl,
      'status': _statusToString(status),
      'created_at': createdDate.toIso8601String(),
      'updated_at': lastUpdated?.toIso8601String(),
      'order_count': orderCount,
    };
  }

  // Helper method for product creation (excludes ID field, farmer_id comes from token)
  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'category': category.toString().split('.').last,
      'quantity': quantity,
      'unit': unit,
      'image_url': imageUrl,
      'status': _statusToString(status),
    };
  }

  // Helper method to convert status to API format
  String _statusToString(ProductStatus status) {
    switch (status) {
      case ProductStatus.available:
        return 'available';
      case ProductStatus.outOfStock:
        return 'out_of_stock';
      case ProductStatus.discontinued:
        return 'discontinued';
    }
  }

  Product copyWith({
    String? id,
    String? farmerId,
    String? title,
    String? description,
    double? price,
    ProductCategory? category,
    int? quantity,
    String? unit,
    String? imageUrl,
    ProductStatus? status,
    DateTime? createdDate,
    DateTime? lastUpdated,
    int? orderCount,
  }) {
    return Product(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      orderCount: orderCount ?? this.orderCount,
    );
  }

  // Helper getters
  String get categoryDisplayName {
    switch (category) {
      case ProductCategory.rice:
        return 'Rice';
      case ProductCategory.fruits:
        return 'Fruits';
      case ProductCategory.vegetables:
        return 'Vegetables';
      case ProductCategory.herbs:
        return 'Herbs';
      case ProductCategory.handmade:
        return 'Handmade';
      case ProductCategory.dairy:
        return 'Dairy';
      case ProductCategory.meat:
        return 'Meat';
      case ProductCategory.other:
        return 'Other';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case ProductStatus.available:
        return 'Available';
      case ProductStatus.outOfStock:
        return 'Out of Stock';
      case ProductStatus.discontinued:
        return 'Discontinued';
    }
  }

  bool get isAvailable => status == ProductStatus.available && quantity > 0;
}
