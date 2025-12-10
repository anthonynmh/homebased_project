import 'dart:convert';

class Author {
  final String username;
  final String? name;
  final String avatar;
  final String? businessName;

  Author({
    required this.username,
    required this.avatar,
    this.name,
    this.businessName,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'avatar': avatar,
      'businessName': businessName,
    };
  }

  factory Author.fromMap(Map<String, dynamic> map) {
    return Author(
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      avatar: map['avatar'] ?? '',
      businessName: map['businessName'] ?? '',
    );
  }
}

class Post {
  final String postId;
  final String userId;
  final String username;
  final String? fullName;
  final String? avatarUrl;
  final String? businessName;
  final String postText;
  final String? postPhotoUrl;
  final String timestamp;
  final int numLikes;
  final int numReplies;
  final bool isFollowing;

  Post({
    required this.postId,
    required this.userId,
    required this.username,
    this.fullName,
    this.avatarUrl,
    this.businessName,
    required this.postText,
    this.postPhotoUrl,
    required this.timestamp,
    required this.numLikes,
    required this.numReplies,
    required this.isFollowing,
  });

  Map<String, dynamic> toMap() { // Should 
    return {
      'post_id': postId,
      'user_id': userId,
      'post_text': postText,
      'photo_url': postPhotoUrl,
      'created_at': timestamp,
      'num_Likes': numLikes,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      postId: map['id'],
      userId: map['user_id'],
      username: map['username'],
      fullName: map['full_name'],
      avatarUrl: map['avatar_url'],
      businessName: map['businessName'],
      postText: map['post_text'] ?? '',
      postPhotoUrl: map['photo_url'],
      timestamp: map['timestamp'],
      numLikes: map['num_likes']?.toInt() ?? 0,
      numReplies: 0,
      isFollowing: false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) => Post.fromMap(json.decode(source));

  Post copyWith({
    String? postId,
    String? userId,
    String? username,
    String? fullname,
    String? avatarUrl,
    String? businessName,
    String? content,
    String? image,
    String? timestamp,
    int? initialLikes,
    int? initialReplies,
    bool? isFollowing,
  }) {
    return Post(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      fullName: fullname ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      businessName: businessName ?? this.businessName,
      postText: content ?? this.postText,
      postPhotoUrl: image ?? this.postPhotoUrl,
      timestamp: timestamp ?? this.timestamp,
      numLikes: initialLikes ?? this.numLikes,
      numReplies: initialReplies ?? this.numReplies,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}