import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

class DatePickerConfig {
  static final DatePickerConfig _instance = DatePickerConfig._internal();
  factory DatePickerConfig() => _instance;
  DatePickerConfig._internal();

  Future<void> initializeLocalization() async {
    await initializeDateFormatting('uk_UA', null);
  }

  static Future<DateTime?> showLocalizedDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('uk', 'UA'),
      cancelText: 'Скасувати',
      confirmText: 'Обрати',
      helpText: 'Оберіть дату',
      fieldLabelText: 'Дата',
      errorFormatText: 'Введіть дійсну дату',
      errorInvalidText: 'Введіть дату у межах допустимого діапазону',
    );
  }
}
