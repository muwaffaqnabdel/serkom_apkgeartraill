import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../../main/controllers/main_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../data/providers/location_service.dart';
import '../../../routes/app_routes.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  final _locationService = Get.find<LocationService>();

  @override
  void initState() {
    super.initState();
    String initName = '';
    String initPhone = '';
    String initAddress = '';

    if (Get.isRegistered<AuthController>()) {
      final auth = Get.find<AuthController>();
      final user = auth.currentUser.value;
      if (user != null) {
        initName = user['name']?.toString() ?? '';
        initPhone = user['phone']?.toString() ?? user['phoneNumber']?.toString() ?? '';
        initAddress = user['address']?.toString() ?? '';
      }
    }

    _nameController = TextEditingController(text: initName);
    _phoneController = TextEditingController(text: initPhone);
    _addressController = TextEditingController(text: initAddress);
  }

  Future<void> _autoFillLocation() async {
    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      final area = _locationService.generateAddressFromCoords(position.latitude, position.longitude);
      final coords = _locationService.formatCoordinates(position);
      _addressController.text = 'Lokasi GPS: $area\n($coords)';
    }
  }

  void _usePrimaryAddress() {
    String primaryAddr = '';

    if (Get.isRegistered<ProfileController>()) {
      final profileCtrl = Get.find<ProfileController>();
      primaryAddr = profileCtrl.userProfile.value?['primaryAddress']?.toString() ?? '';
    }

    if (primaryAddr.isEmpty && Get.isRegistered<AuthController>()) {
      final authCtrl = Get.find<AuthController>();
      primaryAddr = authCtrl.currentUser.value?['primaryAddress']?.toString() ??
                    authCtrl.currentUser.value?['address']?.toString() ?? '';
    }

    if (primaryAddr.isEmpty) {
      primaryAddr = 'Jl. Mawar No. 12, RT 03/RW 05, Kel. Sukamaju, Kec. Cilandak, Jakarta Selatan';
    }

    setState(() {
      _addressController.text = primaryAddr;
    });

    Get.snackbar(
      'Alamat Utama Diterapkan',
      'Alamat pengiriman diisi dari Alamat Utama Profil.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E3A2F),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();
    final MainController mainController = Get.find<MainController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E3A2F)),
          onPressed: () => mainController.changePage(0),
        ),
        title: const Text(
          'KERANJANG',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 0.8,
            color: Color(0xFF1E3A2F),
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (cartController.cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Keranjang belanja Anda masih kosong',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => mainController.changePage(1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A2F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Mulai Belanja'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cart Items Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartController.cartItems.length,
                    separatorBuilder: (context, index) => const Divider(
                      color: Color(0xFFF0ECE6),
                      height: 24,
                    ),
                    itemBuilder: (context, index) {
                      final item = cartController.cartItems[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: Image.network(
                                item.product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: const Color(0xFFF8FAFC),
                                  child: const Icon(
                                    Icons.shopping_bag_outlined,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.product.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF1E3A2F),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      cartController.formatPrice(item.totalPrice),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E3A2F),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.product.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove, size: 14, color: Color(0xFF1E3A2F)),
                                            onPressed: () {
                                              cartController.updateQuantity(item.product, item.quantity - 1);
                                            },
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.all(6),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            child: Text(
                                              '${item.quantity}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1E3A2F),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add, size: 14, color: Color(0xFF1E3A2F)),
                                            onPressed: () {
                                              cartController.updateQuantity(item.product, item.quantity + 1);
                                            },
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.all(6),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Color(0xFF9E9188),
                                        size: 20,
                                      ),
                                      onPressed: () => cartController.removeFromCart(item.product),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Location Detection Card
                Obx(() {
                  final pos = _locationService.currentPosition.value;
                  final isLoading = _locationService.isLoading.value;
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: pos != null ? const Color(0xFFA7F3D0) : const Color(0xFFE5DED9),
                      ),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: pos != null ? const Color(0xFFECFDF5) : const Color(0xFFFAF3E0),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            pos != null ? Icons.location_on : Icons.explore_outlined,
                            color: pos != null ? const Color(0xFF047857) : const Color(0xFF1E3A2F),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pos != null ? 'Lokasi GPS Terdeteksi' : 'Auto-Isi Alamat dari GPS',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: pos != null ? const Color(0xFF047857) : const Color(0xFF1E3A2F),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                pos != null
                                    ? _locationService.formatCoordinates(pos)
                                    : 'Ketuk tombol untuk isi otomatis alamat pengiriman',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        isLoading
                            ? const SizedBox(
                                width: 22, height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E3A2F)),
                              )
                            : TextButton(
                                onPressed: _autoFillLocation,
                                style: TextButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E3A2F),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(
                                  pos != null ? 'Update' : 'Deteksi',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 24),

                const Text(
                  'Informasi Pengiriman',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E3A2F),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                      const Text(
                        'Nama Lengkap',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Masukkan nama Anda',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Nomor HP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Contoh: 08123456789',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) => v!.isEmpty ? 'Nomor HP tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Alamat Lengkap',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _addressController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Masukkan alamat lengkap pengiriman',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) => v!.isEmpty ? 'Alamat tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 8),
                      // Quick Address Selector Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ActionChip(
                              avatar: const Icon(Icons.home, size: 14, color: Color(0xFF1E3A2F)),
                              label: const Text('Alamat Utama Profil', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E3A2F))),
                              backgroundColor: const Color(0xFFF1F5F9),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              onPressed: _usePrimaryAddress,
                            ),
                            const SizedBox(width: 8),
                            ActionChip(
                              avatar: const Icon(Icons.my_location, size: 14, color: Color(0xFFEA580C)),
                              label: const Text('Deteksi Lokasi GPS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFEA580C))),
                              backgroundColor: const Color(0xFFFFF7ED),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              onPressed: _autoFillLocation,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Ringkasan Pesanan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E3A2F),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal (${cartController.totalItems} Barang)',
                            style: const TextStyle(color: Color(0xFF64748B)),
                          ),
                          Text(
                            cartController.formatPrice(cartController.subtotal),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E3A2F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ongkir',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                          Text(
                            cartController.formatPrice(cartController.shipping),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E3A2F),
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFFE2E8F0), height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A2F),
                            ),
                          ),
                          Text(
                            cartController.formatPrice(cartController.grandTotal),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEA580C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            Get.dialog(
                              const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A2F))),
                              barrierDismissible: false,
                            );

                            final orderResult = await cartController.checkout(
                              name: _nameController.text,
                              phone: _phoneController.text,
                              address: _addressController.text,
                            );

                            Get.back(); // Tutup loading dialog

                            if (orderResult != null) {
                              // Langsung arahkan ke Layar Lacak Status Pesanan (OrderTrackingView)
                              Get.toNamed(Routes.orderTracking, arguments: orderResult);
                            } else {
                              Get.snackbar(
                                'Gagal',
                                'Gagal membuat pesanan. Pastikan server backend berjalan.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFFDC2626),
                                colorText: Colors.white,
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A2F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Pesan Sekarang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }
}
