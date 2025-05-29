enum UserRole { farmer, buyer }

class User {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? location;
  final DateTime joinDate;
  final UserRole role;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.location,
    required this.joinDate,
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
      joinDate: DateTime.parse(json['joinDate']),
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
      'joinDate': joinDate.toIso8601String(),
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
    DateTime? joinDate,
    UserRole? role,
    String? profileImageUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      joinDate: joinDate ?? this.joinDate,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
