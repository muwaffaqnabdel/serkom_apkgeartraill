import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

/// LocationService — mengelola GPS dan deteksi lokasi user
/// Digunakan untuk: auto-fill alamat checkout & cari toko terdekat
class LocationService extends GetxController {
  final isLoading = false.obs;
  final currentPosition = Rxn<Position>();
  final currentAddress = ''.obs;
  final permissionStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkPermissionStatus();
  }

  Future<void> _checkPermissionStatus() async {
    if (kIsWeb) {
      permissionStatus.value = 'web';
      return;
    }
    try {
      final permission = await Geolocator.checkPermission();
      permissionStatus.value = permission.name;
    } catch (e) {
      debugPrint('LocationService: Error checking permission: $e');
    }
  }

  /// Minta izin lokasi dari user
  Future<bool> requestPermission() async {
    if (kIsWeb) return true; // Web handles permission natively in browser

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        permissionStatus.value = 'deniedForever';
        Get.snackbar(
          'Akses Lokasi Diblokir',
          'Aktifkan izin lokasi di pengaturan HP untuk menggunakan fitur ini.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFDC2626),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          mainButton: TextButton(
            onPressed: () => Geolocator.openAppSettings(),
            child: const Text('Buka Pengaturan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
        return false;
      }

      if (permission == LocationPermission.denied) {
        permissionStatus.value = 'denied';
        Get.snackbar(
          'Izin Lokasi Ditolak',
          'Izin akses lokasi diperlukan untuk fitur ini.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEA580C),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        return false;
      }

      permissionStatus.value = permission.name;
      return true;
    } catch (e) {
      debugPrint('LocationService: Error requesting permission: $e');
      return false;
    }
  }

  /// Dapatkan posisi GPS saat ini
  Future<Position?> getCurrentPosition() async {
    isLoading.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'GPS Tidak Aktif',
          'Aktifkan GPS/Lokasi di pengaturan perangkat Anda.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEA580C),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
        isLoading.value = false;
        return null;
      }

      final hasPermission = await requestPermission();
      if (!hasPermission) {
        isLoading.value = false;
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      currentPosition.value = position;
      return position;
    } catch (e) {
      debugPrint('LocationService: Error getting position: $e');
      Get.snackbar(
        'Gagal Mendapatkan Lokasi',
        'Tidak dapat mendeteksi lokasi. Coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Hitung jarak antara dua koordinat dalam kilometer
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  /// Format koordinat jadi string yang readable
  String formatCoordinates(Position position) {
    final lat = position.latitude.toStringAsFixed(4);
    final lon = position.longitude.toStringAsFixed(4);
    return 'Lat: $lat, Lon: $lon';
  }

  /// Generate alamat estimasi dari koordinat (reverse geocoding tanpa API key)
  /// Untuk produksi gunakan geocoding package + Google Maps API
  String generateAddressFromCoords(double lat, double lon) {
    // Deteksi area berdasarkan koordinat Indonesia
    if (lat >= -6.4 && lat <= -6.0 && lon >= 106.6 && lon <= 107.0) {
      return 'Jakarta, DKI Jakarta';
    } else if (lat >= -7.1 && lat <= -6.8 && lon >= 107.5 && lon <= 107.8) {
      return 'Bandung, Jawa Barat';
    } else if (lat >= -7.3 && lat <= -7.0 && lon >= 112.6 && lon <= 112.8) {
      return 'Surabaya, Jawa Timur';
    } else if (lat >= -7.9 && lat <= -7.7 && lon >= 110.3 && lon <= 110.5) {
      return 'Yogyakarta, DIY';
    } else if (lat >= -8.7 && lat <= -8.6 && lon >= 115.1 && lon <= 115.3) {
      return 'Denpasar, Bali';
    } else if (lat >= -3.9 && lat <= -3.6 && lon >= 102.2 && lon <= 102.4) {
      return 'Bengkulu, Sumatera';
    } else {
      return 'Koordinat: ${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
    }
  }
}
