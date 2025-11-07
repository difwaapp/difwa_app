import '../core/app_export.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/create_account_screen/create_account_screen.dart';

import '../presentation/login_screen/binding/login_binding.dart';
import '../presentation/create_account_screen/binding/create_account_binding.dart';
import '../presentation/app_navigation_screen/app_navigation_screen.dart';
import '../presentation/app_navigation_screen/binding/app_navigation_binding.dart';

// ignore_for_file: must_be_immutable
class AppPages  {
  static List<GetPage> pages = [
    GetPage(
      name: AppRoutes.loginScreen,
      page: () => LoginScreen(),
      bindings: [LoginBinding()],
    ),
    GetPage(
      name: AppRoutes.createAccountScreen,
      page: () => CreateAccountScreen(),
      bindings: [CreateAccountBinding()],
    ),
    GetPage(
      name: AppRoutes.appNavigationScreen,
      page: () => AppNavigationScreen(),
      bindings: [AppNavigationBinding()],
    ),
    GetPage(
      name: '/',
      page: () => AppNavigationScreen(),
      bindings: [AppNavigationBinding()],
    ),
  ];
}
