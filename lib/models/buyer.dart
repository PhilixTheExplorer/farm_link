import 'user.dart';

class Buyer extends User {
  final double totalSpent;
  final int totalOrders;
  final String? deliveryAddress;
  final List<String>? preferences;

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
    this.preferences,
  }) : super(role: UserRole.buyer);

  factory Buyer.fromJson(Map<String, dynamic> json) {
    return Buyer(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      location: json['location'],
      profileImageUrl: json['profile_image_url'] ?? json['profileImageUrl'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      totalSpent: (json['total_spent'] ?? json['totalSpent'] ?? 0).toDouble(),
      totalOrders: json['total_orders'] ?? json['totalOrders'] ?? 0,
      deliveryAddress: json['delivery_address'] ?? json['deliveryAddress'],
      preferences:
          json['preferences'] != null
              ? List<String>.from(json['preferences'])
              : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'total_spent': totalSpent,
      'total_orders': totalOrders,
      'delivery_address': deliveryAddress,
      if (preferences != null) 'preferences': preferences,
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
    List<String>? preferences,
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
      preferences: preferences ?? this.preferences,
    );
  }

  // Helper getters
  String get spentDisplay => '฿${totalSpent.toStringAsFixed(0)}';
  String get orderCountDisplay => '$totalOrders orders';
  bool get hasDeliveryAddress =>
      deliveryAddress != null && deliveryAddress!.isNotEmpty;

  @override
  String toString() {
    return 'Buyer(id: $id, email: $email, name: $name, totalSpent: $totalSpent, totalOrders: $totalOrders, deliveryAddress: $deliveryAddress)';
  }
}
