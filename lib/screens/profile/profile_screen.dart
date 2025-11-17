import 'package:difwa_app/screens/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  final ProfileController ctrl = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Obx(() {
                    final local = ctrl.localImageFile.value;
                    final url = ctrl.profileImageUrl.value;
                    Widget avatar;
                    if (local != null) {
                      avatar = CircleAvatar(
                        radius: 56,
                        backgroundImage: FileImage(local),
                      );
                    } else if (url != null && url.isNotEmpty) {
                      avatar = CircleAvatar(
                        radius: 56,
                        backgroundImage: NetworkImage(url),
                      );
                    } else {
                      avatar = CircleAvatar(
                        radius: 56,
                        child: Text(
                          ctrl.nameCtrl.text.isNotEmpty
                              ? ctrl.nameCtrl.text[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(fontSize: 32),
                        ),
                      );
                    }
                    return avatar;
                  }),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: ctrl.chooseImageDialog,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Form
              _buildTextField(label: 'Name', controller: ctrl.nameCtrl),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Email',
                controller: ctrl.emailCtrl,
                keyboard: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Phone',
                controller: ctrl.numberCtrl,
                keyboard: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _buildTextField(label: 'Floor', controller: ctrl.floorCtrl),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Order Pin',
                controller: ctrl.orderPinCtrl,
                keyboard: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                label: 'Wallet Balance',
                controller: ctrl.walletCtrl,
                keyboard: TextInputType.number,
              ),

              const SizedBox(height: 24),

              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: ctrl.isLoading.value
                        ? null
                        : ctrl.uploadAndSaveProfile,
                    child: ctrl.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save Profile',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboard,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}
