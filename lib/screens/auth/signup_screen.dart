import 'dart:ui';
import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/controller/auth_controller.dart';
import 'package:difwa_app/routes/user_bottom_bar.dart';
import 'package:difwa_app/screens/auth/login_screen.dart';
import 'package:difwa_app/utils/validators.dart';
import 'package:difwa_app/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../widgets/custom_button.dart';

class MobileNumberPage extends StatefulWidget {
  const MobileNumberPage({super.key});

  @override
  _MobileNumberPageState createState() => _MobileNumberPageState();
}

class _MobileNumberPageState extends State<MobileNumberPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggeredController;
  late List<Interval> _itemSlideIntervals;
  late Interval _buttonInterval;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController authController = Get.put(AuthController());
  bool isLoading = false;

  final GlobalKey<FormState> _formKeyPhone = GlobalKey<FormState>();
  String selectedCountryCode = "+91"; // Default country code

  final _formKeyName = GlobalKey<FormState>();
  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyPassword = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _staggeredController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _createAnimationIntervals();
    _staggeredController.forward();
  }

  void _createAnimationIntervals() {
    _itemSlideIntervals = [];
    for (int i = 0; i < 4; i++) {
      _itemSlideIntervals
          .add(Interval(i * 0.2, (i + 1) * 0.2, curve: Curves.easeIn));
    }

    _buttonInterval = Interval(0.8, 1.0, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _staggeredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/logos/difwalogo1.svg',
                      height: 100,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Create Your Account ",
                      style:  TextStyleHelper.instance.body14BoldPoppins.copyWith(
                        fontSize: isSmallScreen ? 24 : 30,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Order water with ease or register as a \nvendor to sell. Sign up now!",
                      style:  TextStyleHelper.instance.body14BoldPoppins,
                      textAlign: TextAlign.center, // Ensure it's center-aligned
                    ),
                    const SizedBox(height: 30),
                    AnimatedBuilder(
                      animation: _staggeredController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _itemSlideIntervals[0]
                              .transform(_staggeredController.value),
                          child: child,
                        );
                      },
                      child: Form(
                        key: _formKeyPhone,
                        child: Row(
                          children: [
                            Expanded(
                              child: CommonTextField(
                                controller: phoneController,
                                inputType: InputType.phone,
                                label: 'Phone Number',
                                hint: 'Enter Phone Number',
                                showCountryPicker: true,
                                // prefixText: '+91',
                                icon: Icons.phone,
                                onChanged: (String) {
                                  _formKeyPhone.currentState!.validate();
                                },
                                validator: Validators.validatePhone,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: _staggeredController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _itemSlideIntervals[1]
                              .transform(_staggeredController.value),
                          child: child,
                        );
                      },
                      child: Form(
                        key: _formKeyName,
                        child: CommonTextField(
                          controller: nameController,
                          inputType: InputType.name,
                          onChanged: (String) {
                            _formKeyName.currentState!.validate();
                          },
                          label: 'Full Name',
                          hint: 'Enter Name',
                          icon: Icons.person,
                          validator: Validators.validateName,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: _staggeredController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _itemSlideIntervals[2]
                              .transform(_staggeredController.value),
                          child: child,
                        );
                      },
                      child: Form(
                        key: _formKeyEmail,
                        child: CommonTextField(
                          controller: emailController,
                          inputType: InputType.email,
                          label: 'Email Address',
                          hint: 'Enter Email',
                          icon: Icons.email,
                          onChanged: (String) {
                            _formKeyEmail.currentState!.validate();
                          },
                          validator: Validators.validateEmail,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: _staggeredController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _itemSlideIntervals[3]
                              .transform(_staggeredController.value),
                          child: child,
                        );
                      },
                      child: Form(
                        key: _formKeyPassword,
                        child: CommonTextField(
                          controller: passwordController,
                          inputType: InputType.visiblePassword,
                          onChanged: (String) {
                            _formKeyPassword.currentState!.validate();
                          },
                          label: 'Create Password',
                          hint: 'Enter Password',
                          icon: Icons.lock,
                          suffixIcon: Icons.visibility_off,
                          validator: Validators.validatePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    AnimatedBuilder(
                      animation: _staggeredController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _buttonInterval
                              .transform(_staggeredController.value),
                          child: child,
                        );
                      },
                      child: CustomButton(
                        onPressed: () async {
                          if (_formKeyName.currentState!.validate() &&
                              _formKeyEmail.currentState!.validate() &&
                              _formKeyPassword.currentState!.validate()) {
                            setState(() {
                              isLoading = true; // Start loading
                            });

                            try {
                              bool success = await authController.signwithemail(
                                  emailController.text,
                                  nameController.text,
                                  passwordController.text,
                                  selectedCountryCode + phoneController.text,
                                  isLoading,
                                  context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const BottomUserHomePage()));
                              if (!success) {
                                // Handle failure (if needed)
                                Get.snackbar(
                                    "Signup Failed", "Please try again.");
                                isLoading = false;
                              }
                            } catch (e) {
                              print("Errorr: $e");
                              isLoading = false;
                            } finally {
                              setState(() {
                                isLoading =
                                    false; // Stop loading after completion
                              });
                            }
                          }
                        },
                        height: 54,
                        width: double.infinity,
                        text: isLoading ? 'Loading...' : 'Sign Up',
                        baseTextColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyleHelper.instance.body14BoldPoppins,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const LoginScreenPage()));
                          },
                          child:  Text('SignIn',
                              style:  TextStyleHelper.instance.body14BoldPoppins),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: BackdropFilter(
                filter:
                    ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Blur effect
                child: Container(
                  // ignore: deprecated_member_use
                  color:
                      Colors.black.withOpacity(0.5), // Semi-transparent overlay
                  child: Center(
                    child: Lottie.asset(
                      'assets/lottie/loader.json', // Path to your Lottie file
                      width: 200, // Set width of the animation
                      height: 200, // Set height of the animation
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
