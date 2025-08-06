class UserProfile {
  final String id;
  final String username;
  final String? avatarUrl;

  UserProfile({required this.id, required this.username, this.avatarUrl});

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      username: map['username'] as String,
      avatarUrl: map['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'username': username, 'avatar_url': avatarUrl};
  }
}
