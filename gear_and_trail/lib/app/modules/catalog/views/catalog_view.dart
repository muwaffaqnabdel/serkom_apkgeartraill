import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/catalog_controller.dart';
import '../../main/controllers/main_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../../widgets/product_card.dart';
import '../../../widgets/product_detail_sheet.dart';
import '../../../widgets/skeleton_loader.dart';

class CatalogView extends GetView<CatalogController> {
  const CatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController mainController = Get.find<MainController>();
    final CartController cartController = Get.find<CartController>();

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: SizedBox(
              height: 40,
              child: Obx(() => ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final cat = controller.categories[index];
                  return Obx(() {
                    final isActive = cat == controller.activeCategory.value;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ElevatedButton(
                        onPressed: () => controller.selectCategory(cat),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive ? const Color(0xFF1E3A2F) : const Color(0xFFF8FAFC),
                          foregroundColor: isActive ? Colors.white : const Color(0xFF64748B),
                          side: BorderSide(
                            color: isActive ? Colors.transparent : const Color(0xFFCBD5E1),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          elevation: 0,
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  });
                },
              )),
            ),
          ),

          const SizedBox(height: 16),

          // Product Grid Section
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return SkeletonLoader.buildCatalogSkeleton();
              }

              final products = controller.filteredProducts;
              if (products.isEmpty) {
                return const Center(
                  child: Text(
                    'Tidak ada produk untuk kategori ini',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    circularFavoriteBadge: true,
                    onTap: () {
                      Get.bottomSheet(
                        ProductDetailSheet(product: product),
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                      );
                    },
                    onAddToCart: () {
                      cartController.addToCart(product);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
