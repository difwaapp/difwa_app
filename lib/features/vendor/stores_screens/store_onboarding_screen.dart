import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../config/theme/app_color.dart';
import '../../../widgets/custom_button.dart';

class StoreOnboardingScreen extends StatefulWidget {
  const StoreOnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<StoreOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      "middleImage": 'assets/onboardingimg/onboarding0.svg',
      "newHeading": 'Streamlined Order Management',
      "newDescription":
          'Effortlessly track and manage orders in real-time. Stay on top of deliveries with ease.',
      "titleColor": Colors.white,
      "showButton": false,
    },
    {
      "middleImage": 'assets/onboardingimg/onboarding1.svg',
      "newHeading": 'Optimize Your Storefront',
      "newDescription":
          'Showcase your products beautifully and increase visibility in your local community.',
      "titleColor": Colors.white,
      "showButton": false,
    },
    {
      "middleImage": 'assets/onboardingimg/onboarding2.svg',
      "newHeading": 'Seamless Customer Interaction',
      "newDescription":
          'Communicate effortlessly with your customers for a smooth experience.',
      "titleColor": Colors.black,
      "showButton": false,
    },
    {
      "middleImage": 'assets/onboardingimg/onboarding3.svg',
      "newHeading": 'Join Our Community!',
      "newDescription":
          'Connect with thousands of vendors and grow your business.',
      "titleColor": Colors.white,
      "showButton": true,
    },
  ];

  List<Widget> _buildPageIndicator() {
    return List.generate(
      _pages.length,
      (index) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        height: 10.0,
        width: _currentIndex == index ? 20.0 : 10.0,
        decoration: BoxDecoration(
          color: _currentIndex == index
              ? const Color.fromRGBO(29, 55, 87, 1)
              : Colors.grey,
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  void _onNext() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Get.toNamed(AppRoutes.vendoform);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildOnboardingPage(
                middleImage: _pages[index]['middleImage'],
                newHeading: _pages[index]['newHeading'],
                newDescription: _pages[index]['newDescription'],
                titleColor: _pages[index]['titleColor'],
                showButton: _pages[index]['showButton'],
              );
            },
          ),
          Positioned(
            bottom: 30.0,
            left: 20.0,
            right: 20.0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String middleImage,
    required String newHeading,
    required String newDescription,
    required Color titleColor,
    required bool showButton,
  }) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 300,
                  height: 300,
                  padding: const EdgeInsets.all(50),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SvgPicture.asset(
                    middleImage,
                  ),
                ),
                const SizedBox(height: 130),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    newHeading,
                    textAlign: TextAlign.center,
                    style: TextStyleHelper.instance.black14Bold.copyWith(
                      color: AppColors.secondyColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    newDescription,
                    textAlign: TextAlign.center,
                    style: TextStyleHelper.instance.black14Bold,
                  ),
                ),
                const SizedBox(height: 30),
                if (showButton)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: CustomButton(
                      text: "Create Store",
                      height: 50,
                      width: double.infinity,
                      baseTextColor: Colors.white,
                      backgroundColor: Colors.orange,
                      onPressed: _onNext, // Fixed the callback
                    ),
                  ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
