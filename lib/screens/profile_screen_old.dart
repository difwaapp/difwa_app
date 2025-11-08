import 'package:difwa_app/config/app_styles.dart';
import 'package:difwa_app/controller/auth_controller.dart';
import 'package:difwa_app/models/user_models/user_details_model.dart';
import 'package:difwa_app/screens/stores_screens/store_onboarding_screen.dart';
import 'package:difwa_app/screens/auth/saved_address.dart';
import 'package:difwa_app/screens/customer_support_pages/FAQ_page.dart';
import 'package:difwa_app/screens/customer_support_pages/contact_info_page.dart';
import 'package:difwa_app/screens/customer_support_pages/locate_us_page.dart';
import 'package:difwa_app/screens/edit_personaldetails.dart';
import 'package:difwa_app/screens/ordershistory_screen.dart';
import 'package:difwa_app/screens/user_wallet_page.dart';
import 'package:difwa_app/utils/app__text_style.dart';
import 'package:difwa_app/utils/theme_constant.dart';
import 'package:difwa_app/widgets/logout_popup.dart';
import 'package:difwa_app/widgets/simmers/ProfileShimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController _userData = Get.put(AuthController());
  UserDetailsModel? usersData;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Function to launch the URL
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _fetchUserData() async {
    try {
      UserDetailsModel user = await _userData.fetchUserData();

      setState(() {
        print("number");
        _isLoading = false;
        usersData = user;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ProfileShimmer();
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        body: usersData == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),

                    /// Profile Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text("My Profile", style: AppStyle.headingBlack),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.blue.shade700,
                                backgroundImage:
                                    usersData!.profileImage != null &&
                                            usersData!.profileImage!.isNotEmpty
                                        ? NetworkImage(usersData!.profileImage!)
                                        : null,
                                child: (usersData!.profileImage == null ||
                                        usersData!.profileImage!.isEmpty)
                                    ? Text(
                                        usersData!.name.isNotEmpty
                                            ? usersData!.name[0].toUpperCase()
                                            : 'G',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(
                                height: 10,
                                width: 12,
                              ),
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          usersData?.name ?? 'Guest',
                                          textAlign: TextAlign.left,
                                          style: AppStyle.headingBlack,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            usersData?.email ??
                                                'guest@gmail.com',
                                            textAlign: TextAlign.left,
                                            style: AppTextStyle.Text14300),
                                      ],
                                    ),
                                    // Row(
                                    //   mainAxisAlignment:
                                    //       MainAxisAlignment.center,
                                    //   children: [
                                    //     GestureDetector(
                                    //       onTap: () {
                                    //         Get.to(() =>
                                    //             EditPersonaldetails());
                                    //       },
                                    //       child: Container(
                                    //         margin: const EdgeInsets.only(
                                    //             top: 8),
                                    //         padding:
                                    //             const EdgeInsets.symmetric(
                                    //                 horizontal: 16,
                                    //                 vertical: 4),
                                    //         decoration: BoxDecoration(
                                    //           borderRadius:
                                    //               BorderRadius.circular(8),
                                    //           color: ThemeConstants
                                    //               .primaryColor
                                    //               .withOpacity(0.1),
                                    //         ),
                                    //         child: Text(
                                    //           "Edit Profile",
                                    //           style: AppTextStyle.Text12700,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Profile Options List
                    Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6), // Spacing between options
                          decoration: BoxDecoration(
                            color:
                                Colors.grey[200], // Background color grey[200]
                            borderRadius:
                                BorderRadius.circular(15.0), // Rounded corners
                          ),
                          child: buildProfileOption(
                            title: "Profile",
                            subtitle: "Edit profile details",
                            icon: Icons.person,
                            onTap: () {
                              Get.to(() => EditPersonaldetails());
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6), // Spacing between options
                          decoration: BoxDecoration(
                            color:
                                Colors.grey[200], // Background color grey[200]
                            borderRadius:
                                BorderRadius.circular(15.0), // Rounded corners
                          ),
                          child: buildProfileOption(
                            title: "Wallet",
                            subtitle: "Wallet balance",
                            balence:
                                '₹${usersData?.walletBalance.toString() ?? '0.00'}',
                            icon: Icons.account_balance_wallet_rounded,
                            onTap: () {
                              Get.to(() => WalletScreen(
                                    onProfilePressed: () {
                                      // Define the behavior for onProfilePressed
                                      print("Profile pressed");
                                    },
                                    onMenuPressed: () {
                                      // Define the behavior for onMenuPressed
                                      print("Menu pressed");
                                    },
                                  ));
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius:
                                BorderRadius.circular(15.0), // Rounded corners
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Align text to the left
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  left: 15,
                                  bottom: 8,
                                ), // Padding around the text
                                child: Text(
                                  "Orders", // Title text at the top
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors
                                        .black, // You can change this color as needed
                                  ),
                                ),
                              ),
                              buildProfileOption(
                                title: "Delivery Address",
                                subtitle: "Manage multiple addresses",
                                icon: Icons.location_on,
                                onTap: () {
                                  Get.to(() => SavveAddressPage());
                                },
                              ),
                              buildProfileOption(
                                title: "Become A Seller",
                                subtitle: "Start selling your products today!",
                                icon: Icons.store,
                                onTap: () {
                                  Get.to(() => const StoreOnboardingScreen());
                                },
                              ),
                              buildProfileOption(
                                title: "Subscription Details",
                                subtitle: "View/modify water plans",
                                icon: Icons.subscriptions,
                                onTap: () {},
                              ),
                              buildProfileOption(
                                title: "Order History",
                                subtitle: "Check past & ongoing orders",
                                icon: Icons.history,
                                onTap: () {
                                  Get.to(() => const HistoryScreen());
                                },
                              ),
                              buildProfileOption(
                                title: "Payment Methods",
                                subtitle: "Manage payments",
                                icon: Icons.payment,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius:
                                BorderRadius.circular(15.0), // Rounded corners
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Align text to the left
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  left: 15,
                                  bottom: 8,
                                ), // Padding around the text
                                child: Text(
                                  "Customer Support", // Title text at the top
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors
                                        .black, // You can change this color as needed
                                  ),
                                ),
                              ),
                              buildProfileOption(
                                title: "Contact Information",
                                subtitle: "Contact us for any queries",
                                icon: Icons.contact_phone_outlined,
                                onTap: () {
                                  Get.to(() => ContactPage());
                                },
                              ),
                              // buildProfileOption(
                              //   title: "My Requests",
                              //   subtitle:
                              //       "All the requests of the customer",
                              //   icon: Icons.request_page,
                              //   onTap: () {
                              //     Get.to(
                              //         () => const StoreOnboardingScreen());
                              //   },
                              // ),
                              buildProfileOption(
                                title: "FAQ",
                                subtitle: "FAQ",
                                icon: Icons.question_answer_outlined,
                                onTap: () {
                                  Get.to(() => FAQPage());
                                },
                              ),
                              buildProfileOption(
                                title: "Locate Us",
                                subtitle: "location ",
                                icon: Icons.location_on_outlined,
                                onTap: () {
                                  Get.to(() => const LocateUsPage());
                                },
                              ),
                              buildProfileOption(
                                  title: "Rate Us",
                                  subtitle: "Rate us on playstore",
                                  icon: Icons.star,
                                  onTap: () {
                                    // Launch Play Store URL
                                    const String playStoreURL =
                                        'https://play.google.com/store/apps/details?id=com.difmo.difwa';
                                    _launchURL(playStoreURL);
                                  }),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6), // Spacing between options
                          decoration: BoxDecoration(
                            color:
                                Colors.grey[200], // Background color grey[200]
                            borderRadius:
                                BorderRadius.circular(15.0), // Rounded corners
                          ),
                          child: buildProfileOption(
                            title: "Logout",
                            subtitle: "Sign out of your account",
                            icon: Icons.logout,
                            onTap: () {
                              if (!context.mounted) {
                                return; // Ensure the context is valid
                              }

                              showDialog(
                                context: context,
                                barrierDismissible:
                                    false, // Prevent accidental dismiss
                                builder: (BuildContext dialogContext) {
                                  return YesNoPopup(
                                    title: "Logout from app!",
                                    description:
                                        "Are you sure you want to exit from the application?",
                                    noButtonText: "No",
                                    yesButtonText: "Yes",
                                    onNoButtonPressed: () {
                                      Navigator.pop(
                                          dialogContext); // Close the dialog
                                    },
                                    onYesButtonPressed: () async {
                                      await FirebaseAuth.instance.signOut();
                                      if (!context.mounted) return;
                                      Navigator.pop(
                                          dialogContext); // Close the dialog before navigating
                                      Navigator.pushReplacementNamed(
                                          context, '/login');
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
      );
    }
  }

  Widget buildProfileOption({
    required String title,
    required String subtitle,
    required IconData icon,
    String? balence,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap, // Handle the onTap action
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(8),
        // decoration: BoxDecoration(
        //   // color: Colors.white,
        //   borderRadius: BorderRadius.circular(16),
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.black.withOpacity(0.05),
        //       blurRadius: 8,
        //       offset: const Offset(0, 4),
        //     ),
        //   ],
        // ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const Spacer(),
            if (balence != null)
              Text(
                balence,
                style: const TextStyle(
                  fontSize: 14,
                  color: ThemeConstants.primaryColorNew,
                ),
              ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
