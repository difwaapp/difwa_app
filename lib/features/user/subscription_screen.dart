import 'package:difwa_app/config/app_constant.dart';
import 'package:difwa_app/config/theme/text_style_helper.dart';
import 'package:difwa_app/config/theme/theme_helper.dart';
import 'package:difwa_app/features/user/checkout_screen.dart';
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
    selectedDates.clear();
    DateTime currentDate = startDate ?? DateTime.now();
    DateTime endDate =
        this.endDate ?? DateTime.now().add(const Duration(days: 30));

    if (selectedFrequencyIndex == 0) {
      while (currentDate.isBefore(endDate)) {
        currentDate = currentDate.add(const Duration(days: 1));
        selectedDates.add(currentDate);
      }
    } else if (selectedFrequencyIndex == 1) {
      while (currentDate.isBefore(endDate)) {
        currentDate = currentDate.add(const Duration(days: 2));
        selectedDates.add(currentDate);
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
    getDatesBasedOnFrequency();
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
    totalPrice = bottlePrice * orderData['quantity'];
    if (orderData['hasEmptyBottle']) {
      totalPrice += orderData['emptyBottlePrice'] * orderData['quantity'];
    }
    print("totalPricedk: $totalPrice");
  }

  List<DateTime> getDatesBasedOnFrequency() {
    List<DateTime> dates = [];
    DateTime currentDate = startDate ?? DateTime.now();
    DateTime endDate =
        this.endDate ?? DateTime.now().add(const Duration(days: 30));

    if (selectedFrequencyIndex == 0) {
      while (currentDate.isBefore(endDate)) {
        dates.add(currentDate);
        currentDate = currentDate.add(const Duration(days: 1));
      }
    } else if (selectedFrequencyIndex == 1) {
      while (currentDate.isBefore(endDate)) {
        dates.add(currentDate);
        currentDate = currentDate.add(const Duration(days: 2));
      }
    } else if (selectedFrequencyIndex == 2) {
      while (currentDate.isBefore(endDate)) {
        if (currentDate.weekday != DateTime.sunday) {
          dates.add(currentDate);
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }
    }
    return dates;
  }

  Widget _buildSelectionBox(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: showError && selectedDateRange == null
                  ?appTheme.redCustom
                  : appTheme.gray100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.black),
            SizedBox(
              width: 8,
            ),
            Text(title, style: TextStyleHelper.instance.body14BoldPoppins),
          ],
        ),
      ),
    );
  }

  void _handleCheckout() {
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
    bottlePrice = orderData['price'];
    print("aaja");
    print(orderData);
    print(bottlePrice);

    totalPrice = bottlePrice;
    print(totalPrice);
    if (orderData['hasEmptyBottle']) {
      totalPrice += orderData['emptyBottlePrice'] * orderData['quantity'];
    }
    startDate = DateTime.now().add(const Duration(days: 1));

    _generateDates();
    setState(() {
      selectedFrequencyIndex = 0;
      selectedFrequency = "Every Day";
      totalDays = getTotalDays();
    });
    print("totalPricedk: $totalPrice");
  }

  int getTotalDays() {
    return selectedDates.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Subscribe", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      bottleImageUrl,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${orderData['bottle']['size']}L",
                          style: TextStyleHelper.instance.body14BoldPoppins),
                      SizedBox(height: 4),
                      Text("Price: ₹ $bottlePrice per bottle",
                          style:  TextStyleHelper.instance.body14BoldPoppins),
                      Text(
                          "Vacant Bottle Price: ₹ ${orderData['emptyBottlePrice'] * orderData['quantity']}",
                          style: TextStyleHelper.instance.body14BoldPoppins),
                      Text("One Bottle Price: ₹ $totalPrice",
                          style:  TextStyleHelper.instance.body14BoldPoppins),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Package Duration
             Text("Package Duration:", style:  TextStyleHelper.instance.body14BoldPoppins),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) {
                return PackageOption(
                  title: [
                    "1\nMonth",
                    "3\nMonths",
                    "6\nMonths",
                    "1\nYear"
                  ][index],
                  index: index,
                  selectedIndex: selectedPackageIndex,
                  onTap: () {
                    print(index);
                    setState(() {
                      showError = false;
                      selectedPackageIndex = index;
                      print(index);
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
                    selectedDates.add(endDate!);
                    _generateDates();
                    totalDays = getTotalDays();
                  },
                );
              }),
            ),

            const SizedBox(height: 16),

            // Select Date Range
            _buildSelectionBox(
                "Select Date Range", Icons.calendar_month, _selectDateRange),
            // if (showError || selectedDateRange == null)
            //   const Padding(
            //     padding: EdgeInsets.only(top: 8),
            //     child: Text("Please select a date range!",
            //         style: TextStyle(color: Colors.red)),
            //   ),
            const SizedBox(height: 20),
             Text("Frequency:", style:  TextStyleHelper.instance.body14BoldPoppins),
            // Frequency Selection

            Column(
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
              ],
            ),

            const SizedBox(height: 16),

            // Select Custom Dates
            _buildSelectionBox("Select Custom Dates", Icons.calendar_today, () {
              _selectCustomDatesDialog(context);
            }),
            const SizedBox(height: 16),

            // Total Price Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Days:", style:  TextStyleHelper.instance.body14BoldPoppins),
                      Text("$totalDays days", style:  TextStyleHelper.instance.body14BoldPoppins),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("For One Day:", style: TextStyleHelper.instance.body14BoldPoppins),
                      Text("₹$totalPrice", style:  TextStyleHelper.instance.body14BoldPoppins),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Price:",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        "₹ ${orderData['price'] * getTotalDays() + orderData['emptyBottlePrice'] * orderData['quantity']} ",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 16),
            CustomButton(
                text: 'Go to Checkout',
                icon: Icons.shopping_cart_checkout,
                onPressed: _handleCheckout),
          ],
        ),
      ),
    );
  }
}
