import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_model/survey_provider.dart';
import 'package:intl/intl.dart';
import './settings_modal.dart';

class ShowModalSettings extends ConsumerStatefulWidget {
  @override
  ConsumerState<ShowModalSettings> createState() => _ShowModalSettingsState();
}

class _ShowModalSettingsState extends ConsumerState<ShowModalSettings> {
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  DateTime? _startDate, _endDate;

  @override
  void initState() {
    super.initState();

    final selectedSurvey = ref.read(selectedSurveyProvider);
    if (selectedSurvey != null) {
      _startDate = selectedSurvey.startDate;
      _endDate = selectedSurvey.endDate;

      _startDateController.text = _startDate != null
          ? _startDate!.toLocal().toString().split(' ')[0]
          : '';
      _endDateController.text =
          _endDate != null ? _endDate!.toLocal().toString().split(' ')[0] : '';
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    DateTime firstDate = DateTime.now();
    DateTime initialDate = isStartDate
        ? (_startDate ?? firstDate)
        : (_endDate ?? (_startDate ?? firstDate));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          _startDateController.text = DateFormat.yMMMd().format(pickedDate);

          // Ensure end date is not before start date
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
            _endDateController.text = _startDateController.text;
          }
        } else if (_startDate == null ||
            pickedDate.isAtSameMomentAs(_startDate!) ||
            pickedDate.isAfter(_startDate!)) {
          _endDate = pickedDate;
          _endDateController.text = DateFormat.yMMMd().format(pickedDate);
        }
      });
    }
  }

  void _saveDates() {
    final selectedSurvey = ref.read(selectedSurveyProvider);
    if (selectedSurvey != null) {
      final updatedSurvey = selectedSurvey.copyWith(
        startDate: _startDate,
        endDate: _endDate,
      );

      ref.read(surveyListProvider.notifier).updateSurvey(updatedSurvey);
      ref.read(selectedSurveyProvider.notifier).state = updatedSurvey;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Налаштування опитування", style: TextStyle(fontSize: 20)),
            const Divider(),
            SizedBox(height: 10),
            Text("Виберіть дати для опитування"),

            // Дата початку
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _startDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Дата початку",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _pickDate(context, true),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Дата завершення
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _endDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Дата завершення",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _pickDate(context, false),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Кнопки внизу
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Скасувати"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FilledButton(
                    onPressed: _saveDates,
                    child: Text("Зберегти"),
                    style: ElevatedButton.styleFrom(elevation: 4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showCustomDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ShowModalSettings();
    },
  );
}
