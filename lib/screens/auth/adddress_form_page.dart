import 'dart:async';
import 'package:country_picker/country_picker.dart';
import 'package:difwa_app/config/app_color.dart';
import 'package:difwa_app/controller/address_controller.dart';
import 'package:difwa_app/models/address_model.dart';
import 'package:difwa_app/utils/app__text_style.dart';
import 'package:difwa_app/utils/location_helper.dart';
import 'package:difwa_app/utils/theme_constant.dart';
import 'package:difwa_app/utils/validators.dart';
import 'package:difwa_app/widgets/RoleSelector.dart';
import 'package:difwa_app/widgets/custom_input_field.dart';
import 'package:difwa_app/widgets/subscribe_button_component.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class AddressForm extends StatefulWidget {
  final Address address;
  final String flag;
  const AddressForm({
    super.key,
    required this.address,
    required this.flag,
  });

  @override
  _AddressFormState createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();

  final AddressController addressController = AddressController();

  bool _isChecked = false;
  bool _isdeleted = false;
  bool _isSubmitting = false;
  String selectedLocationType = "home";
  final bool _isSelected = false;

  Country? selectedCountry;

  final _formKey = GlobalKey<FormState>();

  String locationDetails = "Fetching location...";

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.address.name;
    _phoneController.text = widget.address.phone;
    _zipController.text = widget.address.zip;
    _stateController.text = widget.address.state;
    _cityController.text = widget.address.city;
    _streetController.text = widget.address.street;
    _floorController.text = widget.address.floor;
    _isChecked = widget.address.saveAddress;
    _isdeleted = widget.address.isDeleted;
    selectedLocationType = widget.address.locationType;
  }

  Future<bool> saveAddress() async {
    try {
      String userId = "";
      List<Address> existingAddresses =
          await addressController.getAddresses().first;

      bool isOnlyAddress = existingAddresses.isEmpty;

      await addressController.saveAddress(
        Address(
          name: _nameController.text,
          phone: _phoneController.text,
          zip: _zipController.text,
          state: _stateController.text,
          city: _cityController.text,
          street: _streetController.text,
          floor: _floorController.text,
          saveAddress: _isChecked,
          userId: userId,
          isDeleted: _isdeleted,
          isSelected: isOnlyAddress,
          docId: "",
          locationType: selectedLocationType,
          country: selectedCountry?.name ?? '',
        ),
      );

      return true;
    } catch (e) {
      print("Error saving address: $e");
      return false;
    }
  }

  Future<bool> updateAddress() async {
    try {
      await addressController.updateAddress(
        Address(
          name: _nameController.text,
          phone: _phoneController.text,
          zip: _zipController.text,
          state: _stateController.text,
          city: _cityController.text,
          street: _streetController.text,
          floor: _floorController.text,
          saveAddress: _isChecked,
          userId: "", // Provide actual userId
          isDeleted: _isdeleted,
          isSelected: _isSelected,
          docId: widget.address.docId,
          country: selectedCountry?.name ?? '',
          locationType: selectedLocationType,
        ),
      );
      return true;
    } catch (e) {
      print("Error updating address: $e");
      return false;
    }
  }

  Future<void> fetchLocation() async {
    Position? position = await LocationHelper.getCurrentLocation();

    if (position != null) {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark placemark = placemarks.first;

        setState(() {
          locationDetails =
              "Address: ${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.postalCode}, ${placemark.country}\n"
              "Lat: ${position.latitude}, Lng: ${position.longitude}";

          // Now assign to respective controllers
          _streetController.text = [
            placemark.subThoroughfare, // House no
            placemark.thoroughfare, // Street/road name
            placemark.subLocality, // Area/colony
            placemark.locality // City
          ].where((e) => e != null && e.trim().isNotEmpty).join(', ');

          // Put optional/extra info like landmark, floor, etc. into floor controller
          _floorController.text = [
            placemark.name, // Landmark
            placemark.administrativeArea, // State
            placemark.postalCode, // Zip
            placemark.country // Country
          ].where((e) => e != null && e.trim().isNotEmpty).join(', ');
          _cityController.text = placemark.locality ?? '';
          _stateController.text = placemark.administrativeArea ?? '';
          _zipController.text = placemark.postalCode ?? '';
          _floorController.text =
              ''; // If you want user input for floor manually
        });
      }
    } else {
      setState(() {
        locationDetails = "Location not available.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.whiteColor,
      appBar: AppBar(
        backgroundColor: ThemeConstants.whiteColor,
        title: Text(widget.flag != "isEdit" ? 'Save Address' : 'Update Address',
            style: AppTextStyle.Text18700),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CommonTextField(
                    controller: _nameController,
                    inputType: InputType.name,
                    label: 'Full Name',
                    hint: 'Full Name',
                    icon: Icons.person,
                    validator: Validators.validateName,
                  ),
                  SizedBox(height: 20),
                  CommonTextField(
                    controller: _phoneController,
                    inputType: InputType.phone,
                    label: 'Phone Number',
                    hint: 'Phone Number',
                    icon: Icons.phone,
                    validator: Validators.validatePhone,
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          icon: Icons.location_pin,
                          inputType: InputType.pin,
                          controller: _zipController,
                          label: 'Pincode',
                          hint: 'Pincode',
                          validator: Validators.validatePin,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: fetchLocation,
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.inputfield),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.location_on,
                                    color: AppColors.inputfield),
                                SizedBox(width: 10),
                                Text("Use my location"),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          icon: Icons.location_city,
                          inputType: InputType.name,
                          controller: _stateController,
                          label: 'State',
                          hint: 'State',
                          validator: Validators.validateState,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: CommonTextField(
                          icon: Icons.location_city,
                          inputType: InputType.name,
                          controller: _cityController,
                          label: 'City',
                          hint: 'City',
                          validator: Validators.validateCity,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  CommonTextField(
                    icon: Icons.home,
                    inputType: InputType.address,
                    controller: _streetController,
                    label: 'House No./Building Name',
                    hint: 'House No./Building Name',
                    validator: Validators.validateHouseNumberBuilding,
                  ),
                  SizedBox(height: 20),
                  CommonTextField(
                    icon: Icons.streetview,
                    inputType: InputType.address,
                    controller: _floorController,
                    label: 'Road name, Area, Landmark',
                    hint: 'Road name, Area, Landmark',
                    validator: Validators().validateLandMark,
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'Type of Address',
                        style: AppTextStyle.Text16700.copyWith(
                          color: AppColors.textBlack.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      LocationTypeSelector(
                        selected: selectedLocationType,
                        options: const ["home", "work"],
                        onChanged: (val) {
                          setState(() {
                            selectedLocationType = val;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: _isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            _isChecked = value!;
                          });
                        },
                        activeColor: AppColors.inputfield,
                        checkColor: AppColors.mywhite,
                      ),
                      Text(
                        'Save shipping address',
                        style: AppTextStyle.Text16700.copyWith(
                          color: AppColors.textBlack.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  SubscribeButtonComponent(
                    text: widget.flag != "isEdit"
                        ? 'SAVE ADDRESS'
                        : 'UPDATE ADDRESS',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isSubmitting = true;
                        });

                        bool success = widget.flag != "isEdit"
                            ? await saveAddress()
                            : await updateAddress();

                        setState(() {
                          _isSubmitting = false;
                        });

                        if (success) {
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Something went wrong")),
                          );
                        }
                      }
                    },
                    // isLoading: _isSubmitting,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
