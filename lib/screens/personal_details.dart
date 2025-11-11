import 'dart:io';
import 'package:difwa_app/config/theme/app_color.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/controller/auth_controller.dart';
import 'package:difwa_app/models/app_user.dart';
import 'package:difwa_app/screens/edit_personaldetails.dart';
import 'package:difwa_app/widgets/custom_prersonaldetails_input.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PersonalDetails extends StatefulWidget {
  const PersonalDetails({super.key});

  @override
  _PersonalDetailsState createState() => _PersonalDetailsState();
}

class _PersonalDetailsState extends State<PersonalDetails> {
  final AuthController _userData = Get.put(AuthController());

  AppUser? usersData;
  bool isLoading = true;
  String? errorMessage;
  File? _selectedImage;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      AppUser user = await _userData.fetchUserData();
      print(user.toMapForCreate());
      setState(() {
        usersData = user;
        isLoading = false;
        emailController.text = usersData?.email ?? 'guest@gmail.com';
        nameController.text = usersData?.name ?? 'Guest';
        mobileController.text = usersData?.number ?? 'N/A';
        // genderController.text = usersData?.gender?? '';
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching user data: $e";
        isLoading = false;
      });
    }
  }

  String _removeCountryCode(String number) {
    return number.replaceAll(RegExp(r'^\+\d+\s?'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.to(() => EditPersonaldetails(
                              name: nameController.text,
                              email: emailController.text,
                              phone: _removeCountryCode(mobileController.text),
                              profileImage: usersData?.profileImage,
                            ));
                      },
                      child: ClipOval(
                        child: _selectedImage != null
                            ? Image.file(
                                _selectedImage!,
                                width: 130,
                                height: 130,
                                fit: BoxFit.cover,
                              )
                            : (usersData?.profileImage != null &&
                                    usersData!.profileImage!.isNotEmpty)
                                ? Image.network(
                                    usersData!.profileImage!,
                                    width: 130,
                                    height: 130,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildInitialsAvatar(
                                          usersData?.name ?? 'G');
                                    },
                                  )
                                : _buildInitialsAvatar(usersData?.name ?? 'G'),
                      ),
                    ),
                    Positioned(
                      bottom: -15,
                      right: 22,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Get.to(() => EditPersonaldetails(
                                name: nameController.text,
                                email: emailController.text,
                                phone:
                                    _removeCountryCode(mobileController.text),
                                profileImage: usersData?.profileImage,
                              ));
                        },
                        icon: Icon(Icons.camera_alt,
                            color: appTheme.secondyColor),
                        label: Text('Edit',
                            style: TextStyle(color: appTheme.secondyColor)),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Text(
                    usersData?.name ?? 'Guest',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : errorMessage != null
                      ? Center(child: Text(errorMessage!))
                      : usersData == null
                          ? Center(child: Text('No user details found.'))
                          : Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  UserDetailInputField(
                                    label: 'Email',
                                    controller: emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    icon: Icons.email,
                                  ),
                                  UserDetailInputField(
                                    label: 'Phone',
                                    controller: mobileController,
                                    keyboardType: TextInputType.phone,
                                    icon: Icons.phone,
                                  ),
                                  UserDetailInputField(
                                    label: 'Gender',
                                    // controller: mobileController,
                                    keyboardType: TextInputType.text,
                                    icon: Icons.person,
                                  ),
                                  UserDetailInputField(
                                    label: 'Pin Code',
                                    // controller: mobileController,
                                    keyboardType: TextInputType.phone,
                                    icon: Icons.location_on,
                                  ),
                                ],
                              ),
                            ),
            ),
            // Padding(
            //   padding: const EdgeInsets.all(16.0),
            //   child: SizedBox(
            //     child: CustomButton(
            //       icon: Icon(
            //         Icons.logout,
            //         color: Colors.white,
            //       ),
            //       width: double.infinity,
            //       text: 'Logout',
            //       onPressed: () {
            //         LogoutDialog.showLogoutDialog(context);
            //       },
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(String name) {
    String initials = name.isNotEmpty ? name[0].toUpperCase() : "G";

    return CircleAvatar(
      radius: 65, // Adjust size
      backgroundColor: Colors.blueGrey, // Background color
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 50,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
