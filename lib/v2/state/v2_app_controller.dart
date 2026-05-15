import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:homebased_project/v2/data/v2_mock_data.dart';
import 'package:homebased_project/v2/models/v2_marketplace.dart';
import 'package:homebased_project/v2/utils/v2_geo.dart';

class V2AppController extends ChangeNotifier {
  static const _storageKey = 'communitii.v2.prototype_state';

  final Map<String, String> _userNamesById = buildV2MockUserNames();
  List<V2Storefront> _storefronts = buildV2MockStorefronts();
  List<V2CatalogItem> _catalogItems = buildV2MockCatalogItems();
  List<V2Subscription> _subscriptions = buildV2MockSubscriptions();
  List<V2DiscussionThread> _threads = buildV2MockThreads();
  List<V2Comment> _comments = buildV2MockComments();
  List<V2NotificationItem> _notifications = buildV2MockNotifications();

  V2CurrentUser? _currentUser;
  String? _selectedStorefrontId = 'sf-mika-bakes';
  int _createdStorefronts = 0;
  int _createdCatalogItems = 0;
  int _createdComments = 0;
  int _createdSubscriptions = 0;
  int _createdThreads = 0;
  bool _restoring = false;

  V2AppController({bool loadPersistedState = true}) {
    if (loadPersistedState) {
      unawaited(loadPersistedStateFromDisk());
    }
  }

  V2CurrentUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  V2UserType get userType => _currentUser?.userType ?? V2UserType.casual;
  V2GeoPoint get currentLocation =>
      _currentUser?.location ?? V2Geo.singaporeCenter;
  double get radiusKm => V2Geo.radiusKm;

