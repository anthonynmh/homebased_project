import 'package:maplibre_gl/maplibre_gl.dart';

enum V2UserMode { casual, lister }

extension V2UserModeLabel on V2UserMode {
  String get label => switch (this) {
    V2UserMode.casual => 'Casual',
    V2UserMode.lister => 'Lister',
  };

  String get description => switch (this) {
    V2UserMode.casual => 'Browse and subscribe to nearby listings.',
    V2UserMode.lister => 'Create listings and manage interested users.',
  };
}

class V2Subscription {
  final String id;
  final String userName;
  final String note;
  final String status;

  const V2Subscription({
    required this.id,
    required this.userName,
    required this.note,
    required this.status,
  });
}

class V2ThreadMessage {
  final String author;
  final String message;
  final String timeLabel;
  final bool fromLister;

  const V2ThreadMessage({
    required this.author,
    required this.message,
    required this.timeLabel,
    required this.fromLister,
  });
}

class V2Listing {
  final String id;
  final String title;
  final String category;
  final String description;
  final String listerName;
  final String pickupArea;
  final String priceLabel;
  final DateTime availableFrom;
  final DateTime availableUntil;
  final LatLng location;
  final bool ownedByCurrentLister;
  final List<V2Subscription> subscriptions;
  final List<V2ThreadMessage> threadMessages;

  const V2Listing({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.listerName,
    required this.pickupArea,
    required this.priceLabel,
    required this.availableFrom,
    required this.availableUntil,
    required this.location,
    required this.ownedByCurrentLister,
    required this.subscriptions,
    required this.threadMessages,
  });

  int get interestCount => subscriptions.length;

  V2Listing copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    String? listerName,
    String? pickupArea,
    String? priceLabel,
    DateTime? availableFrom,
    DateTime? availableUntil,
    LatLng? location,
    bool? ownedByCurrentLister,
    List<V2Subscription>? subscriptions,
    List<V2ThreadMessage>? threadMessages,
  }) {
    return V2Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      listerName: listerName ?? this.listerName,
      pickupArea: pickupArea ?? this.pickupArea,
      priceLabel: priceLabel ?? this.priceLabel,
      availableFrom: availableFrom ?? this.availableFrom,
      availableUntil: availableUntil ?? this.availableUntil,
      location: location ?? this.location,
      ownedByCurrentLister: ownedByCurrentLister ?? this.ownedByCurrentLister,
      subscriptions: subscriptions ?? this.subscriptions,
      threadMessages: threadMessages ?? this.threadMessages,
    );
  }
}
