import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact Information"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // First Section - Container with fixed height and width
            SizedBox(
              width: double.infinity, // Makes the container take the full width
              height: 180, // Set the fixed height of the container
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: appTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Call our Customer Care Executive",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: appTheme.blackColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "We are available from 9 AM to 9 PM. Please call us at the number below for any queries or assistance.",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Monday to Saturday",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomButton(
                      text: "1234567890",
                      onPressed: () {
                        // Handle button press here
                        print("Call button pressed");
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Second Section - Container with fixed height and width
            SizedBox(
              width: double.infinity, // Makes the container take the full width
              height: 150, // Set the fixed height of the container
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: appTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Write to us",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:appTheme.blackColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "We usually get back to you in 1-2 business days. If you have an urgent query, please call us.",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 20),
                    CustomButton(
                      text: "E-Mail Us",
                      onPressed: () {
                        // Handle button press here
                        print("Mail button pressed");
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
