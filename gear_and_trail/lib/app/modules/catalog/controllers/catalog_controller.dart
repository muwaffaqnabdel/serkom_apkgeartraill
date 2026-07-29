import 'package:get/get.dart';
import '../../../data/models/product.dart';
import '../../../data/providers/product_provider.dart';

class CatalogController extends GetxController {
  final ProductProvider _provider = Get.find<ProductProvider>();

  final activeCategory = 'Semua'.obs;
  final categories = <String>['Semua', 'Sepeda Gunung (MTB)', 'Helm & Protektor', 'Aksesori & Outfits', 'Sparepart & Komponen', 'Tas & Hydration Pack'].obs;
  final products = <Product>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchProducts();
  }

  Future<void> fetchCategories() async {
    final fetched = await _provider.getCategories();
    if (fetched.isNotEmpty) {
      final list = ['Semua'];
      for (final cat in fetched) {
        if (!list.contains(cat)) list.add(cat);
      }
      categories.assignAll(list);
    }
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    final res = await _provider.getProducts(category: activeCategory.value);
    products.assignAll(res);
    isLoading.value = false;
  }

  void selectCategory(String category) {
    activeCategory.value = category;
    fetchProducts();
  }

  List<Product> get filteredProducts => products;
}

