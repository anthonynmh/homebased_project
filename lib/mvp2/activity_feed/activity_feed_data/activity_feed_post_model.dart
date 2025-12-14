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
  final int likeCount;
  final int numReplies;
  final bool isLiked;

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
    required this.likeCount,
    required this.numReplies,
    required this.isLiked,
  });

  Map<String, dynamic> toMap() { // Should 
    return {
      'post_id': postId,
      'user_id': userId,
      'post_text': postText,
      'photo_url': postPhotoUrl,
      'created_at': timestamp,
    };
  }

  Map<String, dynamic> toMapWithAuthor() {
    return {
      ...toMap(),
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'business_name': businessName,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      postId: map['post_id'],
      userId: map['user_id'],
      username: map['username'],
      fullName: map['full_name'],
      avatarUrl: map['avatar_url'].trim(),
      businessName: map['business_name'],
      postText: map['post_text'] ?? '',
      postPhotoUrl: map['photo_url'],
      timestamp: map['timestamp'],
      likeCount: map['like_count']?.toInt() ?? 0,
      numReplies: 0,
      isLiked: map['liked_by_user'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) => Post.fromMap(json.decode(source));

  Post copyWith({
    String? postId,
    String? userId,
    String? username,
    String? fullName,
    String? avatarUrl,
    String? businessName,
    String? postText,
    String? postPhotoUrl,
    String? timestamp,
    int? likeCount,
    int? numReplies,
    bool? isLiked,
  }) {
    return Post(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      businessName: businessName ?? this.businessName,
      postText: postText ?? this.postText,
      postPhotoUrl: postPhotoUrl ?? this.postPhotoUrl,
      timestamp: timestamp ?? this.timestamp,
      likeCount: likeCount ?? this.likeCount,
      numReplies: numReplies ?? this.numReplies,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}