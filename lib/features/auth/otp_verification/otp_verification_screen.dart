import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:difwa_app/features/auth/otp_verification/controller/otp_controller.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text('OTP Verification'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            children: [
              SizedBox(height: 8),
              Text(
                'Verify your phone number',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text(
                'Enter the 6-digit code sent to $phone',
                style: TextStyle(fontSize: 14, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              _OtpFields(ctrl: ctrl),
              SizedBox(height: 14),
              Obx(() {
                if (ctrl.error.value != null) {
                  return Text(ctrl.error.value!, style: TextStyle(color: Colors.red));
                }
                return SizedBox.shrink();
              }),
              SizedBox(height: 14),
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: ctrl.loading.value ? null : ctrl.submitOtp,
                    child: ctrl.loading.value
                        ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('VERIFY OTP'),
                  ),
                );
              }),
              SizedBox(height: 16),
              Obx(() {
                if (!ctrl.sent.value) {
                  return Text('Sending code...');
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Didn\'t receive? ', style: TextStyle(color: Colors.black54)),
                    ctrl.canResend.value
                        ? TextButton(
                            onPressed: ctrl.resendCode,
                            child: Text('Resend'),
                          )
                        : Text('Resend in ${ctrl.resendSeconds.value}s', style: TextStyle(color: Colors.black54)),
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
  const _OtpFields({super.key, required this.ctrl});

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
      // Paste handling: fill all boxes if string length==6
      if (ch.length == 6) {
        for (var i = 0; i < 6; i++) {
          _controllers[i].text = ch[i];
          widget.ctrl.updateDigit(i, ch[i]);
        }
        FocusScope.of(context).unfocus();
        return;
      } else {
        // take only first char
        _controllers[index].text = ch[0];
        widget.ctrl.updateDigit(index, ch[0]);
      }
    } else {
      _controllers[index].text = ch;
      widget.ctrl.updateDigit(index, ch);
      if (index < 5) {
        _nodes[index + 1].requestFocus();
      } else {
        FocusScope.of(context).unfocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        return SizedBox(
          width: 46,
          height: 56,
          child: TextField(
            controller: _controllers[i],
            focusNode: _nodes[i],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            decoration: InputDecoration(counterText: '', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            onChanged: (v) => _onChanged(i, v),
          ),
        );
      }),
    );
  }
}
