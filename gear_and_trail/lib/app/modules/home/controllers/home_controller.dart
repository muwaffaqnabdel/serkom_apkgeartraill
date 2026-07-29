import 'package:get/get.dart';
import '../../../data/models/product.dart';
import '../../../data/providers/product_provider.dart';

class HomeController extends GetxController {
  final ProductProvider _provider = Get.find<ProductProvider>();

  final products = <Product>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeProducts();
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

