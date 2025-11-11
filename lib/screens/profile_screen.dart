import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/controller/auth_controller.dart';
import 'package:difwa_app/models/app_user.dart';
import 'package:difwa_app/screens/stores_screens/store_onboarding_screen.dart';
import 'package:difwa_app/screens/auth/saved_address.dart';
import 'package:difwa_app/screens/edit_personaldetails.dart';
import 'package:difwa_app/widgets/logout_popup.dart';
import 'package:difwa_app/widgets/simmers/ProfileShimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController _userData = Get.put(AuthController());
 AppUser? usersData;
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
     AppUser user = await _userData.fetchUserData();

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
                      child: Text("My Profile", style: TextStyleHelper.instance.black14Bold),
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
                                          style:TextStyleHelper.instance.black14Bold,
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
                                            style: TextStyleHelper.instance.black14Bold),
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
                    /// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

                    /// Profile Options List
                    Column(
                      children: [
                        buildProfileOption(
                          title: "Profile",
                          subtitle: "Edit profile details",
                          icon: FontAwesomeIcons.user,
                          onTap: () {
                            Get.to(() => EditPersonaldetails());
                          },
                        ),
                        buildProfileOption(
                          title: "Phone Number",
                          subtitle: usersData?.number ?? "Not available",
                          icon: FontAwesomeIcons.phone,
                          onTap: () {},
                        ),
                        buildProfileOption(
                          title: "Email Address",
                          subtitle: usersData?.email ?? "Not available",
                          icon: FontAwesomeIcons.envelope,
                          onTap: () {},
                        ),
                        buildProfileOption(
                          title: "Delivery Address",
                          subtitle: "Manage multiple addresses",
                          icon: FontAwesomeIcons.locationDot,
                          onTap: () {
                            Get.to(() => SavveAddressPage());
                          },
                        ),
                        buildProfileOption(
                          title: "Become A Seller",
                          subtitle: "Start selling your products today!",
                          icon: FontAwesomeIcons.store,
                          onTap: () {
                            Get.to(() => const StoreOnboardingScreen());
                          },
                        ),
                        buildProfileOption(
                          title: "Logout",
                          subtitle: "Sign out of your account",
                          icon: FontAwesomeIcons.arrowRightFromBracket,
                          onTap: () {
                            if (!context.mounted) return;

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext dialogContext) {
                                return YesNoPopup(
                                  title: "Logout from app!",
                                  description:
                                      "Are you sure you want to exit from the application?",
                                  noButtonText: "No",
                                  yesButtonText: "Yes",
                                  onNoButtonPressed: () {
                                    Navigator.pop(dialogContext);
                                  },
                                  onYesButtonPressed: () async {
                                    await FirebaseAuth.instance.signOut();
                                    if (!context.mounted) return;
                                    Navigator.pop(dialogContext);
                                    Navigator.pushReplacementNamed(
                                        context, '/login');
                                  },
                                );
                              },
                            );
                          },
                        ),
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.black87,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
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
