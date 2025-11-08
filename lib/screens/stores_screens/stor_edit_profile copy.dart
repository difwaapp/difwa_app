// import 'dart:io';
// import 'package:difwa/controller/admin_controller/add_items_controller.dart';
// import 'package:difwa/utils/theme_constant.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:difwa/controller/admin_controller/vendors_controller.dart';
// import 'package:difwa/models/stores_models/store_new_modal.dart';

// class EditVendorDetailsScreen extends StatefulWidget {
//   final VendorModal? vendorModal;

//   const EditVendorDetailsScreen({Key? key, this.vendorModal}) : super(key: key);

//   @override
//   _EditVendorDetailsScreenState createState() =>
//       _EditVendorDetailsScreenState();
// }

// class _EditVendorDetailsScreenState extends State<EditVendorDetailsScreen> {
//   final VendorsController controller = Get.find<VendorsController>();
//   final emailController = TextEditingController();
//   final TextEditingController vendorNameController = TextEditingController();
//   final TextEditingController bussinessNameController = TextEditingController();
//   final TextEditingController contactPersonController = TextEditingController();
//   final TextEditingController phoneNumberController = TextEditingController();
//   final TextEditingController vendorTypeController = TextEditingController();

//   bool isDataFetched = false;
//   int currentStep = 0;
//   Map<String, String> images = {};
//   final ImagePicker _picker = ImagePicker();

//   // Custom color scheme
//   static const Color primaryRed =
//       ThemeConstants.primaryColor; // Red primary color
//   static const Color accentRed = ThemeConstants.primaryColor; // Red accent
//   static const Color backgroundLight =
//       Color(0xFFFFF5F5); // Light red background
//   static const Color textPrimary = Color(0xFF212121); // Dark text
//   static const Color textSecondary = Color(0xFF757575); // Grey text
//   static const Color borderLight = Color(0xFFE0E0E0); // Light grey border

//   @override
//   void initState() {
//     super.initState();
//     fetchVendorData();
//   }

//   // Fetch vendor data
//   Future<void> fetchVendorData() async {
//     if (isDataFetched || !mounted) return;

//     try {
//       final vendor = await controller.fetchStoreData();
//       if (vendor?.images != null) {
//         vendor!.images.forEach((key, value) {
//           print('Image URL: $value');
//         });
//       }

//       if (vendor != null && mounted) {
//         setState(() {
//           controller.vendorNameController.text = vendor.vendorName ?? '';
//           controller.bussinessNameController.text = vendor.bussinessName ?? '';
//           controller.emailController.text = vendor.email ?? '';
//           controller.phoneNumberController.text = vendor.phoneNumber ?? '';
//           controller.contactPersonController.text = vendor.contactPerson ?? '';
//           controller.businessAddressController.text =
//               vendor.businessAddress ?? '';
//           controller.areaCityController.text = vendor.areaCity ?? '';
//           controller.postalCodeController.text = vendor.postalCode ?? '';
//           controller.stateController.text = vendor.state ?? '';
//           controller.waterTypeController.text = vendor.waterType ?? '';
//           controller.capacityOptionsController.text =
//               vendor.capacityOptions ?? '';
//           controller.dailySupplyController.text = vendor.dailySupply ?? '';
//           controller.deliveryAreaController.text = vendor.deliveryArea ?? '';
//           controller.deliveryTimingsController.text =
//               vendor.deliveryTimings ?? '';
//           controller.bankNameController.text = vendor.bankName ?? '';
//           controller.accountNumberController.text = vendor.accountNumber ?? '';
//           controller.upiIdController.text = vendor.upiId ?? '';
//           controller.ifscCodeController.text = vendor.ifscCode ?? '';
//           controller.gstNumberController.text = vendor.gstNumber ?? '';
//           controller.remarksController.text = vendor.remarks ?? '';
//           controller.statusController.text = vendor.status ?? '';
//           images = Map<String, String>.from(vendor.images);

