// lib/screens/stores_screens/vendor_multi_step_form.dart
import 'dart:io';

import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/models/stores_models/store_new_modal.dart';
import 'package:difwa_app/features/vendor/stores_screens/store_not_verified_page.dart';
import 'package:difwa_app/services/firebase_service.dart';
import 'package:difwa_app/features/address/controller/address_controller.dart';
import 'package:difwa_app/utils/location_helper.dart';
import 'package:difwa_app/utils/validators.dart';
import 'package:difwa_app/widgets/custom_input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

import '../../../widgets/custom_button.dart';

class VendorMultiStepForm extends StatefulWidget {
  const VendorMultiStepForm({super.key});

  @override
  State<VendorMultiStepForm> createState() => _VendorMultiStepFormState();
}

class _VendorMultiStepFormState extends State<VendorMultiStepForm> {
  final PageController _controller = PageController();
  final VendorsController controller = Get.find<VendorsController>();
  final FirebaseService _fs = Get.find<FirebaseService>();
  final AddressController _addressCtrl = Get.put(
    AddressController(),
    permanent: false,
  );

  final _formKeys = List.generate(6, (_) => GlobalKey<FormState>());

  // input controller
  final TextEditingController vendorNameController = TextEditingController();
  final TextEditingController bussinessNameController = TextEditingController();
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
  double? latitude;
  double? longitude;
  Map<String, String> imageUrl = {};
  Map<String, bool> uploadingStatus = {};
  int _currentStep = 0;
  bool isLoading = false;
  bool isSubmitting = false;
  List<XFile?> businessImages = [];
  List<String> uploadedUrls = [];
  XFile? businessVideo;

  // Form Data
  String vendorName = '';
  String bussinessName = '';
  String contactPerson = '';
  String phoneNumber = '';
  String email = '';
  String vendorType = '';
  String businessAddress = '';
  String areaCity = '';
  String postalCode = '';
  String state = '';
  String waterType = '';
  String capacityOptions = '';
  String dailySupply = '';
  String deliveryArea = '';
  String deliveryTimings = '';
  String bankName = '';
  String accountNumber = '';
  String upiId = '';
  String ifscCode = '';
  String gstNumber = '';
  String remarks = '';
  String status = '';
  XFile? aadhaarCardImage;
  XFile? panCardImage;
  XFile? passportPhotoImage;
  XFile? businessLicenseImage;
  XFile? waterQualityCertificateImage;
  XFile? identityProofImage;
  XFile? bankDocumentImage;
  String locationDetails = "Fetching location...";

  String? currentUserId;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // initialize uploadingStatus keys
    [
      "Aadhaar Card",
      "PAN Card",
      "Passport Photo",
      "Business License",
      "Water Quality Certificate",
      "Identity Proof",
      "Bank Document",
      "Business Images",
    ].forEach((k) => uploadingStatus[k] = false);