  List<V2Storefront> get allStorefronts => List.unmodifiable(_storefronts);
  List<V2CatalogItem> get allCatalogItems => List.unmodifiable(_catalogItems);
  List<V2NotificationItem> get notifications {
    final items = [..._notifications];
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  List<String> get storefrontCategories {
    final categories = _storefronts.map((storefront) => storefront.category);
    return [
      'All',
      ...{...categories}.toList()..sort(),
    ];
  }

  List<V2Storefront> get nearbyStorefronts {
    final storefronts = _storefronts
        .where((storefront) => distanceFromCurrentKm(storefront) <= radiusKm)
        .toList();

    storefronts.sort(
      (a, b) => distanceFromCurrentKm(a).compareTo(distanceFromCurrentKm(b)),
    );

    return storefronts;
  }

  List<V2Storefront> get popularStorefronts {
    final storefronts = [..._storefronts];
    storefronts.sort(
      (a, b) => subscriberCountFor(b.id).compareTo(subscriberCountFor(a.id)),
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

  V2Storefront? get ownerStorefront {
    final owned = ownedStorefronts;
    return owned.isEmpty ? null : owned.first;
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
  int get unreadNotificationCount =>
      _notifications.where((notification) => !notification.read).length;

  List<V2Storefront> discoverStorefronts({
    String query = '',
    String category = 'All',
    bool nearbyOnly = false,
    bool popularOnly = false,
  }) {
    final normalized = query.trim().toLowerCase();
    Iterable<V2Storefront> storefronts = nearbyOnly
        ? nearbyStorefronts
        : _storefronts;

    if (category != 'All') {
      storefronts = storefronts.where(
        (storefront) => storefront.category == category,
      );
    }

    if (normalized.isNotEmpty) {
      storefronts = storefronts.where((storefront) {
        final products = catalogFor(storefront.id);
        final productMatch = products.any(
          (item) =>
              item.name.toLowerCase().contains(normalized) ||
              item.category.toLowerCase().contains(normalized),
        );
        return storefront.name.toLowerCase().contains(normalized) ||
            storefront.description.toLowerCase().contains(normalized) ||
            storefront.category.toLowerCase().contains(normalized) ||
            productMatch;
      });
    }

    final results = storefronts.toList();
    if (popularOnly) {
      results.sort(
        (a, b) => subscriberCountFor(b.id).compareTo(subscriberCountFor(a.id)),
      );
    } else {
      results.sort(
        (a, b) => distanceFromCurrentKm(a).compareTo(distanceFromCurrentKm(b)),
      );
    }
    return results;
  }

  List<V2Storefront> subscribedStorefronts() {
    final userId = _currentUser?.id;
    if (userId == null) return const [];
    final ids = _subscriptions
        .where((subscription) => subscription.userId == userId)
        .map((subscription) => subscription.storefrontId)
        .toSet();
    return _storefronts
        .where((storefront) => ids.contains(storefront.id))
        .toList(growable: false);
  }

  List<V2CatalogItem> recentSubscribedProducts() {
    final ids = subscribedStorefronts()
        .map((storefront) => storefront.id)
        .toSet();
    return _catalogItems
        .where((item) => ids.contains(item.storefrontId))
        .toList(growable: false)
        .reversed
        .toList();
  }

  V2Storefront? storefrontById(String storefrontId) {
    for (final storefront in _storefronts) {
      if (storefront.id == storefrontId) return storefront;
    }
    return null;
  }

  V2CatalogItem? catalogItemById(String itemId) {
    for (final item in _catalogItems) {
      if (item.id == itemId) return item;
    }
    return null;
  }

  List<V2CatalogItem> catalogFor(String storefrontId) {
    return _catalogItems
        .where((item) => item.storefrontId == storefrontId)
        .toList(growable: false);
  }

  List<V2CatalogItem> productsFor(String storefrontId, {String? status}) {
    return _catalogItems
        .where(
          (item) =>
              item.storefrontId == storefrontId &&
              (status == null || item.status == status),
        )
        .toList(growable: false);
  }

  List<V2DiscussionThread> threadsForStorefront(String storefrontId) {
    return _threads
        .where((thread) => thread.storefrontId == storefrontId)
        .toList(growable: false);
  }

  V2DiscussionThread? threadById(String threadId) {
    for (final thread in _threads) {
      if (thread.id == threadId) return thread;
    }
    return null;
  }

  List<V2Comment> commentsFor(String storefrontId) {
    final comments = _comments
        .where((comment) => comment.storefrontId == storefrontId)
        .toList();
    comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return comments;
  }

  List<V2Comment> commentsForThread(String threadId) {
    final comments = _comments
        .where((comment) => comment.threadId == threadId)
        .toList();
    comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return comments;
  }

  V2Comment? latestCommentForThread(String threadId) {
    final comments = commentsForThread(threadId);
    return comments.isEmpty ? null : comments.last;
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

  String storefrontNameFor(String storefrontId) {
    return storefrontById(storefrontId)?.name ?? 'Storefront';
  }

  double distanceFromCurrentKm(V2Storefront storefront) {
    return V2Geo.distanceKm(currentLocation, storefront.location);
  }

  void simulateLogin({
    required String displayName,
    String email = 'demo@communitii.test',
    V2UserType userType = V2UserType.casual,
  }) {
    _setDemoUser(displayName: displayName, email: email, userType: userType);
  }

  void simulateSignup({
    required String displayName,
    String email = 'demo@communitii.test',
    V2UserType userType = V2UserType.casual,
  }) {
    _setDemoUser(displayName: displayName, email: email, userType: userType);
  }

  void logout() {
    _currentUser = null;
    _savePersistedState();
    notifyListeners();
  }

  Future<void> deleteMockAccount() async {
    _currentUser = null;
    _storefronts = buildV2MockStorefronts();
    _catalogItems = buildV2MockCatalogItems();
    _subscriptions = buildV2MockSubscriptions();
    _threads = buildV2MockThreads();
    _comments = buildV2MockComments();
    _notifications = buildV2MockNotifications();
    _selectedStorefrontId = 'sf-mika-bakes';
    _createdStorefronts = 0;
    _createdCatalogItems = 0;
    _createdComments = 0;
    _createdSubscriptions = 0;
    _createdThreads = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    notifyListeners();
  }

  void updateDisplayName(String displayName) {
    final user = _currentUser;
    final trimmed = displayName.trim();
    if (user == null || trimmed.isEmpty) return;

    _currentUser = user.copyWith(displayName: trimmed);
    _userNamesById[user.id] = trimmed;
    _saveAndNotify();
  }

  void setUserType(V2UserType userType) {
    final user = _currentUser;
    if (user == null || user.userType == userType) return;

    _currentUser = user.copyWith(userType: userType);
    _saveAndNotify();
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
    _saveAndNotify();
  }

  void unsubscribe(String storefrontId) {
    final userId = _currentUser?.id;
    if (userId == null) return;

    _subscriptions.removeWhere(
      (subscription) =>
          subscription.userId == userId &&
          subscription.storefrontId == storefrontId,
    );
    _saveAndNotify();
  }

  void createStorefront({
    required String name,
    required String description,
    required String category,
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
      name: name.trim().isEmpty ? 'New storefront' : name.trim(),
      description: description.trim().isEmpty
          ? 'A new frontend-only storefront.'
          : description.trim(),
      category: category.trim().isEmpty ? 'Local goods' : category.trim(),
      pickupArea: pickupArea.trim().isEmpty ? 'Near you' : pickupArea.trim(),
      location: location,
    );

    _storefronts.insert(0, storefront);
    addCatalogItem(
      storefrontId: storefrontId,
      name: 'Sample listing',
      description: 'Edit this listing to preview product management.',
      price: 12,
      category: 'Product',
      status: V2ProductStatus.upcoming,
      imageUrl: null,
      notify: false,
    );
    _createdThreads += 1;
    _threads.add(
      V2DiscussionThread(
        id: 'thread-local-$_createdThreads',
        storefrontId: storefrontId,
        title: 'General updates',
        relatedLabel: storefront.name,
      ),
    );
    _selectedStorefrontId = storefrontId;
    _currentUser = user.copyWith(userType: V2UserType.owner);
    _saveAndNotify();
  }

  void updateStorefront({
    required String storefrontId,
    required String name,
    required String description,
    required String category,
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
      category: category.trim().isEmpty ? storefront.category : category.trim(),
      pickupArea: pickupArea.trim().isEmpty
          ? storefront.pickupArea
          : pickupArea.trim(),
    );
    _saveAndNotify();
  }

  void deleteStorefront(String storefrontId) {
    if (!canManage(storefrontId)) return;

    _storefronts.removeWhere((storefront) => storefront.id == storefrontId);
    _catalogItems.removeWhere((item) => item.storefrontId == storefrontId);
    _subscriptions.removeWhere(
      (subscription) => subscription.storefrontId == storefrontId,
    );
    final threadIds = _threads
        .where((thread) => thread.storefrontId == storefrontId)
        .map((thread) => thread.id)
        .toSet();
    _threads.removeWhere((thread) => thread.storefrontId == storefrontId);
    _comments.removeWhere(
      (comment) =>
          comment.storefrontId == storefrontId ||
          threadIds.contains(comment.threadId),
    );
    _notifications.removeWhere(
      (notification) => notification.storefrontId == storefrontId,
    );
    if (_selectedStorefrontId == storefrontId) {
      _selectedStorefrontId = _storefronts.isEmpty
          ? null
          : _storefronts.first.id;
    }
    _saveAndNotify();
  }

  void addCatalogItem({
    required String storefrontId,
    required String name,
    required String description,
    required double price,
    required String category,
    required String status,
    String? imageUrl,
    bool notify = true,
  }) {
    if (notify && !canManage(storefrontId)) return;

    _createdCatalogItems += 1;
    _catalogItems.add(
      V2CatalogItem(
        id: 'item-local-$_createdCatalogItems',
        storefrontId: storefrontId,
        name: name.trim().isEmpty ? 'New product' : name.trim(),
        description: description.trim().isEmpty
            ? 'A frontend-only product listing.'
            : description.trim(),
        price: price < 0 ? 0 : price,
        category: category.trim().isEmpty ? 'Product' : category.trim(),
        status: V2ProductStatus.values.contains(status)
            ? status
            : V2ProductStatus.live,
        imageUrl: _cleanImageUrl(imageUrl),
      ),
    );

    if (notify) _saveAndNotify();
  }

  void updateCatalogItem({
    required String itemId,
    required String name,
    required String description,
    required double price,
    required String category,
    required String status,
    String? imageUrl,
  }) {
    final index = _catalogItems.indexWhere((item) => item.id == itemId);
    if (index == -1) return;

    final item = _catalogItems[index];
    if (!canManage(item.storefrontId)) return;

    final cleanedImageUrl = _cleanImageUrl(imageUrl);
    _catalogItems[index] = item.copyWith(
      name: name.trim().isEmpty ? item.name : name.trim(),
      description: description.trim().isEmpty
          ? item.description
          : description.trim(),
      price: price < 0 ? item.price : price,
      category: category.trim().isEmpty ? item.category : category.trim(),
      status: V2ProductStatus.values.contains(status) ? status : item.status,
      imageUrl: cleanedImageUrl,
      clearImageUrl: cleanedImageUrl == null,
    );
    _saveAndNotify();
  }

  void deleteCatalogItem(String itemId) {
    final item = catalogItemById(itemId);
    if (item == null || !canManage(item.storefrontId)) return;

    _catalogItems.removeWhere((candidate) => candidate.id == itemId);
    _saveAndNotify();
  }

  bool postComment({required String storefrontId, required String body}) {
    final threads = threadsForStorefront(storefrontId);
    final threadId = threads.isEmpty ? 'thread-general' : threads.first.id;
    return postThreadReply(threadId: threadId, body: body);
  }

  V2DiscussionThread? createThread({
    required String storefrontId,
    required String title,
    required String relatedLabel,
    String? openingMessage,
  }) {
    final trimmedTitle = title.trim();
    if (!canManage(storefrontId) || trimmedTitle.isEmpty) return null;

    _createdThreads += 1;
    final thread = V2DiscussionThread(
      id: 'thread-local-$_createdThreads',
      storefrontId: storefrontId,
      title: trimmedTitle,
      relatedLabel: relatedLabel.trim().isEmpty
          ? 'Storefront update'
          : relatedLabel.trim(),
    );
    _threads.insert(0, thread);

    final body = openingMessage?.trim() ?? '';
    if (body.isNotEmpty) {
      _createdComments += 1;
      _comments.add(
        V2Comment(
          id: 'comment-local-$_createdComments',
          storefrontId: storefrontId,
          threadId: thread.id,
          userId: _currentUser!.id,
          body: body,
          createdAt: DateTime.now(),
        ),
      );
    }

    _saveAndNotify();
    return thread;
  }

  bool postThreadReply({required String threadId, required String body}) {
    final user = _currentUser;
    final thread = threadById(threadId);
    final trimmed = body.trim();
    if (user == null || thread == null || trimmed.isEmpty) return false;
    if (!canComment(thread.storefrontId)) return false;

    _createdComments += 1;
    _comments.add(
      V2Comment(
        id: 'comment-local-$_createdComments',
        storefrontId: thread.storefrontId,
        threadId: threadId,
        userId: user.id,
        body: trimmed,
        createdAt: DateTime.now(),
      ),
    );
    _saveAndNotify();
    return true;
  }

  void markAllNotificationsRead() {
    _notifications = _notifications
        .map((notification) => notification.copyWith(read: true))
        .toList();
    _saveAndNotify();
  }

  Future<void> loadPersistedStateFromDisk() async {
    _restoring = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return;

      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic>) return;

      final currentUser = data['currentUser'];
      if (currentUser is Map<String, dynamic>) {
        _currentUser = _currentUserFromJson(currentUser);
      }
      _storefronts = _listFromJson(
        data['storefronts'],
        _storefrontFromJson,
        buildV2MockStorefronts,
      );
      _catalogItems = _listFromJson(
        data['catalogItems'],
        _catalogItemFromJson,
        buildV2MockCatalogItems,
      );
      _subscriptions = _listFromJson(
        data['subscriptions'],
        _subscriptionFromJson,
        buildV2MockSubscriptions,
      );
      _threads = _listFromJson(
        data['threads'],
        _threadFromJson,
        buildV2MockThreads,
      );
      _comments = _listFromJson(
        data['comments'],
        _commentFromJson,
        buildV2MockComments,
      );
      _notifications = _listFromJson(
        data['notifications'],
        _notificationFromJson,
        buildV2MockNotifications,
      );
      final selectedStorefrontId = data['selectedStorefrontId'];
      if (selectedStorefrontId is String) {
        _selectedStorefrontId = selectedStorefrontId;
      }
      _createdStorefronts = _intValue(data['createdStorefronts']);
      _createdCatalogItems = _intValue(data['createdCatalogItems']);
      _createdComments = _intValue(data['createdComments']);
      _createdSubscriptions = _intValue(data['createdSubscriptions']);
      _createdThreads = _intValue(data['createdThreads']);
    } finally {
      _restoring = false;
      notifyListeners();
    }
  }

  void _setDemoUser({
    required String displayName,
    required String email,
    required V2UserType userType,
  }) {
    final trimmedName = displayName.trim().isEmpty
        ? 'Demo user'
        : displayName.trim();
    final trimmedEmail = email.trim().isEmpty
        ? 'demo@communitii.test'
        : email.trim();
    _currentUser = V2CurrentUser(
      id: v2DemoUserId,
      displayName: trimmedName,
      email: trimmedEmail,
      userType: userType,
      location: V2Geo.singaporeCenter,
    );
    _userNamesById[v2DemoUserId] = trimmedName;
    _saveAndNotify();
  }

  V2Storefront? _firstNearbyOrNull() {
    final storefronts = nearbyStorefronts;
    return storefronts.isEmpty ? null : storefronts.first;
  }

  String? _cleanImageUrl(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  void _saveAndNotify() {
    _savePersistedState();
    notifyListeners();
  }

  Future<void> _savePersistedState() async {
    if (_restoring) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_toJson()));
  }

  Map<String, dynamic> _toJson() {
    return {
      'currentUser': _currentUser == null
          ? null
          : {
              'id': _currentUser!.id,
              'displayName': _currentUser!.displayName,
              'email': _currentUser!.email,
              'userType': _currentUser!.userType.name,
              'lat': _currentUser!.location.latitude,
              'lng': _currentUser!.location.longitude,
            },
      'storefronts': _storefronts.map(_storefrontToJson).toList(),
      'catalogItems': _catalogItems.map(_catalogItemToJson).toList(),
      'subscriptions': _subscriptions.map(_subscriptionToJson).toList(),
      'threads': _threads.map(_threadToJson).toList(),
      'comments': _comments.map(_commentToJson).toList(),
      'notifications': _notifications.map(_notificationToJson).toList(),
      'selectedStorefrontId': _selectedStorefrontId,
      'createdStorefronts': _createdStorefronts,
      'createdCatalogItems': _createdCatalogItems,
      'createdComments': _createdComments,
      'createdSubscriptions': _createdSubscriptions,
      'createdThreads': _createdThreads,
    };
  }

  Map<String, dynamic> _storefrontToJson(V2Storefront storefront) {
    return {
      'id': storefront.id,
      'ownerId': storefront.ownerId,
      'name': storefront.name,
      'description': storefront.description,
      'category': storefront.category,
      'pickupArea': storefront.pickupArea,
      'lat': storefront.location.latitude,
      'lng': storefront.location.longitude,
    };
  }

  Map<String, dynamic> _catalogItemToJson(V2CatalogItem item) {
    return {
      'id': item.id,
      'storefrontId': item.storefrontId,
      'name': item.name,
      'description': item.description,
      'price': item.price,
      'category': item.category,
      'status': item.status,
      'imageUrl': item.imageUrl,
    };
  }

  Map<String, dynamic> _subscriptionToJson(V2Subscription subscription) {
    return {
      'id': subscription.id,
      'userId': subscription.userId,
      'storefrontId': subscription.storefrontId,
    };
  }

  Map<String, dynamic> _threadToJson(V2DiscussionThread thread) {
    return {
      'id': thread.id,
      'storefrontId': thread.storefrontId,
      'title': thread.title,
      'relatedLabel': thread.relatedLabel,
    };
  }

  Map<String, dynamic> _commentToJson(V2Comment comment) {
    return {
      'id': comment.id,
      'storefrontId': comment.storefrontId,
      'threadId': comment.threadId,
      'userId': comment.userId,
      'body': comment.body,
      'createdAt': comment.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _notificationToJson(V2NotificationItem notification) {
    return {
      'id': notification.id,
      'storefrontId': notification.storefrontId,
      'type': notification.type,
      'title': notification.title,
      'body': notification.body,
      'createdAt': notification.createdAt.toIso8601String(),
      'read': notification.read,
    };
  }

  V2CurrentUser _currentUserFromJson(Map<String, dynamic> json) {
    return V2CurrentUser(
      id: _stringValue(json['id'], v2DemoUserId),
      displayName: _stringValue(json['displayName'], 'Demo user'),
      email: _stringValue(json['email'], 'demo@communitii.test'),
      userType: _userTypeFromName(_stringValue(json['userType'], 'casual')),
      location: V2GeoPoint(
        _doubleValue(json['lat'], V2Geo.singaporeCenter.latitude),
        _doubleValue(json['lng'], V2Geo.singaporeCenter.longitude),
      ),
    );
  }

  V2Storefront _storefrontFromJson(Map<String, dynamic> json) {
    return V2Storefront(
      id: _stringValue(json['id'], 'sf-local'),
      ownerId: _stringValue(json['ownerId'], v2DemoUserId),
      name: _stringValue(json['name'], 'Home kitchen'),
      description: _stringValue(json['description'], 'Frontend-only store.'),
      category: _stringValue(json['category'], 'Food'),
      pickupArea: _stringValue(json['pickupArea'], 'Near you'),
      location: V2GeoPoint(
        _doubleValue(json['lat'], V2Geo.singaporeCenter.latitude),
        _doubleValue(json['lng'], V2Geo.singaporeCenter.longitude),
      ),
    );
  }

  V2CatalogItem _catalogItemFromJson(Map<String, dynamic> json) {
    return V2CatalogItem(
      id: _stringValue(json['id'], 'item-local'),
      storefrontId: _stringValue(json['storefrontId'], 'sf-loaf-lab'),
      name: _stringValue(json['name'], 'Food item'),
      description: _stringValue(json['description'], 'Prototype product.'),
      price: _doubleValue(json['price'], 0),
      category: _stringValue(json['category'], 'Food'),
      status: _stringValue(json['status'], V2ProductStatus.live),
      imageUrl: json['imageUrl'] is String ? json['imageUrl'] as String : null,
    );
  }

  V2Subscription _subscriptionFromJson(Map<String, dynamic> json) {
    return V2Subscription(
      id: _stringValue(json['id'], 'sub-local'),
      userId: _stringValue(json['userId'], v2DemoUserId),
      storefrontId: _stringValue(json['storefrontId'], 'sf-loaf-lab'),
    );
  }

  V2DiscussionThread _threadFromJson(Map<String, dynamic> json) {
    return V2DiscussionThread(
      id: _stringValue(json['id'], 'thread-local'),
      storefrontId: _stringValue(json['storefrontId'], 'sf-loaf-lab'),
      title: _stringValue(json['title'], 'General updates'),
      relatedLabel: _stringValue(json['relatedLabel'], 'Storefront'),
    );
  }

  V2Comment _commentFromJson(Map<String, dynamic> json) {
    return V2Comment(
      id: _stringValue(json['id'], 'comment-local'),
      storefrontId: _stringValue(json['storefrontId'], 'sf-loaf-lab'),
      threadId: _stringValue(json['threadId'], 'thread-general'),
      userId: _stringValue(json['userId'], v2DemoUserId),
      body: _stringValue(json['body'], ''),
      createdAt:
          DateTime.tryParse(_stringValue(json['createdAt'], '')) ??
          DateTime.now(),
    );
  }

  V2NotificationItem _notificationFromJson(Map<String, dynamic> json) {
    return V2NotificationItem(
      id: _stringValue(json['id'], 'notif-local'),
      storefrontId: _stringValue(json['storefrontId'], 'sf-loaf-lab'),
      type: _stringValue(json['type'], 'store_update'),
      title: _stringValue(json['title'], 'Store update'),
      body: _stringValue(json['body'], ''),
      createdAt:
          DateTime.tryParse(_stringValue(json['createdAt'], '')) ??
          DateTime.now(),
      read: json['read'] == true,
    );
  }

  List<T> _listFromJson<T>(
    Object? raw,
    T Function(Map<String, dynamic>) parse,
    List<T> Function() fallback,
  ) {
    if (raw is! List) return fallback();
    return raw
        .whereType<Map>()
        .map((item) => parse(Map<String, dynamic>.from(item)))
        .toList();
  }

  V2UserType _userTypeFromName(String name) {
    return V2UserType.values.firstWhere(
      (value) => value.name == name,
      orElse: () => V2UserType.casual,
    );
  }

  String _stringValue(Object? value, String fallback) {
    return value is String && value.isNotEmpty ? value : fallback;
  }

  double _doubleValue(Object? value, double fallback) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  int _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
