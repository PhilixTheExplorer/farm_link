import 'user.dart';

class Buyer extends User {
  final String preferredDeliveryTime;
  final List<String> dietaryPreferences; // organic, local, etc.
  final double totalSpent;
  final int totalOrders;
  final List<String> favoriteProducts;
  final String deliveryAddress;
  final bool subscribeToNewsletter;

  Buyer({
    required super.id,
    required super.email,
    required super.name,
    required super.phone,
    required super.location,
    required super.joinDate,
    super.profileImageUrl,
    required this.preferredDeliveryTime,
    required this.dietaryPreferences,
    this.totalSpent = 0.0,
    this.totalOrders = 0,
    this.favoriteProducts = const [],
    required this.deliveryAddress,
    this.subscribeToNewsletter = false,
  }) : super(role: UserRole.buyer);

  factory Buyer.fromJson(Map<String, dynamic> json) {
    return Buyer(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      location: json['location'],
      joinDate: DateTime.parse(json['joinDate']),
      profileImageUrl: json['profileImageUrl'],
      preferredDeliveryTime: json['preferredDeliveryTime'],
      dietaryPreferences: List<String>.from(json['dietaryPreferences']),
      totalSpent: json['totalSpent']?.toDouble() ?? 0.0,
      totalOrders: json['totalOrders'] ?? 0,
      favoriteProducts: List<String>.from(json['favoriteProducts'] ?? []),
      deliveryAddress: json['deliveryAddress'],
      subscribeToNewsletter: json['subscribeToNewsletter'] ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'preferredDeliveryTime': preferredDeliveryTime,
      'dietaryPreferences': dietaryPreferences,
      'totalSpent': totalSpent,
      'totalOrders': totalOrders,
      'favoriteProducts': favoriteProducts,
      'deliveryAddress': deliveryAddress,
      'subscribeToNewsletter': subscribeToNewsletter,
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
    DateTime? joinDate,
    UserRole? role,
    String? profileImageUrl,
    String? preferredDeliveryTime,
    List<String>? dietaryPreferences,
    double? totalSpent,
    int? totalOrders,
    List<String>? favoriteProducts,
    String? deliveryAddress,
    bool? subscribeToNewsletter,
  }) {
    return Buyer(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      joinDate: joinDate ?? this.joinDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferredDeliveryTime:
          preferredDeliveryTime ?? this.preferredDeliveryTime,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      totalSpent: totalSpent ?? this.totalSpent,
      totalOrders: totalOrders ?? this.totalOrders,
      favoriteProducts: favoriteProducts ?? this.favoriteProducts,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      subscribeToNewsletter:
          subscribeToNewsletter ?? this.subscribeToNewsletter,
    );
  }
}
