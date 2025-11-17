/// User model class representing a user in the database
class User {
  final int? id;
  final String fullName;
  final String email;
  final String password;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    this.id,
    required this.fullName,
    required this.email,
    required this.password,
    DateTime? createdAt,
    this.lastLogin,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert User object to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  /// Create User object from Map (database query result)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      fullName: map['fullName'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastLogin: map['lastLogin'] != null 
          ? DateTime.parse(map['lastLogin'] as String) 
          : null,
    );
  }

  /// Create a copy of User with updated fields
  User copyWith({
    int? id,
    String? fullName,
    String? email,
    String? password,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, fullName: $fullName, email: $email, createdAt: $createdAt}';
  }
}

