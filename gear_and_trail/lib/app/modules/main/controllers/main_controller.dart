import 'package:get/get.dart';

class MainController extends GetxController {
  final currentIndex = 0.obs;
  final isPageLoading = false.obs;

  void changePage(int index) {
    if (currentIndex.value == index) return;
    isPageLoading.value = true;
    currentIndex.value = index;
    Future.delayed(const Duration(milliseconds: 400), () {
      isPageLoading.value = false;
    });
  }
}
