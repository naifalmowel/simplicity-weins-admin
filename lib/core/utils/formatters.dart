import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'ar');
    return '${formatter.format(amount)} ل.س';
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy/MM/dd - hh:mm a', 'ar').format(dateTime);
  }

  static String formatDateShort(DateTime dateTime) {
    return DateFormat('yyyy/MM/dd', 'ar').format(dateTime);
  }
}
