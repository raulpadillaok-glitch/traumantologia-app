class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String role; // 'admin' or 'user'
  final String themeName;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.role = 'user',
    this.themeName = 'Oscuro',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      role: json['role'] ?? 'user',
      themeName: json['themeName'] ?? 'Oscuro',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'themeName': themeName,
    };
  }
}
