import 'user.dart';

class Farmer extends User {
  final String farmName;
  final double farmSize; // in acres
  final List<String> cropTypes;
  final String farmingMethod; // organic, conventional, etc.
  final double rating;
  final int totalSales;
  final bool isVerified;
  final String? certifications;

  Farmer({
    required super.id,
    required super.email,
    required super.name,
    required super.phone,
    required super.location,
    required super.joinDate,
    super.profileImageUrl,
    required this.farmName,
    required this.farmSize,
    required this.cropTypes,
    required this.farmingMethod,
    this.rating = 0.0,
    this.totalSales = 0,
    this.isVerified = false,
    this.certifications,
  }) : super(role: UserRole.farmer);

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      location: json['location'],
      joinDate: DateTime.parse(json['joinDate']),
      profileImageUrl: json['profileImageUrl'],
      farmName: json['farmName'],
      farmSize: json['farmSize'].toDouble(),
      cropTypes: List<String>.from(json['cropTypes']),
      farmingMethod: json['farmingMethod'],
      rating: json['rating']?.toDouble() ?? 0.0,
      totalSales: json['totalSales'] ?? 0,
      isVerified: json['isVerified'] ?? false,
      certifications: json['certifications'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'farmName': farmName,
      'farmSize': farmSize,
      'cropTypes': cropTypes,
      'farmingMethod': farmingMethod,
      'rating': rating,
      'totalSales': totalSales,
      'isVerified': isVerified,
      'certifications': certifications,
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
    DateTime? joinDate,
    UserRole? role,
    String? profileImageUrl,
    String? farmName,
    double? farmSize,
    List<String>? cropTypes,
    String? farmingMethod,
    double? rating,
    int? totalSales,
    bool? isVerified,
    String? certifications,
  }) {
    return Farmer(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      joinDate: joinDate ?? this.joinDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      farmName: farmName ?? this.farmName,
      farmSize: farmSize ?? this.farmSize,
      cropTypes: cropTypes ?? this.cropTypes,
      farmingMethod: farmingMethod ?? this.farmingMethod,
      rating: rating ?? this.rating,
      totalSales: totalSales ?? this.totalSales,
      isVerified: isVerified ?? this.isVerified,
      certifications: certifications ?? this.certifications,
    );
  }
}
