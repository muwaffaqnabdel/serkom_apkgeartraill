import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/data/providers/product_provider.dart';
import 'app/data/providers/local_storage_service.dart';
import 'app/data/providers/network_service.dart';
import 'app/data/providers/notification_service.dart';
import 'app/data/providers/location_service.dart';
import 'app/modules/auth/controllers/auth_controller.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init('GearTrailDB');
  Get.put(LocalStorageService(), permanent: true);
  Get.put(ProductProvider());
  Get.put(NetworkService(), permanent: true);
  Get.put(NotificationService(), permanent: true);
  Get.put(LocationService(), permanent: true);
  Get.put(AuthController(), permanent: true);
  runApp(const GearTrailApp());
}

class GearTrailApp extends StatelessWidget {
  const GearTrailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Gear & Trail',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
