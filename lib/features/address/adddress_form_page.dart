import 'dart:async';
import 'package:country_picker/country_picker.dart';
import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/features/address/controller/address_controller.dart';
import 'package:difwa_app/models/Address.dart';
import 'package:difwa_app/utils/location_helper.dart';
import 'package:difwa_app/utils/validators.dart';
import 'package:difwa_app/widgets/FloorSelector.dart';
import 'package:difwa_app/widgets/custom_button.dart';
import 'package:difwa_app/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class AddressForm extends StatefulWidget {
  final Address address;
  final String flag;

  const AddressForm({super.key, required this.address, required this.flag});

  @override
  _AddressFormState createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  // Text Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _zipController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _floorController = TextEditingController();

  final AddressController addressController = AddressController();

  bool _isChecked = true;
  bool _isSubmitting = false;
  String selectedLocationType = "home";

  Country? selectedCountry;
  double? latitude;
  double? longitude;

  final _formKey = GlobalKey<FormState>();
  String? selectedFloor = "Ground";
  // ----------------------------------------------------------
  // INIT
  // ----------------------------------------------------------
  @override
  void initState() {
    super.initState();
    selectedFloor = widget.address.floor;
    _nameController.text = widget.address.name;
    _phoneController.text = widget.address.phone;
    _zipController.text = widget.address.zip;
    _stateController.text = widget.address.state;
    _cityController.text = widget.address.city;
    _streetController.text = widget.address.street;
    _floorController.text = widget.address.floor;
    selectedLocationType = widget.address.locationType;
    _isChecked = widget.address.saveAddress;

    latitude = widget.address.latitude;
    longitude = widget.address.longitude;

    if (widget.address.country.isNotEmpty) {
      selectedCountry = Country.tryParse(widget.address.country);
    }
  }

  // ----------------------------------------------------------
  // SAVE NEW ADDRESS
  // ----------------------------------------------------------
  Future<bool> saveAddress() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      List<Address> existingAddresses = await addressController
          .getAddressesStream()
          .first;

      bool isOnlyAddress = existingAddresses.isEmpty;

      final newAddress = Address(
        docId: "",
        uid: uid,
        name: _nameController.text,
        phone: _phoneController.text,
        street: _streetController.text,
        city: _cityController.text,
        state: _stateController.text,
        zip: _zipController.text,
        country: selectedCountry?.name ?? "",
        locationType: selectedLocationType,
        floor: _floorController.text,
        isSelected: isOnlyAddress,
        isDeleted: false,
        saveAddress: _isChecked,
        latitude: latitude,
        longitude: longitude,
      );

      await addressController.saveAddress(newAddress);
      return true;
    } catch (e) {
      print("Error saving address: $e");
      return false;
    }
  }

  // ----------------------------------------------------------
  // UPDATE ADDRESS
  // ----------------------------------------------------------
  Future<bool> updateAddress() async {
    try {
      final updatedAddress = Address(
        docId: widget.address.docId,
        uid: widget.address.uid,
        name: _nameController.text,
        phone: _phoneController.text,
        street: _streetController.text,
        city: _cityController.text,
        state: _stateController.text,
        zip: _zipController.text,
        country: selectedCountry?.name ?? "",
        locationType: selectedLocationType,
        floor: _floorController.text,
        isSelected: widget.address.isSelected,
        isDeleted: widget.address.isDeleted,
        saveAddress: _isChecked,
        latitude: latitude,
        longitude: longitude,
      );

      await addressController.updateAddress(updatedAddress);
      return true;
    } catch (e) {
      print("Error updating address: $e");
      return false;
    }
  }

  // ----------------------------------------------------------
  // FETCH CURRENT LOCATION
  // ----------------------------------------------------------
  Future<void> fetchLocation() async {
    Position? position = await LocationHelper.getCurrentLocation();

    if (position != null) {
      latitude = position.latitude;
      longitude = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude!,
        longitude!,
      );

      if (placemarks.isNotEmpty) {
        Placemark p = placemarks.first;

        setState(() {
          _streetController.text =
              "${p.subThoroughfare ?? ''} ${p.thoroughfare ?? ''}".trim();

          _cityController.text = p.locality ?? '';
          _stateController.text = p.administrativeArea ?? '';
          _zipController.text = p.postalCode ?? '';

          selectedCountry = Country.tryParse(p.country ?? '');
        });
      }
    }
  }

  // ----------------------------------------------------------
  // UI
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.whiteColor,
      appBar: AppBar(
        backgroundColor: appTheme.whiteColor,
        elevation: 0,
        title: Text(
          widget.flag == "isEdit" ? "Update Address" : "Save Address",
          style: TextStyleHelper.instance.body14BoldPoppins,
        ),
      ),

      // --------------------------------------------------------
      // BODY
      // --------------------------------------------------------
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // NAME
                  CommonTextField(
                    controller: _nameController,
                    label: "Full Name",
                    hint: "Full Name",
                    icon: Icons.person,
                    inputType: InputType.name,
                    validator: Validators.validateName,
                  ),
                  SizedBox(height: 20),

                  // PHONE
                  CommonTextField(
                    controller: _phoneController,
                    label: "Phone Number",
                    hint: "Phone Number",
                    icon: Icons.phone,
                    inputType: InputType.phone,
                    validator: Validators.validatePhone,
                  ),
                  SizedBox(height: 20),

                  // ZIP + LOCATION BUTTON
                  Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          controller: _zipController,
                          label: "Pincode",
                          hint: "Pincode",
                          icon: Icons.location_pin,
                          inputType: InputType.pin,
                          validator: Validators.validatePin,
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: fetchLocation,
                        child: Container(
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black54, width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.my_location, size: 22),
                              SizedBox(width: 10),
                              Text("Use my location"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // STATE + CITY
                  Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          controller: _stateController,
                          label: "State",
                          hint: "State",
                          icon: Icons.location_city,
                          validator: Validators.validateState,
                          inputType: InputType.text,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: CommonTextField(
                          controller: _cityController,
                          label: "City",
                          hint: "City",
                          icon: Icons.location_city,
                          validator: Validators.validateCity,
                          inputType: InputType.text,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        "Select Home Floor",
                        style: TextStyleHelper.instance.body14BoldPoppins,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // ➜ important
                    child: Row(
                      children: [
                        FloorSelector(
                          initial: selectedFloor!.isNotEmpty
                              ? selectedFloor
                              : null,
                          onChanged: (floor) {
                            setState(() => selectedFloor = floor);
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                  // STREET
                  CommonTextField(
                    controller: _streetController,
                    label: "House No / Street / Building",
                    hint: "House No / Street / Building",
                    icon: Icons.home,
                    validator: Validators.validateHouseNumberBuilding,
                    inputType: InputType.text,
                  ),
                  SizedBox(height: 20),

                  // LANDMARK
                  CommonTextField(
                    controller: _floorController,
                    label: "Road name, Area, Landmark",
                    hint: "Road name, Area, Landmark",
                    icon: Icons.map,
                    validator: Validators().validateLandMark,
                    inputType: InputType.text,
                  ),
                  SizedBox(height: 20),

                  // LOCATION TYPE
                  Row(
                    children: [
                      Text(
                        "Type of Address",
                        style: TextStyleHelper.instance.body14BoldPoppins,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  Row(
                    children: [
                      ChoiceChip(
                        label: Text("Home"),
                        selected: selectedLocationType == "home",
                        onSelected: (v) => setState(() {
                          selectedLocationType = "home";
                        }),
                      ),
                      SizedBox(width: 10),
                      ChoiceChip(
                        label: Text("Work"),
                        selected: selectedLocationType == "work",
                        onSelected: (v) => setState(() {
                          selectedLocationType = "work";
                        }),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // SAVE CHECKBOX
                  Row(
                    children: [
                      Checkbox(
                        value: _isChecked,
                        onChanged: (v) {
                          setState(() {
                            _isChecked = v!;
                          });
                        },
                      ),
                      Text("Save shipping address"),
                    ],
                  ),

                  SizedBox(height: 20),

                  // SUBMIT BUTTON
                  CustomButton(
                    text: widget.flag == "isEdit"
                        ? "UPDATE ADDRESS"
                        : "SAVE ADDRESS",
                    isLoading: _isSubmitting,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isSubmitting = true);
                        bool success = widget.flag == "isEdit"
                            ? await updateAddress()
                            : await saveAddress();

                        setState(() => _isSubmitting = false);

                        if (success) {
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Something went wrong")),
                          );
                        }
                      }
                    },
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
