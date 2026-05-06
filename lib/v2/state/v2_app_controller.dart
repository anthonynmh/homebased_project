import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:homebased_project/v2/data/v2_mock_data.dart';
import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/utils/v2_geo.dart';

class V2AppController extends ChangeNotifier {
  final Map<String, String> _userNamesById = buildV2MockUserNames();
  final List<V2Storefront> _storefronts = buildV2MockStorefronts();
  final List<V2CatalogItem> _catalogItems = buildV2MockCatalogItems();
  final List<V2Subscription> _subscriptions = buildV2MockSubscriptions();
  final List<V2Comment> _comments = buildV2MockComments();

  V2CurrentUser? _currentUser;
  String? _selectedStorefrontId = 'sf-mika-bakes';
  int _createdStorefronts = 0;
  int _createdCatalogItems = 0;
  int _createdComments = 0;
  int _createdSubscriptions = 0;

  V2CurrentUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  V2UserType get userType => _currentUser?.userType ?? V2UserType.casual;
  LatLng get currentLocation => _currentUser?.location ?? V2Geo.singaporeCenter;
  double get radiusKm => V2Geo.radiusKm;

  List<V2Storefront> get allStorefronts => List.unmodifiable(_storefronts);

  List<V2Storefront> get nearbyStorefronts {
    final storefronts = _storefronts
        .where((storefront) => distanceFromCurrentKm(storefront) <= radiusKm)
        .toList();

    storefronts.sort(
      (a, b) => distanceFromCurrentKm(a).compareTo(distanceFromCurrentKm(b)),
    );

    return storefronts;
  }

  List<V2Storefront> get ownedStorefronts {
    final userId = _currentUser?.id;
    if (userId == null) return const [];

    return _storefronts
        .where((storefront) => storefront.ownerId == userId)
        .toList(growable: false);
  }

  V2Storefront? get selectedStorefront {
    if (_selectedStorefrontId == null) return _firstNearbyOrNull();
    return storefrontById(_selectedStorefrontId!) ?? _firstNearbyOrNull();
  }

  int get subscribedCount {
    final userId = _currentUser?.id;
    if (userId == null) return 0;
    return _subscriptions
        .where((subscription) => subscription.userId == userId)
        .length;
  }

  int get catalogItemCount => _catalogItems.length;

  V2Storefront? storefrontById(String storefrontId) {
    for (final storefront in _storefronts) {
      if (storefront.id == storefrontId) return storefront;
    }
    return null;
  }

  List<V2CatalogItem> catalogFor(String storefrontId) {
    return _catalogItems
        .where((item) => item.storefrontId == storefrontId)
        .toList(growable: false);
  }

  List<V2Comment> commentsFor(String storefrontId) {
    final comments = _comments
        .where((comment) => comment.storefrontId == storefrontId)
        .toList();
    comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return comments;
  }

  List<V2Subscription> subscriptionsFor(String storefrontId) {
    return _subscriptions
        .where((subscription) => subscription.storefrontId == storefrontId)
        .toList(growable: false);
  }

  int subscriberCountFor(String storefrontId) {
    return subscriptionsFor(storefrontId).length;
  }

  bool isSubscribed(String storefrontId) {
    final userId = _currentUser?.id;
    if (userId == null) return false;

    return _subscriptions.any(
      (subscription) =>
          subscription.userId == userId &&
          subscription.storefrontId == storefrontId,
    );
  }

  bool canManage(String storefrontId) {
    final user = _currentUser;
    if (user == null || user.userType != V2UserType.owner) return false;
    final storefront = storefrontById(storefrontId);
    return storefront?.ownerId == user.id;
  }

  bool canComment(String storefrontId) {
    return canManage(storefrontId) || isSubscribed(storefrontId);
  }

  String displayNameFor(String userId) {
    return _userNamesById[userId] ?? 'Neighbour';
  }

  double distanceFromCurrentKm(V2Storefront storefront) {
    return V2Geo.distanceKm(currentLocation, storefront.location);
  }

  void simulateLogin({
    required String displayName,
    V2UserType userType = V2UserType.casual,
  }) {
    _setDemoUser(displayName: displayName, userType: userType);
  }

