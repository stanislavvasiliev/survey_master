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
import '../../view_model/faculties_provider.dart';

final activeSwitchProvider = StateProvider<bool>((ref) {
  final selectedSurvey = ref.read(selectedSurveyProvider);
  return selectedSurvey?.isActivated ?? false;
});

final selectedFacultiesProvider =
    StateProvider<List<EduInstitution>>((ref) => []);
final selectedGroupsProvider = StateProvider<List<String>>((ref) => []);

class ShowModalSettings extends ConsumerStatefulWidget {
  ShowModalSettings({super.key});
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    final selectedSurvey = ref.read(selectedSurveyProvider);
    if (selectedSurvey != null) {
      _startDate = selectedSurvey.startDate;
      _endDate = selectedSurvey.endDate;
      _startDateController.text =
          _startDate != null ? customFormatDate(_startDate!) : '';
      _endDateController.text =
          _endDate != null ? customFormatDate(_endDate!) : '';

      final facultiesAsync = ref.read(facultiesProvider);
      facultiesAsync.whenData((faculties) {
        final savedFacultyNames = selectedSurvey.faculty;
        final savedFaculties = faculties
            .where((faculty) => savedFacultyNames.contains(faculty.name))
            .toList();

        // Update the state providers with the filtered faculties and groups
        ref.read(selectedFacultiesProvider.notifier).state = savedFaculties;
        ref.read(selectedGroupsProvider.notifier).state = selectedSurvey.group;
      });
    }
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
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

  void _saveSettings() {
    final selectedSurvey = ref.read(selectedSurveyProvider);
    if (selectedSurvey == null) return;

    final newStartDate = _startDate;
    final newEndDate = _endDate;
    final newFaculties = ref.read(selectedFacultiesProvider);
    final newGroups = ref.read(selectedGroupsProvider);
    final newIsActivated = ref.read(activeSwitchProvider);

    bool hasChanges = newStartDate != selectedSurvey.startDate ||
        newEndDate != selectedSurvey.endDate ||
        !listEquals(
            newFaculties.map((f) => f.name).toList(), selectedSurvey.faculty) ||
        !listEquals(newGroups, selectedSurvey.group) ||
        newIsActivated != selectedSurvey.isActivated;

    if (hasChanges) {
      final updatedSurvey = selectedSurvey.copyWith(
        startDate: newStartDate,
        endDate: newEndDate,
        faculty: newFaculties.map((f) => f.name).toList(),
        group: newGroups,
        isActivated: newIsActivated,
      );
      ref.read(surveyListProvider.notifier).updateSurvey(updatedSurvey);
      ref.read(selectedSurveyProvider.notifier).state = updatedSurvey;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final selectedFaculties = ref.watch(selectedFacultiesProvider);
    final selectedGroups = ref.watch(selectedGroupsProvider);
    final activeSwitch = ref.watch(activeSwitchProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 600,
        height: 700,
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
                mainAxisAlignment: MainAxisAlignment.start,
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      FormBuilderSwitch(
                        name: 'Статус опитування',
                        initialValue: activeSwitch,
                        title: const Text('Опитування активне'),
                        onChanged: (bool? value) {
                          ref.read(activeSwitchProvider.notifier).state =
                              value ?? false;
                        },
                      ),
                      FacultyMultiSelectDropdown(
                        initialSelectedFaculties:
                            selectedFaculties, // Pass selected faculties here
                        onFacultiesSelected: (faculties) => ref
                            .read(selectedFacultiesProvider.notifier)
                            .state = faculties,
                      ),
                      GroupMultiSelectDropdown(
                        initialSelectedGroups: selectedGroups,
                        onGroupsSelected: (groups) => ref
                            .read(selectedGroupsProvider.notifier)
                            .state = groups,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ModalActionButtons(
              onSave: _saveSettings,
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
