import 'package:difwa_app/config/theme/app_color.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AvailableServiceSelect extends StatefulWidget {
  const AvailableServiceSelect({super.key});

  @override
  _AvailableServiceSelectState createState() => _AvailableServiceSelectState();
}

class _AvailableServiceSelectState extends State<AvailableServiceSelect> {
  String? selectedCity; // Keep track of the selected city

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mywhite,
      appBar: AppBar(
        title: const Text('Hello, Sudheer '),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment
            .spaceBetween, // Spread content and push button to the bottom
        children: [
          // This part holds the content above the button
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading:
                     Icon(Icons.location_on, color:appTheme.secondyColor),
                    title: const Text('Detect my location'),
                    onTap: () {
                      // Add functionality for location detection
                    },
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Our Services',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  GridView.count(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    shrinkWrap: true,
                    crossAxisCount: 2, // 2 tiles per row
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio:
                        1.2, // Optional: adjusts the aspect ratio of each tile
                    crossAxisSpacing: 16.0, // Spacing between columns
                    mainAxisSpacing: 16.0, // Spacing between rows
                    children: [
                      _CityTile(
                        cityName: 'Mumbai',
                        icon: Icons.location_city,
                        isSelected: selectedCity == 'Mumbai',
                        onTap: () {
                          setState(() {
                            selectedCity = 'Mumbai'; // Set selected city
                          });
                        },
                      ),
                      _CityTile(
                        cityName: 'Delhi-NCR',
                        icon: Icons.apartment,
                        isSelected: selectedCity == 'Delhi-NCR',
                        onTap: () {
                          setState(() {
                            selectedCity = 'Delhi-NCR'; // Set selected city
                          });
                        },
                      ),
                      _CityTile(
                        cityName: 'Bengaluru',
                        icon: Icons.business,
                        isSelected: selectedCity == 'Bengaluru',
                        onTap: () {
                          setState(() {
                            selectedCity = 'Bengaluru'; // Set selected city
                          });
                        },
                      ),
                      _CityTile(
                        cityName: 'Hyderabad',
                        icon: Icons.castle,
                        isSelected: selectedCity == 'Hyderabad',
                        onTap: () {
                          setState(() {
                            selectedCity = 'Hyderabad'; // Set selected city
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Get.toNamed(AppRoutes.userDashbord);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, // Button color
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child:  Text(
                'Go to Home',
                style: TextStyle(color: appTheme.whiteColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CityTile extends StatelessWidget {
  final String cityName;
  final IconData icon;
  final bool isSelected; // Whether this tile is selected
  final VoidCallback onTap; // Callback when the tile is tapped

  const _CityTile({
    required this.cityName,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Trigger the onTap callback when the tile is tapped
      child: Padding(
        padding:
            const EdgeInsets.all(8.0), // Add padding around the entire widget
        child: Container(
          padding: const EdgeInsets.all(12.0), // Padding inside the container
          decoration: BoxDecoration(
            color: Colors.white, // Background color
            borderRadius: BorderRadius.circular(4.0), // Rounded corners
            border: Border.all(
              color: isSelected
                  ? AppColors.primary // Change border color when selected
                  : const Color.fromARGB(
                      255, 212, 212, 212), // Default border color
              width: 2.0, // Border width
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 40, // Increased icon size
                color: AppColors.primary,
              ),
              const SizedBox(
                  height: 8), // Increased space between icon and text
              Text(
                cityName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16, // Increased text size
                  fontWeight: FontWeight.w600, // Make the text a little bolder
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
