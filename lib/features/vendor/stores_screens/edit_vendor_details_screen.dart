// lib/features/vendor/stores_screens/edit_vendor_details_screen.dart
import 'dart:io';

import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/models/vendors_models/vendor_model.dart';
import 'package:difwa_app/utils/location_helper.dart';
import 'package:difwa_app/utils/validators.dart';
import 'package:difwa_app/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

import '../../../widgets/custom_button.dart';

class EditVendorDetailsScreen extends StatefulWidget {
  final VendorModel? vendorModel;

  const EditVendorDetailsScreen({super.key, this.vendorModel});

  @override
  State<EditVendorDetailsScreen> createState() =>
      _EditVendorDetailsScreenState();
}

class _EditVendorDetailsScreenState extends State<EditVendorDetailsScreen> {
  final PageController _controller = PageController();
  final VendorsController controller = Get.find<VendorsController>();

  final _formKeys = List.generate(7, (_) => GlobalKey<FormState>());

  // Input controllers
  final TextEditingController vendorNameController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController businessAddressController =
      TextEditingController();
  final TextEditingController areaCityController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
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
  final TextEditingController maxOrdersPerDayController =
      TextEditingController();
  final TextEditingController serviceRadiusKmController =
      TextEditingController();
  final TextEditingController minOrderQtyController = TextEditingController();
  final TextEditingController deliveryChargesController =
      TextEditingController();

  double? latitude;
  double? longitude;
  Map<String, String> imageUrl = {};
  Map<String, bool> uploadingStatus = {};
  int _currentStep = 0;
  bool isLoading = false;
  bool isSubmitting = false;
  List<String> uploadedUrls = [];

  // Form Data
  String vendorType = '';
  String waterType = '';
  String locationDetails = "Fetching location...";
  
  // Operational settings state
  int maxOrdersPerDay = 100;
  double serviceRadiusKm = 5.0;
  int minOrderQty = 1;
  double deliveryCharges = 0.0;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize uploadingStatus keys
    for (var k in [
      "Aadhaar Card",
      "PAN Card",
      "Passport Photo",
      "Business License",
      "Water Quality Certificate",
      "Identity Proof",
      "Bank Document",
      "Business Images",
    ]) {
      uploadingStatus[k] = false;
    }

