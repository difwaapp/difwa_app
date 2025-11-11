import 'dart:io';

import 'package:difwa_app/config/theme/app_color.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/controller/admin_controller/vendors_controller.dart';
import 'package:difwa_app/models/stores_models/store_new_modal.dart';
import 'package:difwa_app/screens/stores_screens/store_not_verified_page.dart';
import 'package:difwa_app/utils/location_helper.dart';
import 'package:difwa_app/utils/validators.dart';
import 'package:difwa_app/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

import '../../widgets/custom_button.dart';

class VendorMultiStepForm extends StatefulWidget {
  const VendorMultiStepForm({super.key});

  @override
  State<VendorMultiStepForm> createState() => _VendorMultiStepFormState();
}

class _VendorMultiStepFormState extends State<VendorMultiStepForm> {
  final PageController _controller = PageController();
  final VendorsController controller = Get.put(VendorsController());
  final _formKey = GlobalKey<FormState>();
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

  Map<String, String> imageUrl = {};
  Map<String, bool> uploadingStatus = {
    "Aadhaar Card": false,
    "PAN Card": false,
    "Passport Photo": false,
    "Business License": false,
    "Water Quality Certificate": false,
    "Identity Proof": false,
    "Bank Document": false,
    "Business Images": false,
  };
  int _currentStep = 0;
  bool isLoading = false;
  List<XFile?> selectedImages = [];
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

  Future<void> fetchLocation() async {
    print("Picking location...");

    Position? position = await LocationHelper.getCurrentLocation();
    print("Picked location... $position");

    if (position != null) {
      try {
        // Fetch placemarks from coordinates
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        // Filter out only those placemarks which have valid address details
        placemarks = placemarks
            .where((place) =>
                place.street != null &&
                place.locality != null &&
                place.administrativeArea != null)
            .toList();

        print("Filtered Placemarks: $placemarks");

        if (placemarks.isNotEmpty) {
          // Take the most complete one
          final Placemark placemark = placemarks.first;

          print("Selected Placemark: ${placemark.administrativeArea}");

          setState(() {
            // Update UI with the location information
            bussinessNameController.text = [
              placemark.name ?? '', // House or building name
              placemark.thoroughfare ?? '', // Street/Road name
              placemark.subLocality ?? '', // Area/Colony
              placemark.locality ?? '' // City
            ].where((e) => e.isNotEmpty).join(', ');

            areaCityController.text = [
              placemark.subLocality ?? '', // Landmark
              placemark.locality ?? '', // City
              placemark.postalCode ?? '', // Zip Code
              placemark.country ?? '' // Country
            ].where((e) => e.isNotEmpty).join(', ');

            stateController.text = placemark.administrativeArea ?? '';
            postalCodeController.text = placemark.postalCode ?? '';
          });
        } else {
          print("No valid placemarks found.");
          setState(() {
            locationDetails = "No address information available.";
          });
        }
      } catch (e) {
        print("Error fetching placemarks: $e");
        setState(() {
          locationDetails = "Error fetching address.";
        });
      }
    } else {
      print("Location not available.");
      setState(() {
        locationDetails = "Location not available.";
      });
    }
  }

