import 'package:get/get.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/auth/views/change_password_view.dart';
import '../modules/main/bindings/main_binding.dart';
import '../modules/main/views/main_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/views/nearby_stores_view.dart';
import '../modules/catalog/views/catalog_view.dart';
import '../modules/cart/bindings/cart_binding.dart';
import '../modules/cart/views/cart_view.dart';
import '../modules/cart/views/order_tracking_view.dart';
import '../modules/profile/views/profile_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.login;

  static final routes = [
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordView(),
    ),
    GetPage(
      name: Routes.changePassword,
      page: () => const ChangePasswordView(),
    ),
    GetPage(
      name: Routes.main,
      page: () => const MainView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
    ),
    GetPage(
      name: Routes.catalog,
      page: () => const CatalogView(),
    ),
    GetPage(
      name: Routes.cart,
      page: () => const CartView(),
      binding: CartBinding(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileView(),
    ),
    GetPage(
      name: Routes.nearbyStores,
      page: () => const NearbyStoresView(),
    ),
    GetPage(
      name: Routes.orderTracking,
      page: () => const OrderTrackingView(),
    ),
  ];
}
