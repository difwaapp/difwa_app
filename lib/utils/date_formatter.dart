import 'package:intl/intl.dart';

class DateFormatter {
  // Format DateTime to "MMMM d, yyyy HH:mm" (e.g., "April 4, 2025 16:46")
  static String formatToFullDateTime(DateTime date) {
    return DateFormat('MMMM d, yyyy HH:mm').format(date);
  }
}
