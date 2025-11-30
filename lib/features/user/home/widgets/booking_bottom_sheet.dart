import 'package:difwa_app/config/core/app_export.dart';
import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/routes/app_routes.dart';
import 'package:difwa_app/features/address/controller/address_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';

class BookingBottomSheet extends StatefulWidget {
  final Map<String, dynamic> itemData;
  final double walletBalance;
  final Function(
    int quantity,
    bool hasEmptyBottle,
    DateTime date,
    String timeSlot,
  )
  onConfirm;

  final bool isSubscription;

  const BookingBottomSheet({
    super.key,
    required this.itemData,
    required this.walletBalance,
    required this.onConfirm,
    this.isSubscription = false,
  });

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  int _quantity = 1;
  bool _hasEmptyBottle = false;
  DateTime _selectedDate = DateTime.now();
  final String _selectedTimeSlot = 'Morning'; // Morning, Afternoon, Evening

  double get _basePrice => (widget.itemData['price'] ?? 0).toDouble();
  double get _emptyBottlePrice =>
      (widget.itemData['emptyBottlePrice'] ?? 0).toDouble();

  double get _totalPrice {
    double price = _basePrice * _quantity;
    if (_hasEmptyBottle) {
      price += _emptyBottlePrice * _quantity;
    }
    return price;
  }

  @override
  Widget build(BuildContext context) {
    bool hasInsufficientFunds = _totalPrice > widget.walletBalance;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Order Details Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 7)),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${DateFormat('d MMM').format(_selectedDate)}, $_selectedTimeSlot',
                      style: const TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Delivery Location (Static for now, can be dynamic)
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Delivery Location',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Obx(() {
                final address = Get.find<AddressController>().selectedAddress.value;
                return Text(
                  address != null
                      ? '${address.street}, ${address.city}'
                      : 'Select Address',
                  style: TextStyle(color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                );
              }),
            ],
          ),
          const SizedBox(height: 12),

          // Delivery Time
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.grey, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Delivery time',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text('30 minutes', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 24),

          // Quantity Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '20 L Water Can', // TODO: Get from item name
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: () {
                        if (_quantity > 1) setState(() => _quantity--);
                      },
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () {
                        setState(() => _quantity++);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Empty Bottle Checkbox
          GestureDetector(
            onTap: () => setState(() => _hasEmptyBottle = !_hasEmptyBottle),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _hasEmptyBottle
                        ? Colors.grey[300]
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _hasEmptyBottle
                      ? const Icon(Icons.check, size: 16, color: Colors.black)
                      : null,
                ),
                const SizedBox(width: 12),
                const Text('I have empty Can'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Price Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '20 L Water Can',
                style: TextStyleHelper.instance.body12RegularPoppins,
              ),
              Text('${_quantity}x ₹${_basePrice.toStringAsFixed(0)}'),
            ],
          ),
          if (_hasEmptyBottle) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Security Money for Can'),
                Text('${_quantity}x ₹${_emptyBottlePrice.toStringAsFixed(0)}'),
              ],
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${_totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          if (hasInsufficientFunds)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  const Text(
                    'Insufficient wallet ! ',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.addbalance_screen);
                    },
                    child: const Text(
                      'Add money to your wallet',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.account_balance_wallet,
                    size: 14,
                    color: Colors.red,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Slide to Buy
          if (!hasInsufficientFunds)
            SlideAction(
              borderRadius: 24,
              elevation: 0,
              innerColor: const Color(0xFF29B6F6),
              outerColor: Colors.grey[200],
              sliderButtonIcon: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 14,
              ),
              text: widget.isSubscription ? 'Proceed to Subscription' : 'Slide to buy',
              textStyle: TextStyle(
                color: Colors.grey[800],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              onSubmit: () {
                widget.onConfirm(
                  _quantity,
                  _hasEmptyBottle,
                  _selectedDate,
                  _selectedTimeSlot,
                );
                return null;
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
