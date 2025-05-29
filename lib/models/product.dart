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
  final bool isOrganic;
  final int orderCount; // number of times this product was ordered
  final double rating; // average rating from buyers
  final int reviewCount;

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
    this.isOrganic = false,
    this.orderCount = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      farmerId: json['farmerId'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      category: ProductCategory.values.firstWhere(
        (c) => c.toString().split('.').last == json['category'],
        orElse: () => ProductCategory.other,
      ),
      quantity: json['quantity'],
      unit: json['unit'],
      imageUrl: json['imageUrl'],
      status: ProductStatus.values.firstWhere(
        (s) => s.toString().split('.').last == json['status'],
        orElse: () => ProductStatus.available,
      ),
      createdDate: DateTime.parse(json['createdDate']),
      lastUpdated:
          json['lastUpdated'] != null
              ? DateTime.parse(json['lastUpdated'])
              : null,
      isOrganic: json['isOrganic'] ?? false,
      orderCount: json['orderCount'] ?? 0,
      rating: json['rating']?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'title': title,
      'description': description,
      'price': price,
      'category': category.toString().split('.').last,
      'quantity': quantity,
      'unit': unit,
      'imageUrl': imageUrl,
      'status': status.toString().split('.').last,
      'createdDate': createdDate.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
      'isOrganic': isOrganic,
      'orderCount': orderCount,
      'rating': rating,
      'reviewCount': reviewCount,
    };
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
    bool? isOrganic,
    int? orderCount,
    double? rating,
    int? reviewCount,
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
      isOrganic: isOrganic ?? this.isOrganic,
      orderCount: orderCount ?? this.orderCount,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
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
