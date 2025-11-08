import 'dart:io';
import 'package:difwa_app/config/app_color.dart';
import 'package:difwa_app/controller/auth_controller.dart';
import 'package:difwa_app/models/user_models/user_details_model.dart';
import 'package:difwa_app/screens/personal_details.dart';
import 'package:difwa_app/utils/app__text_style.dart';
import 'package:difwa_app/utils/theme_constant.dart';
import 'package:difwa_app/widgets/custom_input_field.dart';
import 'package:difwa_app/widgets/subscribe_button_component.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditPersonaldetails extends StatefulWidget {
  final String? name;
  final String? email;
  final String? phone;
  final String? profileImage;

  const EditPersonaldetails({
    super.key,
    this.name,
    this.email,
    this.phone,
    this.profileImage,
  });

  @override
  State<EditPersonaldetails> createState() => _EditPersonaldetailsState();
}

class _EditPersonaldetailsState extends State<EditPersonaldetails> {
  File? _selectedImage;
  String selectedCountryCode = "+91 ";
  final AuthController auth = Get.put(AuthController());

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  UserDetailsModel? usersData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    try {
      UserDetailsModel user = await auth.fetchUserData();
      setState(() {
        _isLoading = false;
        usersData = user;

        nameController.text =
            usersData!.name.isNotEmpty
                ? usersData!.name.toString()
                : 'Guest';
        emailController.text =
            usersData!.email.isNotEmpty
                ? usersData!.email.toString()
                : 'guest@gmail.com';
        mobileController.text =
            usersData!.number.isNotEmpty
                ? usersData!.number.toString()
                : '9999999999';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          title: const Text("Choose Profile Image"),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label:
                    const Text("Camera", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.logosecondry),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
                icon: const Icon(Icons.photo, color: Colors.white),
                label: const Text("Gallery",
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.logoprimary),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Edit Profile ",
          style: AppTextStyle.Text18700,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap: () => _showImageSourceDialog(context),
                      child: ClipOval(
                        child: _selectedImage != null
                            ? Image.file(
                                _selectedImage!,
                                width: 130,
                                height: 130,
                                fit: BoxFit.cover,
                              )
                            : usersData != null &&
                                    usersData!.profileImage != null &&
                                    usersData!.profileImage!.isNotEmpty
                                ? Image.network(
                                    usersData!.profileImage!,
                                    width: 130,
                                    height: 130,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildInitialsAvatar(
                                          widget.name ?? '');
                                    },
                                  )
                                : _buildInitialsAvatar(
                                    usersData != null &&
                                            usersData!.name.isNotEmpty
                                        ? usersData!.name[0].toUpperCase()
                                        : 'G',
                                  ),
                      ),
                    ),
                    Positioned(
                      bottom: -10,
                      right: 10,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () => _showImageSourceDialog(context),
                        icon: Icon(Icons.camera_alt,
                            color: AppColors.logosecondry),
                        label: Text('Change',
                            style: TextStyle(color: AppColors.logosecondry)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 38.0),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  CommonTextField(
                    label: 'Name',
                    controller: nameController,
                    icon: Icons.person,
                    inputType: InputType.email,
                  ),
                  const SizedBox(height: 30),
                  CommonTextField(
                    label: 'Email',
                    controller: emailController,
                    icon: Icons.email,
                    inputType: InputType.email,
                    readOnly: true,
                  ),
                  const SizedBox(height: 30),
                  CommonTextField(
                    label: 'Phone',
                    showCountryPicker: true,
                    controller: mobileController,
                    icon: Icons.phone,
                    inputType: InputType.phone,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
            child: SubscribeButtonComponent(
              text: "Save Changes",
              onPressed: () async {
                try {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await auth.updateUserDetails(
                      user.uid,
                      emailController.text,
                      nameController.text,
                      selectedCountryCode + mobileController.text,
                      "some_floor_value",
                    );

                    Get.snackbar(
                      "Success",
                      "Details updated successfully",
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );

                    await Future.delayed(Duration(seconds: 2));
                    Get.off(() => PersonalDetails());
                  } else {
                    Get.snackbar(
                      "Error",
                      "User not logged in",
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                } catch (e) {
                  Get.snackbar(
                    "Error",
                    "Failed to update details: $e",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(String name) {
    String initials = name.isNotEmpty ? name[0].toUpperCase() : "G";

    return CircleAvatar(
      radius: 65,
      backgroundColor: ThemeConstants.primaryColor,
      child: Text(
        initials,
        style: AppTextStyle.TextWhite24700,
      ),
    );
  }
}
