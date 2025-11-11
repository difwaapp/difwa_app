import 'package:difwa_app/config/theme/app_color.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(phoneUri);
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support Needed&body=Describe your issue here...',
    );
    await launchUrl(emailUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondyColor,
        title: const Text(
          "Contact Support",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white, // ✅ This makes the back arrow white
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "Need Help?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.secondyColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Our support team is available 24/7 to assist you.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            ListTile(
              leading: Icon(Icons.phone, color: AppColors.secondyColor),
              title: const Text("Call Us"),
              subtitle: const Text("+919519202509"),
              onTap: () {
                _makePhoneCall("+919519202509");
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.email, color: AppColors.secondyColor),
              title: const Text("Email Us"),
              subtitle: const Text("difwa.app@gmail.com"),
              onTap: () {
                _sendEmail("difwa.app@gmail.com");
              },
            ),
            const Divider(),
            const Spacer(),
            Center(
              child: Text(
                "We are always here to help you!",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
