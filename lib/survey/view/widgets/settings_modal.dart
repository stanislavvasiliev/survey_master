import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_model/survey_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../../services/date_formatter.dart';

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

      _startDateController.text =
          _startDate != null ? customFormatDate(_startDate!) : '';
      _endDateController.text =
          _endDate != null ? customFormatDate(_endDate!) : '';
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
    if (selectedSurvey == null) return;

    // Track changes before updating
    bool hasChanges = false;
    DateTime? newStartDate = _startDate;
    DateTime? newEndDate = _endDate;

    if (newStartDate != selectedSurvey.startDate ||
        newEndDate != selectedSurvey.endDate) {
      hasChanges = true;
    }

    if (hasChanges) {
      final updatedSurvey = selectedSurvey.copyWith(
        startDate: newStartDate,
        endDate: newEndDate,
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

            // Layout with Row, date fields on the left and dropdowns on the right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      // Start Date
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

                      // End Date
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
                    ],
                  ),
                ),
                SizedBox(width: 20), // Space between date fields and dropdowns
                Expanded(
                  child: Column(
                    children: [
                      // First Dropdown
                      FormBuilderDropdown(
                        name: 'dropdown_field',
                        items: ['Option 1', 'Option 2', 'Option 3']
                            .map(
                              (String option) => DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              ),
                            )
                            .toList(),
                        onChanged: (String? value) {},
                      ),
                      SizedBox(height: 10),

                      // Second Dropdown
                      FormBuilderDropdown(
                        name: 'dropdown_field',
                        items: ['Option 1', 'Option 2', 'Option 3']
                            .map(
                              (String option) => DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              ),
                            )
                            .toList(),
                        onChanged: (String? value) {},
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Buttons at the bottom
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
