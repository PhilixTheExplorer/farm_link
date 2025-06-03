import 'user.dart';

class Farmer extends User {
  final String? farmName;
  final String? farmAddress;
  final int totalSales;
  final bool isVerified;

  Farmer({
    required super.id,
    required super.email,
    required super.name,
    required super.phone,
    required super.location,
    super.profileImageUrl,
    this.farmName,
    this.farmAddress,
    this.totalSales = 0,
    this.isVerified = false,
  }) : super(role: UserRole.farmer);

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      location: json['location'],
      profileImageUrl: json['profileImageUrl'],
      farmName: json['farmName'] ?? '',
      farmAddress: json['farmAddress'] ?? '',
      totalSales: json['totalSales'] ?? 0,
      isVerified: json['isVerified'] ?? false,
    );
  }
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'farmName': farmName,
      'farmAddress': farmAddress,
      'totalSales': totalSales,
      'isVerified': isVerified,
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
    String? farmName,
    String? farmAddress,
    int? totalSales,
    bool? isVerified,
  }) {
    return Farmer(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      farmName: farmName ?? this.farmName,
      farmAddress: farmAddress ?? this.farmAddress,
      totalSales: totalSales ?? this.totalSales,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  String toString() {
    return 'Farmer(id: $id, email: $email, name: $name, farmName: $farmName, farmAddress: $farmAddress, totalSales: $totalSales, isVerified: $isVerified)';
  }
}
