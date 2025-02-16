import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:survey_master/survey/view/widgets/survey_form_widget.dart';
import '../models/faculty_model.dart';
import '../view_model/faculties_provider.dart';
import '../view_model/survey_provider.dart';
import '../view/widgets/survey_list_widget.dart';
import '../models/survey_model.dart';
import './widgets/survey_settings.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late TextEditingController titleController;
  late TextEditingController descController;
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  late TextEditingController facultyController;
  late TextEditingController groupController;
  late TextEditingController isActivatedController;

  List<EduInstitution> _selectedFaculties = []; // ДОДАЛИ ОГОЛОШЕННЯ
  List<String> _selectedGroups = []; // ДОДАЛИ ОГОЛОШЕННЯ


  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descController = TextEditingController();
    startDateController = TextEditingController();
    endDateController = TextEditingController();
    facultyController = TextEditingController();
    groupController = TextEditingController();
    isActivatedController = TextEditingController();

    final selectedSurvey = ref.read(selectedSurveyProvider);
    if (selectedSurvey != null) {
      _updateControllers(selectedSurvey);

      final allFaculties = ref.read(facultiesProvider).value ?? [];
      _selectedFaculties = allFaculties
          .where((faculty) => selectedSurvey.faculty.contains(faculty.name))
          .toList();
      _selectedGroups = List<String>.from(selectedSurvey.group);
    }

    // Виконуємо оновлення провайдерів після завершення побудови віджета
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedFacultiesProvider.notifier).state = _selectedFaculties;
      ref.read(selectedGroupsProvider.notifier).state = _selectedGroups;
    });
  }

  void _updateControllers(Survey selectedSurvey) {
    titleController.text = selectedSurvey.title;
    descController.text = selectedSurvey.description;
    startDateController.text = selectedSurvey.startDate?.toIso8601String() ?? '';
    endDateController.text = selectedSurvey.endDate?.toIso8601String() ?? '';
    facultyController.text = selectedSurvey.faculty.join(', ');
    groupController.text = selectedSurvey.group.join(', ');
    isActivatedController.text = selectedSurvey.isActivated ? 'Активне' : 'Неактивне';
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    facultyController.dispose();
    groupController.dispose();
    isActivatedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(selectedFacultiesProvider, (_, next) {
      setState(() {
        facultyController.text = next.map((f) => f.name).join(', ');
      });
    });

    ref.listen(selectedGroupsProvider, (_, next) {
      setState(() {
        groupController.text = next.join(', ');
      });
    });

    ref.listen(selectedSurveyProvider, (previous, next) {
      if (next != null) {
        _updateControllers(next);
      }
    });
    final selectedSurvey = ref.watch(selectedSurveyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактор опитувань'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: FilledButton.icon(
              onPressed: () {
                if (selectedSurvey != null) {
                  final updatedSurvey = Survey(
                    id: selectedSurvey.id,
                    title: titleController.text,
                    description: descController.text,
                    questions: selectedSurvey.questions,
                    startDate: DateTime.tryParse(startDateController.text),
                    endDate: DateTime.tryParse(endDateController.text),
                    faculty: facultyController.text
                        .split(',')
                        .map((e) => e.trim())
                        .toList(),
                    group: groupController.text
                        .split(',')
                        .map((e) => e.trim())
                        .toList(),
                    isActivated: selectedSurvey.isActivated,
                  );

                  ref
                      .read(surveyListProvider.notifier)
                      .updateSurvey(updatedSurvey);
                  ref
                      .read(selectedSurveyProvider.notifier)
                      .update((_) => updatedSurvey);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Зміни збережено'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Зберегти зміни'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ліва панель - список опитувань
            Card(
              elevation: 1,
              margin: EdgeInsets.zero,
              child: SizedBox(
                width: 300,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Список опитувань',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: SurveyListWidget(
                        onSelectSurvey: (id) {
                          final surveys = ref.read(surveyListProvider);
                          final selected =
                          surveys.firstWhere((survey) => survey.id == id);
                          ref.read(selectedSurveyProvider.notifier).state =
                              selected;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const VerticalDivider(width: 1),

            // Права панель - редагування
            Expanded(
              child: selectedSurvey == null
                  ? const Center(child: Text('Оберіть опитування для редагування'))
                  : Card(
                elevation: 1,
                margin: EdgeInsets.zero,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Назва опитування',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),

                      const SurveySettings(),
                      const SizedBox(height: 24),
                      // Опис
                      TextField(
                        controller: descController,
                        decoration: InputDecoration(
                          labelText: 'Опис опитування',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      Text("Група(и): ${selectedSurvey.group.contains("all") ? "Всі" : selectedSurvey.group.join(", ")}"),
                      const SizedBox(height: 32),

                      // // Список питань
                      SurveyFormWidget(
                        survey: selectedSurvey,
                        onSubmit: (updatedAnswers) {
                          final updatedQuestions =
                          selectedSurvey.questions.map((q) {
                            return Question(
                              id: q.id,
                              text: updatedAnswers[q.id] ?? q.text,
                              type: q.type,
                              options: q.options,
                              minScale: q.minScale,
                              maxScale: q.maxScale,
                            );
                          }).toList();

                          final updatedSurvey = Survey(
                            id: selectedSurvey.id,
                            title: selectedSurvey.title,
                            description: selectedSurvey.description,
                            questions: updatedQuestions,
                            startDate: DateTime.tryParse(
                                startDateController.text),
                            endDate:
                            DateTime.tryParse(endDateController.text),
                            faculty: facultyController.text
                                .split(',')
                                .map((e) => e.trim())
                                .toList(),
                            group: groupController.text
                                .split(',')
                                .map((e) => e.trim())
                                .toList(),
                            isActivated: selectedSurvey.isActivated,
                          );
                          ref
                              .read(surveyListProvider.notifier)
                              .updateSurvey(updatedSurvey);
                          ref
                              .read(selectedSurveyProvider.notifier)
                              .state = updatedSurvey;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Зміни збережено'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}