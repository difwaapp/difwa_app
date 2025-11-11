import 'dart:io';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/models/stores_models/store_new_modal.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditVendorDetailsScreen extends StatefulWidget {
  const EditVendorDetailsScreen({super.key});

  @override
  _EditVendorDetailsScreenState createState() =>
      _EditVendorDetailsScreenState();
}

class _EditVendorDetailsScreenState extends State<EditVendorDetailsScreen> {
  final VendorsController vendorsController = Get.find<VendorsController>();
  final emailController = TextEditingController();
  final TextEditingController vendorNameController = TextEditingController();
  final TextEditingController bussinessNameController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController businessAddressController =
      TextEditingController();
  final TextEditingController areaCityController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController waterTypeController = TextEditingController();
  final TextEditingController capacityOptionsController =
      TextEditingController();
  final TextEditingController dailySupplyController = TextEditingController();
  final TextEditingController deliveryAreaController = TextEditingController();
  final TextEditingController deliveryTimingsController =
      TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController upiIdController = TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  final TextEditingController gstNumberController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  bool isDataFetched = false;
  bool isLoading = true;
  int currentStep = 0;
  Map<String, String> images = {};
  final ImagePicker _picker = ImagePicker();
  VendorModal? vendor; // Store fetched vendor data

