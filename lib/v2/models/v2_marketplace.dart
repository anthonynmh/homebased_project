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
    V2UserType.owner => 'Create storefronts and manage food catalog items.',
  };
}

class V2Availability {
  static const available = 'available';
  static const preorder = 'preorder';
  static const soldOut = 'soldOut';

  static const values = [available, preorder, soldOut];

  static String label(String value) => switch (value) {
    available => 'Available',
    preorder => 'Preorder',
    soldOut => 'Sold out',
    _ => 'Available',
  };
}

class V2CurrentUser {
  final String id;
  final String displayName;
  final V2UserType userType;
  final LatLng location;

  const V2CurrentUser({
    required this.id,
    required this.displayName,
    required this.userType,
    required this.location,
  });

  V2CurrentUser copyWith({
    String? id,
    String? displayName,
    V2UserType? userType,
    LatLng? location,
  }) {
    return V2CurrentUser(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
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
  final String pickupArea;
  final LatLng location;

  const V2Storefront({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.pickupArea,
    required this.location,
  });

  V2Storefront copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? pickupArea,
    LatLng? location,
  }) {
    return V2Storefront(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
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
  final String availability;
  final String? imageUrl;

  const V2CatalogItem({
    required this.id,
    required this.storefrontId,
    required this.name,
    required this.description,
    required this.price,
    this.category = 'food',
    this.availability = V2Availability.available,
    this.imageUrl,
  });

  String get priceLabel => 'S\$${price.toStringAsFixed(2)}';

  String get availabilityLabel => V2Availability.label(availability);

  V2CatalogItem copyWith({
    String? id,
    String? storefrontId,
    String? name,
    String? description,
    double? price,
    String? category,
    String? availability,
    String? imageUrl,
  }) {
    return V2CatalogItem(
      id: id ?? this.id,
      storefrontId: storefrontId ?? this.storefrontId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      availability: availability ?? this.availability,
      imageUrl: imageUrl ?? this.imageUrl,
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
  final String userId;
  final String body;
  final DateTime createdAt;

  const V2Comment({
    required this.id,
    required this.storefrontId,
    required this.userId,
    required this.body,
    required this.createdAt,
  });
}
