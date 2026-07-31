import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/product.dart';
import '../../../data/providers/product_provider.dart';

class BannerItem {
  final String image;
  final String title;
  final String subtitle;

  const BannerItem({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

class HomeController extends GetxController {
  final ProductProvider _provider = Get.find<ProductProvider>();

  final products = <Product>[].obs;
  final isLoading = true.obs;

  final PageController bannerPageController = PageController();
  final currentBannerIndex = 0.obs;
  Timer? _bannerTimer;

  final List<BannerItem> banners = const [
    BannerItem(
      image: 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=1000&auto=format&fit=crop&q=80',
      title: 'SEPEDA GUNUNG &\nPERALATAN OUTDOOR',
      subtitle: 'Pilihan sepeda MTB trail, enduro, helm proteksi, serta aksesori gowes terbaik untuk petualanganmu.',
    ),
    BannerItem(
      image: 'https://images.unsplash.com/photo-1532298229144-0ec0c57515c7?w=1000&auto=format&fit=crop&q=80',
      title: 'PETUALANGAN TRAIL\nTANPA BATAS',
      subtitle: 'Jelajahi keindahan medan ekstrem dengan performa suspensi & komponen sepeda kelas dunia.',
    ),
    BannerItem(
      image: 'https://images.unsplash.com/photo-1576435728678-68d0fbf94e91?w=1000&auto=format&fit=crop&q=80',
      title: 'PERLENGKAPAN GOWES\nPROFESIONAL',
      subtitle: 'Proteksi maksimal dan perlengkapan MTB teruji tahan di segala kondisi cuaca.',
    ),
    BannerItem(
      image: 'https://images.unsplash.com/photo-1507035895480-2b3156c31fc8?w=1000&auto=format&fit=crop&q=80',
      title: 'PROMO SPESIAL\nGEAR & TRAIL 2026',
      subtitle: 'Dapatkan penawaran harga terbaik untuk aksesoris dan suku cadang sepeda MTB pilihan.',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    fetchHomeProducts();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (bannerPageController.hasClients) {
        final nextPage = (currentBannerIndex.value + 1) % banners.length;
        bannerPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void onPageChanged(int index) {
    currentBannerIndex.value = index;
  }

  @override
  void onClose() {
    _bannerTimer?.cancel();
    bannerPageController.dispose();
    super.onClose();
  }

  Future<void> fetchHomeProducts() async {
    isLoading.value = true;
    final res = await _provider.getProducts();
    if (res.isNotEmpty) {
      products.assignAll(res);
    }
    isLoading.value = false;
  }

  List<Product> get recommendedProducts {
    final favorites = products.where((p) => p.isFavorite).toList();
    if (favorites.isNotEmpty) {
      return favorites;
    }
    return products.take(4).toList();
  }
}

