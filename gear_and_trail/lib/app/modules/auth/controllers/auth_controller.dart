import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/local_storage_service.dart';
import '../../../data/providers/product_provider.dart';
import '../../../data/providers/notification_service.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final ProductProvider _provider = Get.find<ProductProvider>();
  final LocalStorageService _storage = Get.find<LocalStorageService>();
  NotificationService? get _notifications => Get.isRegistered<NotificationService>()
      ? Get.find<NotificationService>()
      : null;

  final isLoggedIn = false.obs;
  final isLoading = false.obs;
  final userToken = ''.obs;
  final currentUser = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    _restoreLocalSession();
  }

  void _restoreLocalSession() {
    try {
      final token = _storage.getToken();
      final user = _storage.getUserSession();
      if (token != null && token.isNotEmpty && user != null) {
        userToken.value = token;
        currentUser.value = user;
        isLoggedIn.value = true;
      }
    } catch (e) {
      debugPrint('Error restoring user session DB: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    if (isLoading.value) return false;
    isLoading.value = true;
    
    try {
      final res = await _provider.loginUser(email, password);
      isLoading.value = false;

      if (res != null && res['success'] == true) {
        isLoggedIn.value = true;
        userToken.value = res['token']?.toString() ?? '';
        currentUser.value = Map<String, dynamic>.from(res['user'] ?? {});

        // Save session locally to offline DB
        await _storage.saveUserSession(currentUser.value!, userToken.value);

        final userName = currentUser.value?['name'] ?? 'Pengguna';

        Get.snackbar(
          'Login Berhasil',
          'Selamat datang kembali, $userName!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1E3A2F),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );

        Get.offAllNamed(Routes.main);

        // Kirim notifikasi sambutan setelah login
        _notifications?.showWelcomeNotification(userName);

        return true;
      } else {
        Get.snackbar(
          'Gagal Login',
          'Email/username atau password salah, atau server tidak merespon.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEA580C),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Gagal Menghubungkan',
        'Tidak dapat terhubung ke REST API Server (http://localhost:5000).',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEA580C),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
  }

  void logout() {
    isLoggedIn.value = false;
    userToken.value = '';
    currentUser.value = null;
    _storage.clearUserSession();
    Get.offAllNamed(Routes.login);
  }

  Future<bool> register(String name, String email, String password) async {
    if (isLoading.value) return false;
    isLoading.value = true;

    try {
      final res = await _provider.registerUser(name, email, password);
      isLoading.value = false;

      if (res != null && res['success'] == true) {
        Get.snackbar(
          'Pendaftaran Berhasil!',
          'Akun Anda telah dibuat. Silakan login untuk melanjutkan.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1E3A2F),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        );

        Get.offAllNamed(Routes.login);
        return true;
      } else {
        Get.snackbar(
          'Pendaftaran Gagal',
          res?['message'] ?? 'Email sudah terdaftar atau data tidak valid.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEA580C),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Gagal Menghubungkan',
        'Tidak dapat terhubung ke REST API Server.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEA580C),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
  }
}
