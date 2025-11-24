import 'package:difwa_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:difwa_app/features/auth/otp_verification/controller/otp_controller.dart';
import '../../../config/theme/app_color.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Expecting arguments: { phone, verificationId, resendToken }
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final phone = args['phone'] as String? ?? '';
    final verificationId = args['verificationId'] as String?;
    final resendToken = args['resendToken'] as int?;

    // Create controller with phone + initial verification id (if provided)
    final OtpController ctrl = Get.put(OtpController(
      phone: phone,
      initialVerificationId: verificationId,
      initialResendToken: resendToken,
    ));

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
                  'assets/images/otp.svg', // Ensure this asset exists or use a placeholder
                  height: size.height * 0.25,
                  fit: BoxFit.contain,
                  placeholderBuilder: (context) => SizedBox(
                    height: size.height * 0.25,
                    child: const Center(child: Icon(Icons.lock_outline, size: 80, color: Colors.grey)),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.04),
              const Text(
                'OTP Verification',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                  children: [
                    const TextSpan(text: 'Enter the code sent to '),
                    TextSpan(
                      text: phone,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _OtpFields(ctrl: ctrl),
              const SizedBox(height: 24),
              Obx(() {
                if (ctrl.error.value != null) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      ctrl.error.value!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              Obx(() => CustomButton(
                    text: "Verify OTP",
                    isLoading: ctrl.loading.value,
                    onPressed: () => ctrl.submitOtp(),
                  )),
              const SizedBox(height: 24),
              Obx(() {
                if (!ctrl.sent.value) {
                  return const Center(child: Text('Sending code...', style: TextStyle(color: Colors.black54)));
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Didn't receive code? ", style: TextStyle(color: Colors.black54)),
                    ctrl.canResend.value
                        ? TextButton(
                            onPressed: ctrl.resendCode,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Resend',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Text(
                            'Resend in ${ctrl.resendSeconds.value}s',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpFields extends StatefulWidget {
  final OtpController ctrl;
  const _OtpFields({required this.ctrl});

  @override
  State<_OtpFields> createState() => _OtpFieldsState();
}

class _OtpFieldsState extends State<_OtpFields> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (i) => TextEditingController());
    _nodes = List.generate(6, (i) => FocusNode());
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isEmpty) {
      widget.ctrl.updateDigit(index, '');
      if (index > 0) _nodes[index - 1].requestFocus();
      return;
    }
    
    final ch = value.trim();
    if (ch.length > 1) {
      // Paste handling or autofill
      if (ch.length == 6) {
        for (var i = 0; i < 6; i++) {
          _controllers[i].text = ch[i];
          widget.ctrl.updateDigit(i, ch[i]);
        }
        FocusScope.of(context).unfocus();
        return;
      }
    }

    // Single digit entry
    if (ch.isNotEmpty) {
       _controllers[index].text = ch[0]; // Ensure only one char
       widget.ctrl.updateDigit(index, ch[0]);
       if (index < 5) {
         _nodes[index + 1].requestFocus();
       } else {
         FocusScope.of(context).unfocus();
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (i) {
          return SizedBox(
            width: 45,
            height: 56,
            child: TextField(
              controller: _controllers[i],
              focusNode: _nodes[i],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              autofillHints: const [AutofillHints.oneTimeCode],
              // textContentType: TextContentType.oneTimeCode, // Uncomment if targeting iOS specifically and needed
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: (v) => _onChanged(i, v),
            ),
          );
        }),
      ),
    );
  }
}
