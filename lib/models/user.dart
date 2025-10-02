class User {
  const User({
    required this.id,
    required this.email,
    this.name,
    this.role,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String? name;
  final String? role;
  final String? avatarUrl;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? json['userId'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      role: json['role'] as String?,
      avatarUrl: json['image'] as String? ?? json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }

  User copyWith({
    String? name,
    String? role,
    String? avatarUrl,
  }) {
    return User(
      id: id,
      email: email,
      name: name ?? this.name,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
