import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// AppNotification — Compact, modern floating snackbar/notification system for Gear & Trail
class AppNotification {
  AppNotification._();

  static void showSuccess(String title, String message) {
    _showCompactSnackbar(
      title: title,
      message: message,
      icon: Icons.check_circle_rounded,
      iconColor: const Color(0xFF34D399),
      borderColor: const Color(0xFF059669),
      backgroundColor: const Color(0xFF064E3B),
    );
  }

  static void showError(String title, String message) {
    _showCompactSnackbar(
      title: title,
      message: message,
      icon: Icons.error_rounded,
      iconColor: const Color(0xFFF87171),
      borderColor: const Color(0xFFDC2626),
      backgroundColor: const Color(0xFF7F1D1D),
    );
  }

  static void showInfo(String title, String message) {
    _showCompactSnackbar(
      title: title,
      message: message,
      icon: Icons.info_rounded,
      iconColor: const Color(0xFF60A5FA),
      borderColor: const Color(0xFF2563EB),
      backgroundColor: const Color(0xFF1E3A2F),
    );
  }

  static void showWarning(String title, String message) {
    _showCompactSnackbar(
      title: title,
      message: message,
      icon: Icons.warning_amber_rounded,
      iconColor: const Color(0xFFFBBF24),
      borderColor: const Color(0xFFD97706),
      backgroundColor: const Color(0xFF451A03),
    );
  }

  static void _showCompactSnackbar({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required Color borderColor,
    required Color backgroundColor,
  }) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.rawSnackbar(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
      messageText: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: iconColor, width: 3.5)),
        ),
        padding: const EdgeInsets.only(left: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      duration: const Duration(seconds: 3),
      isDismissible: true,
    );
  }
}
