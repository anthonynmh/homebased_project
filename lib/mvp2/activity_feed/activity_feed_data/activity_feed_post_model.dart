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
  final String id;
  final Author author;
  final String content;
  final String? image;
  final String timestamp;
  final int initialLikes;
  final int initialReplies;
  final bool isFollowing;

  Post({
    required this.id,
    required this.author,
    required this.content,
    this.image,
    required this.timestamp,
    required this.initialLikes,
    required this.initialReplies,
    required this.isFollowing,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'author': author.toMap(),
      'content': content,
      'image': image,
      'timestamp': timestamp,
      'initialLikes': initialLikes,
      'initialReplies': initialReplies,
      'isFollowing': isFollowing,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] ?? '',
      author: Author.fromMap(map['author']),
      content: map['content'] ?? '',
      image: map['image'],
      timestamp: map['timestamp'] ?? '',
      initialLikes: map['initialLikes']?.toInt() ?? 0,
      initialReplies: map['initialReplies']?.toInt() ?? 0,
      isFollowing: map['isFollowing'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) => Post.fromMap(json.decode(source));

  Post copyWith({
    String? id,
    Author? author,
    String? content,
    String? image,
    String? timestamp,
    int? initialLikes,
    int? initialReplies,
    bool? isFollowing,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      content: content ?? this.content,
      image: image ?? this.image,
      timestamp: timestamp ?? this.timestamp,
      initialLikes: initialLikes ?? this.initialLikes,
      initialReplies: initialReplies ?? this.initialReplies,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}