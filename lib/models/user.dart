enum UserRole { farmer, buyer }

class User {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? location;
  final UserRole role;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.location,
    required this.role,
    this.profileImageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      location: json['location'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
      ),
      profileImageUrl: json['profileImageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'location': location,
      'role': role.toString().split('.').last,
      'profileImageUrl': profileImageUrl,
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
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
