import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../home/views/home_view.dart';
import '../../catalog/views/catalog_view.dart';
import '../../cart/views/cart_view.dart';
import '../../profile/views/profile_view.dart';
import '../../../data/providers/network_service.dart';
import '../../../widgets/skeleton_loader.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final NetworkService networkService = Get.find<NetworkService>();

    final List<Widget> pages = const [
      HomeView(),
      CatalogView(),
      CartView(),
      ProfileView(),
    ];

    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: const Color(0xFFF8FAFC),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF1E3A2F),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Gear & Trail',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Toko Sepeda Gunung & Gear Outdoor',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined, color: Color(0xFF1E3A2F)),
                title: const Text('Beranda', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Get.back();
                  controller.changePage(0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.grid_view_outlined, color: Color(0xFF1E3A2F)),
                title: const Text('Katalog', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Get.back();
                  controller.changePage(1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF1E3A2F)),
                title: const Text('Keranjang', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Get.back();
                  controller.changePage(2);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline, color: Color(0xFF1E3A2F)),
                title: const Text('Profil Saya', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Get.back();
                  controller.changePage(3);
                },
              ),
              const Spacer(),
              const Divider(color: Color(0xFFE2E8F0)),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFB71C1C)),
                title: const Text(
                  'Keluar',
                  style: TextStyle(color: Color(0xFFB71C1C), fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Get.back();
                  authController.logout();
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Offline Banner — muncul saat tidak ada koneksi internet
          Obx(() {
            if (networkService.isOnline.value) return const SizedBox.shrink();
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: const Color(0xFFDC2626),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Tidak Ada Koneksi Internet — Mode Offline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              if (controller.isPageLoading.value) {
                final idx = controller.currentIndex.value;
                switch (idx) {
                  case 0:
                    return SkeletonLoader.buildHomeSkeleton();
                  case 1:
                    return SkeletonLoader.buildCatalogSkeleton();
                  case 2:
                    return SkeletonLoader.buildCartSkeleton();
                  case 3:
                    return SkeletonLoader.buildProfileSkeleton();
                  default:
                    return SkeletonLoader.buildHomeSkeleton();
                }
              }

              return IndexedStack(
                index: controller.currentIndex.value,
                children: pages,
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(0, Icons.home_outlined, Icons.home, 'Beranda'),
              _buildBottomNavItem(1, Icons.grid_view_outlined, Icons.grid_view, 'Katalog'),
              _buildBottomNavItem(2, Icons.shopping_cart_outlined, Icons.shopping_cart, 'Keranjang'),
              _buildBottomNavItem(3, Icons.person_outline, Icons.person, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData outlineIcon, IconData filledIcon, String label) {
    return Obx(() {
      final isActive = controller.currentIndex.value == index;
      if (isActive) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A2F),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(filledIcon, color: Colors.white, size: 20),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      } else {
        return InkWell(
          onTap: () => controller.changePage(index),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(outlineIcon, color: const Color(0xFF64748B), size: 22),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
  }
}