  void nextStep() {
    if (_formKeys[_currentStep].currentState?.validate() ?? false) {
      if (_currentStep < 5) {
        setState(() => _currentStep++);
        _controller.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.ease);
      }
    } else {
      Get.snackbar(
        'Error',
        'Please fill the required fields in this step.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _controller.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  Widget stepHeader(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      );

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
                controller: vendorNameController..text = vendorName,
                hint: "Enter Vendor Name",
                label: "Vendor Name",
                icon: Icons.person,
                validator: (value) =>
                    Validators.validateEmpty(value, "Vendor Name"),
                onChanged: (value) {
                  vendorName = value;
                },
                inputType: InputType.text,
              ),
              const SizedBox(height: 20),
              CommonTextField(
                controller: bussinessNameController..text = bussinessName,
                hint: "Business Name",
                label: "Business Name",
                icon: Icons.business,
                onChanged: (value) => bussinessName = value,
                validator: (value) =>
                    Validators.validateEmpty(value, "Business Name"),
                inputType: InputType.text,
              ),
              const SizedBox(height: 20),
              CommonTextField(
                controller: contactPersonController..text = contactPerson,
                hint: "Contact Person Name",
                icon: Icons.person,
                onChanged: (value) => contactPerson = value,
                inputType: InputType.text,
                validator: (value) =>
                    Validators.validateEmpty(value, "Contact Person Name"),
              ),
              const SizedBox(height: 20),
              CommonTextField(
                controller: phoneNumberController..text = phoneNumber,
                hint: "Phone Number",
                icon: Icons.phone,
                onChanged: (value) => phoneNumber = value,
                validator: (value) =>
                    Validators.validateEmpty(value, "Phone Number"),
                inputType: InputType.phone,
              ),
              const SizedBox(height: 20),
              CommonTextField(
                controller: emailController..text = email,
                hint: "Email",
                icon: Icons.email,
                onChanged: (value) => email = value,
                inputType: InputType.email,
                validator: (value) => Validators.validateEmpty(value, "Email"),
              ),
              // const SizedBox(height: 20),
              // dropdownInput(
              //     "Vendor Type",
              //     ["Bottled", "Tanker", "RO", "Mineral"],
              //     (value) => vendorType = value ?? ''),
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
                  Expanded(
                    child: stepHeader("Location Details"),
                  ),
                  SizedBox(width: 10),
                  // Expanded(
                  //   child: GestureDetector(
                  //     onTap: fetchLocation,
                  //     child: Container(
                  //       padding: EdgeInsets.all(8),
                  //       decoration: BoxDecoration(
                  //         border: Border.all(color: AppColors.inputfield),
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //       child: Row(
                  //         children: const [
                  //           Icon(Icons.location_on,
                  //               color: AppColors.inputfield),
                  //           SizedBox(width: 10),
                  //           Text("Use my location"),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              textInput(
                  "Business Address",
                  "Enter address",
                  Icons.location_on,
                  (value) => businessAddress = value,
                  businessAddressController..text = businessAddress,
                  InputType.address,
                  null),
              textInput(
                "Area/City",
                "Enter area or city",
                Icons.location_city,
                (value) => areaCity = value,
                areaCityController..text = areaCity,
                InputType.text,
                null,
              ),
              textInput(
                "PIN/ZIP Code",
                "Enter postal code",
                Icons.pin,
                (value) => postalCode = value,
                postalCodeController..text = postalCode,
                InputType.pin,
                (value) => Validators.validateEmpty(value, "Business Address"),
              ),
              textInput(
                "State/Province",
                "Enter state",
                Icons.location_on,
                (value) => state = value,
                stateController..text = state,
                InputType.text,
                (value) => Validators.validateEmpty(value, "Business Address"),
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
                  (value) => waterType = value ?? '',
                  validator: (value) => Validators.validateEmpty(
                      value, "Type of Water Supplied")),
              textInput(
                "Capacity Options",
                "e.g. 20L, 500L, 1000L",
                Icons.filter_1,
                (value) => capacityOptions = value,
                capacityOptionsController..text = capacityOptions,
                InputType.text,
                null,
              ),
              textInput(
                "Daily Supply Capacity (in Litres)",
                "e.g. 2000",
                Icons.local_drink,
                (value) => dailySupply = value,
                dailySupplyController..text = dailySupply,
                InputType.text,
                null,
              ),
              textInput(
                "Delivery Area Covered",
                "Enter area",
                Icons.map,
                (value) => deliveryArea = value,
                deliveryAreaController..text = deliveryArea,
                InputType.text,
                null,
              ),
              textInput(
                "Delivery Timings",
                "e.g. 6 AM - 8 PM",
                Icons.access_time,
                (value) => deliveryTimings = value,
                deliveryTimingsController..text = deliveryTimings,
                InputType.text,
                null,
              ),
            ],
          ),
        ),

        // Step 4 - KYC / Documents
        Form(
          key: _formKeys[3],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              stepHeader("KYC / Documents"),
              uploadCard(
                "Aadhaar Card",
                () => pickFile("Aadhaar Card"),
                aadhaarCardImage,
                imageUrl["aadharImg"],
                isUploading: uploadingStatus["Aadhaar Card"] ?? false,
                validator: (value) =>
                    aadhaarCardImage == null && imageUrl["aadharImg"] == null
                        ? "Aadhaar Card is required"
                        : null,
              ),
              uploadCard(
                "PAN Card",
                () => pickFile("PAN Card"),
                panCardImage,
                imageUrl["panImg"],
                isUploading: uploadingStatus["PAN Card"] ?? false,
                validator: (value) =>
                    aadhaarCardImage == null && imageUrl["aadharImg"] == null
                        ? "Aadhaar Card is required"
                        : null,
              ),
              uploadCard(
                "Passport-size Photo",
                () => pickFile("Passport Photo"),
                passportPhotoImage,
                imageUrl["passportImg"],
                isUploading: uploadingStatus["Passport Photo"] ?? false,
                validator: (value) =>
                    aadhaarCardImage == null && imageUrl["aadharImg"] == null
                        ? "Aadhaar Card is required"
                        : null,
              ),
              uploadCard(
                "Business License",
                () => pickFile("Business License"),
                businessLicenseImage,
                imageUrl["businessLicenseImg"],
                isUploading: uploadingStatus["Business License"] ?? false,
                validator: (value) =>
                    aadhaarCardImage == null && imageUrl["aadharImg"] == null
                        ? "Aadhaar Card is required"
                        : null,
              ),
              uploadCard(
                "Water Quality Certificate",
                () => pickFile("Water Quality Certificate"),
                waterQualityCertificateImage,
                imageUrl["waterQualityCertificateImg"],
                isUploading:
                    uploadingStatus["Water Quality Certificate"] ?? false,
              ),
              uploadCard(
                "Identity Proof",
                () => pickFile("Identity Proof"),
                identityProofImage,
                imageUrl["IdentityProofImg"],
                isUploading: uploadingStatus["Identity Proof"] ?? false,
              ),
              uploadCard(
                "Bank Passbook or Cancelled Cheque",
                () => pickFile("Bank Document"),
                bankDocumentImage,
                imageUrl["bankDocumentImg"],
                isUploading: uploadingStatus["Bank Document"] ?? false,
                validator: (value) =>
                    aadhaarCardImage == null && imageUrl["aadharImg"] == null
                        ? "Aadhaar Card is required"
                        : null,
              ),
              uploadCard(
                "Business Images",
                () => pickBusinessImages(),
                businessImages.isEmpty ? null : businessImages[0],
                uploadedUrls.isEmpty ? null : uploadedUrls[0],
                isUploading: uploadingStatus["Business Images"] ?? false,
              ),
              displayBusinessImages(),
            ],
          ),
        ),

        // Step 5 - Financial Info
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
                (value) => bankName = value,
                bankNameController..text = bankName,
                InputType.text,
                (value) => Validators.validateEmpty(value, "Bank Name"),
              ),
              textInput(
                "Account Number",
                "Enter account number",
                Icons.account_box,
                (value) => accountNumber = value,
                accountNumberController..text = accountNumber,
                InputType.text,
                (value) => Validators.validateEmpty(value, "Bank Name"),
              ),
              textInput(
                "UPI ID",
                "Enter UPI ID",
                Icons.account_box,
                (value) => upiId = value,
                upiIdController..text = upiId,
                InputType.text,
                (value) => Validators.validateEmpty(value, "Bank Name"),
              ),
              textInput(
                "IFSC/SWIFT Code",
                "Enter IFSC/SWIFT",
                Icons.code,
                (value) => ifscCode = value,
                ifscCodeController..text = ifscCode,
                InputType.text,
                (value) => Validators.validateEmpty(value, "Bank Name"),
              ),
              dropdownInput("Payment Terms", ["Prepaid", "Postpaid", "Weekly"],
                  (value) => status = value ?? ''),
              textInput(
                "GST Number / Tax ID",
                "Enter GST/Tax ID",
                Icons.business_center,
                (value) => gstNumber = value,
                gstNumberController..text = gstNumber,
                InputType.text,
                null,
              ),
            ],
          ),
        ),

        // Step 6 - Preview
        previewStep(),
      ];

  InputDecoration inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
            validator: validator != null ? (value) => validator(value) : null,
            onChanged: onChanged,
            inputType: type,
          ),
        ],
      ),
    );
  }

  Widget dropdownInput(
      String label, List<String> items, Function(String?) onChanged,
      {String? Function(String?)? validator}) {
    String? selectedValue;
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
              selectedValue = value;
              onChanged(value);
            },
          ),
        ],
      ),
    );
  }

  Widget uploadCard(String label, Function() onTap, XFile? image, String? url,
      {bool isUploading = false, FormFieldValidator<dynamic>? validator}) {
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
                    : url != null && url.isNotEmpty
                        ? Image.network(
                            url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 100,
                            errorBuilder: (context, error, stackTrace) => Text(
                              "Failed to load $label",
                              style: const TextStyle(color: Colors.red),
                            ),
                          )
                        : image != null
                            ? Image.file(
                                File(image.path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 100,
                                errorBuilder: (context, error, stackTrace) =>
                                    Text(
                                  "Failed to load $label",
                                  style: const TextStyle(color: Colors.red),
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

  Widget _imagePreviewItem(String label, XFile? image) {
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
              : Image.file(
                  File(image.path),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
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

  Future<void> pickBusinessVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedVideo =
        await picker.pickVideo(source: ImageSource.gallery);

    if (pickedVideo != null) {
      setState(() {
        businessVideo = pickedVideo;
      });
    }
  }

  Future<void> pickBusinessImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        businessImages = pickedFiles;
        uploadingStatus["Business Images"] = true;
      });
      try {
        List<String> urls = [];
        for (var image in pickedFiles) {
          String url = await uploadImage(File(image.path), "Business Images");
          if (url.isNotEmpty) {
            urls.add(url);
          }
        }
        setState(() {
          uploadedUrls = urls;
          businessImages = [];
          uploadingStatus["Business Images"] = false;
          imageUrl["businessImages"] = urls.join(',');
        });
      } catch (e) {
        setState(() {
          uploadingStatus["Business Images"] = false;
        });
        Get.snackbar('Error', 'Failed to upload business images: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<void> uploadImagesOneByOne(
      List<XFile?> images, String documentType) async {
    for (var image in images) {
      if (image != null) {
        String url = await uploadImage(File(image.path), documentType);
        uploadedUrls.add(url);
      }
    }
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
              return Image.network(
                uploadedUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Text(
                  "Failed to load image",
                  style: TextStyle(color: Colors.red),
                ),
              );
            },
          );
  }

  Future<String> uploadImage(File image, String documentType) async {
    String url = await controller.uploadImage(image, documentType);
    return url;
  }

  Future<void> pickFile(String documentType) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (documentType == "Aadhaar Card") {
          aadhaarCardImage = pickedFile;
        } else if (documentType == "PAN Card") {
          panCardImage = pickedFile;
        } else if (documentType == "Passport Photo") {
          passportPhotoImage = pickedFile;
        } else if (documentType == "Business License") {
          businessLicenseImage = pickedFile;
        } else if (documentType == "Water Quality Certificate") {
          waterQualityCertificateImage = pickedFile;
        } else if (documentType == "Identity Proof") {
          identityProofImage = pickedFile;
        } else if (documentType == "Bank Document") {
          bankDocumentImage = pickedFile;
        }
        uploadingStatus[documentType] = true;
      });

      try {
        String url = await uploadImage(File(pickedFile.path), documentType);
        setState(() {
          if (documentType == "Aadhaar Card") {
            imageUrl["aadharImg"] = url;
            aadhaarCardImage = null; // Clear local image after upload
          } else if (documentType == "PAN Card") {
            imageUrl["panImg"] = url;
            panCardImage = null;
          } else if (documentType == "Passport Photo") {
            imageUrl["passportImg"] = url;
            passportPhotoImage = null;
          } else if (documentType == "Business License") {
            imageUrl["businessLicenseImg"] = url;
            businessLicenseImage = null;
          } else if (documentType == "Water Quality Certificate") {
            imageUrl["waterQualityCertificateImg"] = url;
            waterQualityCertificateImage = null;
          } else if (documentType == "Identity Proof") {
            imageUrl["IdentityProofImg"] = url;
            identityProofImage = null;
          } else if (documentType == "Bank Document") {
            imageUrl["bankDocumentImg"] = url;
            bankDocumentImage = null;
          }
          uploadingStatus[documentType] = false;
        });
      } catch (e) {
        setState(() {
          uploadingStatus[documentType] = false;
        });
        Get.snackbar('Error', 'Failed to upload $documentType: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Widget _previewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label : ",
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.whiteColor,
      appBar: AppBar(
        title: const Text("Register Water Vendor"),
        // backgroundColor: AppColors.logoprimary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              child: Column(
                children: [
                  Text("Step ${_currentStep + 1} of ${steps.length}",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    minHeight: 8,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8),
                    ),
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
                    .map((step) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: SingleChildScrollView(child: step),
                        ))
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
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: CustomButton(
                        text: _currentStep == steps.length - 1
                            ? "Finish"
                            : "Next",
                        height: 50,
                        width: double.infinity,
                        baseTextColor: Colors.white,
                        backgroundColor: Colors.orange,
                        onPressed: nextStep, // Fixed the callback
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget imagePreview() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: selectedImages.length,
      itemBuilder: (context, index) {
        return Image.file(
          File(selectedImages[index]!.path),
          fit: BoxFit.cover,
        );
      },
    );
  }

  Widget previewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        stepHeader("Preview & Submit"),
        _previewItem("Vendor Name", vendorName),
        _previewItem("Business Name", bussinessName),
        _previewItem("Contact Person", contactPerson),
        _previewItem("Phone Number", phoneNumber),
        _previewItem("Email", email),
        _previewItem("Vendor Type", vendorType),
        _previewItem("Business Address", businessAddress),
        _previewItem("Area/City", areaCity),
        _previewItem("PIN/ZIP Code", postalCode),
        _previewItem("State/Province", state),
        _previewItem("Water Type", waterType),
        _previewItem("Capacity Options", capacityOptions),
        _previewItem("Daily Supply Capacity", dailySupply),
        _previewItem("Delivery Area", deliveryArea),
        _previewItem("Delivery Timings", deliveryTimings),
        _previewItem("Bank Name", bankName),
        _previewItem("Account Number", accountNumber),
        _previewItem("IFSC Code", ifscCode),
        _previewItem("GST Number", gstNumber),
        _previewItem("Remarks", remarks),
        _previewItem("Status", status),
        const SizedBox(height: 20),
        _imagePreviewItem2("Aadhaar Card", imageUrl["aadharImg"]),
        _imagePreviewItem2("PAN Card", imageUrl["panImg"]),
        _imagePreviewItem2("Passport Photo", imageUrl["passportImg"]),
        _imagePreviewItem2("Business License", imageUrl["businessLicenseImg"]),
        _imagePreviewItem2("Water Quality Certificate",
            imageUrl["waterQualityCertificateImg"]),
        _imagePreviewItem2("Identity Proof", imageUrl["IdentityProofImg"]),
        _imagePreviewItem2("Bank Document", imageUrl["bankDocumentImg"]),
        const SizedBox(height: 20),
        const Text(
          "Business Images:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        displayBusinessImages(),
        const SizedBox(height: 20),
        CustomButton(
            text: isLoading ? "Loading..." : "Submit", onPressed: submitData)
      ],
    );
  }

  void submitData() async {
    VendorModal vendorModal = VendorModal(
        isVerified: false,
        uid: "",
        merchantId: "",
        earnings: 0,
        vendorName: vendorName,
        bussinessName: bussinessName,
        contactPerson: contactPerson,
        phoneNumber: phoneNumber,
        email: email,
        vendorType: vendorType,
        businessAddress: businessAddress,
        areaCity: areaCity,
        postalCode: postalCode,
        state: state,
        waterType: waterType,
        capacityOptions: capacityOptions,
        dailySupply: dailySupply,
        deliveryArea: deliveryArea,
        deliveryTimings: deliveryTimings,
        bankName: bankName,
        accountNumber: accountNumber,
        upiId: upiId,
        ifscCode: ifscCode,
        gstNumber: gstNumber,
        remarks: remarks,
        status: status,
        images: imageUrl);

    setState(() => isLoading = true);
    bool isSuccess = await controller.submitForm2(imageUrl, vendorModal);
    setState(() => isLoading = false);
    if (isSuccess) {
      Get.offAll(() => const StoreNotVerifiedPage());
    } else {
      Get.snackbar('Error', 'Failed to create the store. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
