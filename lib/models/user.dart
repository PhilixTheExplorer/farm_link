enum UserRole { farmer, buyer }

class User {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? location;
  final UserRole role;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.location,
    required this.role,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      location: json['location'],
      role: _parseUserRole(json['role']),
      profileImageUrl: json['profile_image_url'] ?? json['profileImageUrl'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  static UserRole _parseUserRole(String? role) {
    switch (role?.toLowerCase()) {
      case 'farmer':
        return UserRole.farmer;
      case 'buyer':
        return UserRole.buyer;
      default:
        return UserRole.buyer; // Default to buyer
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'location': location,
      'role': role.toString().split('.').last,
      'profile_image_url': profileImageUrl,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? location,
    UserRole? role,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters
  String get displayName => name ?? email.split('@').first;
  String get roleDisplayName => role.toString().split('.').last.toUpperCase();
  bool get isFarmer => role == UserRole.farmer;
  bool get isBuyer => role == UserRole.buyer;
}
