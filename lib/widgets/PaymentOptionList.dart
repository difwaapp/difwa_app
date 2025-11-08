import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PaymentOptionList extends StatelessWidget {
  final List<Map<String, dynamic>> paymentOptions;
  final Function(String method)? onMethodTap;

  const PaymentOptionList({
    super.key,
    required this.paymentOptions,
    this.onMethodTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: paymentOptions.map((option) {
          return Column(
            children: [
              _buildPaymentOptionTile(option, context),
              if (paymentOptions.last != option)
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentOptionTile(
      Map<String, dynamic> option, BuildContext context) {
    return InkWell(
      onTap: () {
        if (onMethodTap != null && option['methods'].isNotEmpty) {
          onMethodTap!(option['methods'][0]); // or custom handling
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/${option['icon']}',
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option['title'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Row(
              children: List.generate(
                (option['methods'] as List).length.clamp(0, 3),
                (index) => Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: Container(
                      height: 21,
                      width: 32,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Image.asset(
                        'assets/icons/${option['methods'][index]}',
                        fit: BoxFit.contain,
                        width: 24,
                        height: 24,
                      )),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.keyboard_arrow_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
