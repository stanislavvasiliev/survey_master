import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_model/survey_provider.dart';
import 'package:intl/intl.dart';
import '../../services/date_formatter.dart';
import '../../models/faculty_model.dart';
import './faculty_dropdown.dart';
import './group_dropdown.dart';
import '../widgets/settings_buttons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class ShowModalSettings extends ConsumerStatefulWidget {
  ShowModalSettings({super.key});
  @override
  ConsumerState<ShowModalSettings> createState() => _ShowModalSettingsState();
}

class _ShowModalSettingsState extends ConsumerState<ShowModalSettings> {
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  DateTime? _startDate, _endDate;
  List<EduInstitution> _selectedFaculties = [];
  bool _activeSwitch = false;

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
      _activeSwitch = selectedSurvey.isActivated;
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

  void _handleFacultiesSelected(List<EduInstitution> faculties) {
    setState(() {
      _selectedFaculties = faculties;
    });
  }

  void _saveDates() {
    final selectedSurvey = ref.read(selectedSurveyProvider);
    if (selectedSurvey == null) return;

    bool hasChanges = false;
    DateTime? newStartDate = _startDate;
    DateTime? newEndDate = _endDate;
    List<String> newFacultiesNames =
        _selectedFaculties.map((f) => f.name).toList();
    List<String> newGroupNames =
        _selectedFaculties.expand((faculty) => faculty.groups).toList();
    bool newIsActivated = _activeSwitch; // Ensure this is correctly set

    if (newStartDate != selectedSurvey.startDate ||
        newEndDate != selectedSurvey.endDate ||
        !listEquals(newFacultiesNames, selectedSurvey.faculty) ||
        !listEquals(newGroupNames, selectedSurvey.group) ||
        newIsActivated != selectedSurvey.isActivated) {
      hasChanges = true;
    }
    if (hasChanges) {
      final updatedSurvey = selectedSurvey.copyWith(
        startDate: newStartDate,
        endDate: newEndDate,
        faculty: newFacultiesNames,
        group: newGroupNames,
        isActivated: newIsActivated, // Updated correctly
      );
      ref.read(surveyListProvider.notifier).updateSurvey(updatedSurvey);
      ref.read(selectedSurveyProvider.notifier).state =
          updatedSurvey; // Set new survey state
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 600,
        height: 600,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Налаштування опитування", style: TextStyle(fontSize: 20)),
            const Divider(),
            SizedBox(height: 10),
            Text("Виберіть дати для опитування"),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
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
                      Row(
                        children: [
                          Expanded(
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
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: FormBuilderSwitch(
                      name: 'Статус опитування',
                      initialValue: _activeSwitch,
                      title: const Text('Опитування активне'),
                      onChanged: (bool? value) {
                        setState(() {
                          _activeSwitch = value ?? false;
                        });
                      },
                    ),
                  ),
                  FacultyMultiSelectDropdown(
                    onFacultiesSelected: _handleFacultiesSelected,
                  ),
                  GroupMultiSelectDropdown(
                    selectedFaculties: _selectedFaculties,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ModalActionButtons(
              onSave: _saveDates,
              onCancel: () => Navigator.of(context).pop(),
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
