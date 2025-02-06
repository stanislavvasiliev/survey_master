import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

String customFormatDate(DateTime? date) {
  initializeDateFormatting('uk_UA', null);

  return date != null
      ? DateFormat.yMMMMEEEEd('uk_UA').format(date)
      : 'Немає дати';
}
