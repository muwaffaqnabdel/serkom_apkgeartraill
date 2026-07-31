import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/models/product.dart';
import '../../../data/providers/local_storage_service.dart';
import '../../../data/providers/product_provider.dart';
import '../../../data/providers/network_service.dart';
import '../../../data/providers/notification_service.dart';
import '../../../widgets/app_notification.dart';

class CartController extends GetxController {
  final cartItems = <CartItem>[].obs;
  final LocalStorageService _storage = Get.find<LocalStorageService>();
  final NetworkService _network = Get.find<NetworkService>();
  final NotificationService _notifications = Get.find<NotificationService>();

  @override
  void onInit() {
    super.onInit();
    _loadLocalCart();
  }

  void _loadLocalCart() {
    try {
      final items = _storage.getCartItems();
      if (items.isNotEmpty) {
        cartItems.value = items.map((e) => CartItem.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error loading local cart DB: $e');
    }
  }

  void _saveLocalCart() {
    try {
      _storage.saveCartItems(cartItems.map((e) => e.toJson()).toList());
    } catch (e) {
      debugPrint('Error saving local cart DB: $e');
    }
  }

  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);

  int get subtotal => cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  int get shipping => subtotal > 0 ? 10000 : 0;

  int get grandTotal => subtotal + shipping;

  String formatPrice(int price) {
    return 'Rp ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  void addToCart(Product product, [int quantity = 1, bool showSnackbar = true]) {
    final existingIndex = cartItems.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      cartItems[existingIndex].quantity += quantity;
      cartItems.refresh();
    } else {
      cartItems.add(CartItem(product: product, quantity: quantity));
    }

    _saveLocalCart();

    if (showSnackbar) {
      AppNotification.showSuccess(
        'Ditambahkan ke Keranjang',
        '${product.name} dimasukkan ke keranjang',
      );
    }
  }

  void updateQuantity(Product product, int quantity) {
    final index = cartItems.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      if (quantity <= 0) {
        removeFromCart(product);
      } else {
        cartItems[index].quantity = quantity;
        cartItems.refresh();
        _saveLocalCart();
      }
    }
  }

  void removeFromCart(Product product) {
    cartItems.removeWhere((item) => item.product.id == product.id);
    _saveLocalCart();
  }

  void clearCart() {
    cartItems.clear();
    _storage.clearCart();
  }

  Future<Map<String, dynamic>?> checkout({
    required String name,
    required String phone,
    required String address,
  }) async {
    // Cek koneksi internet sebelum checkout
    if (!_network.checkBeforeAction('melakukan checkout')) {
      return null;
    }

    try {
      final ProductProvider provider = Get.find<ProductProvider>();
      final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final payload = {
        'orderId': orderId,
        'customerName': name,
        'customerPhone': phone,
        'shippingAddress': address,
        'items': cartItems.map((i) => {
          'productId': i.product.id,
          'productName': i.product.name,
          'price': i.product.price,
          'quantity': i.quantity,
          'totalPrice': i.totalPrice,
        }).toList(),
        'subtotal': subtotal,
        'shippingFee': shipping,
        'totalAmount': grandTotal,
      };

      final orderResult = await provider.sendOrder(payload);
      if (orderResult != null) {
        final realId = (orderResult['id'] ?? orderId).toString();
        // Simpan pesanan ke riwayat pesanan lokal
        await _storage.saveUserOrder(orderResult);
        // Kirim notifikasi lokal pesanan berhasil
        await _notifications.showOrderSuccessNotification(
          orderId: realId,
          totalAmount: formatPrice(grandTotal),
        );
        clearCart();
        return orderResult;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
