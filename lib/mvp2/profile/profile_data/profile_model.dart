import 'dart:convert';

class Profile {
  final String id;
  final String? updatedAt;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? email;

  Profile({
    required this.id,
    this.updatedAt,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.email,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      updatedAt: map['updated_at'] as String?,
      username: map['username'] as String?,
      fullName: map['full_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      email: map['email'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'updated_at': updatedAt,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'email': email,
    };
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toMap());
  }
}
