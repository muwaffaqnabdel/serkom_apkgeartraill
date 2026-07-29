import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

/// NotificationService — mengelola notifikasi lokal menggunakan flutter_local_notifications
/// Digunakan untuk notifikasi: pesanan berhasil, promosi produk, dan selamat datang.
class NotificationService extends GetxController {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _idOrderSuccess = 1;
  static const int _idWelcome = 2;
  static const int _idPromo = 3;

  // Channel IDs untuk Android
  static const String _channelOrderId = 'gear_trail_orders';
  static const String _channelPromoId = 'gear_trail_promos';

  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    // Skip local notifications on web (not supported)
    if (kIsWeb) {
      debugPrint('NotificationService: Local notifications not supported on Web');
      return;
    }

    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      final result = await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (result == true) {
        _isInitialized = true;
        debugPrint('NotificationService: Initialized successfully');
      }
    } catch (e) {
      debugPrint('NotificationService: Error initializing: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('NotificationService: Notification tapped, payload: ${response.payload}');
  }

  /// Notifikasi pesanan berhasil checkout
  Future<void> showOrderSuccessNotification({
    required String orderId,
    required String totalAmount,
  }) async {
    if (kIsWeb || !_isInitialized) {
      debugPrint('NotificationService: [Demo] Order success notification for $orderId');
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        _channelOrderId,
        'Pesanan Gear & Trail',
        channelDescription: 'Notifikasi status pesanan sepeda & gear outdoor',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      );

      const details = NotificationDetails(android: androidDetails);

      await _plugin.show(
        _idOrderSuccess,
        '✅ Pesanan Berhasil Dibuat!',
        'Order #$orderId — $totalAmount. Pesanan Anda sedang diproses.',
        details,
        payload: 'order:$orderId',
      );
    } catch (e) {
      debugPrint('NotificationService: Error showing order notification: $e');
    }
  }

  /// Notifikasi selamat datang setelah login
  Future<void> showWelcomeNotification(String userName) async {
    if (kIsWeb || !_isInitialized) {
      debugPrint('NotificationService: [Demo] Welcome notification for $userName');
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        _channelPromoId,
        'Promosi Gear & Trail',
        channelDescription: 'Notifikasi promo dan selamat datang',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      );

      const details = NotificationDetails(android: androidDetails);

      await _plugin.show(
        _idWelcome,
        '🚴‍♂️ Selamat Datang, $userName!',
        'Temukan sepeda MTB & gear outdoor terbaik hanya di Gear & Trail.',
        details,
        payload: 'welcome',
      );
    } catch (e) {
      debugPrint('NotificationService: Error showing welcome notification: $e');
    }
  }

  /// Notifikasi promo produk baru
  Future<void> showPromoNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb || !_isInitialized) {
      debugPrint('NotificationService: [Demo] Promo notification: $title');
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        _channelPromoId,
        'Promosi Gear & Trail',
        channelDescription: 'Notifikasi promo dan selamat datang',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
      );

      const details = NotificationDetails(android: androidDetails);

      await _plugin.show(
        _idPromo,
        title,
        body,
        details,
        payload: 'promo',
      );
    } catch (e) {
      debugPrint('NotificationService: Error showing promo notification: $e');
    }
  }

  /// Notifikasi lokal kode OTP reset password
  Future<void> showOtpNotification(String otp) async {
    if (kIsWeb || !_isInitialized) {
      debugPrint('NotificationService: [Demo] OTP Notification: $otp');
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        _channelPromoId,
        'Keamanan & OTP Gear & Trail',
        channelDescription: 'Notifikasi kode OTP reset password',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      );

      const details = NotificationDetails(android: androidDetails);

      await _plugin.show(
        4,
        '🔐 Kode OTP Reset Password',
        'Kode OTP Anda adalah $otp. Rahasiakan kode ini.',
        details,
        payload: 'otp:$otp',
      );
    } catch (e) {
      debugPrint('NotificationService: Error showing OTP notification: $e');
    }
  }

  /// Batalkan semua notifikasi
  Future<void> cancelAll() async {
    if (kIsWeb || !_isInitialized) return;
    await _plugin.cancelAll();
  }
}
