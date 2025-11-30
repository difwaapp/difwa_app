// lib/screens/admin/add_item_screen.dart
import 'dart:io';

import 'package:difwa_app/controller/admin_controller/add_items_controller.dart';
import 'package:difwa_app/models/water_bottle_model.dart';
import 'package:difwa_app/utils/location_helper.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class AddItemScreen extends StatefulWidget {
  final WaterBottleModel? initialItem; // if not null -> edit mode

  const AddItemScreen({super.key, this.initialItem});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseController _controller = FirebaseController();

  final List<int> sizes = [10, 15, 18, 20];
  int? selectedSize;
  File? pickedImage;
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _filledPriceCtrl = TextEditingController();
  final _emptyBottlePriceCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '0');
  String _category = 'Water Bottle';
  bool _inStock = true;
  bool _isSaving = false;
  double? latitude;
  double? longitude;
  final ImagePicker _picker = ImagePicker();
  bool get isEdit => widget.initialItem != null;

  @override
  void initState() {
    super.initState();
    fetchLocation();
    _initFromItem();
  }

  void _initFromItem() {
    if (!isEdit) return;
    final it = widget.initialItem!;
    selectedSize = it.size;
    _nameCtrl.text = it.name;
    _descCtrl.text = it.description;
    _filledPriceCtrl.text = it.price.toStringAsFixed(2);
    _emptyBottlePriceCtrl.text = it.emptyBottlePrice.toStringAsFixed(2);
    _quantityCtrl.text = it.quantity.toString();
    _category = it.category;
    _inStock = it.inStock;
    // we don't populate pickedImage; show remote image via initialItem.imageUrl
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _filledPriceCtrl.dispose();
    _emptyBottlePriceCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? xfile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 80,
    );
    if (xfile == null) return;
    setState(() {
      pickedImage = File(xfile.path);
    });
  }

  Future<void> _removeImage() async {
    setState(() {
      pickedImage = null;
    });
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    String? prefixText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          prefixText: prefixText,
          prefixStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.deepPurple.shade300)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildSizeChips(double maxWidth) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: sizes.map((s) {
        final bool selected = selectedSize == s;
        return GestureDetector(
          onTap: () => setState(() => selectedSize = s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: selected
                  ? LinearGradient(
                      colors: [
                        Colors.deepPurple.shade400,
                        Colors.blue.shade500,
                      ],
                    )
                  : null,
              color: selected ? null : Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: selected ? Colors.transparent : Colors.grey.shade200,
              ),
            ),
            child: Text(
              '$s L',
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<bool> _saveItem() async {
    if (!_formKey.currentState!.validate()) return false;
    if (selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bottle size.')),
      );
      return false;
    }

    final filledPrice = double.parse(_filledPriceCtrl.text.trim());
    final emptyBottlePrice = double.parse(_emptyBottlePriceCtrl.text.trim());
    final quantity = int.tryParse(_quantityCtrl.text.trim()) ?? 0;

    setState(() => _isSaving = true);
    try {
      final name = _nameCtrl.text.trim().isEmpty
          ? 'Water ${selectedSize}L'
          : _nameCtrl.text.trim();

      await _controller.addItem(
        name: name,
        description: _descCtrl.text.trim(),
        size: selectedSize!,
        price: filledPrice,
        emptyBottlePrice: emptyBottlePrice,
        imageFile: pickedImage,
        extraImageFiles: null,
        category: _category,
        inStock: _inStock,
        quantity: quantity,
        latitude: latitude,
        longitude: longitude,
      );

      if (!mounted) return false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item saved successfully')));
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save item: $e')));
      }
      return false;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool> _updateItem() async {
    // Use update flow - requires initialItem to be present
    if (!isEdit) return false;
    if (!_formKey.currentState!.validate()) return false;
    if (selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bottle size.')),
      );
      return false;
    }

    final filledPrice = double.parse(_filledPriceCtrl.text.trim());
    final emptyBottlePrice = double.parse(_emptyBottlePriceCtrl.text.trim());
    final quantity = int.tryParse(_quantityCtrl.text.trim()) ?? 0;

    setState(() => _isSaving = true);
    try {
      await _controller.updateItem(
        docId: widget.initialItem!.docId,
        size: selectedSize!,
        price: filledPrice,
        emptyBottlePrice: emptyBottlePrice,
        name: _nameCtrl.text.trim().isEmpty
            ? 'Water ${selectedSize}L'
            : _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        newImageFile:
            pickedImage, // if null, controller will keep existing image
        category: _category,
        inStock: _inStock,
        quantity: quantity,
        latitude: latitude,
        longitude: longitude,
      );

      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item updated successfully')),
      );
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update item: $e')));
      }
      return false;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> fetchLocation() async {
    Position? position = await LocationHelper.getCurrentLocation();

    if (position != null) {
      latitude = position.latitude;
      longitude = position.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude!,
        longitude!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxWidth = media.size.width;
    final horizontalPadding = maxWidth > 700 ? 48.0 : 20.0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.purple.shade50],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      isEdit ? 'Edit Item' : 'Add New Item',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 10,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Picker Section
                        Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  if (pickedImage != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Image.file(
                                        pickedImage!,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.contain,
                                      ),
                                    )
                                  else if (isEdit &&
                                      widget.initialItem?.imageUrl != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Image.network(
                                        widget.initialItem!.imageUrl!,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  else
                                    Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.deepPurple.shade50,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.add_a_photo_outlined,
                                              size: 32,
                                              color: Colors.deepPurple.shade300,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Upload Product Image',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (pickedImage != null)
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: GestureDetector(
                                        onTap: _removeImage,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(
                                              0.6,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        const Text(
                          'Bottle Size',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSizeChips(maxWidth),
                        const SizedBox(height: 32),

                        const Text(
                          'Product Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildModernTextField(
                          controller: _nameCtrl,
                          label: 'Product Name',
                          icon: Icons.edit_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildModernTextField(
                          controller: _descCtrl,
                          label: 'Description',
                          maxLines: 3,
                          icon: Icons.description_outlined,
                        ),
                        const SizedBox(height: 32),

                        const Text(
                          'Pricing & Stock',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernTextField(
                                controller: _filledPriceCtrl,
                                label: 'Filled Price',
                                prefixText: '₹ ',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildModernTextField(
                                controller: _emptyBottlePriceCtrl,
                                label: 'Empty Price',
                                prefixText: '₹ ',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernTextField(
                                controller: _quantityCtrl,
                                label: 'Stock Quantity',
                                keyboardType: TextInputType.number,
                                icon: Icons.inventory_2_outlined,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _category,
                                    isExpanded: true,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.deepPurple.shade300,
                                    ),
                                    items: ['Water Bottle', 'Mineral', 'RO']
                                        .map(
                                          (c) => DropdownMenuItem(
                                            value: c,
                                            child: Text(c),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) => setState(
                                      () => _category = v ?? 'Water Bottle',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _inStock
                                          ? Colors.green.shade50
                                          : Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _inStock
                                          ? Icons.check_circle_outline
                                          : Icons.cancel_outlined,
                                      color: _inStock
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Available in Stock',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _inStock,
                                activeColor: Colors.green,
                                onChanged: (v) => setState(() => _inStock = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100), // Space for bottom button
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.of(context).padding.bottom,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSaving
                ? null
                : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isSaving = true);
                      bool success = isEdit
                          ? await _updateItem()
                          : await _saveItem();
                      setState(() => _isSaving = false);
                      if (success) {
                        Navigator.pop(context, true);
                      }
                    }
                  },
                  
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade900,
                    Colors.deepPurple.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                alignment: Alignment.center,
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEdit ? "UPDATE ITEM" : "SAVE ITEM",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