    _initFromUser();
    // ensure the address stream is bound
    _addressCtrl.getAddressesStream();
  }

  @override
  void dispose() {
    vendorNameController.dispose();
    bussinessNameController.dispose();
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
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initFromUser() async {
    // fetch current authenticated user & prefill contact fields
    try {
      final userMap = await _fs.fetchAppUser(
        FirebaseAuth.instance.currentUser!.uid,
      ); // you can add this helper
      if (userMap != null) {
        setState(() {
          currentUserId = userMap.uid;
          vendorName = userMap.name;
          email = userMap.email;
          phoneNumber = userMap.number;
          bussinessName = "$vendorName Water Supply";
          // prefill controllers
          vendorNameController.text = vendorName;
          emailController.text = email;
          phoneNumberController.text = phoneNumber;
          contactPersonController.text = vendorName;
          bussinessNameController.text = bussinessName;
        });
      } else {
        // fallback: use firebase auth id
        currentUserId = FirebaseAuth
            .instance
            .currentUser!
            .uid; // add helper or get from FirebaseService
      }

      // try to fetch selected address and prefill location fields
      final selectedAddress = await _addressCtrl
          .getSelectedAddressStream()
          .first;
      if (selectedAddress != null) {
        setState(() {
          businessAddressController.text =
              '${selectedAddress.street}, ${selectedAddress.floor}';
          areaCityController.text =
              '${selectedAddress.city}${selectedAddress.state != null && selectedAddress.state!.isNotEmpty ? ", ${selectedAddress.state}" : ""}';
          postalCodeController.text = selectedAddress.zip;
          stateController.text = selectedAddress.state;
        });
      }
    } catch (e) {
      debugPrint('Init user error: $e');
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
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  Future<void> fetchLocation() async {
    setState(() => isLoading = true);
    try {
      final position = await LocationHelper.getCurrentLocation();
      if (position == null) {
        setState(() {
          latitude = position!.latitude;
          longitude = position.longitude;
          locationDetails = 'Location not available';
          isLoading = false;
        });
        return;
      }

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
      } else {
        setState(() {
          locationDetails = 'No address info found for position';
        });
      }
    } catch (e) {
      debugPrint('fetchLocation error: $e');
      setState(() {
        locationDetails = 'Error fetching location';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ----------------------
  // File pick & upload
  // ----------------------
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
    // map human label -> map key
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
    final List<XFile>? picked = await _picker.pickMultiImage();
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

  // ----------------------
  // Submit
  // ----------------------
  Future<void> submitData() async {
    if (isSubmitting) return;
    // final validation across all steps
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
      final uid = currentUserId ?? FirebaseAuth.instance.currentUser!.uid ?? '';
      final vendorModal = VendorModal(
        isVerified: false,
        uid: uid,
        merchantId: '',
        earnings: 0,
        vendorName: vendorNameController.text.trim(),
        bussinessName: bussinessNameController.text.trim(),
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
        remarks: remarks,
        status: status,
        images: imageUrl,
        latitude: latitude,
        longitude: longitude,
      );

      final success = await controller.submitForm2(imageUrl, vendorModal);
      setState(() => isSubmitting = false);

      if (success) {
        Get.offAll(() => const StoreNotVerifiedPage());
      } else {
        Get.snackbar(
          'Error',
          'Failed to create vendor, please try again',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      setState(() => isSubmitting = false);
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ----------------------
  // UI helpers
  // ----------------------
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
            value: items.contains(vendorType) ? vendorType : null,
            validator: validator != null ? (value) => validator(value) : null,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) {
              vendorType = value ?? '';
              onChanged(value);
            },
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

  Widget _imagePreviewItem2(String label, String? image) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          image == null
              ? const Text("No image uploaded")
              : Image.network(
                  image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
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
        // show a few key items
        Text("Vendor: ${vendorNameController.text}"),
        Text("Business: ${bussinessNameController.text}"),
        const SizedBox(height: 12),
        const Text(
          "Uploaded Documents:",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        _imagePreviewItem2("Aadhaar Card", imageUrl["aadharImg"]),
        _imagePreviewItem2("PAN Card", imageUrl["panImg"]),
        _imagePreviewItem2("Passport Photo", imageUrl["passportImg"]),
        _imagePreviewItem2("Business License", imageUrl["businessLicenseImg"]),
        const SizedBox(height: 12),
        displayBusinessImages(),
        const SizedBox(height: 20),
        CustomButton(
          text: isSubmitting ? "Submitting..." : "Submit",
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
            onChanged: (v) => vendorName = v,
            inputType: InputType.text,
          ),
          const SizedBox(height: 12),
          CommonTextField(
            controller: bussinessNameController,
            hint: "Business Name",
            label: "Business Name",
            icon: Icons.business,
            validator: (v) => Validators.validateEmpty(v, "Business Name"),
            onChanged: (v) => bussinessName = v,
            inputType: InputType.text,
          ),
          const SizedBox(height: 12),
          CommonTextField(
            controller: contactPersonController,
            hint: "Contact Person Name",
            icon: Icons.person,
            validator: (v) =>
                Validators.validateEmpty(v, "Contact Person Name"),
            onChanged: (v) => contactPerson = v,
            inputType: InputType.text,
          ),
          const SizedBox(height: 12),
          CommonTextField(
            controller: phoneNumberController,
            hint: "Phone Number",
            icon: Icons.phone,
            validator: (v) => Validators.validateEmpty(v, "Phone Number"),
            onChanged: (v) => phoneNumber = v,
            inputType: InputType.phone,
          ),
          const SizedBox(height: 12),
          CommonTextField(
            controller: emailController,
            hint: "Email",
            icon: Icons.email,
            validator: (v) => Validators.validateEmpty(v, "Email"),
            onChanged: (v) => email = v,
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
            (v) => state = v,
            stateController,
            InputType.text,
            (v) => Validators.validateEmpty(v, "State"),
          ),
          textInput(
            "Area/City",
            "Enter area or city",
            Icons.location_city,
            (v) => areaCity = v,
            areaCityController,
            InputType.text,
            null,
          ),
          textInput(
            "Business Address",
            "Enter address",
            Icons.location_on,
            (v) => businessAddress = v,
            businessAddressController,
            InputType.address,
            (v) => Validators.validateEmpty(v, "Business Address"),
          ),
          textInput(
            "PIN/ZIP Code",
            "Enter postal code",
            Icons.pin,
            (v) => postalCode = v,
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
            "Type of Water Supplied",
            ["Drinking", "Industrial", "RO", "Mineral"],
            (v) => waterType = v ?? '',
            validator: (v) =>
                Validators.validateEmpty(v, "Type of Water Supplied"),
          ),
          textInput(
            "Capacity Options",
            "e.g. 20L, 500L, 1000L",
            Icons.filter_1,
            (v) => capacityOptions = v,
            capacityOptionsController,
            InputType.text,
            null,
          ),
          textInput(
            "Daily Supply Capacity (in Litres)",
            "e.g. 2000",
            Icons.local_drink,
            (v) => dailySupply = v,
            dailySupplyController,
            InputType.text,
            null,
          ),
          textInput(
            "Delivery Area Covered",
            "Enter area",
            Icons.map,
            (v) => deliveryArea = v,
            deliveryAreaController,
            InputType.text,
            null,
          ),
          textInput(
            "Delivery Timings",
            "e.g. 6 AM - 8 PM",
            Icons.access_time,
            (v) => deliveryTimings = v,
            deliveryTimingsController,
            InputType.text,
            null,
          ),
        ],
      ),
    ),

    // Step 4 - KYC / Docs
    Form(
      key: _formKeys[3],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          stepHeader("KYC / Documents"),
          uploadCard(
            "Aadhaar Card",
            () => pickFileAndUpload("Aadhaar Card"),
            imageUrl["aadharImg"],
            isUploading: uploadingStatus["Aadhaar Card"] ?? false,
            validator: (v) => (imageUrl["aadharImg"] ?? '').isEmpty
                ? "Aadhaar Card required"
                : null,
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

    // Step 5 - Financial
    Form(
      key: _formKeys[4],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          stepHeader("Financial / Payment Info"),
          textInput(
            "Bank Name",
            "Enter bank name",
            Icons.account_balance,
            (v) => bankName = v,
            bankNameController,
            InputType.text,
            (v) => Validators.validateEmpty(v, "Bank Name"),
          ),
          textInput(
            "Account Number",
            "Enter account number",
            Icons.account_box,
            (v) => accountNumber = v,
            accountNumberController,
            InputType.text,
            (v) => Validators.validateEmpty(v, "Account Number"),
          ),
          textInput(
            "UPI ID",
            "Enter UPI ID",
            Icons.account_box,
            (v) => upiId = v,
            upiIdController,
            InputType.text,
            null,
          ),
          textInput(
            "IFSC/SWIFT Code",
            "Enter IFSC/SWIFT",
            Icons.code,
            (v) => ifscCode = v,
            ifscCodeController,
            InputType.text,
            (v) => Validators.validateEmpty(v, "IFSC"),
          ),
          dropdownInput("Payment Terms", [
            "Prepaid",
            "Postpaid",
            "Weekly",
          ], (v) => status = v ?? ''),
          textInput(
            "GST Number / Tax ID",
            "Enter GST/Tax ID",
            Icons.business_center,
            (v) => gstNumber = v,
            gstNumberController,
            InputType.text,
            null,
          ),
        ],
      ),
    ),

    // Step 6 - Preview
    previewStep(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.whiteColor,
      appBar: AppBar(
        title: const Text("Register Water Vendor"),
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
            padding: const EdgeInsets.all(16),
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
