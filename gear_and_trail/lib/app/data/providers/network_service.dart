import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// NetworkService — memantau status koneksi internet secara real-time
/// Menampilkan banner merah saat offline dan hijau saat kembali online.
class NetworkService extends GetxController {
  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final isOnline = true.obs;
  final isChecking = false.obs;
  bool _wasOffline = false;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnectivity();
    _listenConnectivity();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateStatus(results);
    } catch (e) {
      debugPrint('NetworkService: Error checking initial connectivity: $e');
    }
  }

  void _listenConnectivity() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) => _updateStatus(results),
      onError: (e) => debugPrint('NetworkService: Stream error: $e'),
    );
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final connected = results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);

    if (isOnline.value == connected) return; // no change

    isOnline.value = connected;

    if (!connected) {
      _wasOffline = true;
      _showOfflineBanner();
    } else if (_wasOffline) {
      _wasOffline = false;
      _showOnlineBanner();
    }
  }

  void _showOfflineBanner() {
    Get.rawSnackbar(
      messageText: const Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tidak Ada Koneksi Internet',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Beberapa fitur mungkin tidak tersedia',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFDC2626),
      snackPosition: SnackPosition.TOP,
      borderRadius: 0,
      margin: EdgeInsets.zero,
      duration: const Duration(days: 1), // tetap tampil sampai online
      isDismissible: false,
    );
  }

  void _showOnlineBanner() {
    // Tutup banner offline jika ada
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.rawSnackbar(
      messageText: const Row(
        children: [
          Icon(Icons.wifi_rounded, color: Colors.white, size: 20),
          SizedBox(width: 10),
          Text(
            'Koneksi Internet Tersambung Kembali',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF047857),
      snackPosition: SnackPosition.TOP,
      borderRadius: 0,
      margin: EdgeInsets.zero,
      duration: const Duration(seconds: 3),
    );
  }

  /// Cek koneksi sebelum operasi penting (misal: checkout)
  bool checkBeforeAction(String actionName) {
    if (!isOnline.value) {
      Get.snackbar(
        'Tidak Ada Koneksi',
        'Anda perlu terhubung ke internet untuk $actionName',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDC2626),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.wifi_off_rounded, color: Colors.white),
      );
      return false;
    }
    return true;
  }
}
