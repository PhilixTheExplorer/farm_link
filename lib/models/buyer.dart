import 'user.dart';

class Buyer extends User {
  final double totalSpent;
  final int totalOrders;
  final String? deliveryAddress;

  Buyer({
    required super.id,
    required super.email,
    required super.name,
    required super.phone,
    required super.location,
    super.profileImageUrl,
    this.totalSpent = 0.0,
    this.totalOrders = 0,
    this.deliveryAddress,
  }) : super(role: UserRole.buyer);
  
  factory Buyer.fromJson(Map<String, dynamic> json) {
    return Buyer(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      location: json['location'],
      profileImageUrl: json['profileImageUrl'],
      totalSpent: json['totalSpent']?.toDouble() ?? 0.0,
      totalOrders: json['totalOrders'] ?? 0,
      deliveryAddress: json['deliveryAddress'] ?? '',
    );
  }
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'totalSpent': totalSpent,
      'totalOrders': totalOrders,
      'deliveryAddress': deliveryAddress,
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
    double? totalSpent,
    int? totalOrders,
    String? deliveryAddress,
  }) {
    return Buyer(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      totalSpent: totalSpent ?? this.totalSpent,
      totalOrders: totalOrders ?? this.totalOrders,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
    );
  }

  @override
  String toString() {
    return 'Buyer(id: $id, email: $email, name: $name, totalSpent: $totalSpent, totalOrders: $totalOrders, deliveryAddress: $deliveryAddress)';
  }
}
