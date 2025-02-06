import 'package:intl/intl.dart';

String customFormatDate(DateTime? date) {
  return date != null ? DateFormat.yMMMd().format(date) : 'Немає дати';
}
