import 'package:country_code_picker/country_code_picker.dart';
import 'package:difwa_app/config/theme/app_color.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum InputType { phone, email, name, text, address, visiblePassword, pin }

class CommonTextField extends StatefulWidget {
  final InputType inputType;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final String? label;
  final String? hint;
  final bool readOnly;
  final bool autofocus;
  final double? borderRadius;
  final double? height;
  final Color? borderColor;
  final String? prefixText;
  final IconData? icon;
  final IconData? suffixIcon;
  final String? Function(String?)? validator; // Accept a validator function
  final bool showCountryPicker;
  const CommonTextField({
    super.key,
    required this.inputType,
    required this.controller,
    this.onChanged,
    this.label,
    this.hint,
    this.readOnly = false,
    this.autofocus = false,
    this.borderRadius,
    this.height,
    this.borderColor,
    this.icon,
    this.prefixText,
    this.suffixIcon,
    this.validator,
    this.showCountryPicker = false,
  });

  @override
  _CommonTextFieldState createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  late List<TextInputFormatter> _inputFormatters;
  late TextInputType _keyboardType;
  final FocusNode _focusNode = FocusNode(); // ✅ Direct initialization
  bool _obscureText = true;
  String _selectedCountryCode = '+91';
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {}); // Rebuild UI when focus state changes
    });
    _setInputType();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _setInputType() {
    _inputFormatters = []; // Ensure initialization
    switch (widget.inputType) {
      case InputType.phone:
        _keyboardType = TextInputType.phone;
        _inputFormatters = [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ];
        break;
      case InputType.email:
        _keyboardType = TextInputType.emailAddress;
        break;
      case InputType.name:
        _keyboardType = TextInputType.name;
        _inputFormatters = [
          FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]")),
        ];
        break;
      case InputType.text:
        _keyboardType = TextInputType.text;

        break;
      case InputType.address:
        _keyboardType = TextInputType.streetAddress;
        break;
      case InputType.visiblePassword:
        _keyboardType = TextInputType.text;
        break;

      case InputType.pin:
        _keyboardType = TextInputType.number;
        _inputFormatters = [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ];
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: widget.autofocus,
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: _keyboardType,
      inputFormatters: _inputFormatters,
      readOnly: widget.readOnly,
      onChanged: widget.onChanged,
      obscureText:
          widget.inputType == InputType.visiblePassword ? _obscureText : false,
      validator: widget.validator, // Apply validation function
      style: TextStyle(
        color: widget.readOnly ? Colors.grey : Colors.black,
        letterSpacing: 1.5,
      ),
      decoration: InputDecoration(
        prefixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null)
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: Icon(
                  widget.icon,
                  color: _focusNode.hasFocus ? Colors.black : Colors.grey,
                ),
              ),
            if (widget.showCountryPicker) // ✅ Show Country Picker
              Container(
                //  width: 45,
                //  decoration: BoxDecoration(
                //   color: Colors.red
                //  ),
                child: CountryCodePicker(
                  onChanged: (code) {
                    setState(() {
                      _selectedCountryCode = code.dialCode!;
                    });
                  },
                  initialSelection: _selectedCountryCode,
                  favorite: const ['+91'],
                  showCountryOnly: false,
                  showOnlyCountryWhenClosed: false,
                  // dialogTextStyle: TextStyle(color: Colors.deepOrange),
                  // textStyle: TextStyle(color: Colors.amber),
                  showFlag: false,
                  showFlagDialog: true,
                  margin: EdgeInsets.all(0),
                  padding: EdgeInsets.all(0),
                ),
              ),
            // if (widget.prefixText != null)
            //   Text(
            //     widget.prefixText!,
            //     style: TextStyle(
            //       color: Colors.black,
            //       fontWeight: FontWeight.bold,
            //       fontSize: 16,
            //     ),
            //   ),
          ],
        ),

        //  widget.icon != null
        //     ? Icon(
        //         widget.icon,
        //         color: _focusNode.hasFocus
        //             ? Colors.black
        //             : Colors.grey, // Change color on focus
        //       )
        //     : null,
        suffixIcon: widget.inputType == InputType.visiblePassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: appTheme.blackColor,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : (widget.suffixIcon != null
                ? Icon(widget.suffixIcon, color:appTheme.gray100)
                : null),
        labelText: widget.label,
        hintText: widget.hint,
        labelStyle: TextStyle(
          color: widget.readOnly ? Colors.grey : appTheme.gray100,
          fontWeight: FontWeight.w200,
          fontSize: 16,
        ),
        hintStyle: TextStyle(
          color: widget.readOnly ? Colors.grey : Colors.grey,
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 12.0),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelStyle: TextStyle(
          color: widget.readOnly ?appTheme.blackColor : appTheme.gray100,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.borderColor ?? Colors.grey[200]!,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 16.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: appTheme.blackColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 16.0),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 17),
      ),
    );
  }
}