  void simulateSignup({
    required String displayName,
    V2UserType userType = V2UserType.casual,
  }) {
    _setDemoUser(displayName: displayName, userType: userType);
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void updateDisplayName(String displayName) {
    final user = _currentUser;
    final trimmed = displayName.trim();
    if (user == null || trimmed.isEmpty) return;

    _currentUser = user.copyWith(displayName: trimmed);
    _userNamesById[user.id] = trimmed;
    notifyListeners();
  }

  void setUserType(V2UserType userType) {
    final user = _currentUser;
    if (user == null || user.userType == userType) return;

    _currentUser = user.copyWith(userType: userType);
    notifyListeners();
  }

  void selectStorefront(String storefrontId) {
    _selectedStorefrontId = storefrontId;
    notifyListeners();
  }

  void subscribe(String storefrontId) {
    final user = _currentUser;
    if (user == null || isSubscribed(storefrontId)) return;

    _createdSubscriptions += 1;
    _subscriptions.add(
      V2Subscription(
        id: 'sub-local-$_createdSubscriptions',
        userId: user.id,
        storefrontId: storefrontId,
      ),
    );
    _selectedStorefrontId = storefrontId;
    notifyListeners();
  }

  void unsubscribe(String storefrontId) {
    final userId = _currentUser?.id;
    if (userId == null) return;

    _subscriptions.removeWhere(
      (subscription) =>
          subscription.userId == userId &&
          subscription.storefrontId == storefrontId,
    );
    notifyListeners();
  }

  void createStorefront({
    required String name,
    required String description,
    required String pickupArea,
  }) {
    final user = _currentUser;
    if (user == null) return;

    _createdStorefronts += 1;
    final location = V2Geo.offsetFromCenter(
      northMeters: 160 + (_createdStorefronts * 80),
      eastMeters: -130 + (_createdStorefronts * 95),
    );
    final storefrontId = 'sf-local-$_createdStorefronts';
    final storefront = V2Storefront(
      id: storefrontId,
      ownerId: user.id,
      name: name.trim().isEmpty ? 'New home kitchen' : name.trim(),
      description: description.trim().isEmpty
          ? 'A new frontend-only storefront.'
          : description.trim(),
      pickupArea: pickupArea.trim().isEmpty ? 'Near you' : pickupArea.trim(),
      location: location,
    );

    _storefronts.insert(0, storefront);
    addCatalogItem(
      storefrontId: storefrontId,
      name: 'Sample food item',
      description: 'Edit this item to preview catalog management.',
      price: 12,
      availability: V2Availability.preorder,
      notify: false,
    );
    _selectedStorefrontId = storefrontId;
    _currentUser = user.copyWith(userType: V2UserType.owner);
    notifyListeners();
  }

  void updateStorefront({
    required String storefrontId,
    required String name,
    required String description,
    required String pickupArea,
  }) {
    if (!canManage(storefrontId)) return;

    final index = _storefronts.indexWhere(
      (storefront) => storefront.id == storefrontId,
    );
    if (index == -1) return;

    final storefront = _storefronts[index];
    _storefronts[index] = storefront.copyWith(
      name: name.trim().isEmpty ? storefront.name : name.trim(),
      description: description.trim().isEmpty
          ? storefront.description
          : description.trim(),
      pickupArea: pickupArea.trim().isEmpty
          ? storefront.pickupArea
          : pickupArea.trim(),
    );
    notifyListeners();
  }

  void addCatalogItem({
    required String storefrontId,
    required String name,
    required String description,
    required double price,
    required String availability,
    bool notify = true,
  }) {
    if (notify && !canManage(storefrontId)) return;

    _createdCatalogItems += 1;
    _catalogItems.add(
      V2CatalogItem(
        id: 'item-local-$_createdCatalogItems',
        storefrontId: storefrontId,
        name: name.trim().isEmpty ? 'New food item' : name.trim(),
        description: description.trim().isEmpty
            ? 'A frontend-only catalog item.'
            : description.trim(),
        price: price < 0 ? 0 : price,
        availability: availability,
      ),
    );

    if (notify) notifyListeners();
  }

  void updateCatalogItem({
    required String itemId,
    required String name,
    required String description,
    required double price,
    required String availability,
  }) {
    final index = _catalogItems.indexWhere((item) => item.id == itemId);
    if (index == -1) return;

    final item = _catalogItems[index];
    if (!canManage(item.storefrontId)) return;

    _catalogItems[index] = item.copyWith(
      name: name.trim().isEmpty ? item.name : name.trim(),
      description: description.trim().isEmpty
          ? item.description
          : description.trim(),
      price: price < 0 ? item.price : price,
      availability: availability,
    );
    notifyListeners();
  }

  bool postComment({required String storefrontId, required String body}) {
    final user = _currentUser;
    final trimmed = body.trim();
    if (user == null || trimmed.isEmpty || !canComment(storefrontId)) {
      return false;
    }

    _createdComments += 1;
    _comments.add(
      V2Comment(
        id: 'comment-local-$_createdComments',
        storefrontId: storefrontId,
        userId: user.id,
        body: trimmed,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return true;
  }

  void _setDemoUser({
    required String displayName,
    required V2UserType userType,
  }) {
    final trimmed = displayName.trim().isEmpty
        ? 'Demo user'
        : displayName.trim();
    _currentUser = V2CurrentUser(
      id: v2DemoUserId,
      displayName: trimmed,
      userType: userType,
      location: V2Geo.singaporeCenter,
    );
    _userNamesById[v2DemoUserId] = trimmed;
    notifyListeners();
  }

  V2Storefront? _firstNearbyOrNull() {
    final storefronts = nearbyStorefronts;
    return storefronts.isEmpty ? null : storefronts.first;
  }
}
