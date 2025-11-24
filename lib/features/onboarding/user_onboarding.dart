import 'package:difwa_app/config/theme/app_color.dart';
import 'package:difwa_app/controller/OnboardingController.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:difwa_app/widgets/custom_button.dart';
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
  bool isLoading = false;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/icon/one.svg',
      'title': 'Premium Quality Water',
      'description':
          'Experience crystal-clear, mineral-rich water sourced from the finest springs and purified to perfection for your health.',
    },
    {
      'image': 'assets/icon/two.svg',
      'title': 'Flexible Delivery Schedule',
      'description':
          'Choose your preferred delivery time and frequency. Daily, weekly, or on-demand — we adapt to your lifestyle.',
    },
    {
      'image': 'assets/icon/three.svg',
      'title': 'Fast & Eco-Friendly Delivery',
      'description':
          'Enjoy prompt doorstep delivery from trusted partners committed to quality service and environmental sustainability.',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _markOnboardingComplete() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);

    // Small delay for better UX
    await Future.delayed(const Duration(milliseconds: 300));

    Get.offAllNamed(AppRoutes.phoneLogin);
  }

  @override
  Widget build(BuildContext context) {
    return BackPressToExit(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Obx(() {
                    return controller.currentIndex.value < 2
                        ? TextButton(
                            onPressed: _markOnboardingComplete,
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : const SizedBox.shrink();
                  }),
                ),
              ),
              // PageView
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: (index) =>
                      controller.currentIndex.value = index,
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) {
                    return OnboardingPage(
                      image: onboardingData[index]['image']!,
                      title: onboardingData[index]['title']!,
                      description: onboardingData[index]['description']!,
                    );
                  },
                ),
              ),
              // Indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Obx(() {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: controller.currentIndex.value == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: controller.currentIndex.value == index
                              ? AppColors.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              // Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Obx(() {
                  final isLastPage = controller.currentIndex.value == 2;
                  return CustomButton(
                    text: isLastPage ? "Get Started" : "Next",
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : () {
                            if (isLastPage) {
                              _markOnboardingComplete();
                            } else {
                              controller.nextPage();
                            }
                          },
                  );
                }),
              ),
              const SizedBox(height: 16),
            ],
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
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          SvgPicture.asset(
            image,
            height: size.height * 0.35,
            fit: BoxFit.contain,
            placeholderBuilder: (context) => SizedBox(
              height: size.height * 0.35,
              child: const Center(
                child: Icon(
                  Icons.water_drop_outlined,
                  size: 100,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.05),
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
