import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/product.dart';

class ProductProvider extends GetConnect {
  static String get baseUrlStr {
    if (kIsWeb) return 'http://localhost:5000/api';
    if (GetPlatform.isAndroid) return 'http://10.0.2.2:5000/api';
    return 'http://localhost:5000/api';
  }

  @override
  void onInit() {
    httpClient.baseUrl = baseUrlStr;
    httpClient.timeout = const Duration(seconds: 10);
    super.onInit();
  }

  Future<List<Product>> getProducts({String? category, String? search, bool? isFavorite}) async {
    try {
      String url = '/products?';
      if (category != null && category != 'Semua') {
        url += 'category=${Uri.encodeComponent(category)}&';
      }
      if (search != null && search.isNotEmpty) {
        url += 'search=${Uri.encodeComponent(search)}&';
      }
      if (isFavorite == true) {
        url += 'isFavorite=true&';
      }

      final response = await get(url);
      if (response.status.hasError || response.body == null) {
        return [];
      }

      final data = response.body['data'] as List?;
      if (data == null) return [];
      return data.map((item) => Product.fromJson(Map<String, dynamic>.from(item))).toList();
    } catch (e) {
      debugPrint('Error fetching products from API: $e');
      return [];
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await get('/categories');
      if (response.status.hasError || response.body == null) return [];
      final data = response.body['data'] as List?;
      if (data == null) return [];
      return data.map((e) {
        if (e is Map) {
          return (e['name'] ?? e['title'] ?? e['category'] ?? e.toString()).toString();
        }
        return e.toString();
      }).toList();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  Future<bool> sendOrder(Map<String, dynamic> orderPayload) async {
    try {
      final response = await post('/orders', orderPayload);
      return !response.status.hasError;
    } catch (e) {
      debugPrint('Error sending order: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      final response = await post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response.status.hasError || response.body == null) {
        return null;
      }

      if (response.body['success'] == true) {
        return Map<String, dynamic>.from(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error logging in API: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> registerUser(String name, String email, String password) async {
    try {
      final response = await post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.status.hasError || response.body == null) {
        return null;
      }

      if (response.body['success'] == true) {
        return Map<String, dynamic>.from(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error registering user API: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProfile(String email) async {
    try {
      final response = await get('/auth/profile?email=${Uri.encodeComponent(email)}');
      if (response.status.hasError || response.body == null) return null;
      if (response.body['success'] == true) {
        return Map<String, dynamic>.from(response.body['user'] ?? {});
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching profile API: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> forgotPassword(String email) async {
    try {
      final response = await post('/auth/forgot-password', {'email': email});
      if (response.body == null) return null;
      return Map<String, dynamic>.from(response.body);
    } catch (e) {
      debugPrint('Error forgot-password API: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> verifyResetOtp(String email, String otp) async {
    try {
      final response = await post('/auth/verify-reset-otp', {'email': email, 'otp': otp});
      if (response.body == null) return null;
      return Map<String, dynamic>.from(response.body);
    } catch (e) {
      debugPrint('Error verify-reset-otp API: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> resetPassword(String email, String resetToken, String newPassword) async {
    try {
      final response = await post('/auth/reset-password', {
        'email': email,
        'resetToken': resetToken,
        'newPassword': newPassword,
      });
      if (response.body == null) return null;
      return Map<String, dynamic>.from(response.body);
    } catch (e) {
      debugPrint('Error reset-password API: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> changePassword(String email, String currentPassword, String newPassword) async {
    try {
      final response = await post('/auth/change-password', {
        'email': email,
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      if (response.body == null) return null;
      return Map<String, dynamic>.from(response.body);
    } catch (e) {
      debugPrint('Error change-password API: $e');
      return null;
    }
  }
}
