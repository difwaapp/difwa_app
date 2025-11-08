// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:scanner/configs/app_colors.dart'; // Make sure to import your color config

// class CustomDateRangePicker extends StatefulWidget {
//   final DateTimeRange? initialRange;

//   const CustomDateRangePicker({Key? key, this.initialRange}) : super(key: key);

//   @override
//   _CustomDateRangePickerState createState() => _CustomDateRangePickerState();
// }

// class _CustomDateRangePickerState extends State<CustomDateRangePicker> {
//   DateTimeRange? selectedDateRange;
//   DateTime? startDate;
//   DateTime? endDate;

//   @override
//   void initState() {
//     super.initState();
//     selectedDateRange = widget.initialRange;
//     startDate = selectedDateRange?.start;
//     endDate = selectedDateRange?.end;
//   }

//   void _onDaySelected(DateTime day, DateTime focusedDay) {
//     setState(() {
//       if (startDate == null || (endDate != null && day.isBefore(startDate!))) {
//         startDate = day;
//         endDate = null;
//       } else if (endDate == null && day.isAfter(startDate!)) {
//         endDate = day;
//       } else {
//         startDate = day;
//         endDate = null;
//       }
//     });
//   }

//   void _confirmSelection() {
//     if (startDate != null && endDate != null) {
//       selectedDateRange = DateTimeRange(start: startDate!, end: endDate!);
//       Navigator.of(context).pop(selectedDateRange);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       backgroundColor: const Color.fromARGB(
//           159, 128, 255, 0), // Set your desired background color
//       title: const Text("Select Date Range"),
//       content: SizedBox(
//         width: 300, // Fixed width for the dialog content
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TableCalendar<DateTime>(
//               firstDay: DateTime.now(),
//               lastDay: DateTime(2025),
//               focusedDay: DateTime.now(),
//               selectedDayPredicate: (day) {
//                 return (startDate != null &&
//                         endDate == null &&
//                         day == startDate) ||
//                     (endDate != null &&
//                         (day.isAfter(startDate!) && day.isBefore(endDate!) ||
//                             day == endDate));
//               },
//               onDaySelected: _onDaySelected,
//               calendarStyle: CalendarStyle(
//                 selectedDecoration: BoxDecoration(
//                   color: Colors
//                       .blue, // Change this color to the desired selection color
//                   shape: BoxShape.circle,
//                 ),
//                 todayDecoration: BoxDecoration(
//                   color: Colors
//                       .orange, // Change this color to the desired today's date color
//                   shape: BoxShape.circle,
//                 ),
//                 defaultDecoration: BoxDecoration(
//                   color: AppColors
//                       .inactive, // Change the calendar background color
//                   shape: BoxShape.rectangle,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               selectedDateRange != null
//                   ? 'From: ${DateFormat('d MMMM yyyy').format(selectedDateRange!.start)} to ${DateFormat('d MMMM yyyy').format(selectedDateRange!.end)}'
//                   : 'Please select a range',
//               textAlign: TextAlign
//                   .center, // Center align the text for better visibility
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: _confirmSelection,
//           child: const Text("Done"),
//         ),
//       ],
//     );
//   }
// }