    _loadVendorData();
  }

  @override
  void dispose() {
    vendorNameController.dispose();
    businessNameController.dispose();
    contactPersonController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    businessAddressController.dispose();
    areaCityController.dispose();
    postalCodeController.dispose();
    stateController.dispose();
    capacityOptionsController.dispose();
    dailySupplyController.dispose();
    deliveryAreaController.dispose();
    deliveryTimingsController.dispose();
    bankNameController.dispose();
    accountNumberController.dispose();
    upiIdController.dispose();
    ifscCodeController.dispose();
    gstNumberController.dispose();
    maxOrdersPerDayController.dispose();
    serviceRadiusKmController.dispose();
    minOrderQtyController.dispose();
    deliveryChargesController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadVendorData() async {
    setState(() => isLoading = true);
    try {
      VendorModel? vendor;
      if (widget.vendorModel != null) {
        vendor = widget.vendorModel;
      } else {
        vendor = await controller.fetchStoreData();
      }

      if (vendor != null && mounted) {
        setState(() {
          // Basic info
          vendorNameController.text = vendor!.vendorName;
          businessNameController.text = vendor.businessName;
          contactPersonController.text = vendor.contactPerson;
          phoneNumberController.text = vendor.phoneNumber;
          emailController.text = vendor.email;

          // Location
          businessAddressController.text = vendor.businessAddress;
          areaCityController.text = vendor.areaCity;
          postalCodeController.text = vendor.postalCode;
          stateController.text = vendor.state;
          latitude = vendor.latitude;
          longitude = vendor.longitude;

          // Service details
          vendorType = vendor.vendorType;
          waterType = vendor.waterType;
          capacityOptionsController.text = vendor.capacityOptions;
          dailySupplyController.text = vendor.dailySupply;
          deliveryAreaController.text = vendor.deliveryArea;
          deliveryTimingsController.text = vendor.deliveryTimings;

          // Operational settings
          maxOrdersPerDay = vendor.maxOrdersPerDay;
          serviceRadiusKm = vendor.serviceRadiusKm;
          minOrderQty = vendor.minOrderQty;
          deliveryCharges = vendor.deliveryCharges;
          maxOrdersPerDayController.text = vendor.maxOrdersPerDay.toString();
          serviceRadiusKmController.text = vendor.serviceRadiusKm.toStringAsFixed(1);
          minOrderQtyController.text = vendor.minOrderQty.toString();
          deliveryChargesController.text = vendor.deliveryCharges.toStringAsFixed(1);

          // Financial
          bankNameController.text = vendor.bankName;
          accountNumberController.text = vendor.accountNumber;
          upiIdController.text = vendor.upiId;
          ifscCodeController.text = vendor.ifscCode;
          gstNumberController.text = vendor.gstNumber;

          // Images
          imageUrl = Map<String, String>.from(vendor.images);
          
          // Parse business images if available
          if (imageUrl['businessImages'] != null &&
              imageUrl['businessImages']!.isNotEmpty) {
            uploadedUrls = imageUrl['businessImages']!.split(',');
          }
        });
      }
    } catch (e) {
      debugPrint('Load vendor data error: $e');
      Get.snackbar(
        'Error',
        'Failed to load vendor data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Step navigation helpers
  void nextStep() {
    final valid = _formKeys[_currentStep].currentState?.validate() ?? true;
    if (!valid) {
      Get.snackbar(
        'Error',
        'Please fix required fields in this step.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (_currentStep < steps.length - 1) {
      setState(() => _currentStep++);
      // Use animateToPage instead of nextPage to avoid controller issues
      if (_controller.hasClients) {
        _controller.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      // Use animateToPage instead of previousPage to avoid controller issues
      if (_controller.hasClients) {
        _controller.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    }
  }

  Future<void> fetchLocation() async {
    setState(() => isLoading = true);
    try {
      final position = await LocationHelper.getCurrentLocation();
      if (position == null) {
        setState(() {
          locationDetails = 'Location not available';
          isLoading = false;
        });
        return;
      }

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          areaCityController.text = [
            p.subLocality ?? '',
            p.locality ?? '',
            p.postalCode ?? '',
            p.country ?? '',
          ].where((s) => s.isNotEmpty).join(', ');

          stateController.text = p.administrativeArea ?? '';
          postalCodeController.text = p.postalCode ?? '';
          businessAddressController.text = [
            p.subThoroughfare ?? '',
            p.thoroughfare ?? '',
            p.subLocality ?? '',
            p.locality ?? '',
          ].where((s) => s.isNotEmpty).join(', ');

          locationDetails =
              '${p.street ?? ''}, ${p.locality ?? ''}, ${p.administrativeArea ?? ''}';
        });
      }
    } catch (e) {
      debugPrint('fetchLocation error: $e');
      setState(() => locationDetails = 'Error fetching location');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // File pick & upload
  Future<void> pickFileAndUpload(String documentType) async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      uploadingStatus[documentType] = true;
    });

    try {
      final url = await controller.uploadImage(File(picked.path), documentType);
      setState(() {
        imageUrl[_keyForDocument(documentType)] = url;
        uploadingStatus[documentType] = false;
      });
    } catch (e) {
      setState(() {
        uploadingStatus[documentType] = false;
      });
      Get.snackbar(
        'Upload failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String _keyForDocument(String doc) {
    switch (doc) {
      case 'Aadhaar Card':
        return 'aadharImg';
      case 'PAN Card':
        return 'panImg';
      case 'Passport Photo':
        return 'passportImg';
      case 'Business License':
        return 'businessLicenseImg';
      case 'Water Quality Certificate':
        return 'waterQualityCertificateImg';
      case 'Identity Proof':
        return 'IdentityProofImg';
      case 'Bank Document':
        return 'bankDocumentImg';
      case 'Business Images':
        return 'businessImages';
      default:
        return doc.replaceAll(' ', '_');
    }
  }

  Future<void> pickBusinessImages() async {
    final List<XFile> picked = await _picker.pickMultiImage();
    if (picked == null || picked.isEmpty) return;

    setState(() {
      uploadingStatus['Business Images'] = true;
    });

    try {
      final urls = <String>[];
      for (final xf in picked) {
        final u = await controller.uploadImage(
          File(xf.path),
          'Business Images',
        );
        if (u.isNotEmpty) urls.add(u);
      }
      setState(() {
        uploadedUrls = urls;
        imageUrl['businessImages'] = urls.join(',');
        uploadingStatus['Business Images'] = false;
      });
    } catch (e) {
      setState(() {
        uploadingStatus['Business Images'] = false;
      });
      Get.snackbar(
        'Error',
        'Failed to upload business images: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Submit
  Future<void> submitData() async {
    if (isSubmitting) return;
    
    for (var i = 0; i < _formKeys.length; i++) {
      if (!(_formKeys[i].currentState?.validate() ?? true)) {
        Get.snackbar(
          'Error',
          'Please complete all required fields',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    setState(() => isSubmitting = true);

    try {
      // If latitude/longitude are not set, try to geocode from address
      if (latitude == null || longitude == null) {
        try {
          final address =
              '${businessAddressController.text}, ${areaCityController.text}, ${stateController.text}, ${postalCodeController.text}';
          final locations = await locationFromAddress(address);
          if (locations.isNotEmpty) {
            setState(() {
              latitude = locations.first.latitude;
              longitude = locations.first.longitude;
            });
          }
        } catch (e) {
          debugPrint('Geocoding error: $e');
        }
      }

      final updatedVendor = VendorModel(
        id: widget.vendorModel?.id ?? '',
        uid: widget.vendorModel?.uid ?? '',
        merchantId: widget.vendorModel?.merchantId ?? '',
        vendorName: vendorNameController.text.trim(),
        businessName: businessNameController.text.trim(),
        contactPerson: contactPersonController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
        email: emailController.text.trim(),
        vendorType: vendorType,
        businessAddress: businessAddressController.text.trim(),
        areaCity: areaCityController.text.trim(),
        postalCode: postalCodeController.text.trim(),
        state: stateController.text.trim(),
        waterType: waterType,
        capacityOptions: capacityOptionsController.text.trim(),
        dailySupply: dailySupplyController.text.trim(),
        deliveryArea: deliveryAreaController.text.trim(),
        deliveryTimings: deliveryTimingsController.text.trim(),
        bankName: bankNameController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        upiId: upiIdController.text.trim(),
        ifscCode: ifscCodeController.text.trim(),
        gstNumber: gstNumberController.text.trim(),
        maxOrdersPerDay: int.tryParse(maxOrdersPerDayController.text) ?? 100,
        serviceRadiusKm: double.tryParse(serviceRadiusKmController.text) ?? 5.0,
        minOrderQty: int.tryParse(minOrderQtyController.text) ?? 1,
        deliveryCharges: double.tryParse(deliveryChargesController.text) ?? 0.0,
        images: imageUrl,
        latitude: latitude,
        longitude: longitude,
        earnings: widget.vendorModel?.earnings ?? 0.0,
        status: widget.vendorModel?.status ?? 'pending',
        isVerified: widget.vendorModel?.isVerified ?? false,
        isActive: widget.vendorModel?.isActive ?? false,
        rating: widget.vendorModel?.rating ?? 0.0,
        ratingCount: widget.vendorModel?.ratingCount ?? 0,
        createdAt: widget.vendorModel?.createdAt,
      );

      await controller.editVendorDetails(modal: updatedVendor);
      setState(() => isSubmitting = false);

      Get.back();
      Get.snackbar(
        'Success',
        'Vendor details updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      setState(() => isSubmitting = false);
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // UI helpers
  Widget stepHeader(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );

  InputDecoration inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      );

  Widget textInput(
    String label,
    String hint,
    IconData icon,
    Function(String) onChanged,
    TextEditingController controller,
    InputType type,
    String? Function(String?)? validator,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          CommonTextField(
            controller: controller,
            hint: hint,
            icon: icon,
            validator: validator != null ? (v) => validator(v) : null,
            onChanged: onChanged,
            inputType: type,
          ),
        ],
      ),
    );
  }

  Widget dropdownInput(
    String label,
    List<String> items,
    Function(String?) onChanged, {
    String? Function(String?)? validator,
  }) {
    String? currentValue;
    if (label.contains("Vendor Type")) {
      currentValue = items.contains(vendorType) ? vendorType : null;
    } else if (label.contains("Water")) {
      currentValue = items.contains(waterType) ? waterType : null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            decoration: inputDecoration("Select"),
            value: currentValue,
            validator: validator != null ? (value) => validator(value) : null,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderInput({
    required String label,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    required String displayValue,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.blue,
              inactiveTrackColor: Colors.blue.shade100,
              thumbColor: Colors.blue,
              overlayColor: Colors.blue.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                min.toInt().toString(),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                max.toInt().toString(),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget uploadCard(
    String label,
    Function() onTap,
    String? url, {
    bool isUploading = false,
    FormFieldValidator<dynamic>? validator,
  }) {
    return FormField(
      validator: validator,
      builder: (FormFieldState<dynamic> state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: isUploading
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: double.infinity,
                          height: 100,
                          color: Colors.grey.shade300,
                        ),
                      )
                    : (url != null && url.isNotEmpty)
                        ? Image.network(
                            url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 100,
                            errorBuilder: (c, e, s) => const Text(
                              "Failed to load",
                              style: TextStyle(color: Colors.red),
                            ),
                          )
                        : Text(
                            "Upload $label",
                            style: const TextStyle(color: Colors.grey),
                          ),
              ),
            ),
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                state.errorText ?? '',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget displayBusinessImages() {
    return uploadedUrls.isEmpty
        ? const Text("No business images uploaded")
        : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: uploadedUrls.length,
            itemBuilder: (context, index) {
              return Image.network(uploadedUrls[index], fit: BoxFit.cover);
            },
          );
  }

  Widget previewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        stepHeader("Preview & Submit"),
        Text("Vendor: ${vendorNameController.text}"),
        Text("Business: ${businessNameController.text}"),
        const SizedBox(height: 12),
        const Text(
          "Uploaded Documents:",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        displayBusinessImages(),
        const SizedBox(height: 20),
        CustomButton(
          text: isSubmitting ? "Updating..." : "Update Details",
          onPressed: submitData,
        ),
      ],
    );
  }

  List<Widget> get steps => [
        // Step 1 - Basic Info
        Form(
          key: _formKeys[0],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              stepHeader("Basic Vendor Info"),
              const SizedBox(height: 10),
              CommonTextField(
                controller: vendorNameController,
                hint: "Enter Vendor Name",
                label: "Vendor Name",
                icon: Icons.person,
                validator: (v) => Validators.validateEmpty(v, "Vendor Name"),
                onChanged: (v) {},
                inputType: InputType.text,
              ),
              const SizedBox(height: 12),
              CommonTextField(
                controller: businessNameController,
                hint: "Business Name",
                label: "Business Name",
                icon: Icons.business,
                validator: (v) => Validators.validateEmpty(v, "Business Name"),
                onChanged: (v) {},
                inputType: InputType.text,
              ),
              const SizedBox(height: 12),
              CommonTextField(
                controller: contactPersonController,
                hint: "Contact Person Name",
                icon: Icons.person,
                validator: (v) =>
                    Validators.validateEmpty(v, "Contact Person Name"),
                onChanged: (v) {},
                inputType: InputType.text,
              ),
              const SizedBox(height: 12),
              CommonTextField(
                controller: phoneNumberController,
                hint: "Phone Number",
                icon: Icons.phone,
                validator: (v) => Validators.validateEmpty(v, "Phone Number"),
                onChanged: (v) {},
                inputType: InputType.phone,
              ),
              const SizedBox(height: 12),
              CommonTextField(
                controller: emailController,
                hint: "Email",
                icon: Icons.email,
                validator: (v) => Validators.validateEmpty(v, "Email"),
                onChanged: (v) {},
                inputType: InputType.email,
              ),
            ],
          ),
        ),

        // Step 2 - Location
        Form(
          key: _formKeys[1],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: stepHeader("Location Details")),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: fetchLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text("Use my location"),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              textInput(
                "State/Province",
                "Enter state",
                Icons.location_on,
                (v) {},
                stateController,
                InputType.text,
                (v) => Validators.validateEmpty(v, "State"),
              ),
              textInput(
                "Area/City",
                "Enter area or city",
                Icons.location_city,
                (v) {},
                areaCityController,
                InputType.text,
                null,
              ),
              textInput(
                "Business Address",
                "Enter address",
                Icons.location_on,
                (v) {},
                businessAddressController,
                InputType.address,
                (v) => Validators.validateEmpty(v, "Business Address"),
              ),
              textInput(
                "PIN/ZIP Code",
                "Enter postal code",
                Icons.pin,
                (v) {},
                postalCodeController,
                InputType.pin,
                (v) => Validators.validateEmpty(v, "Postal code"),
              ),
            ],
          ),
        ),

        // Step 3 - Service
        Form(
          key: _formKeys[2],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              stepHeader("Service Details"),
              dropdownInput(
                "Vendor Type",
                ["RO", "Mineral", "Tanker", "Packaged Water"],
                (v) => setState(() => vendorType = v ?? ''),
                validator: (v) => Validators.validateEmpty(v, "Vendor Type"),
              ),
              dropdownInput(
                "Type of Water Supplied",
                ["Drinking", "Industrial", "Mixed"],
                (v) => setState(() => waterType = v ?? ''),
                validator: (v) =>
                    Validators.validateEmpty(v, "Type of Water Supplied"),
              ),
              textInput(
                "Capacity Options",
                "e.g. 20L, 500L, 1000L",
                Icons.filter_1,
                (v) {},
                capacityOptionsController,
                InputType.text,
                null,
              ),
              textInput(
                "Daily Supply Capacity (in Litres)",
                "e.g. 2000",
                Icons.local_drink,
                (v) {},
                dailySupplyController,
                InputType.text,
                null,
              ),
              textInput(
                "Delivery Area Covered",
                "Enter area",
                Icons.map,
                (v) {},
                deliveryAreaController,
                InputType.text,
                null,
              ),
              textInput(
                "Delivery Timings",
                "e.g. 6 AM - 8 PM",
                Icons.access_time,
                (v) {},
                deliveryTimingsController,
                InputType.text,
                null,
              ),
            ],
          ),
        ),

        // Step 4 - Operational Settings
        Form(
          key: _formKeys[3],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              stepHeader("Operational Settings"),
              const SizedBox(height: 8),
              _buildSliderInput(
                label: "Maximum Orders Per Day",
                icon: Icons.shopping_cart,
                value: maxOrdersPerDay.toDouble(),
                min: 10,
                max: 500,
                divisions: 49,
                onChanged: (val) {
                  setState(() {
                    maxOrdersPerDay = val.toInt();
                    maxOrdersPerDayController.text = maxOrdersPerDay.toString();
                  });
                },
                displayValue: "$maxOrdersPerDay orders",
              ),
              const SizedBox(height: 20),
              _buildSliderInput(
                label: "Service Radius (in KM)",
                icon: Icons.radar,
                value: serviceRadiusKm,
                min: 1,
                max: 50,
                divisions: 49,
                onChanged: (val) {
                  setState(() {
                    serviceRadiusKm = val;
                    serviceRadiusKmController.text = serviceRadiusKm.toStringAsFixed(1);
                  });
                },
                displayValue: "${serviceRadiusKm.toStringAsFixed(1)} km",
              ),
              const SizedBox(height: 20),
              _buildSliderInput(
                label: "Minimum Order Quantity",
                icon: Icons.production_quantity_limits,
                value: minOrderQty.toDouble(),
                min: 1,
                max: 20,
                divisions: 19,
                onChanged: (val) {
                  setState(() {
                    minOrderQty = val.toInt();
                    minOrderQtyController.text = minOrderQty.toString();
                  });
                },
                displayValue: "$minOrderQty items",
              ),
              const SizedBox(height: 20),
              _buildSliderInput(
                label: "Delivery Charges",
                icon: Icons.local_shipping,
                value: deliveryCharges,
                min: 0,
                max: 200,
                divisions: 40,
                onChanged: (val) {
                  setState(() {
                    deliveryCharges = val;
                    deliveryChargesController.text = deliveryCharges.toStringAsFixed(1);
                  });
                },
                displayValue: "₹${deliveryCharges.toStringAsFixed(1)}",
              ),
            ],
          ),
        ),

        // Step 5 - KYC / Docs
        Form(
          key: _formKeys[4],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              stepHeader("KYC / Documents"),
              uploadCard(
                "Aadhaar Card",
                () => pickFileAndUpload("Aadhaar Card"),
                imageUrl["aadharImg"],
                isUploading: uploadingStatus["Aadhaar Card"] ?? false,
              ),
              uploadCard(
                "PAN Card",
                () => pickFileAndUpload("PAN Card"),
                imageUrl["panImg"],
                isUploading: uploadingStatus["PAN Card"] ?? false,
              ),
              uploadCard(
                "Passport-size Photo",
                () => pickFileAndUpload("Passport Photo"),
                imageUrl["passportImg"],
                isUploading: uploadingStatus["Passport Photo"] ?? false,
              ),
              uploadCard(
                "Business License",
                () => pickFileAndUpload("Business License"),
                imageUrl["businessLicenseImg"],
                isUploading: uploadingStatus["Business License"] ?? false,
              ),
              uploadCard(
                "Water Quality Certificate",
                () => pickFileAndUpload("Water Quality Certificate"),
                imageUrl["waterQualityCertificateImg"],
                isUploading: uploadingStatus["Water Quality Certificate"] ?? false,
              ),
              uploadCard(
                "Identity Proof",
                () => pickFileAndUpload("Identity Proof"),
                imageUrl["IdentityProofImg"],
                isUploading: uploadingStatus["Identity Proof"] ?? false,
              ),
              uploadCard(
                "Bank Passbook or Cancelled Cheque",
                () => pickFileAndUpload("Bank Document"),
                imageUrl["bankDocumentImg"],
                isUploading: uploadingStatus["Bank Document"] ?? false,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: pickBusinessImages,
                icon: const Icon(Icons.photo_library),
                label: const Text("Pick business images"),
              ),
              const SizedBox(height: 8),
              displayBusinessImages(),
            ],
          ),
        ),

        // Step 6 - Financial
        Form(
          key: _formKeys[5],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              stepHeader("Financial / Payment Info"),
              textInput(
                "Bank Name",
                "Enter bank name",
                Icons.account_balance,
                (v) {},
                bankNameController,
                InputType.text,
                (v) => Validators.validateEmpty(v, "Bank Name"),
              ),
              textInput(
                "Account Number",
                "Enter account number",
                Icons.account_box,
                (v) {},
                accountNumberController,
                InputType.text,
                (v) => Validators.validateEmpty(v, "Account Number"),
              ),
              textInput(
                "UPI ID",
                "Enter UPI ID",
                Icons.account_box,
                (v) {},
                upiIdController,
                InputType.text,
                null,
              ),
              textInput(
                "IFSC/SWIFT Code",
                "Enter IFSC/SWIFT",
                Icons.code,
                (v) {},
                ifscCodeController,
                InputType.text,
                (v) => Validators.validateEmpty(v, "IFSC"),
              ),
              textInput(
                "GST Number / Tax ID",
                "Enter GST/Tax ID",
                Icons.business_center,
                (v) {},
                gstNumberController,
                InputType.text,
                null,
              ),
            ],
          ),
        ),

        // Step 7 - Preview
        previewStep(),
      ];

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Edit Vendor Details"),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: appTheme.whiteColor,
      appBar: AppBar(
        title: const Text("Edit Vendor Details"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: Column(
              children: [
                Text(
                  "Step ${_currentStep + 1} of ${steps.length}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  minHeight: 8,
                  value: (_currentStep + 1) / steps.length,
                  color: Colors.blue,
                  backgroundColor: Colors.blue.shade100,
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              children: steps
                  .map(
                    (s) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(child: s),
                    ),
                  )
                  .toList(),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: CustomButton(
                      text: "Previous",
                      onPressed: previousStep,
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: _currentStep == steps.length - 1 ? "Finish" : "Next",
                    onPressed: _currentStep == steps.length - 1
                        ? submitData
                        : nextStep,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
