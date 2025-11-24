import 'package:country_code_picker/country_code_picker.dart';
import 'package:difwa_app/features/auth/phone_login/controller/phone_login_controller.dart';
import 'package:difwa_app/widgets/custom_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../config/theme/app_color.dart';
import 'package:url_launcher/url_launcher.dart';
class PhoneLoginScreen extends StatelessWidget {
  PhoneLoginScreen({super.key});

  final PhoneLoginController ctrl = Get.put(PhoneLoginController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              SizedBox(height: size.height * 0.02),
              Center(
                child: SvgPicture.asset(
                  'assets/images/login.svg',
                  height: size.height * 0.25,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: size.height * 0.04),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your phone number to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    CountryCodePicker(
                      onChanged: (country) {
                        // Update country code in controller if needed
                        // ctrl.countryCode.value = country.dialCode!;
                      },
                      initialSelection: 'IN',
                      favorite: const ['+91', 'IN'],
                      showCountryOnly: false,
                      showOnlyCountryWhenClosed: false,
                      alignLeft: false,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      height: 24,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: TextField(
                        controller: ctrl.phoneCtrl,
                        keyboardType: TextInputType.phone,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Phone Number',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => Row(
                    children: [
                      Checkbox(
                        value: ctrl.acceptTerms.value,
                        onChanged: (val) => ctrl.acceptTerms.value = val ?? false,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                            children: [

                              const TextSpan(text: 'I accept the '),
                              TextSpan(
                                text: 'Terms and Conditions',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    const url = 'https://www.difwa.com/terms-of-service';
                                    if (await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(Uri.parse(url));
                                    }
                                  },
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    const url = 'https://www.difwa.com/privacy-policy';
                                    if (await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(Uri.parse(url));
                                    }
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
              const SizedBox(height: 16),
              Obx(() => CustomButton(
                    text:ctrl.loading.value?"Sending...": "Send OTP",
                    isLoading: ctrl.loading.value,
                    onPressed: (ctrl.loading.value || !ctrl.acceptTerms.value)
                        ? null
                        : () => ctrl.sendOtp(),
                        
                  )
                  ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 24),
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: ctrl.googleLoading.value
                          ? null
                          : () => ctrl.signInWithGoogle(),
                      icon: ctrl.googleLoading.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Image.asset(
                              'assets/icon/google_icon.png',
                              height: 24,
                            ),
                      label: Text(
                        ctrl.googleLoading.value
                            ? 'Signing in...'
                            : 'Continue with Google',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: ctrl.googleLoading.value
                              ? Colors.grey.shade300
                              : Colors.grey.shade400,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
