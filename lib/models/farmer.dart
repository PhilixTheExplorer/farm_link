import 'user.dart';

class Farmer extends User {
  final String? farmName;
  final String? farmAddress;
  final String? description;
  final int totalSales;
  final bool isVerified;
  final int? totalProducts;

  Farmer({
    required super.id,
    required super.email,
    required super.name,
    required super.phone,
    required super.location,
    super.profileImageUrl,
    super.createdAt,
    super.updatedAt,
    this.farmName,
    this.farmAddress,
    this.description,
    this.totalSales = 0,
    this.isVerified = false,
    this.totalProducts,
  }) : super(role: UserRole.farmer);

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
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
      farmName: json['farm_name'] ?? json['farmName'],
      farmAddress: json['farm_address'] ?? json['farmAddress'],
      description: json['description'],
      totalSales: json['total_sales'] ?? json['totalSales'] ?? 0,
      isVerified: json['is_verified'] ?? json['isVerified'] ?? false,
      totalProducts: json['total_products'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'farm_name': farmName,
      'farm_address': farmAddress,
      'description': description,
      'total_sales': totalSales,
      'is_verified': isVerified,
      if (totalProducts != null) 'total_products': totalProducts,
    });
    return json;
  }

  @override
  Farmer copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? location,
    UserRole? role,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? farmName,
    String? farmAddress,
    String? description,
    int? totalSales,
    bool? isVerified,
    int? totalProducts,
  }) {
    return Farmer(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      farmName: farmName ?? this.farmName,
      farmAddress: farmAddress ?? this.farmAddress,
      description: description ?? this.description,
      totalSales: totalSales ?? this.totalSales,
      isVerified: isVerified ?? this.isVerified,
      totalProducts: totalProducts ?? this.totalProducts,
    );
  }

  // Helper getters
  String get displayFarmName => farmName ?? 'Farm';
  String get verificationStatus => isVerified ? 'Verified' : 'Unverified';

  @override
  String toString() {
    return 'Farmer(id: $id, email: $email, name: $name, farmName: $farmName, farmAddress: $farmAddress, totalSales: $totalSales, isVerified: $isVerified)';
  }
}
