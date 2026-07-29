import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/profile_controller.dart';
import '../../main/controllers/main_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/skeleton_loader.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController mainController = Get.find<MainController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF1E3A2F)),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: const Text(
          'Gear & Trail',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xFF1E3A2F),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF1E3A2F)),
            onPressed: () => mainController.changePage(2),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return SkeletonLoader.buildProfileSkeleton();
        }

        final profile = controller.userProfile.value ?? {};
        final name = profile['name'] ?? controller.authController.currentUser.value?['name'] ?? 'Budi Santoso';
        final email = profile['email'] ?? controller.authController.currentUser.value?['email'] ?? 'budi.santoso@gmail.com';
        final phone = profile['phone'] ?? '081234567890';
        final role = profile['role'] ?? 'Member Gear & Trail';
        final address = profile['primaryAddress'] ?? 'Jl. Mawar No. 12, RT 03/RW 05, Kel. Sukamaju, Kec. Cilandak, Jakarta Selatan';

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            children: [
              // Profile Avatar Container (Unit 5: Camera & Gallery picker)
              Obx(() {
                final path = controller.avatarPath.value;
                final hasImage = path.isNotEmpty;

                ImageProvider? imageProvider;
                if (hasImage) {
                  if (kIsWeb || path.startsWith('http') || path.startsWith('blob:')) {
                    imageProvider = NetworkImage(path);
                  } else {
                    imageProvider = FileImage(io.File(path));
                  }
                }

                return GestureDetector(
                  onTap: () => _showAvatarPickerSheet(context, controller),
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF1E3A2F), width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E3A2F).withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: const Color(0xFFECFDF5),
                          backgroundImage: imageProvider,
                          child: !hasImage
                              ? const Icon(
                                  Icons.person,
                                  size: 56,
                                  color: Color(0xFF1E3A2F),
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEA580C),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 14),

              // User Name & Edit Name Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A2F),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: Color(0xFFEA580C)),
                    onPressed: () => _showEditBottomSheet(context, 'Nama Lengkap', 'name', name),
                  ),
                ],
              ),
              const SizedBox(height: 2),

              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, size: 14, color: Color(0xFF1E3A2F)),
                    const SizedBox(width: 4),
                    Text(
                      role,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A2F),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Informasi Akun Card
              _buildProfileSectionCard(
                icon: Icons.person_outline,
                title: 'Informasi Akun',
                child: Column(
                  children: [
                    _buildInfoRow(
                      'Email Terdaftar',
                      email,
                      () => _showEditBottomSheet(context, 'Email', 'email', email),
                    ),
                    const Divider(color: Color(0xFFE2E8F0), height: 24),
                    _buildInfoRow(
                      'No. Handphone',
                      phone,
                      () => _showEditBottomSheet(context, 'No. Handphone', 'phone', phone),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Pengaturan Alamat Card
              _buildProfileSectionCard(
                icon: Icons.location_on_outlined,
                title: 'Alamat Pengiriman Utama',
                actionText: 'Ubah',
                onActionTap: () => _showEditBottomSheet(context, 'Alamat Utama', 'primaryAddress', address, isMultiline: true),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A2F),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Alamat Utama',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$name ($phone)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Riwayat Transaksi Card
              _buildProfileSectionCard(
                icon: Icons.receipt_long_outlined,
                title: 'Riwayat Pesanan',
                actionText: 'Lihat Semua',
                onActionTap: () => _showAllOrdersBottomSheet(context),
                child: Column(
                  children: [
                    _buildOrderItem(
                      orderId: 'Order #ORD-1002',
                      status: 'Selesai',
                      statusColor: const Color(0xFFECFDF5),
                      statusTextColor: const Color(0xFF047857),
                      details: 'Polygon Siskiu T8 MTB & Helm Fox',
                      price: 'Rp 31.350.000',
                      buttonText: 'Lihat Detail Pesanan',
                      onButtonTap: () => _showOrderDetailBottomSheet(
                        context,
                        orderId: 'ORD-1002',
                        status: 'Selesai',
                        date: '24 Juli 2026',
                        name: name,
                        phone: phone,
                        address: address,
                        items: [
                          {'name': 'Polygon Siskiu T8 MTB', 'price': 'Rp 28.500.000', 'qty': 1},
                          {'name': 'Helm Fox Dropframe Pro', 'price': 'Rp 2.850.000', 'qty': 1},
                        ],
                        totalAmount: 'Rp 31.350.000',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Ubah Password Button
              OutlinedButton(
                onPressed: () => Get.toNamed(Routes.changePassword),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1E3A2F),
                  side: const BorderSide(color: Color(0xFF1E3A2F), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.security_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Ubah Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Keluar Button
              ElevatedButton(
                onPressed: controller.logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Keluar dari Akun',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  // ----------------------------------------------------
  // BottomSheet: Edit Field Dialog
  // ----------------------------------------------------
  void _showEditBottomSheet(
    BuildContext context,
    String label,
    String fieldKey,
    String currentValue, {
    bool isMultiline = false,
  }) {
    final textController = TextEditingController(text: currentValue);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ubah $label',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A2F),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              maxLines: isMultiline ? 3 : 1,
              decoration: InputDecoration(
                hintText: 'Masukkan $label baru',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF1E3A2F), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final newValue = textController.text.trim();
                if (newValue.isNotEmpty) {
                  controller.updateProfileField(fieldKey, newValue);
                  Get.back();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A2F),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ----------------------------------------------------
  // BottomSheet: Lihat Semua Pesanan
  // ----------------------------------------------------
  void _showAllOrdersBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Semua Pesanan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A2F),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildOrderItem(
                    orderId: 'Order #ORD-1002',
                    status: 'Selesai',
                    statusColor: const Color(0xFFECFDF5),
                    statusTextColor: const Color(0xFF047857),
                    details: 'Polygon Siskiu T8 MTB & Helm Fox',
                    price: 'Rp 31.350.000',
                    buttonText: 'Lihat Detail Pesanan',
                    onButtonTap: () {
                      Get.back();
                      _showOrderDetailBottomSheet(
                        context,
                        orderId: 'ORD-1002',
                        status: 'Selesai',
                        date: '24 Juli 2026',
                        name: controller.userProfile.value?['name'] ?? 'Budi Santoso',
                        phone: controller.userProfile.value?['phone'] ?? '081234567890',
                        address: controller.userProfile.value?['primaryAddress'] ?? 'Jl. Mawar No. 12, Jakarta',
                        items: [
                          {'name': 'Polygon Siskiu T8 MTB', 'price': 'Rp 28.500.000', 'qty': 1},
                          {'name': 'Helm Fox Dropframe Pro', 'price': 'Rp 2.850.000', 'qty': 1},
                        ],
                        totalAmount: 'Rp 31.350.000',
                      );
                    },
                  ),
                  const Divider(color: Color(0xFFE2E8F0), height: 24),
                  _buildOrderItem(
                    orderId: 'Order #ORD-1001',
                    status: 'Sedang Dikirim',
                    statusColor: const Color(0xFFFFFBEB),
                    statusTextColor: const Color(0xFFB45309),
                    details: 'United Clovis 6.10 Hardtail MTB',
                    price: 'Rp 9.800.000',
                    buttonText: 'Lihat Detail Pesanan',
                    onButtonTap: () {
                      Get.back();
                      _showOrderDetailBottomSheet(
                        context,
                        orderId: 'ORD-1001',
                        status: 'Sedang Dikirim',
                        date: '22 Juli 2026',
                        name: controller.userProfile.value?['name'] ?? 'Budi Santoso',
                        phone: controller.userProfile.value?['phone'] ?? '081234567890',
                        address: controller.userProfile.value?['primaryAddress'] ?? 'Jl. Mawar No. 12, Jakarta',
                        items: [
                          {'name': 'United Clovis 6.10 Hardtail', 'price': 'Rp 9.800.000', 'qty': 1},
                        ],
                        totalAmount: 'Rp 9.810.000',
                      );
                    },
                  ),
                  const Divider(color: Color(0xFFE2E8F0), height: 24),
                  _buildOrderItem(
                    orderId: 'Order #ORD-1000',
                    status: 'Diproses',
                    statusColor: const Color(0xFFEFF6FF),
                    statusTextColor: const Color(0xFF1D4ED8),
                    details: 'Sarung Tangan Enduro Giro DND',
                    price: 'Rp 420.000',
                    buttonText: 'Lihat Detail Pesanan',
                    onButtonTap: () {
                      Get.back();
                      _showOrderDetailBottomSheet(
                        context,
                        orderId: 'ORD-1000',
                        status: 'Diproses',
                        date: '20 Juli 2026',
                        name: controller.userProfile.value?['name'] ?? 'Budi Santoso',
                        phone: controller.userProfile.value?['phone'] ?? '081234567890',
                        address: controller.userProfile.value?['primaryAddress'] ?? 'Jl. Mawar No. 12, Jakarta',
                        items: [
                          {'name': 'Sarung Tangan Enduro Giro DND', 'price': 'Rp 420.000', 'qty': 1},
                        ],
                        totalAmount: 'Rp 430.000',
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ----------------------------------------------------
  // BottomSheet: Lihat Detail Pesanan
  // ----------------------------------------------------
  void _showOrderDetailBottomSheet(
    BuildContext context, {
    required String orderId,
    required String status,
    required String date,
    required String name,
    required String phone,
    required String address,
    required List<Map<String, dynamic>> items,
    required String totalAmount,
  }) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.80,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detail Order #$orderId',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A2F),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF047857), size: 24),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status: $status',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF047857),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Tanggal Transaksi: $date',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Alamat Pengiriman
                    const Text(
                      'Alamat Tujuan Pengiriman',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E3A2F)),
                    ),
                    const SizedBox(height: 6),
                    Text('$name ($phone)', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(address, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),

                    const Divider(color: Color(0xFFE2E8F0), height: 28),

                    // Rincian Produk
                    const Text(
                      'Rincian Produk Dipesan',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E3A2F)),
                    ),
                    const SizedBox(height: 10),
                    ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item['name']} (x${item['qty']})',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                            ),
                          ),
                          Text(
                            item['price'].toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFEA580C)),
                          ),
                        ],
                      ),
                    )),

                    const Divider(color: Color(0xFFE2E8F0), height: 28),

                    // Rincian Pembayaran
                    const Text(
                      'Rincian Pembayaran',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E3A2F)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
                        Text(totalAmount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFEA580C))),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A2F),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Tutup Detail', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildProfileSectionCard({
    required IconData icon,
    required String title,
    String? actionText,
    VoidCallback? onActionTap,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1E3A2F), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A2F),
                ),
              ),
              const Spacer(),
              if (actionText != null && onActionTap != null)
                GestureDetector(
                  onTap: onActionTap,
                  child: Text(
                    actionText,
                    style: const TextStyle(
                      color: Color(0xFFEA580C),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, VoidCallback onEdit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onEdit,
          child: const Text(
            'Ubah',
            style: TextStyle(
              color: Color(0xFFEA580C),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem({
    required String orderId,
    required String status,
    required Color statusColor,
    required Color statusTextColor,
    required String details,
    required String price,
    required String buttonText,
    required VoidCallback onButtonTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  orderId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            Text(
              price,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFFEA580C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          details,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onButtonTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1E3A2F),
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(double.infinity, 36),
          ),
          child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // Unit 5: Modal Bottom Sheet opsi Kamera / Galeri
  // ----------------------------------------------------
  void _showAvatarPickerSheet(BuildContext context, ProfileController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ubah Foto Profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A2F),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF1E3A2F)),
              ),
              title: const Text(
                'Ambil Foto dari Kamera',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              subtitle: const Text('Gunakan kamera HP langsung', style: TextStyle(fontSize: 12)),
              onTap: () {
                Get.back();
                controller.pickImage(ImageSource.camera);
              },
            ),
            const Divider(color: Color(0xFFF1F5F9)),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library_outlined, color: Color(0xFFEA580C)),
              ),
              title: const Text(
                'Pilih dari Galeri Foto',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              subtitle: const Text('Pilih foto dari penyimpanan galeri', style: TextStyle(fontSize: 12)),
              onTap: () {
                Get.back();
                controller.pickImage(ImageSource.gallery);
              },
            ),
            if (controller.avatarPath.value.isNotEmpty) ...[
              const Divider(color: Color(0xFFF1F5F9)),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
                ),
                title: const Text(
                  'Hapus Foto Profil',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                ),
                subtitle: const Text('Kembali ke foto avatar standar', style: TextStyle(fontSize: 12)),
                onTap: () {
                  Get.back();
                  controller.removeAvatar();
                },
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
