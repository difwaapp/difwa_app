import 'package:difwa_app/models/Address.dart';
import 'package:difwa_app/routes/store_bottom_bar.dart';
import 'package:difwa_app/routes/user_bottom_bar.dart';
import 'package:difwa_app/screens/add_balance_screen.dart';
import 'package:difwa_app/screens/auth/adddress_form_page.dart';
import 'package:difwa_app/screens/auth/login_screen.dart';
import 'package:difwa_app/screens/auth/signup_screen.dart';
import 'package:difwa_app/screens/available_service_select.dart';
import 'package:difwa_app/screens/book_now_screen.dart';
import 'package:difwa_app/screens/otp_verification_screen/otp_verification_screen.dart';
import 'package:difwa_app/screens/phone_login_screen/phone_login_screen.dart';
import 'package:difwa_app/screens/notification_page.dart';
import 'package:difwa_app/screens/profile_screen_old.dart';
import 'package:difwa_app/screens/splash_screen.dart';
import 'package:difwa_app/screens/stores_screens/global_popup.dart';
import 'package:difwa_app/screens/stores_screens/payment_methods.dart';
import 'package:difwa_app/screens/stores_screens/request_for_withdraw.dart';
import 'package:difwa_app/screens/stores_screens/stor_edit_profile.dart';
import 'package:difwa_app/screens/stores_screens/store_not_verified_page.dart';
import 'package:difwa_app/screens/stores_screens/water_vendor_form.dart';
import 'package:difwa_app/screens/subscription_screen.dart';
import 'package:difwa_app/screens/user_all_transaction_page.dart';
import 'package:difwa_app/screens/onboarding_screen/user_onboarding.dart';
import 'package:difwa_app/screens/welcome_screen/welcome_screen.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const home = '/';
  static const profile = '/profile';
  static const splash = '/splash';
  static const availableservices = '/availableservices';
  static const login = '/login';
  static const phoneLogin = '/phone_login_screen';
  static const otpVerification = '/otp_verification_screen';
  static const welcome = '/welcome';
  static const signUp = '/signup';
  static const otp = '/otp';
  static const userbottom = '/userbottom';
  static const subscription = '/subscription';
  static const address_page = '/address_page';
  static const notification = '/notification_page';
  static const fullScreenPopup = '/fullScreenPopup';
  static const useronboarding = '/useronboarding';
  static const vendoform = '/vendorform';
  static const vendor_edit_form = '/vendor_edit_form';

  static const addbalance_screen = '/addbalance_screen';
  static const vendor_not_verified = '/vendor_not_verified';

  //////// Admin stuff////////
  static const additem = '/additem';
  static const createstore = '/createstore';
  static const requestforwithdraw = '/requestforwithdraw';
  static const storebottombar = '/storebottombar';
  static const store_home = '/store_home';
  static const store_profile = '/store_profile';
  static const paymentmethods = '/paymentmethods';
  static const useralltransaction = '/useralltransaction';

  static final List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(seconds: 1),
    ),
    GetPage(
      name: vendor_not_verified,
      page: () => const StoreNotVerifiedPage(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(seconds: 1),
    ),
    GetPage(
      name: home,
      page: () => BookNowScreen(onProfilePressed: () {}, onMenuPressed: () {}),
      transition: Transition
          .rightToLeftWithFade, // Smooth right-to-left with fade for home screen
      transitionDuration: Duration(milliseconds: 800),
    ),
    GetPage(
      name: useronboarding,
      page: () => UserOnboardingScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 600),
    ),
    GetPage(
      name: profile,
      page: () => ProfileScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 600),
    ),
    GetPage(
      name: notification,
      page: () => const NotificationScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 600),
    ),
    GetPage(
      name: availableservices,
      page: () => const AvailableServiceSelect(),
      transition: Transition.downToUp,
      transitionDuration: Duration(milliseconds: 700),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreenPage(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 1000),
    ),
    GetPage(
      name: phoneLogin,
      page: () => PhoneLoginScreen(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 1000),
    ),

    GetPage(
      name: otpVerification,
      page: () => OtpVerificationScreen(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 1000),
    ),
    GetPage(
      name: welcome,
      page: () => const WelcomeScreen(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 1000),
    ),
    GetPage(
      name: signUp,
      page: () => const MobileNumberPage(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 1000),
    ),
    GetPage(
      name: fullScreenPopup,
      page: () => FullScreenPopupPage(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 1000),
    ),
    GetPage(
      name: userbottom,
      page: () => const BottomUserHomePage(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 600),
    ),
    GetPage(
      name: subscription,
      page: () => SubscriptionScreen(),
      transition: Transition.zoom,
      transitionDuration: Duration(milliseconds: 800),
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
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: requestforwithdraw,
      page: () => const RequestForWithdraw(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: vendoform,
      page: () => const VendorMultiStepForm(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: vendor_edit_form,
      page: () => EditVendorDetailsScreen(),
      transition: Transition.fadeIn,
      transitionDuration: Duration(milliseconds: 500),
    ),
    GetPage(
      name: storebottombar,
      page: () => const BottomStoreHomePage(),
      transition: Transition
          .leftToRight, // Slide transition from left for store dashboard
      transitionDuration: Duration(milliseconds: 600),
    ),

    GetPage(
      name: addbalance_screen,
      page: () => const AddBalanceScreen(),
      transition: Transition
          .leftToRight, // Slide transition from left for store dashboard
      transitionDuration: Duration(milliseconds: 600),
    ),

    GetPage(
      name: useralltransaction,
      page: () => const UserAllTransactionPage(),
      transition: Transition
          .leftToRight, // Slide transition from left for store dashboard
      transitionDuration: Duration(milliseconds: 600),
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
      transition: Transition.fadeIn, // Smooth fade-in for store home screen
      transitionDuration: Duration(milliseconds: 500),
    ),
  ];
}
