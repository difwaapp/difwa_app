import 'package:difwa_app/config/app_constant.dart';
import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/features/address/controller/address_controller.dart';
import 'package:difwa_app/features/orders/controller/checkout_controller.dart';
import 'package:difwa_app/models/Address.dart';
import 'package:difwa_app/features/address/address_screen.dart';
import 'package:difwa_app/widgets/AddressNotFound.dart';
import 'package:difwa_app/widgets/CustomPopup.dart';
import 'package:difwa_app/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final double totalPrice;
  final int totalDays;
  final List<DateTime> selectedDates;

  const CheckoutScreen({
    super.key,
    required this.orderData,
    required this.totalPrice,
    required this.totalDays,
    required this.selectedDates,
  });

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final CheckoutController checkoutController;
  late final AddressController _addressController;
  String? userUid = FirebaseAuth.instance.currentUser?.uid;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    checkoutController = Get.put(CheckoutController());
    _addressController = Get.put(AddressController());
    checkoutController.fetchWalletBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: isProcessing ? null : () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout',
          style: TextStyleHelper.instance.black14Bold.copyWith(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Card - Modern Design
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        appTheme.primaryColor,
                        appTheme.primaryColor.withOpacity(0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: appTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              bottleImageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.water_drop,
                                    size: 40,
                                    color: appTheme.primaryColor.withOpacity(0.5),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${widget.orderData['bottle']['name'] ?? 'Water Can'}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildInfoRow(
                                Icons.water_drop_outlined,
                                "${widget.orderData['bottle']['size']}L",
                              ),
                              const SizedBox(height: 6),
                              _buildInfoRow(
                                Icons.shopping_cart_outlined,
                                "Quantity: ${widget.orderData['quantity']}",
                              ),
                              const SizedBox(height: 6),
                              _buildInfoRow(
                                Icons.currency_rupee,
                                "₹${widget.orderData['price']} per bottle",
                              ),
                              if (widget.orderData['hasEmptyBottle']) ...[
                                const SizedBox(height: 6),
                                _buildInfoRow(
                                  Icons.recycling,
                                  "Deposit: ₹${widget.orderData['emptyBottlePrice'] * widget.orderData['quantity']}",
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Calendar Section
                _buildSectionTitle("Delivery Schedule"),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: appTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.calendar_month,
                                    color: appTheme.primaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Selected Dates',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: appTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: appTheme.primaryColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${widget.totalDays} ${widget.totalDays == 1 ? 'day' : 'days'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: appTheme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Wrap calendar in physics-enabled container
                      IgnorePointer(
                        ignoring: false,
                        child: TableCalendar(
                          firstDay: DateTime.utc(2000, 1, 1),
                          lastDay: DateTime.utc(2100, 12, 31),
                          focusedDay: widget.selectedDates.isNotEmpty
                              ? widget.selectedDates.first
                              : DateTime.now(),
                          headerVisible: false,
                          selectedDayPredicate: (day) {
                            return widget.selectedDates
                                .any((selectedDate) => isSameDay(selectedDate, day));
                          },
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              shape: BoxShape.circle,
                            ),
                            todayTextStyle: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: appTheme.primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: appTheme.primaryColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            selectedTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            defaultDecoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            weekendDecoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            outsideDecoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            weekendStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          daysOfWeekVisible: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Price Breakdown
                _buildSectionTitle("Price Summary"),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildPriceRow(
                        "Daily Cost (${widget.orderData['quantity']} bottles)",
                        "₹${widget.totalPrice}",
                      ),
                      const SizedBox(height: 16),
                      _buildPriceRow(
                        "Total Days",
                        "${widget.totalDays} ${widget.totalDays == 1 ? 'day' : 'days'}",
                      ),
                      const SizedBox(height: 16),
                      _buildPriceRow(
                        "Subtotal",
                        "₹${(widget.orderData['price'] * widget.orderData['quantity'] * widget.totalDays).toStringAsFixed(0)}",
                      ),
                      if (widget.orderData['hasEmptyBottle']) ...[
                        const SizedBox(height: 16),
                        _buildPriceRow(
                          "Empty Bottle Deposit",
                          "₹${(widget.orderData['emptyBottlePrice'] * widget.orderData['quantity']).toStringAsFixed(0)}",
                          isDeposit: true,
                        ),
                      ],
                      const SizedBox(height: 20),
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.grey.shade300,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildPriceRow(
                        "Total Amount",
                        "₹${((widget.orderData['price'] * widget.orderData['quantity'] * widget.totalDays) + (widget.orderData['emptyBottlePrice'] * widget.orderData['quantity'])).toStringAsFixed(0)}",
                        isTotal: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Wallet Balance
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade50,
                        Colors.blue.shade50,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.green.shade200,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: Colors.green.shade700,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wallet Balance',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Obx(() {
                              return Text(
                                '₹${checkoutController.walletBalance.value.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26,
                                  letterSpacing: 0.5,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Delivery Address
                _buildSectionTitle("Delivery Address"),
                const SizedBox(height: 12),
                StreamBuilder<Address?>(
                  stream: _addressController.getSelectedAddressStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (snapshot.hasData && snapshot.data != null) {
                      final address = snapshot.data!;
                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: appTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.location_on,
                                    color: appTheme.primaryColor,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    address.locationType.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: appTheme.primaryColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: appTheme.primaryColor.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: TextButton.icon(
                                    onPressed: isProcessing
                                        ? null
                                        : () async {
                                            await Get.to(() => AddressScreen());
                                          },
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('Change'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: appTheme.primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              address.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${address.floor.isNotEmpty ? '${address.floor}, ' : ''}${address.street}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${address.city}, ${address.state} - ${address.zip}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                            ),
                            if (address.landmark != null && address.landmark!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.place_outlined,
                                    size: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      address.landmark!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                        fontStyle: FontStyle.italic,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 14),
                            Container(
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.grey.shade200,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.phone,
                                    size: 16,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  address.phone,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    } else {
                      return AddressNotFound();
                    }
                  },
                ),

                const SizedBox(height: 24),

                // Payment Button
                Obx(() {
                  final isLoading = checkoutController.isLoading.value || isProcessing;
                  return CustomButton(
                    text: 'Proceed to Pay',
                    onPressed: isLoading ? null : paynow,
                    isLoading: isLoading,
                  );
                }),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // Loading Overlay
          if (isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(appTheme.primaryColor),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Processing Payment...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please wait',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false, bool isDeposit = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.black : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal
                ? appTheme.primaryColor
                : isDeposit
                    ? Colors.orange.shade700
                    : Colors.black87,
          ),
        ),
      ],
    );
  }

  void paynow() async {
    final selectedAddress = _addressController.selectedAddress.value;

    if (selectedAddress == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomPopup(
            title: "Address Required",
            description: "Please select a delivery address to proceed with your order.",
            buttonText: "Add Address",
            onButtonPressed: () {
              Get.back();
              Get.to(() => AddressScreen());
            },
          );
        },
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      await checkoutController.processPayment(
        selectedAddress,
        widget.orderData,
        widget.totalPrice,
        widget.totalDays,
        (widget.orderData['emptyBottlePrice'] * widget.orderData['quantity']).toDouble(),
        widget.selectedDates,
        context,
      );
    } catch (e) {
      print("Error in payment: $e");
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to process payment. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }
}
