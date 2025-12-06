import 'package:difwa_app/features/vendor/profile/edit_vendor_details_screen.dart';
import 'package:difwa_app/models/Address.dart';
import 'package:difwa_app/features/vendor/vendor_dashbord_screen.dart';
import 'package:difwa_app/features/user/user_dashboard_screen.dart';
import 'package:difwa_app/features/user/wallet/add_balance_screen.dart';
import 'package:difwa_app/features/address/adddress_form_page.dart';
import 'package:difwa_app/features/auth/login_screen.dart';
import 'package:difwa_app/features/auth/signup_screen.dart';
import 'package:difwa_app/features/user/home/home_screen.dart';
import 'package:difwa_app/features/auth/otp_verification/binding/OtpBinding.dart';
import 'package:difwa_app/features/auth/otp_verification/otp_verification_screen.dart';
import 'package:difwa_app/features/auth/phone_login/phone_login_screen.dart';
import 'package:difwa_app/features/notifications/notification_page.dart';
import 'package:difwa_app/features/user/profile/binding/profile_binding.dart';
import 'package:difwa_app/features/user/profile/edit_profile_screen.dart';
import 'package:difwa_app/features/user/profile/profile_screen_home.dart';
import 'package:difwa_app/splash_screen.dart';
import 'package:difwa_app/features/vendor/stores_screens/global_popup.dart';
import 'package:difwa_app/features/vendor/stores_screens/payment_methods.dart';
import 'package:difwa_app/features/vendor/stores_screens/request_for_withdraw.dart';
import 'package:difwa_app/features/vendor/stores_screens/store_not_verified_page.dart';
import 'package:difwa_app/features/vendor/stores_screens/water_vendor_form.dart';
import 'package:difwa_app/features/vendor/stores_screens/binding/vendor_form_binding.dart';
import 'package:difwa_app/features/user/subscription_screen.dart';
import 'package:difwa_app/features/user/user_all_transaction_page.dart';
import 'package:difwa_app/features/onboarding/user_onboarding.dart';
import 'package:difwa_app/features/user/orders/orders_screen.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const home = '/';

  static const splash = '/splash';
  static const availableservices = '/availableservices';
  static const login = '/login';
  static const phoneLogin = '/phone_login_screen';
  static const otpVerification = '/otp_verification_screen';
  static const profileScreen = '/profile_screen';
  static const profileOld = '/profile_old';
  static const profileHome = '/profile_home';

  static const welcome = '/welcome';
  static const signUp = '/signup';
  static const otp = '/otp';

  static const userDashbord = '/user-dashbord';

  static const subscription = '/subscription';
  static const address_page = '/address_page';
  static const notification = '/notification_page';
  static const fullScreenPopup = '/fullScreenPopup';
  static const useronboarding = '/useronboarding';
  static const vendoform = '/vendorform';
  static const vendor_edit_form = '/vendor_edit_form';

  static const addbalance_screen = '/addbalance_screen';
  static const vendor_not_verified = '/vendor_not_verified';
  static const myOrders = '/my_orders';

  //////// Admin stuff////////
  static const verndorDashbord = '/verndor-dashbord';
  static const vendorHome = '/vendor-home';

  static const additem = '/additem';
  static const createstore = '/createstore';
  static const requestforwithdraw = '/requestforwithdraw';
  static const store_profile = '/store_profile';
  static const paymentmethods = '/paymentmethods';
  static const useralltransaction = '/useralltransaction';

  static final List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      // transition: Transition.fadeIn,
      // transitionDuration: Duration(seconds: 1),
    ),
    GetPage(
      name: vendor_not_verified,
      page: () => const StoreNotVerifiedPage(),
      // transition: Transition.fadeIn,
      // transitionDuration: Duration(seconds: 1),
    ),
    GetPage(
      name: home,
      page: () =>
          HomeScreen(onWalletPressed: () {}, onNotificationPressed: () {}),
      // transition: Transition
      //     .rightToLeftWithFade, // Smooth right-to-left with fade for home screen
      // transitionDuration: Duration(milliseconds: 800),
    ),
    GetPage(
      name: useronboarding,
      page: () => UserOnboardingScreen(),
      // transition: Transition.fadeIn,
      // transitionDuration: Duration(milliseconds: 600),
    ),
    GetPage(
      name: profileScreen,
      page: () => EditProfileScreen(),
      // transition: Transition.fadeIn,
      // transitionDuration: Duration(milliseconds: 600),
      binding: ProfileBinding(),
    ),

    GetPage(
      name: profileHome,
      page: () => ProfileScreenHome(),
      // transition: Transition.fadeIn,
      // transitionDuration: Duration(milliseconds: 600),
    ),
    GetPage(
      name: notification,
      page: () => const NotificationScreen(),
      // transition: Transition.fadeIn,
      // transitionDuration: Duration(milliseconds: 600),
    ),

    GetPage(
      name: login,
      page: () => const LoginScreenPage(),
      // transition: Transition.circularReveal,
      // transitionDuration: Duration(milliseconds: 1000),
    ),
    GetPage(
      name: phoneLogin,
      page: () => PhoneLoginScreen(),
      // transition: Transition.circularReveal,
      // transitionDuration: Duration(milliseconds: 1000),
    ),

    GetPage(
      name: otpVerification,
      page: () => OtpVerificationScreen(),
      // transition: Transition.circularReveal,
      // transitionDuration: Duration(milliseconds: 1000),
      binding: OtpBinding(),
    ),

    GetPage(
      name: signUp,
      page: () => const MobileNumberPage(),
      // transition: Transition.circularReveal,
      // transitionDuration: Duration(milliseconds: 1000),
    ),
    GetPage(
      name: fullScreenPopup,
      page: () => FullScreenPopupPage(),
      // transition: Transition.circularReveal,
      // transitionDuration: Duration(milliseconds: 1000),
    ),
    GetPage(
      name: userDashbord,
      page: () => const UserDashbordScreen(),
      // transition: Transition.rightToLeft,
      // transitionDuration: Duration(milliseconds: 600),
    ),
    GetPage(
      name: subscription,
      page: () => SubscriptionScreen(),
      // transition: Transition.zoom,
      // transitionDuration: Duration(milliseconds: 800),
    ),

    /////////////////////////Admin Routes/////////////////
    // GetPage(
    //   name: createstore,
    //   page: () => const CreateStorePage(),
    //   transition: Transition.fadeIn,
    //   transitionDuration: Duration(milliseconds: 500),
    // ),
    GetPage(
      name: paymentmethods,
      page: () => const PaymentMethods(),
      // transition: Transition.fadeIn,
      // transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: requestforwithdraw,
      page: () => const RequestForWithdraw(),
      // transition: Transition.fadeIn,
      // transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: vendoform,
      page: () => VendorMultiStepForm(),
      binding: VendorFormBinding(),
      // transition: Transition.fadeIn,
      // transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: vendor_edit_form,
      page: () => EditVendorDetailsScreen(),
      binding: VendorFormBinding(),
      // transition: Transition.fadeIn,
      // transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: verndorDashbord,
      page: () => const VendorDashbordScreen(),
      // transition: Transition
      //     .leftToRight, // Slide transition from left for store dashboard
      // transitionDuration: Duration(milliseconds: 600),
    ),

    GetPage(
      name: addbalance_screen,
      page: () => const AddBalanceScreen(),
      // transition: Transition
      //     .leftToRight, // Slide transition from left for store dashboard
      // transitionDuration: Duration(milliseconds: 600),
    ),

    GetPage(
      name: useralltransaction,
      page: () => const UserAllTransactionPage(),
      // transition: Transition
      //     .leftToRight, // Slide transition from left for store dashboard
      // transitionDuration: Duration(milliseconds: 600),
    ),
    GetPage(
      name: address_page,
      page: () => AddressForm(
        address: Address(
          docId: "",
          name: "",
          street: "",
          city: "",
          state: "",
          zip: "",
          isDeleted: false,
          isSelected: false,
          country: "",
          phone: "",
          saveAddress: false,
          uid: "",
          floor: "",
          locationType: '',
        ),
        flag: "",
      ),
      // transition: Transition.fadeIn, // Smooth fade-in for store home screen
      // transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: myOrders,
      page: () => const OrdersScreen(),
      // transition: Transition.fadeIn,
      // transitionDuration: Duration(milliseconds: 500),
    ),
  ];
}
