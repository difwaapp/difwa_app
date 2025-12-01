import 'package:difwa_app/config/app_constant.dart';
import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/features/user/wallet/checkout_screen.dart';
import 'package:difwa_app/widgets/FrequencyOption.dart';
import 'package:difwa_app/widgets/PackageOption.dart';
import 'package:difwa_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int selectedPackageIndex = 0;
  int selectedFrequencyIndex = 0;
  DateTime? startDate;
  DateTime? endDate;
  List<DateTime> selectedDates = [];

  late Map<String, dynamic> orderData;
  late double totalPrice;
  late double overAllTotalo;
  late double bottlePrice = 0.0;

//old code
  String? selectedDateRange;
  String selectedFrequency = "Every Day";
  int totalDays = 0;
  double pricePerDay = 0.0;
  bool showError = false;
  bool isLoading = false;

  Future<void> _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (picked != null) {
      setState(() {
        selectedDateRange =
            "${DateFormat('dd MMM').format(picked.start)} - ${DateFormat('dd MMM').format(picked.end)}";
        totalDays = picked.end.difference(picked.start).inDays + 1;
        showError = false;
        startDate = picked.start;
        endDate = picked.end;
      });
      _generateDates();
    }
  }

  void _generateDates() {
    if (selectedFrequencyIndex == 3) return; // Do not clear dates for Custom

    selectedDates.clear();
    DateTime currentDate = startDate ?? DateTime.now();
    DateTime endDate =
        this.endDate ?? DateTime.now().add(const Duration(days: 30));

    if (selectedFrequencyIndex == 0) {
      while (currentDate.isBefore(endDate)) {
        selectedDates.add(currentDate);
        currentDate = currentDate.add(const Duration(days: 1));
      }
    } else if (selectedFrequencyIndex == 1) {
      while (currentDate.isBefore(endDate)) {
        selectedDates.add(currentDate);
        currentDate = currentDate.add(const Duration(days: 2));
      }
    } else if (selectedFrequencyIndex == 2) {
      while (currentDate.isBefore(endDate)) {
        if (currentDate.weekday != DateTime.sunday) {
          selectedDates.add(currentDate);
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }
    }
  }

  Future<void> _selectCustomDatesDialog(BuildContext context) async {
    List<DateTime> tempSelectedDates = List.from(selectedDates);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Dates'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: 500,
                  height: 400,
                  child: TableCalendar(
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: DateTime.now(),
                    selectedDayPredicate: (day) {
                      return tempSelectedDates
                          .any((selectedDate) => isSameDay(selectedDate, day));
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        if (tempSelectedDates.contains(selectedDay)) {
                          tempSelectedDates.remove(selectedDay);
                        } else {
                          tempSelectedDates.add(selectedDay);
                        }
                      });
                    },
                    calendarStyle: const CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      defaultDecoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      outsideDecoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: Colors.black),
                      weekendStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedDates = tempSelectedDates;
                });
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  tempSelectedDates.clear(); // Clear selection if needed
                });
              },
              child: const Text('Clear Selection'),
            ),
          ],
        );
      },
    );

    // Update totalDays and totalPrice after selection
    totalDays = getTotalDays();
    // Recalculate totalPrice if needed, but totalPrice variable is per-day recurring.
    // So we don't need to update totalPrice variable here unless it depends on dates (it doesn't).
  }

  Widget _buildSelectionBox(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: showError && selectedDateRange == null
                  ? appTheme.redCustom
                  : Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: appTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: appTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyleHelper.instance.body14BoldPoppins.copyWith(
                  color: title == "Select Date Range" ? Colors.grey.shade500 : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCheckout() async {
    // if (selectedPackageIndex == -1 || selectedDateRange == null) {
    //   setState(() {
    //     showError = true;
    //   });
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text("Please select a package duration and date range!"),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }

    setState(() {
      isLoading = true;
    });

    // Simulate loading for effect
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    print("Order Data: $orderData");
    print("Total Price: $totalPrice (Type: ${totalPrice.runtimeType})");
    print("Total Days: ${getTotalDays()}");
    print("Selected Dates: $selectedDates");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          orderData: orderData,
          totalPrice: totalPrice, // Ensure this is double
          totalDays: getTotalDays(),
          selectedDates: selectedDates,
        ),
      ),
    );

    setState(() {
      isLoading = false;
    });
  }

  bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    Uri? uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }

  @override
  void initState() {
    super.initState();
    orderData = Get.arguments ?? {};
    bottlePrice = (orderData['price'] as num).toDouble();
    int quantity = (orderData['quantity'] as num).toInt();
    
    // totalPrice represents the recurring cost per day (without deposit)
    // or with deposit? The previous code added deposit.
    // Let's stick to "Price per Day" = Recurring Cost.
    // But the UI shows "For One Day".
    // If we want to be consistent with previous logic which added deposit:
    // totalPrice = (bottlePrice * quantity);
    // if (orderData['hasEmptyBottle']) {
    //   totalPrice += orderData['emptyBottlePrice'] * quantity;
    // }
    // But this is confusing for multi-day.
    
    // Let's define totalPrice as RECURRING daily cost.
    totalPrice = bottlePrice * quantity;
    
    startDate = DateTime.now().add(const Duration(days: 1));

    _generateDates();
    setState(() {
      selectedFrequencyIndex = 0;
      selectedFrequency = "Every Day";
      totalDays = getTotalDays();
    });
  }

  int getTotalDays() {
    return selectedDates.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background
      appBar: AppBar(
        title: const Text("Subscribe", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Card
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
                children: [
                  ClipRRect(
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
                          color: Colors.grey.shade100,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${orderData['bottle']['size']}L Bottle",
                          style: TextStyleHelper.instance.body14BoldPoppins.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildPriceRow("Price", "₹ $bottlePrice / bottle"),
                        const SizedBox(height: 4),
                        _buildPriceRow("Vacant Bottle", "₹ ${orderData['emptyBottlePrice'] * orderData['quantity']}"),
                        const SizedBox(height: 4),
                        Divider(color: Colors.grey.shade200),
                        const SizedBox(height: 4),
                        _buildPriceRow("Total / Unit", "₹ $totalPrice", isBold: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Package Duration
            Text(
              "Select Duration",
              style: TextStyleHelper.instance.body14BoldPoppins.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: PackageOption(
                      title: [
                        "1\nMonth",
                        "3\nMonths",
                        "6\nMonths",
                        "1\nYear"
                      ][index],
                      index: index,
                      selectedIndex: selectedPackageIndex,
                      onTap: () {
                        setState(() {
                          showError = false;
                          selectedPackageIndex = index;
                          if (index == 0) {
                            endDate = startDate?.add(const Duration(days: 30));
                          }
                          if (index == 1) {
                            endDate = startDate?.add(const Duration(days: 90));
                          }
                          if (index == 2) {
                            endDate = startDate?.add(const Duration(days: 180));
                          }
                          if (index == 3) {
                            endDate = startDate?.add(const Duration(days: 365));
                          }
                        });
                        // selectedDates.add(endDate!); // Removed incorrect line
                        _generateDates();
                        totalDays = getTotalDays();
                      },
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // Select Date Range
            Text(
              "Date Range",
              style: TextStyleHelper.instance.body14BoldPoppins.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildSelectionBox(
                selectedDateRange ?? "Select Date Range", Icons.calendar_month, _selectDateRange),
            
            const SizedBox(height: 24),
            
            Text(
              "Frequency",
              style: TextStyleHelper.instance.body14BoldPoppins.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  FrequencyOption(
                    title: "Every Day",
                    value: "Every Day",
                    selectedValue: selectedFrequency,
                    icon: Icons.calendar_today,
                    onTap: () {
                      setState(() {
                        selectedFrequencyIndex = 0;
                        selectedFrequency = "Every Day";
                        _generateDates();
                        totalDays = getTotalDays();
                      });
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),
                  FrequencyOption(
                    title: "Alternate Days",
                    value: "Alternate Days",
                    selectedValue: selectedFrequency,
                    icon: Icons.swap_horiz,
                    onTap: () {
                      setState(() {
                        selectedFrequencyIndex = 1;
                        selectedFrequency = "Alternate Days";
                        _generateDates();
                        totalDays = getTotalDays();
                      });
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),
                  FrequencyOption(
                    title: "Except Sundays",
                    value: "Except Sundays",
                    selectedValue: selectedFrequency,
                    icon: Icons.block,
                    onTap: () {
                      setState(() {
                        selectedFrequencyIndex = 2;
                        selectedFrequency = "Except Sundays";
                        _generateDates();
                        totalDays = getTotalDays();
                      });
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade100),
                  FrequencyOption(
                    title: "Custom",
                    value: "Custom",
                    selectedValue: selectedFrequency,
                    icon: Icons.edit_calendar,
                    onTap: () {
                      setState(() {
                        selectedFrequencyIndex = 3;
                        selectedFrequency = "Custom";
                        _generateDates();
                        totalDays = getTotalDays();
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Select Custom Dates
            if (selectedFrequencyIndex == 3)
              _buildSelectionBox("Select Custom Dates", Icons.calendar_today, () {
                _selectCustomDatesDialog(context);
              }),
            
            const SizedBox(height: 32),

            // Summary Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Days", style: TextStyle(color: Colors.grey.shade600)),
                      Text("$totalDays days", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Price per Day", style: TextStyle(color: Colors.grey.shade600)),
                      Text("₹$totalPrice", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Amount",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        "₹ ${totalPrice * getTotalDays() + (orderData['hasEmptyBottle'] ? orderData['emptyBottlePrice'] * orderData['quantity'] : 0)} ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20, color: appTheme.primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Go to Checkout',
                    icon: Icons.arrow_forward,
                    isLoading: isLoading,
                    onPressed: _handleCheckout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isBold ? Colors.black : Colors.grey.shade600,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