//           isDataFetched = true;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         Get.snackbar('Error', 'Failed to fetch vendor data: $e',
//             snackPosition: SnackPosition.BOTTOM, backgroundColor: accentRed);
//       }
//     }
//   }

//   // Image upload function using VendorsController
//   Future<void> _pickAndUploadImage(String imageKey, String imageName) async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 800,
//         maxHeight: 800,
//         imageQuality: 85,
//       );

//       if (pickedFile != null) {
//         File imageFile = File(pickedFile.path);
//         String fileName =
//             '${imageKey}_${DateTime.now().millisecondsSinceEpoch}.jpg';
//         String uploadedImageUrl =
//             await controller.uploadImage(imageFile, fileName);

//         setState(() {
//           images[imageKey] = uploadedImageUrl;
//         });
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to upload $imageName: $e',
//           snackPosition: SnackPosition.BOTTOM, backgroundColor: accentRed);
//     }
//   }

//   // List of steps for the Stepper widget
//   List<Step> get steps => [
//         Step(
//           title: const Text('Vendor Info', style: TextStyle(color: primaryRed)),
//           content: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildTextField(controller.vendorNameController, 'Vendor Name'),
//               _buildTextField(
//                   controller.bussinessNameController, 'Business Name'),
//               _buildTextField(controller.emailController, 'Email'),
//               _buildTextField(controller.phoneNumberController, 'Phone Number'),
//             ],
//           ),
//           isActive: currentStep >= 0,
//           state: currentStep > 0 ? StepState.complete : StepState.indexed,
//         ),
//         Step(
//           title: const Text('Address & Details',
//               style: TextStyle(color: primaryRed)),
//           content: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildTextField(
//                   controller.businessAddressController, 'Business Address'),
//               _buildTextField(controller.areaCityController, 'Area/City'),
//               _buildTextField(controller.postalCodeController, 'Postal Code'),
//               _buildTextField(controller.stateController, 'State'),
//             ],
//           ),
//           isActive: currentStep >= 1,
//           state: currentStep > 1 ? StepState.complete : StepState.indexed,
//         ),
//         Step(
//           title: const Text('Water & Delivery',
//               style: TextStyle(color: primaryRed)),
//           content: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildTextField(controller.waterTypeController, 'Water Type'),
//               _buildTextField(
//                   controller.capacityOptionsController, 'Capacity Options'),
//               _buildTextField(controller.dailySupplyController, 'Daily Supply'),
//               _buildTextField(
//                   controller.deliveryAreaController, 'Delivery Area'),
//               _buildTextField(
//                   controller.deliveryTimingsController, 'Delivery Timings'),
//             ],
//           ),
//           isActive: currentStep >= 2,
//           state: currentStep > 2 ? StepState.complete : StepState.indexed,
//         ),
//         Step(
//           title:
//               const Text('Bank Details', style: TextStyle(color: primaryRed)),
//           content: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildTextField(controller.bankNameController, 'Bank Name'),
//               _buildTextField(
//                   controller.accountNumberController, 'Account Number'),
//               _buildTextField(controller.upiIdController, 'UPI ID'),
//               _buildTextField(controller.ifscCodeController, 'IFSC Code'),
//             ],
//           ),
//           isActive: currentStep >= 3,
//           state: currentStep > 3 ? StepState.complete : StepState.indexed,
//         ),
//         Step(
//           title: const Text('Others', style: TextStyle(color: primaryRed)),
//           content: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildTextField(controller.gstNumberController, 'GST Number'),
//               _buildTextField(controller.remarksController, 'Remarks'),
//               _buildTextField(controller.statusController, 'Status'),
//               const SizedBox(height: 16),
//               const Text(
//                 'Upload Images',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: primaryRed,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               _buildImageUploadSection('aadharImg', 'Aadhaar Card'),
//               const SizedBox(height: 16),
//               _buildImageUploadSection('panImg', 'PAN Card'),
//               const SizedBox(height: 16),
//               _buildImageUploadSection('bankDocumentImg', 'Bank Document'),
//               const SizedBox(height: 16),
//               _buildImageUploadSection('passportImg', 'Passport Image'),
//               const SizedBox(height: 16),
//               _buildImageUploadSection(
//                   'waterQualityCertificateImg', 'Water Quality Certificates'),
//               const SizedBox(height: 16),
//               _buildImageUploadSection('IdentityProofImg', 'Identity Proof '),
//               const SizedBox(height: 16),
//               _buildImageUploadSection('', 'Bussiness Images'),
//               const SizedBox(height: 16),
//               displayBusinessImages(),
//             ],
//           ),
//           isActive: currentStep >= 4,
//           state: currentStep == 4 ? StepState.indexed : StepState.complete,
//         ),
//       ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 245, 249, 255),
//       appBar: AppBar(
//         backgroundColor: primaryRed,
//         title: const Text(
//           'Edit Vendor Details',
//           style: TextStyle(color: Colors.white),
//         ),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Stepper(
//         steps: steps,
//         currentStep: currentStep,
//         onStepContinue: () {
//           if (currentStep < steps.length - 1) {
//             setState(() {
//               currentStep += 1;
//             });
//           } else {
//             try {
//               // Create a VendorModal with updated data including images
//               VendorModal updatedVendor = VendorModal(
//                 userId: widget.vendorModal?.userId ?? '',
//                 merchantId: widget.vendorModal?.merchantId ?? '',
//                 vendorName: controller.vendorNameController.text,
//                 bussinessName: controller.bussinessNameController.text,
//                 email: controller.emailController.text,
//                 phoneNumber: controller.phoneNumberController.text,
//                 contactPerson: controller.contactPersonController.text,
//                 businessAddress: controller.businessAddressController.text,
//                 areaCity: controller.areaCityController.text,
//                 postalCode: controller.postalCodeController.text,
//                 state: controller.stateController.text,
//                 waterType: controller.waterTypeController.text,
//                 capacityOptions: controller.capacityOptionsController.text,
//                 dailySupply: controller.dailySupplyController.text,
//                 deliveryArea: controller.deliveryAreaController.text,
//                 deliveryTimings: controller.deliveryTimingsController.text,
//                 bankName: controller.bankNameController.text,
//                 accountNumber: controller.accountNumberController.text,
//                 upiId: controller.upiIdController.text,
//                 ifscCode: controller.ifscCodeController.text,
//                 gstNumber: controller.gstNumberController.text,
//                 remarks: controller.remarksController.text,
//                 status: controller.statusController.text,
//                 vendorType: widget.vendorModal?.vendorType ?? 'isVendor',
//                 images: images,
//                 earnings: widget.vendorModal?.earnings ?? 0.0,
//               );
//               controller.editVendorDetails(modal: updatedVendor);
//             } catch (e) {
//               Get.snackbar('Error', 'Failed to update vendor details: $e',
//                   snackPosition: SnackPosition.BOTTOM,
//                   backgroundColor: accentRed);
//             }
//           }
//         },
//         onStepCancel: () {
//           if (currentStep > 0) {
//             setState(() {
//               currentStep -= 1;
//             });
//           }
//         },
//         onStepTapped: (index) {
//           setState(() {
//             currentStep = index;
//           });
//         },
//         type: StepperType.vertical,
//         physics: const ClampingScrollPhysics(),
//         elevation: 0,
//         connectorColor: MaterialStateProperty.all(primaryRed),
//         controlsBuilder: (context, details) {
//           return Row(
//             children: [
//               if (details.currentStep < steps.length - 1)
//                 ElevatedButton(
//                   onPressed: details.onStepContinue,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryRed,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text('Continue'),
//                 ),
//               if (details.currentStep == steps.length - 1)
//                 ElevatedButton(
//                   onPressed: details.onStepContinue,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: primaryRed,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text('Save'),
//                 ),
//               const SizedBox(width: 8),
//               if (details.currentStep > 0)
//                 TextButton(
//                   onPressed: details.onStepCancel,
//                   style: TextButton.styleFrom(
//                     foregroundColor: primaryRed,
//                   ),
//                   child: const Text('Back'),
//                 ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   // Helper method to build TextFormField widgets
//   Widget _buildTextField(TextEditingController controller, String label) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelStyle: TextStyle(
//             color: textSecondary,
//             fontWeight: FontWeight.w400,
//             fontSize: 16,
//           ),
//           hintStyle: TextStyle(
//             color: textSecondary,
//             fontWeight: FontWeight.w400,
//             fontSize: 14,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//           floatingLabelBehavior: FloatingLabelBehavior.always,
//           floatingLabelStyle: const TextStyle(
//             color: primaryRed,
//             fontWeight: FontWeight.w600,
//             fontSize: 16,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(
//               color: borderLight,
//               width: 1.5,
//             ),
//             borderRadius: BorderRadius.circular(16.0),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderSide: const BorderSide(
//               color: primaryRed,
//               width: 1.5,
//             ),
//             borderRadius: BorderRadius.circular(16.0),
//           ),
//           contentPadding:
//               const EdgeInsets.symmetric(vertical: 10, horizontal: 17),
//           labelText: label,
//           fillColor: Colors.white,
//           filled: true,
//         ),
//         style: const TextStyle(fontSize: 16, color: textPrimary),
//       ),
//     );
//   }

