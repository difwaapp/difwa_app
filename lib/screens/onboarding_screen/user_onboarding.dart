import 'package:difwa_app/config/theme/app_color.dart';
import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/controller/OnboardingController.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:difwa_app/widgets/others/back_press_toexit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserOnboardingScreen extends StatefulWidget {
  const UserOnboardingScreen({super.key});

  @override
  State<UserOnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<UserOnboardingScreen> {
  final OnboardingController controller = Get.put(OnboardingController());

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/icon/onboarding1.svg',
      'title': 'We Deliver the Purest Water',
      'description':
          'Experience crystal-clear, mineral-balanced water sourced and purified to the highest standards.',
    },
    {
      'image': 'assets/icon/onboarding2.svg',
      'title': 'Get Water When You Need It',
      'description':
          'Set your delivery time once, and we’ll handle the rest — daily, weekly, or on demand.',
    },
    {
      'image': 'assets/icon/onboarding3.svg',
      'title': 'Fast. Reliable. Sustainable.',
      'description':
          'Enjoy doorstep delivery from trusted local partners who care about quality and the planet.',
    },
  ];

  @override
  void initState() {
    super.initState();
    // _checkOnboardingStatus();
  }

  Future<void> _markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    Get.offAllNamed(AppRoutes.phoneLogin);
  }

  @override
  Widget build(BuildContext context) {
    return BackPressToExit(
      child: Scaffold(
        body: Stack(
          children: [
            _buildPageView(),
            _buildBackgroundCircle(),
            _buildIndicator(),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  void _onNext() {
    if (controller.currentIndex < 2) {
      controller.nextPage();
    } else {
      _markOnboardingComplete();
      Get.toNamed(AppRoutes.login);
    }
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: controller.pageController,
      onPageChanged: (index) => controller.currentIndex.value = index,
      itemCount: onboardingData.length,
      itemBuilder: (context, index) {
        return OnboardingPage(
          image: onboardingData[index]['image']!,
          title: onboardingData[index]['title']!,
          description: onboardingData[index]['description']!,
        );
      },
    );
  }

  Widget _buildIndicator() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 164,
      child: Align(
        alignment: Alignment.center,
        child: Obx(() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onboardingData.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: 23,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: controller.currentIndex.value == index
                      ? appTheme.primayColor
                      : appTheme.grayLight,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBackgroundCircle() {
    return Positioned(
      left: -400,
      right: -400,
      bottom: -500,
      child: Center(
        child: Container(
          width: 800,
          height: 700,
          decoration: BoxDecoration(
            color: AppColors.cardbgcolor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 50,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SizedBox(
            width: double.infinity,
            height: 65,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _markOnboardingComplete,
                  child: Text(
                    "Skip",
                    style: TextStyleHelper.instance.title16BoldPoppins.copyWith(
                      height: 1.5,
                    ),
                  ),
                ),
                Obx(() {
                  return controller.currentIndex.value !=
                          onboardingData.length - 1
                      ? TextButton(
                          onPressed: _onNext,
                          child: Text(
                            "Next",
                            style: TextStyleHelper.instance.title16BoldPoppins
                                .copyWith(height: 1.5),
                          ),
                        )
                      : TextButton(
                          onPressed: _markOnboardingComplete,
                          child: Text(
                            "Get Started",
                            style: TextStyleHelper.instance.title16BoldPoppins
                                .copyWith(height: 1.5),
                          ),
                        );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 98),
            SvgPicture.asset(image, height: 300, fit: BoxFit.contain),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    title,
                    style: TextStyleHelper.instance.title20BoldPoppins.copyWith(
                      height: 1.5,
                    ),

                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    description,
                    style: TextStyleHelper.instance.body14RegularPoppins
                        .copyWith(height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
