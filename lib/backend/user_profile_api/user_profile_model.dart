import 'dart:convert';

class UserProfile {
  final String id;
  final String? updatedAt;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? email;

  UserProfile({
    required this.id,
    this.updatedAt,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.email,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
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

  UserProfile copyWith({
    String? id,
    String? updatedAt,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? email,
  }) {
    return UserProfile(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email,
    );
  }

  @override
  String toString() {
    return const JsonEncoder.withIndent('  ').convert(toMap());
  }
}