//   // Helper method to build image upload section
//   Widget _buildImageUploadSection(String imageKey, String imageName) {
//     String? imageUrl = images[imageKey];
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: Text(
//                 imageName,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: textPrimary,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () => _pickAndUploadImage(imageKey, imageName),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryRed,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text('Upload'),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         if (imageUrl != null && imageUrl.isNotEmpty)
//           _buildImageWidget(imageUrl, imageName),
//       ],
//     );
//   }

//   // Helper method to build image widget with error handling
//   Widget _buildImageWidget(String imageUrl, String imageName) {
//     if (imageUrl.isEmpty || !Uri.parse(imageUrl).hasAuthority) {
//       return SizedBox(
//         width: 100,
//         height: 100,
//         child: Center(child: Text('Invalid $imageName URL')),
//       );
//     }

//     return Column(
//       children: [
//         Image.network(
//           imageUrl,
//           width: 100,
//           height: 100,
//           fit: BoxFit.cover,
//           loadingBuilder: (context, child, loadingProgress) {
//             if (loadingProgress == null) return child;
//             return const SizedBox(
//               width: 100,
//               height: 100,
//               child:
//                   Center(child: CircularProgressIndicator(color: primaryRed)),
//             );
//           },
//           errorBuilder: (context, error, stackTrace) {
//             return SizedBox(
//               width: 100,
//               height: 100,
//               child: Center(child: Text('Failed to load $imageName')),
//             );
//           },
//         ),
//         const SizedBox(height: 8),
//         Text(
//           imageName,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: textPrimary,
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     // Do not dispose controllers here since they are managed by GetX
//     super.dispose();
//   }

//   Widget displayBusinessImages() {
//     List<String> businessImages = images["businessImages"]
//         .toString()
//         .split(',')
//         .map((url) => url.trim())
//         .toList();

//     return businessImages.isEmpty
//         ? const Text("No business images uploaded")
//         : GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               crossAxisSpacing: 8,
//               mainAxisSpacing: 8,
//             ),
//             itemCount: businessImages.length,
//             itemBuilder: (context, index) {
//               return Image.network(
//                 businessImages[index],
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) => const Text(
//                   "Failed to load image",
//                   style: TextStyle(color: Colors.red),
//                 ),
//               );
//             },
//           );
//   }
// }
