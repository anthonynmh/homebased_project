import 'package:maplibre_gl/maplibre_gl.dart';

enum V2UserType { casual, owner }

extension V2UserTypeLabel on V2UserType {
  String get label => switch (this) {
    V2UserType.casual => 'Casual',
    V2UserType.owner => 'Owner',
  };

  String get accountLabel => switch (this) {
    V2UserType.casual => 'Casual user',
    V2UserType.owner => 'Storefront owner',
  };

  String get description => switch (this) {
    V2UserType.casual => 'Browse nearby storefronts and subscriptions.',
    V2UserType.owner => 'Manage a storefront, products, and community.',
  };
}

class V2ProductStatus {
  static const live = 'live';
  static const upcoming = 'upcoming';

  static const values = [live, upcoming];

  static String label(String value) => switch (value) {
    live => 'Live',
    upcoming => 'Upcoming',
    _ => 'Live',
  };
}

class V2Availability {
  static const available = V2ProductStatus.live;
  static const preorder = V2ProductStatus.upcoming;
  static const soldOut = 'soldOut';

  static const values = [available, preorder];

  static String label(String value) => V2ProductStatus.label(value);
}

class V2CurrentUser {
  final String id;
  final String displayName;
  final String email;
  final V2UserType userType;
  final LatLng location;

  const V2CurrentUser({
    required this.id,
    required this.displayName,
    required this.email,
    required this.userType,
    required this.location,
  });

  V2CurrentUser copyWith({
    String? id,
    String? displayName,
    String? email,
    V2UserType? userType,
    LatLng? location,
  }) {
    return V2CurrentUser(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      location: location ?? this.location,
    );
  }
}

class V2Storefront {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String category;
  final String pickupArea;
  final LatLng location;

  const V2Storefront({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    this.category = 'Bakery',
    required this.pickupArea,
    required this.location,
  });

  V2Storefront copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? category,
    String? pickupArea,
    LatLng? location,
  }) {
    return V2Storefront(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      pickupArea: pickupArea ?? this.pickupArea,
      location: location ?? this.location,
    );
  }
}

class V2CatalogItem {
  final String id;
  final String storefrontId;
  final String name;
  final String description;
  final double price;
  final String category;
  final String status;
  final String? imageUrl;

  const V2CatalogItem({
    required this.id,
    required this.storefrontId,
    required this.name,
    required this.description,
    required this.price,
    this.category = 'Food',
    this.status = V2ProductStatus.live,
    this.imageUrl,
  });

  String get priceLabel => 'S\$${price.toStringAsFixed(2)}';

  String get statusLabel => V2ProductStatus.label(status);

  String get availability => status;

  String get availabilityLabel => statusLabel;

  V2CatalogItem copyWith({
    String? id,
    String? storefrontId,
    String? name,
    String? description,
    double? price,
    String? category,
    String? status,
    String? imageUrl,
    bool clearImageUrl = false,
  }) {
    return V2CatalogItem(
      id: id ?? this.id,
      storefrontId: storefrontId ?? this.storefrontId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      status: status ?? this.status,
      imageUrl: clearImageUrl ? null : imageUrl ?? this.imageUrl,
    );
  }
}

class V2Subscription {
  final String id;
  final String userId;
  final String storefrontId;

  const V2Subscription({
    required this.id,
    required this.userId,
    required this.storefrontId,
  });
}

class V2Comment {
  final String id;
  final String storefrontId;
  final String threadId;
  final String userId;
  final String body;
  final DateTime createdAt;

  const V2Comment({
    required this.id,
    required this.storefrontId,
    this.threadId = 'thread-general',
    required this.userId,
    required this.body,
    required this.createdAt,
  });
}

class V2DiscussionThread {
  final String id;
  final String storefrontId;
  final String title;
  final String relatedLabel;

  const V2DiscussionThread({
    required this.id,
    required this.storefrontId,
    required this.title,
    required this.relatedLabel,
  });
}

class V2NotificationItem {
  final String id;
  final String storefrontId;
  final String type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;

  const V2NotificationItem({
    required this.id,
    required this.storefrontId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });

  V2NotificationItem copyWith({bool? read}) {
    return V2NotificationItem(
      id: id,
      storefrontId: storefrontId,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      read: read ?? this.read,
    );
  }
}
