import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/providers/product_provider.dart';
import '../../main/controllers/main_controller.dart';

/// OrderTrackingView — Layar Lacak Status Pesanan Real-Time
/// Terhubung langsung dengan Server Node.js & React Admin Dashboard
class OrderTrackingView extends StatefulWidget {
  const OrderTrackingView({super.key});

  @override
  State<OrderTrackingView> createState() => _OrderTrackingViewState();
}

class _OrderTrackingViewState extends State<OrderTrackingView> {
  final ProductProvider _provider = Get.find<ProductProvider>();
  
  Map<String, dynamic>? _order;
  String _currentStatus = 'Diproses';
  bool _isLoading = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      _order = args;
      _currentStatus = (args['status'] ?? 'Diproses').toString();
    }
    
    // Mulai auto-polling refresh status setiap 3 detik dari Server API
    _startLiveStatusPolling();
  }

  void _startLiveStatusPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _refreshOrderStatus(silent: true);
    });
  }

  Future<void> _refreshOrderStatus({bool silent = false}) async {
    if (_order == null) return;
    final orderId = _order!['id']?.toString() ?? _order!['orderId']?.toString();
    if (orderId == null || orderId.isEmpty) return;

    if (!silent) {
      setState(() => _isLoading = true);
    }

    try {
      final updatedData = await _provider.getOrderById(orderId);
      if (updatedData != null && mounted) {
        final newStatus = (updatedData['status'] ?? _currentStatus).toString();
        if (newStatus != _currentStatus && silent) {
          // Tampilkan snackbar jika ada perubahan status dari Admin Server
          Get.snackbar(
            'Update Status Pengiriman!',
            'Status pesanan Anda kini berubah menjadi "$newStatus"',
            snackPosition: SnackPosition.TOP,
            backgroundColor: const Color(0xFFEA580C),
            colorText: Colors.white,
            icon: const Icon(Icons.local_shipping, color: Colors.white),
            duration: const Duration(seconds: 4),
          );
        }

        setState(() {
          _order = updatedData;
          _currentStatus = newStatus;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error polling order status: $e');
    } finally {
      if (mounted && !silent) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  int _getStatusStepIndex(String status) {
    final s = status.trim().toLowerCase();
    if (s.contains('selesai') || s.contains('diterima') || s.contains('completed')) {
      return 2;
    }
    if (s.contains('kirim') || s.contains('perjalanan') || s.contains('shipped') || s.contains('transit')) {
      return 1;
    }
    return 0;
  }

  String _formatPrice(dynamic amount) {
    final val = int.tryParse(amount.toString()) ?? 0;
    return 'Rp ${val.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final orderId = _order?['id']?.toString() ?? _order?['orderId']?.toString() ?? 'ORD-0000';
    final customerName = _order?['customerName']?.toString() ?? 'Pelanggan';
    final customerPhone = _order?['customerPhone']?.toString() ?? '-';
    final address = _order?['shippingAddress']?.toString() ?? '-';
    final items = (_order?['items'] as List?) ?? [];
    final subtotal = _order?['subtotal'] ?? 0;
    final shippingFee = _order?['shippingFee'] ?? 10000;
    final totalAmount = _order?['totalAmount'] ?? 0;

    final currentStep = _getStatusStepIndex(_currentStatus);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E3A2F), size: 20),
          onPressed: () {
            final MainController mainController = Get.find<MainController>();
            Get.back();
            mainController.changePage(0);
          },
        ),
        title: Text(
          'Lacak Status Pesanan',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A2F),
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E3A2F)),
                  )
                : const Icon(Icons.refresh_rounded, color: Color(0xFF1E3A2F)),
            onPressed: () => _refreshOrderStatus(silent: false),
            tooltip: 'Refresh Status Terkini',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID & Live Sync Badge Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A2F), Color(0xFF047857)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E3A2F).withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ID PESANAN',
                            style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            orderId,
                            style: GoogleFonts.orbitron(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.sync, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Live Sync Server',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Stepper Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PROGRES PENGIRIMAN',
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E3A2F),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: currentStep == 2
                              ? const Color(0xFFECFDF5)
                              : currentStep == 1
                                  ? const Color(0xFFFFFBEB)
                                  : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _currentStatus.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: currentStep == 2
                                ? const Color(0xFF047857)
                                : currentStep == 1
                                    ? const Color(0xFFB45309)
                                    : const Color(0xFF1E3A2F),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3-Step Visual Progress Stepper
                  _buildStepperStep(
                    stepIndex: 0,
                    currentStep: currentStep,
                    title: 'Pesanan Diterima & Diproses',
                    subtitle: 'Admin toko sedang menyiapkan barang Anda',
                    icon: Icons.inventory_2_outlined,
                    isLast: false,
                  ),
                  _buildStepperStep(
                    stepIndex: 1,
                    currentStep: currentStep,
                    title: 'Sedang Dikirim',
                    subtitle: 'Pesanan dalam perjalanan oleh kurir ekspedisi',
                    icon: Icons.local_shipping_outlined,
                    isLast: false,
                  ),
                  _buildStepperStep(
                    stepIndex: 2,
                    currentStep: currentStep,
                    title: 'Pesanan Selesai',
                    subtitle: 'Paket telah sampai & diterima dengan baik',
                    icon: Icons.task_alt_outlined,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Customer & Delivery Address Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: Color(0xFF1E3A2F), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Alamat Pengiriman',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(customerPhone, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(address, style: const TextStyle(color: Color(0xFF334155), fontSize: 13, height: 1.4)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Order Items & Payment Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shopping_bag_outlined, color: Color(0xFF1E3A2F), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Rincian Produk Dipesan',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (items.isEmpty)
                    const Text('Detail produk telah tersimpan di server', style: TextStyle(color: Color(0xFF64748B)))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final pName = item['productName'] ?? item['name'] ?? 'Produk';
                        final qty = item['quantity'] ?? 1;
                        final price = item['totalPrice'] ?? ((item['price'] ?? 0) * qty);

                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.directions_bike, color: Color(0xFF1E3A2F), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(pName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('$qty x ${_formatPrice(item['price'] ?? 0)}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                                ],
                              ),
                            ),
                            Text(_formatPrice(price), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E3A2F))),
                          ],
                        );
                      },
                    ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                      Text(_formatPrice(subtotal), style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ongkir', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                      Text(_formatPrice(shippingFee), style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                      Text(_formatPrice(totalAmount), style: GoogleFonts.orbitron(fontWeight: FontWeight.w900, fontSize: 16, color: const Color(0xFFEA580C))),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Back to Home Button
            ElevatedButton(
              onPressed: () {
                final MainController mainController = Get.find<MainController>();
                Get.back();
                mainController.changePage(0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A2F),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                'Kembali ke Beranda',
                style: GoogleFonts.orbitron(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperStep({
    required int stepIndex,
    required int currentStep,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isLast,
  }) {
    final isDone = stepIndex < currentStep;
    final isCurrent = stepIndex == currentStep;

    final circleColor = isDone
        ? const Color(0xFF047857)
        : isCurrent
            ? const Color(0xFFEA580C)
            : const Color(0xFFCBD5E1);

    final iconColor = (isDone || isCurrent) ? Colors.white : const Color(0xFF64748B);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: const Color(0xFFEA580C).withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ]
                      : [],
                ),
                child: Icon(isDone ? Icons.check : icon, color: iconColor, size: 18),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 3,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isDone ? const Color(0xFF047857) : const Color(0xFFE2E8F0),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrent || isDone ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent
                          ? const Color(0xFFEA580C)
                          : isDone
                              ? const Color(0xFF047857)
                              : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