  // Custom color scheme
  static const Color primaryRed =Colors.black;
  static const  accentRed = Colors.black;
  static const Color backgroundLight = Color(0xFFFFF5F5);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color borderLight = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    fetchVendorData();
  }

  // Fetch vendor data
  Future<void> fetchVendorData() async {
    if (isDataFetched || !mounted) return;

    try {
      setState(() => isLoading = true);
      vendor = await vendorsController.fetchStoreData();
      print('Fetched vendor: $vendor');
      if (vendor != null && mounted) {
        setState(() {
          vendorNameController.text = vendor!.vendorName ?? '';
          bussinessNameController.text = vendor!.bussinessName ?? '';
          emailController.text = vendor!.email ?? '';
          phoneNumberController.text = vendor!.phoneNumber ?? '';
          contactPersonController.text = vendor!.contactPerson ?? '';
          businessAddressController.text = vendor!.businessAddress ?? '';
          areaCityController.text = vendor!.areaCity ?? '';
          postalCodeController.text = vendor!.postalCode ?? '';
          stateController.text = vendor!.state ?? '';
          waterTypeController.text = vendor!.waterType ?? '';
          capacityOptionsController.text = vendor!.capacityOptions ?? '';
          dailySupplyController.text = vendor!.dailySupply ?? '';
          deliveryAreaController.text = vendor!.deliveryArea ?? '';
          deliveryTimingsController.text = vendor!.deliveryTimings ?? '';
          bankNameController.text = vendor!.bankName ?? '';
          accountNumberController.text = vendor!.accountNumber ?? '';
          upiIdController.text = vendor!.upiId ?? '';
          ifscCodeController.text = vendor!.ifscCode ?? '';
          gstNumberController.text = vendor!.gstNumber ?? '';
          remarksController.text = vendor!.remarks ?? '';
          images = Map<String, String>.from(vendor!.images);

          isDataFetched = true;
          isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() => isLoading = false);
          Get.snackbar('Error', 'No vendor data found',
              snackPosition: SnackPosition.BOTTOM, backgroundColor: accentRed);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        Get.snackbar('Error', 'Failed to fetch vendor data: $e',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: accentRed);
      }
    }
  }

  // Image upload function
  Future<void> _pickAndUploadImage(String imageKey, String imageName) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        String fileName =
            '${imageKey}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        String uploadedImageUrl =
            await vendorsController.uploadImage(imageFile, fileName);

        if (mounted) {
          setState(() {
            images[imageKey] = uploadedImageUrl;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', 'Failed to upload $imageName: $e',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: accentRed);
      }
    }
  }

  // List of steps for the Stepper widget
  List<Step> get steps => [
        Step(
          title: const Text('Vendor Info', style: TextStyle(color: primaryRed)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(vendorNameController, 'Vendor Name',
                  isEditable: false),
              _buildTextField(bussinessNameController, 'Business Name'),
              _buildTextField(emailController, 'Email'),
              _buildTextField(phoneNumberController, 'Phone Number'),
            ],
          ),
          isActive: currentStep >= 0,
          state: currentStep > 0 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: const Text('Address & Details',
              style: TextStyle(color: primaryRed)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(businessAddressController, 'Business Address'),
              _buildTextField(areaCityController, 'Area/City'),
              _buildTextField(postalCodeController, 'Postal Code'),
              _buildTextField(stateController, 'State'),
            ],
          ),
          isActive: currentStep >= 1,
          state: currentStep > 1 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: const Text('Water & Delivery',
              style: TextStyle(color: primaryRed)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(waterTypeController, 'Water Type'),
              _buildTextField(capacityOptionsController, 'Capacity Options'),
              _buildTextField(dailySupplyController, 'Daily Supply'),
              _buildTextField(deliveryAreaController, 'Delivery Area'),
              _buildTextField(deliveryTimingsController, 'Delivery Timings'),
            ],
          ),
          isActive: currentStep >= 2,
          state: currentStep > 2 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title:
              const Text('Bank Details', style: TextStyle(color: primaryRed)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(bankNameController, 'Bank Name'),
              _buildTextField(accountNumberController, 'Account Number'),
              _buildTextField(upiIdController, 'UPI ID'),
              _buildTextField(ifscCodeController, 'IFSC Code'),
            ],
          ),
          isActive: currentStep >= 3,
          state: currentStep > 3 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: const Text('Others', style: TextStyle(color: primaryRed)),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(gstNumberController, 'GST Number'),
              _buildTextField(remarksController, 'Remarks'),
              const SizedBox(height: 16),
              const Text(
                'Upload Images',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryRed,
                ),
              ),
              const SizedBox(height: 8),
              _buildImageUploadSection('aadharImg', 'Aadhaar Card'),
              const SizedBox(height: 16),
              _buildImageUploadSection('panImg', 'PAN Card'),
              const SizedBox(height: 16),
              _buildImageUploadSection('bankDocumentImg', 'Bank Document'),
              const SizedBox(height: 16),
              _buildImageUploadSection('passportImg', 'Passport Image'),
              const SizedBox(height: 16),
              _buildImageUploadSection(
                  'waterQualityCertificateImg', 'Water Quality Certificates'),
              const SizedBox(height: 16),
              _buildImageUploadSection('IdentityProofImg', 'Identity Proof'),
              const SizedBox(height: 16),
              _buildImageUploadSection('businessImages', 'Business Images'),
              const SizedBox(height: 16),
              displayBusinessImages(),
            ],
          ),
          isActive: currentStep >= 4,
          state: currentStep == 4 ? StepState.indexed : StepState.complete,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 249, 255),
      appBar: AppBar(
        backgroundColor: primaryRed,
        title: const Text(
          'Edit Vendor Details',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryRed))
          : Stepper(
              steps: steps,
              currentStep: currentStep,
              onStepContinue: () {
                if (currentStep < steps.length - 1) {
                  setState(() {
                    currentStep += 1;
                  });
                } else {
                  try {
                    saveData();
                    Get.snackbar('Success', 'Vendor details updated',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: primaryRed);
                  } catch (e) {
                    Get.snackbar('Error', 'Failed to update vendor details: $e',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: accentRed);
                  }
                }
              },
              onStepCancel: () {
                if (currentStep > 0) {
                  setState(() {
                    currentStep -= 1;
                  });
                }
              },
              onStepTapped: (index) {
                setState(() {
                  currentStep = index;
                });
              },
              type: StepperType.vertical,
              physics: const ClampingScrollPhysics(),
              elevation: 0,
              connectorColor: WidgetStateProperty.all(primaryRed),
              controlsBuilder: (context, details) {
                return Row(
                  children: [
                    if (details.currentStep < steps.length - 1)
                      ElevatedButton(
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Continue'),
                      ),
                    if (details.currentStep == steps.length - 1)
                      ElevatedButton(
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                    const SizedBox(width: 8),
                    if (details.currentStep > 0)
                      TextButton(
                        onPressed: details.onStepCancel,
                        style: TextButton.styleFrom(
                          foregroundColor: primaryRed,
                        ),
                        child: const Text('Back'),
                      ),
                  ],
                );
              },
            ),
    );
  }

  // Helper method to build TextFormField widgets
  Widget _buildTextField(TextEditingController controller, String label,
      {bool isEditable = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: !isEditable, // Set read-only based on isEditable
        decoration: InputDecoration(
          labelStyle: TextStyle(
            color: textSecondary,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
          hintStyle: TextStyle(
            color: textSecondary,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          floatingLabelStyle: const TextStyle(
            color: primaryRed,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: borderLight,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: primaryRed,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 17),
          labelText: label,
          fillColor: isEditable ? Colors.white : Colors.grey[200],
          filled: true,
        ),
        style: const TextStyle(fontSize: 16, color: textPrimary),
      ),
    );
  }

  // Helper method to build image upload section
  Widget _buildImageUploadSection(String imageKey, String imageName) {
    String? imageUrl = images[imageKey];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                imageName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => _pickAndUploadImage(imageKey, imageName),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Upload'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (imageUrl != null && imageUrl.isNotEmpty)
          _buildImageWidget(imageUrl, imageName),
      ],
    );
  }

  // Helper method to build image widget with error handling
  Widget _buildImageWidget(String imageUrl, String imageName) {
    if (imageUrl.isEmpty || !Uri.parse(imageUrl).hasAuthority) {
      return SizedBox(
        width: 100,
        height: 100,
        child: Center(child: Text('Invalid $imageName URL')),
      );
    }

    return Column(
      children: [
        Image.network(
          imageUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              width: 100,
              height: 100,
              child:
                  Center(child: CircularProgressIndicator(color: primaryRed)),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return SizedBox(
              width: 100,
              height: 100,
              child: Center(child: Text('Failed to load $imageName')),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          imageName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
        ),
      ],
    );
  }

  // Display business images
  Widget displayBusinessImages() {
    List<String> businessImages = images["businessImages"]
            ?.split(',')
            .where((url) => url.trim().isNotEmpty)
            .toList() ??
        [];

    return businessImages.isEmpty
        ? const Text("No business images uploaded")
        : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: businessImages.length,
            itemBuilder: (context, index) {
              return Image.network(
                businessImages[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Text(
                  "Failed to load image",
                  style: TextStyle(color: Colors.red),
                ),
              );
            },
          );
  }

  // Save vendor data
  void saveData() {
    VendorModal updatedVendor = vendor!.copyWith(
      vendorName: vendorNameController.text,
      bussinessName: bussinessNameController.text,
      email: emailController.text,
      phoneNumber: phoneNumberController.text,
      contactPerson: contactPersonController.text,
      businessAddress: businessAddressController.text,
      areaCity: areaCityController.text,
      postalCode: postalCodeController.text,
      state: stateController.text,
      waterType: waterTypeController.text,
      capacityOptions: capacityOptionsController.text,
      dailySupply: dailySupplyController.text,
      deliveryArea: deliveryAreaController.text,
      deliveryTimings: deliveryTimingsController.text,
      bankName: bankNameController.text,
      accountNumber: accountNumberController.text,
      upiId: upiIdController.text,
      ifscCode: ifscCodeController.text,
      gstNumber: gstNumberController.text,
      remarks: remarksController.text,
      vendorType: vendor!.vendorType, // Use fetched vendor's vendorType
      images: images,
      updatedAt: DateTime.now().toIso8601String(),
    );

    vendorsController.editVendorDetails(modal: updatedVendor);
  }

  @override
  void dispose() {
    // Do not dispose controllers here since they are managed by GetX
    super.dispose();
  }
}
