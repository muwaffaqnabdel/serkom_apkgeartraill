abstract class Routes {
  Routes._();

  static const login = _Paths.login;
  static const register = _Paths.register;
  static const forgotPassword = _Paths.forgotPassword;
  static const changePassword = _Paths.changePassword;
  static const main = _Paths.main;
  static const home = _Paths.home;
  static const catalog = _Paths.catalog;
  static const cart = _Paths.cart;
  static const profile = _Paths.profile;
  static const nearbyStores = _Paths.nearbyStores;
  static const orderTracking = _Paths.orderTracking;
}

abstract class _Paths {
  _Paths._();

  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const changePassword = '/change-password';
  static const main = '/main';
  static const home = '/home';
  static const catalog = '/catalog';
  static const cart = '/cart';
  static const profile = '/profile';
  static const nearbyStores = '/nearby-stores';
  static const orderTracking = '/order-tracking';
}
