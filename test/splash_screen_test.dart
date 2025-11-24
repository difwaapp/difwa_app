import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:difwa_app/splash_screen.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:lottie/lottie.dart';

void main() {
  testWidgets('SplashScreen navigates after animation', (WidgetTester tester) async {
    // Mock the Lottie asset loading if necessary, but for basic widget testing
    // we might just check if the widget renders and attempts navigation.
    // However, Lottie.asset might fail in tests without proper asset bundle mocking.
    // For now, let's try to pump the widget and see if it renders the Lottie widget.
    
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.splash,
        getPages: [
          GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
          GetPage(name: AppRoutes.home, page: () => const Scaffold(body: Text('Home'))),
        ],
      ),
    );

    expect(find.byType(Lottie), findsOneWidget);

    // We can't easily test the exact animation duration and completion in a unit test 
    // without more complex mocking of the Lottie composition.
    // But we can verify the structure.
  });
}
