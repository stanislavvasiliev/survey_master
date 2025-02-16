import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_model/faculties_provider.dart';
import '../../view_model/survey_provider.dart';
import '../../services/date_formatter.dart';
import '../../models/faculty_model.dart';
import './faculty_dropdown.dart';
import './group_dropdown.dart';
import '../widgets/settings_buttons.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../../view_model/date_picker_config.dart';

class ShowModalSettings extends ConsumerStatefulWidget {
  const ShowModalSettings({super.key});
  @override
  ConsumerState<ShowModalSettings> createState() => _ShowModalSettingsState();
}

class _ShowModalSettingsState extends ConsumerState<ShowModalSettings> {
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  DateTime? _startDate, _endDate;
  List<EduInstitution> _selectedFaculties = [];
  bool _activeSwitch = false;
  List<String> _selectedGroups = []; // Додаємо оголошення змінної тут  add

  @override
  void initState() {
    super.initState();
    final selectedSurvey = ref.read(selectedSurveyProvider);
    if (selectedSurvey != null) {
      // Отримуємо всі факультети
      final allFaculties = ref.read(facultiesProvider).when(
        data: (faculties) => faculties,
        loading: () => [],
        error: (_, __) => [],
      );

      // Знаходимо факультети, які вже обрані в опитуванні
      _selectedFaculties = allFaculties
          .where((faculty) => selectedSurvey.faculty.contains(faculty.name))
          .toList()
          .cast<EduInstitution>();

      _startDate = selectedSurvey.startDate;
      _endDate = selectedSurvey.endDate;
      _startDateController.text =
      _startDate != null ? customFormatDate(_startDate!) : '';
      _endDateController.text =
      _endDate != null ? customFormatDate(_endDate!) : '';
      _activeSwitch = selectedSurvey.isActivated;
      _selectedGroups = List<String>.from(selectedSurvey.group); // Ініціалізуємо значення // add
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStartDate) async {
    DateTime firstDate = DateTime.now();
    DateTime initialDate = isStartDate
        ? (_startDate ?? firstDate)
        : (_endDate ?? (_startDate ?? firstDate));

    final pickedDate = await DatePickerConfig.showLocalizedDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          _startDateController.text = customFormatDate(pickedDate);

          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
            _endDateController.text = _startDateController.text;
          }
        } else if (_startDate == null ||
            pickedDate.isAtSameMomentAs(_startDate!) ||
            pickedDate.isAfter(_startDate!)) {
          _endDate = pickedDate;
          _endDateController.text = customFormatDate(pickedDate);
        }
      });
    }
  }
  void _handleFacultiesSelected(List<EduInstitution> faculties) {
    final facultiesData = ref.read(facultiesProvider).value ?? [];

    List<String> newSelectedGroups;

    if (faculties.isEmpty) {
      // Якщо факультети не вибрані, вибираємо всі групи
      newSelectedGroups = facultiesData.expand((faculty) => faculty.groups).toSet().toList();
    } else {
      // Визначаємо доступні групи на основі вибраних факультетів
      final availableGroups = faculties.expand((faculty) => faculty.groups).toSet().toList();

      // Якщо користувач вже вибрав якісь групи, залишаємо їх (фільтруємо)
      newSelectedGroups = _selectedGroups.isNotEmpty
          ? _selectedGroups.where((group) => availableGroups.contains(group)).toList()
          : availableGroups;
    }

    setState(() {
      _selectedFaculties = faculties;
      //_selectedGroups = newSelectedGroups;
      _selectedGroups = faculties.expand((faculty) => faculty.groups).toSet().toList();
    });

    // Оновлення стану у провайдерах
    ref.read(selectedFacultiesProvider.notifier).state = faculties;
    // ref.read(selectedGroupsProvider.notifier).state = newSelectedGroups;
    ref.read(selectedGroupsProvider.notifier).state = _selectedGroups;
  }


  void _handleGroupsSelected(List<String> groups) {
    setState(() {
      _selectedGroups = groups;
    });
    ref.read(selectedGroupsProvider.notifier).state = groups; // add
  }
  // add

  void _saveDates() {
    final selectedSurvey = ref.read(selectedSurveyProvider);
    if (selectedSurvey == null) return;

    final allFaculties = ref.read(facultiesProvider).value ?? [];
    final allGroupNames = allFaculties.expand((f) => f.groups).toSet().toList();

    // Перевіряємо, чи користувач ще нічого не вибрав
    final bool isFacultiesEmpty = _selectedFaculties.isEmpty;
    final bool isGroupsEmpty = _selectedGroups.isEmpty;

    // Якщо факультети ще не вибрані користувачем, встановлюємо всі факультети
    final newFacultiesNames = isFacultiesEmpty
        ? allFaculties.map((f) => f.name).toList()
        : _selectedFaculties.map((f) => f.name).toList();

    // Якщо групи ще не вибрані користувачем, встановлюємо всі групи
    final newGroups = isGroupsEmpty
        ? ["all"] // Фікс: якщо жодної групи не вибрано, записуємо "all"
        : (_selectedGroups.length == allGroupNames.length ? ["all"] : List<String>.from(_selectedGroups));

    // При активації не змінюємо вибір, якщо користувач уже щось вибрав
    final updatedFaculties = isFacultiesEmpty ? allFaculties.map((f) => f.name).toList() : newFacultiesNames;
    final updatedGroups = isGroupsEmpty ? ["all"] : newGroups; // Фікс для коректного запису "all"

    print("Перевірка allFaculties: $allFaculties");
    print("Збережені факультети: $updatedFaculties");
    print("Збережені групи: $updatedGroups");
    print("Фактично збережені групи: ${updatedGroups.contains("all") ? allGroupNames : updatedGroups}");

    final updatedSurvey = selectedSurvey.copyWith(
      faculty: updatedFaculties,
      group: updatedGroups,
      isActivated: _activeSwitch,
      startDate: _startDate,
      endDate: _endDate,
    );

    ref.read(surveyListProvider.notifier).updateSurvey(updatedSurvey);
    ref.read(selectedSurveyProvider.notifier).state = updatedSurvey;

    // Відображаємо повідомлення про успішне збереження
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Зміни збережено"),
        duration: Duration(seconds: 2),
      ),
    );

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
                    // add
                    key: ValueKey(_selectedFaculties.hashCode), // Додаємо унікальний ключ
                    availableGroups: ref.watch(facultiesProvider).value?.expand((faculty) => faculty.groups).toSet().toList() ?? [],
                    onGroupsSelected: _handleGroupsSelected,
                    value: _selectedGroups, // Додаємо цей параметр
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
