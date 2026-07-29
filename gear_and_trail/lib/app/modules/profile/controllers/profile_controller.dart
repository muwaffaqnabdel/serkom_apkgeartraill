import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/providers/product_provider.dart';
import '../../../data/providers/local_storage_service.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final ProductProvider _provider = Get.find<ProductProvider>();
  final LocalStorageService _storage = Get.find<LocalStorageService>();
  final ImagePicker _picker = ImagePicker();

  final isLoading = false.obs;
  final userProfile = Rxn<Map<String, dynamic>>();
  final avatarPath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLocalAvatar();
    fetchProfile();
  }

  void _loadLocalAvatar() {
    final savedPath = _storage.getAvatarPath();
    if (savedPath != null && savedPath.isNotEmpty) {
      avatarPath.value = savedPath;
    }
  }


  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final currentEmail = authController.currentUser.value?['email'] ?? 'budi.santoso@gmail.com';
      final res = await _provider.getProfile(currentEmail);

      if (res != null) {
        userProfile.value = res;
      } else {
        userProfile.value = authController.currentUser.value ?? {
          'name': 'Budi Santoso',
          'email': 'budi.santoso@gmail.com',
          'phone': '081234567890',
          'role': 'Member Gear & Trail',
          'primaryAddress': 'Jl. Mawar No. 12, Kebayoran Baru, Jakarta Selatan',
        };
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateProfileField(String key, String value) {
    if (userProfile.value != null) {
      final updated = Map<String, dynamic>.from(userProfile.value!);
      updated[key] = value;
      userProfile.value = updated;
    } else {
      userProfile.value = {
        key: value,
      };
    }
    
    Get.snackbar(
      'Profil Berhasil Diperbarui',
      'Perubahan data berhasil disimpan',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E3A2F),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  void logout() {
    authController.logout();
  }

  // ----------------------------------------------------
  // Unit 5: Mobile Sensor & Camera Integration (Image Picker)
  // ----------------------------------------------------
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        avatarPath.value = pickedFile.path;
        await _storage.saveAvatarPath(pickedFile.path);

        Get.snackbar(
          'Foto Profil Diperbarui',
          source == ImageSource.camera
              ? 'Foto dari kamera berhasil dipasang'
              : 'Foto dari galeri berhasil dipasang',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1E3A2F),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      Get.snackbar(
        'Gagal Mengambil Gambar',
        'Tidak dapat mengakses ${source == ImageSource.camera ? "kamera" : "galeri"}. Pastikan izin telah diberikan.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> removeAvatar() async {
    avatarPath.value = '';
    await _storage.removeAvatarPath();
    Get.snackbar(
      'Foto Profil Dihapus',
      'Foto profil kembali ke tampilan standar',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E3A2F),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}
