import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../config/theme/app_color.dart';
import '../../config/theme/text_style_helper.dart';
import '../../config/theme/theme_helper.dart';
import '../../routes/app_routes.dart';
import '../../widgets/others/back_press_toexit.dart';
import 'controller/onboarding_controller.dart';

class UserOnboardingScreen extends StatefulWidget {
  const UserOnboardingScreen({super.key});

  @override
  _UserOnboardingScreenState createState() => _UserOnboardingScreenState();
}

class _UserOnboardingScreenState extends State<UserOnboardingScreen> {
  final OnboardingController controller = Get.put(OnboardingController());

  final List<_OnboardData> pages = [
    _OnboardData(
      image: 'assets/icon/onboarding1.svg',
      title: 'We Deliver the Purest Water',
      description:
          'Experience crystal-clear, mineral-balanced water sourced and purified to the highest standards.',
    ),
    _OnboardData(
      image: 'assets/icon/onboarding2.svg',
      title: 'Get Water When You Need It',
      description:
          'Set your delivery time once and we’ll handle the rest — daily, weekly or on demand.',
    ),
    _OnboardData(
      image: 'assets/icon/onboarding3.svg',
      title: 'Fast. Reliable. Sustainable.',
      description:
          'Doorstep delivery from trusted local partners who care about quality and the planet.',
    ),
  ];

  void _markOnboardingComplete() async {
    // Save to prefs / navigate
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('onboardingComplete', true);
    Get.offAllNamed(AppRoutes.login); // adjust route constant to your app
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelper().themeData();
    final size = MediaQuery.of(context).size;
    return BackPressToExit(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            // light gradient + subtle texture look
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.95),
                AppColors.primary.withOpacity(0.85),
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Top-left floating accent circle
                Positioned(
                  left: -size.width * 0.3,
                  top: -size.width * 0.25,
                  child: Container(
                    width: size.width * 0.7,
                    height: size.width * 0.7,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // PageView content
                Positioned.fill(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // Small app logo / title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Difwa',
                            style: TextStyleHelper
                                .instance
                                .title20BoldPoppinsBlue
                                .copyWith(
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: PageView.builder(
                          controller: controller.pageController,
                          onPageChanged: (index) =>
                              controller.currentIndex.value = index,
                          itemCount: pages.length,
                          itemBuilder: (context, index) {
                            final p = pages[index];
                            return _OnboardingCard(data: p);
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom rounded panel with controls
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // indicators + Skip
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _markOnboardingComplete,
                              child: Text(
                                'Skip',
                                style: TextStyleHelper
                                    .instance
                                    .body14BoldPoppins
                                    .copyWith(color: appTheme.secondyColor),
                              ),
                            ),
                            Obx(() {
                              return Row(
                                children: List.generate(
                                  pages.length,
                                  (i) => _buildIndicator(
                                    i,
                                    controller.currentIndex.value,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Primary button row
                        Obx(() {
                          final isLast =
                              controller.currentIndex.value == pages.length - 1;
                          return Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isLast
                                      ? _markOnboardingComplete
                                      : controller.nextPage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 6,
                                    shadowColor: AppColors.primary.withOpacity(
                                      0.35,
                                    ),
                                  ),
                                  child: Text(
                                    isLast ? 'Get Started' : 'Next',
                                    style: TextStyleHelper
                                        .instance
                                        .title16BoldPoppins
                                        .copyWith(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // small ghost button for previous (only visible if not first)
                              AnimatedOpacity(
                                opacity: controller.currentIndex.value == 0
                                    ? 0.0
                                    : 1.0,
                                duration: const Duration(milliseconds: 300),
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: OutlinedButton(
                                    onPressed:
                                        controller.currentIndex.value == 0
                                        ? null
                                        : controller.previousPage,
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: appTheme.grayLight,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      backgroundColor: Colors.white,
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(int index, int activeIndex) {
    final isActive = index == activeIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: isActive ? 28 : 10,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? appTheme.primayColor : appTheme.grayLight,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  final _OnboardData data;
  const _OnboardingCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageHeight = size.height * 0.36;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 30),
          // artwork
          Semantics(
            label: data.title,
            child: SizedBox(
              height: imageHeight,
              child: Center(
                child: SvgPicture.asset(
                  data.image,
                  width: imageHeight * 0.9,
                  height: imageHeight * 0.9,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
          // card block with title and description
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            child: Column(
              children: [
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: TextStyleHelper.instance.title20BoldPoppins.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: TextStyleHelper.instance.body14RegularPoppins.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // Spacer to push up content
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _OnboardData {
  final String image;
  final String title;
  final String description;

  _OnboardData({
    required this.image,
    required this.title,
    required this.description,
  });
}
