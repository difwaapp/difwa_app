import 'dart:io';
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
  int currentStep = 0;
  Map<String, String> images = {};
  final ImagePicker _picker = ImagePicker();
  VendorModel? vendor;

  // Modern Flat Theme Colors
  static const Color primaryBackground = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF2D3142);
  static const Color textSecondary = Color(0xFF9094A6);
  static const Color accentColor = Color(0xFF6C63FF);
  static const Color successColor = Color(0xFF00C853);

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
          bussinessNameController.text = vendor!.businessName?? '';
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
        File imageFile = File(pickedFile.path);
        String fileName =
            '${imageKey}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        String uploadedImageUrl = await vendorsController.uploadImage(
          imageFile,
          fileName,
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
          Text(
            'Business Images',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
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
        children: [
          _buildTextField(remarksController, 'Remarks'),
        ],
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
        backgroundColor: Colors.deepPurple.shade700,
        elevation: 0,
        title: Text(
          'Edit Vendor Details',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.deepPurple.shade700, Colors.blue.shade700],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: accentColor))
          : Theme(
              data: ThemeData(
                colorScheme: ColorScheme.light(
                  primary: accentColor,
                  secondary: accentColor,
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
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        if (currentStep < steps.length - 1)
                          ElevatedButton(
                            onPressed: details.onStepContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Continue',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                            ),
                          )
                        else
                          ElevatedButton(
                            onPressed: details.onStepContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: successColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Save Changes',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                            ),
                          ),
                        if (currentStep > 0) ...[
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: Text(
                              'Back',
                              style: GoogleFonts.inter(
                                color: textSecondary,
                                fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isEditable = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
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
        child: TextFormField(
          controller: controller,
          enabled: isEditable,
          style: GoogleFonts.inter(color: textPrimary, fontSize: 14),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.inter(
              color: textSecondary,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            floatingLabelStyle: GoogleFonts.inter(
              color: accentColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
            fillColor: Colors.transparent,
            filled: true,
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection(String imageKey, String imageName) {
    String? imageUrl = images[imageKey];
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                imageName,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickAndUploadImage(imageKey, imageName),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor.withOpacity(0.1),
                  foregroundColor: accentColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: accentColor.withOpacity(0.5)),
                  ),
                ),
                icon: const Icon(Icons.upload_rounded, size: 18),
                label: const Text('Upload'),
              ),
            ],
          ),
          if (imageUrl != null && imageUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildImageWidget(imageUrl, imageName),
          ],
        ],
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl, String imageName) {
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
            child: InteractiveViewer(
              child: Image.network(imageUrl),
            ),
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
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Text(
                imageName,
                style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              businessImages[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.black12,
                child: const Icon(Icons.error, color: Colors.redAccent),
              ),
            ),
          ),
        );
      },
    );
  }

  void saveData() {
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

    vendorsController.editVendorDetails(modal: updatedVendor);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
