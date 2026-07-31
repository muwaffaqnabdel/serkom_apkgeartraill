import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

class LocalStorageService {
  final GetStorage _box = GetStorage('GearTrailDB');

  static const String _keyFavorites = 'favorite_product_ids';
  static const String _keyCart = 'cart_items';
  static const String _keyUser = 'user_session';
  static const String _keyToken = 'auth_token';

  // ----------------------------------------------------
  // 1. Local Persistence: Favorite Products (Wishlist)
  // ----------------------------------------------------
  List<String> getFavorites() {
    try {
      final List<dynamic>? raw = _box.read<List<dynamic>>(_keyFavorites);
      if (raw == null) return [];
      return raw.map((e) => e.toString()).toList();
    } catch (e) {
      debugPrint('Error reading local favorites DB: $e');
      return [];
    }
  }

  Future<void> saveFavorites(List<String> favoriteIds) async {
    try {
      await _box.write(_keyFavorites, favoriteIds);
    } catch (e) {
      debugPrint('Error writing local favorites DB: $e');
    }
  }

  bool isFavorite(String productId) {
    final list = getFavorites();
    return list.contains(productId);
  }

  Future<bool> toggleFavorite(String productId) async {
    final list = getFavorites();
    bool isNowFav = false;
    if (list.contains(productId)) {
      list.remove(productId);
      isNowFav = false;
    } else {
      list.add(productId);
      isNowFav = true;
    }
    await saveFavorites(list);
    return isNowFav;
  }

  // ----------------------------------------------------
  // 2. Local Persistence: Cart Items Storage
  // ----------------------------------------------------
  List<Map<String, dynamic>> getCartItems() {
    try {
      final List<dynamic>? raw = _box.read<List<dynamic>>(_keyCart);
      if (raw == null) return [];
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('Error reading local cart DB: $e');
      return [];
    }
  }

  Future<void> saveCartItems(List<Map<String, dynamic>> items) async {
    try {
      await _box.write(_keyCart, items);
    } catch (e) {
      debugPrint('Error writing local cart DB: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      await _box.remove(_keyCart);
    } catch (e) {
      debugPrint('Error clearing local cart DB: $e');
    }
  }

  // ----------------------------------------------------
  // 3. Local Persistence: User Session & Token Storage
  // ----------------------------------------------------
  Map<String, dynamic>? getUserSession() {
    try {
      final raw = _box.read<Map<String, dynamic>>(_keyUser);
      return raw;
    } catch (e) {
      debugPrint('Error reading user session DB: $e');
      return null;
    }
  }

  String? getToken() {
    return _box.read<String>(_keyToken);
  }

  Future<void> saveUserSession(Map<String, dynamic> user, String token) async {
    try {
      await _box.write(_keyUser, user);
      await _box.write(_keyToken, token);
    } catch (e) {
      debugPrint('Error saving user session DB: $e');
    }
  }

  Future<void> clearUserSession() async {
    try {
      await _box.remove(_keyUser);
      await _box.remove(_keyToken);
    } catch (e) {
      debugPrint('Error clearing user session DB: $e');
    }
  }

  // ----------------------------------------------------
  // 4. Local Persistence: Profile Avatar Path Storage
  // ----------------------------------------------------
  String? getAvatarPath() {
    try {
      return _box.read<String>('profile_avatar_path');
    } catch (e) {
      debugPrint('Error reading avatar path: $e');
      return null;
    }
  }

  Future<void> saveAvatarPath(String path) async {
    try {
      await _box.write('profile_avatar_path', path);
    } catch (e) {
      debugPrint('Error saving avatar path: $e');
    }
  }

  Future<void> removeAvatarPath() async {
    try {
      await _box.remove('profile_avatar_path');
    } catch (e) {
      debugPrint('Error removing avatar path: $e');
    }
  }

  // ----------------------------------------------------
  // 5. Local Persistence: Order History Storage
  // ----------------------------------------------------
  static const String _keyOrders = 'user_orders';

  List<Map<String, dynamic>> getUserOrders() {
    try {
      final List<dynamic>? raw = _box.read<List<dynamic>>(_keyOrders);
      if (raw == null) return [];
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('Error reading user orders DB: $e');
      return [];
    }
  }

  Future<void> saveUserOrder(Map<String, dynamic> order) async {
    try {
      final existing = getUserOrders();
      final orderId = (order['id'] ?? order['orderId'] ?? '').toString();
      existing.removeWhere((o) => (o['id'] ?? o['orderId'] ?? '').toString() == orderId);
      existing.insert(0, order);
      await _box.write(_keyOrders, existing);
    } catch (e) {
      debugPrint('Error saving user order DB: $e');
    }
  }
}
