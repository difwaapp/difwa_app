import 'package:difwa_app/screens/phone_login_screen/controller/phone_login_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme/app_color.dart'; // adjust if different

class PhoneLoginScreen extends StatelessWidget {
  PhoneLoginScreen({super.key});

  final PhoneLoginController ctrl = Get.put(PhoneLoginController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sidePadding = 20.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // single scroll ensures small screens won't overflow
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sidePadding,
              vertical: 18,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // back arrow aligned left
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    splashRadius: 20,
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                // Logo (replace with your asset)
                SizedBox(
                  height: 84,
                  child: Image.asset(
                    'assets/icon/icon_transparent.png',
                    fit: BoxFit.contain,
                  ),
                ),

                SizedBox(height: 24),

                // Heading
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ENTER PHONE NUMBER',
                    style: TextStyle(
                      color: AppColors.primary, // brand blue
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),

                SizedBox(height: 8),

                // Description
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Please enter your mobile number to send OTP to your phone.',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ),

                SizedBox(height: 16),

                // Phone input
                _buildPhoneField(),

                SizedBox(height: 12),

                // Terms & conditions checkbox row
                Obx(() {
                  return GestureDetector(
                    onTap: () =>
                        ctrl.acceptTerms.value = !ctrl.acceptTerms.value,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: ctrl.acceptTerms.value,
                          onChanged: (v) => ctrl.acceptTerms.value = v ?? false,
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(text: 'I accept all '),
                                TextSpan(
                                  text: 'terms and conditions',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // TODO navigate to terms page
                                      // Get.toNamed(AppRoutes.termsAndConditions);
                                    },
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'privacy policy.',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      // TODO navigate to privacy page
                                      // Get.toNamed(AppRoutes.privacyPolicy);
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                SizedBox(height: 8),

                // SEND OTP button
                Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: ctrl.loading.value ? null : ctrl.sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: ctrl.loading.value
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            )
                          : Text(
                              'SEND OTP',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                }),

                SizedBox(height: 18),

                // OR divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey.shade300, thickness: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey.shade300, thickness: 1),
                    ),
                  ],
                ),

                SizedBox(height: 18),

                // Continue with Google
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      //  ctrl.loading.value
                      //                         ? null
                      //                         : ctrl.signInWithGoogle,
                    },
                    icon: Image.asset(
                      'assets/icon/google_icon.png',
                      height: 22,
                    ),
                    label: Text(
                      'CONTINUE WITH GOOGLE',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.primary.withOpacity(0.14),
                      ),
                      backgroundColor: AppColors.primary.withOpacity(0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                SizedBox(height: 14),

                // Sign in with email link
                GestureDetector(
                  onTap: () {
                    //  Get.toNamed(AppRoutes.emailLogin)
                  },
                  child: Text(
                    'prefer email? Sign in with email',
                    style: TextStyle(
                      color: Colors.black54,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // small bottom bar indicator like in Figma
                Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextField(
      controller: ctrl.phoneCtrl,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        hintText: '+911234567890',
        labelText: 'Phone Number',
        labelStyle: TextStyle(fontSize: 13, color: Colors.black87),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
      ),
    );
  }
}
