import 'user.dart';

class Buyer extends User {
  final double totalSpent;
  final int totalOrders;
  final String? deliveryAddress;
  final String? deliveryInstructions;
  final List<String>? preferences;
  final int? loyaltyPoints;

  Buyer({
    required super.id,
    required super.email,
    required super.name,
    required super.phone,
    required super.location,
    super.profileImageUrl,
    super.createdAt,
    super.updatedAt,
    this.totalSpent = 0.0,
    this.totalOrders = 0,
    this.deliveryAddress,
    this.deliveryInstructions,
    this.preferences,
    this.loyaltyPoints,
  }) : super(role: UserRole.buyer);

  factory Buyer.fromJson(Map<String, dynamic> json) {
    // Handle both nested structure from API and flat structure
    final userData = json['users'] ?? json;
    final buyerData = json;

    return Buyer(
      id: userData['id'],
      email: userData['email'],
      name: userData['name'],
      phone: userData['phone'],
      location: userData['location'],
      profileImageUrl:
          userData['profile_image_url'] ?? userData['profileImageUrl'],
      createdAt:
          buyerData['created_at'] != null
              ? DateTime.parse(buyerData['created_at'])
              : null,
      updatedAt:
          buyerData['updated_at'] != null
              ? DateTime.parse(buyerData['updated_at'])
              : null,
      totalSpent:
          (buyerData['total_spent'] ?? buyerData['totalSpent'] ?? 0).toDouble(),
      totalOrders: buyerData['total_orders'] ?? buyerData['totalOrders'] ?? 0,
      deliveryAddress:
          buyerData['delivery_address'] ?? buyerData['deliveryAddress'],
      deliveryInstructions:
          buyerData['delivery_instructions'] ??
          buyerData['deliveryInstructions'],
      preferences:
          buyerData['preferred_payment_methods'] != null
              ? List<String>.from(buyerData['preferred_payment_methods'])
              : (buyerData['preferences'] != null
                  ? List<String>.from(buyerData['preferences'])
                  : null),
      loyaltyPoints: buyerData['loyalty_points'] ?? buyerData['loyaltyPoints'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'total_spent': totalSpent,
      'total_orders': totalOrders,
      'delivery_address': deliveryAddress,
      'delivery_instructions': deliveryInstructions,
      'loyalty_points': loyaltyPoints,
      if (preferences != null) 'preferred_payment_methods': preferences,
    });
    return json;
  }

  @override
  Buyer copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? location,
    UserRole? role,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? totalSpent,
    int? totalOrders,
    String? deliveryAddress,
    String? deliveryInstructions,
    List<String>? preferences,
    int? loyaltyPoints,
  }) {
    return Buyer(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalSpent: totalSpent ?? this.totalSpent,
      totalOrders: totalOrders ?? this.totalOrders,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      preferences: preferences ?? this.preferences,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
    );
  }

  // Business logic methods
  String get spendingDisplay => '฿${totalSpent.toStringAsFixed(2)}';
  String get orderCountDisplay => '$totalOrders orders';

  bool get hasDeliveryAddress =>
      deliveryAddress != null && deliveryAddress!.isNotEmpty;

  @override
  String toString() {
    return 'Buyer(id: $id, email: $email, name: $name, totalSpent: $totalSpent, totalOrders: $totalOrders, deliveryAddress: $deliveryAddress)';
  }
}
