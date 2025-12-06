import 'dart:io';
import 'dart:ui';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/models/vendors_models/vendor_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class EditVendorDetailsScreen extends StatefulWidget {
  const EditVendorDetailsScreen({super.key});
  @override
  _EditVendorDetailsScreenState createState() =>
      _EditVendorDetailsScreenState();
}

class _EditVendorDetailsScreenState extends State<EditVendorDetailsScreen> {
  late VendorsController vendorsController;
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
  bool isUploading = false;
  int currentStep = 0;
  Map<String, String> images = {};
  final ImagePicker _picker = ImagePicker();
  VendorModel? vendor;

  // Modern Clean Theme Colors
  static const Color primaryBackground = Colors.white;
  static const Color cardColor = Color(
    0xFFFAFAFA,
  ); // Very light grey for inputs
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color accentColor = Color(0xFF6366F1); // Indigo

  @override
  void initState() {
    super.initState();
    // Initialize VendorsController
    try {
      vendorsController = Get.find<VendorsController>();
    } catch (e) {
      vendorsController = Get.put(VendorsController());
    }
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
          bussinessNameController.text = vendor!.businessName ?? '';
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
          Get.snackbar(
            'Error',
            'No vendor data found',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        Get.snackbar(
          'Error',
          'Failed to fetch vendor data: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
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
        setState(() => isUploading = true);

        File imageFile = File(pickedFile.path);
        String fileName =
            '${imageKey}_${DateTime.now().millisecondsSinceEpoch}.jpg';

        String? uid = FirebaseAuth.instance.currentUser?.uid;

        String uploadedImageUrl = await vendorsController.uploadImage(
          imageFile,
          fileName,
          subFolder: uid,
        );

        if (mounted) {
          setState(() {
            images[imageKey] = uploadedImageUrl;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to upload $imageName: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() => isUploading = false);
      }
    }
  }

  Future<void> _pickAndUploadBusinessImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() => isUploading = true);

        String? uid = FirebaseAuth.instance.currentUser?.uid;
        List<String> newImageUrls = [];

        // Split existing images
        List<String> currentImages =
            images['businessImages']
                ?.split(',')
                .where((s) => s.isNotEmpty)
                .toList() ??
            [];

        for (var i = 0; i < pickedFiles.length; i++) {
          File imageFile = File(pickedFiles[i].path);
          String fileName =
              'business_image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

          String uploadedUrl = await vendorsController.uploadImage(
            imageFile,
            fileName,
            subFolder: uid,
          );
          newImageUrls.add(uploadedUrl);
        }

        // Append new images to existing list
        currentImages.addAll(newImageUrls);

        if (mounted) {
          setState(() {
            images['businessImages'] = currentImages.join(',');
          });
          Get.snackbar(
            'Success',
            'Business images uploaded successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: appTheme.primaryColor,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to upload business images: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() => isUploading = false);
      }
    }
  }

  // List of steps for the Stepper widget
  List<Step> get steps => [
    Step(
      title: Text(
        'Vendor Info',
        style: GoogleFonts.inter(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            vendorNameController,
            'Vendor Name',
            isEditable: false,
          ),
          _buildTextField(bussinessNameController, 'Business Name'),
          _buildTextField(emailController, 'Email'),
          _buildTextField(phoneNumberController, 'Phone Number'),
        ],
      ),
      isActive: currentStep >= 0,
      state: currentStep > 0 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: Text(
        'Address & Details',
        style: GoogleFonts.inter(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(contactPersonController, 'Contact Person'),
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
      title: Text(
        'Service Details',
        style: GoogleFonts.inter(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
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
      title: Text(
        'Bank Details',
        style: GoogleFonts.inter(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(bankNameController, 'Bank Name'),
          _buildTextField(accountNumberController, 'Account Number'),
          _buildTextField(ifscCodeController, 'IFSC Code'),
          _buildTextField(upiIdController, 'UPI ID'),
          _buildTextField(gstNumberController, 'GST Number'),
        ],
      ),
      isActive: currentStep >= 3,
      state: currentStep > 3 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: Text(
        'Documents',
        style: GoogleFonts.inter(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageUploadSection('aadharImg', 'Aadhar Card'),
          const SizedBox(height: 12),
          _buildImageUploadSection('panImg', 'PAN Card'),
          const SizedBox(height: 12),
          _buildImageUploadSection('gstImg', 'GST Certificate'),
          const SizedBox(height: 12),
          _buildImageUploadSection('fssaiImg', 'FSSAI License'),
          const SizedBox(height: 12),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Business Images',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _pickAndUploadBusinessImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor.withOpacity(0.1),
                  foregroundColor: accentColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: accentColor.withOpacity(0.5)),
                  ),
                ),
                icon: const Icon(Icons.add_photo_alternate, size: 18),
                label: const Text('Add Images'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          displayBusinessImages(),
        ],
      ),
      isActive: currentStep >= 4,
      state: currentStep > 4 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: Text(
        'Additional Info',
        style: GoogleFonts.inter(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildTextField(remarksController, 'Remarks')],
      ),
      isActive: currentStep >= 5,
      state: currentStep > 5 ? StepState.complete : StepState.indexed,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Details',
          style: GoogleFonts.plusJakartaSans(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[100], height: 1),
        ),
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: accentColor),
                )
              : Theme(
                  data: ThemeData(
                    colorScheme: ColorScheme.light(
                      primary: appTheme.primaryColor,
                      secondary: appTheme.secondyColor,
                    ),
                  ),
                  child: Stepper(
                    currentStep: currentStep,
                    onStepContinue: () {
                      if (currentStep < steps.length - 1) {
                        setState(() => currentStep++);
                      } else {
                        saveData();
                      }
                    },
                    onStepCancel: () {
                      if (currentStep > 0) {
                        setState(() => currentStep--);
                      }
                    },
                    onStepTapped: (step) => setState(() => currentStep = step),
                    steps: steps,
                    controlsBuilder: (context, details) {
                      final isLastStep = currentStep >= steps.length - 1;
                      return Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Row(
                          children: [
                            if (!isLastStep)
                              Expanded(
                                child: CustomButton(
                                  text: 'Next Step',
                                  onPressed: () {
                                    if (currentStep < steps.length - 1) {
                                      setState(() => currentStep++);
                                    }
                                  },
                                ),
                              )
                            else
                              Expanded(
                                child: CustomButton(
                                  text: 'Update',
                                  onPressed: saveData,
                                ),
                              ),
                            if (currentStep > 0) ...[
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                     if (currentStep > 0) {
                                      setState(() => currentStep--);
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: textPrimary,
                                    side: const BorderSide(
                                      color: Color(0xFFE5E7EB),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Back',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
          if (isUploading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Uploading... Please wait',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isEditable = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isEditable ? Colors.white : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextFormField(
            controller: controller,
            enabled: isEditable,
            style: GoogleFonts.plusJakartaSans(
              color: textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: textPrimary,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection(String imageKey, String imageName) {
    String? imageUrl = images[imageKey];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                imageName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              if (imageUrl == null || imageUrl.isEmpty)
                TextButton.icon(
                  onPressed: () => _pickAndUploadImage(imageKey, imageName),
                  style: TextButton.styleFrom(
                    foregroundColor: accentColor,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label: Text(
                    'Upload',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (imageUrl != null && imageUrl.isNotEmpty)
          _buildImageWidget(imageUrl, imageName, imageKey)
        else
          GestureDetector(
            onTap: () => _pickAndUploadImage(imageKey, imageName),
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  style: BorderStyle.none,
                ), // Using solid border instead of dashed for simplicity or use custom painter
              ),
              child: CustomPaint(
                painter: DashedBorderPainter(
                  color: const Color(0xFFD1D5DB),
                  strokeWidth: 1.5,
                  gap: 5,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 28,
                        color: textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload',
                        style: GoogleFonts.plusJakartaSans(
                          color: textSecondary.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageWidget(String imageUrl, String imageName, String imageKey) {
    if (imageUrl.isEmpty || !Uri.parse(imageUrl).hasAuthority) {
      return Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text('Invalid URL', style: TextStyle(color: textSecondary)),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Get.dialog(
          Dialog(
            backgroundColor: Colors.transparent,
            child: InteractiveViewer(child: Image.network(imageUrl)),
          ),
        );
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: 150,
                color: Colors.black12,
                child: const Center(
                  child: Icon(Icons.error, color: Colors.redAccent),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      imageName,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        images[imageKey] = '';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget displayBusinessImages() {
    List<String> businessImages =
        images["businessImages"]
            ?.split(',')
            .where((url) => url.trim().isNotEmpty)
            .toList() ??
        [];

    if (businessImages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "No business images uploaded",
            style: TextStyle(color: textSecondary),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: businessImages.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Get.dialog(
              Dialog(
                backgroundColor: Colors.transparent,
                child: InteractiveViewer(
                  child: Image.network(businessImages[index]),
                ),
              ),
            );
          },
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  businessImages[index],
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.black12,
                    child: const Icon(Icons.error, color: Colors.redAccent),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      businessImages.removeAt(index);
                      images['businessImages'] = businessImages.join(',');
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> saveData() async {
    setState(() => isUploading = true);

    try {
      VendorModel updatedVendor = vendor!.copyWith(
        vendorName: vendorNameController.text,
        businessName: bussinessNameController.text,
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
        vendorType: vendor!.vendorType,
        images: images,
        updatedAt: DateTime.now(),
      );

      await vendorsController.editVendorDetails(modal: updatedVendor);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to update vendor details: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() => isUploading = false);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedBorderPainter({
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    Path path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ),
    );

    Path dashPath = Path();
    double dashWidth = 10.0;
    double distance = 0.0;
    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + gap;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
