import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:survey_master/survey/view/widgets/survey_form_widget.dart';
import '../view_model/survey_provider.dart';
import '../view/widgets/survey_list_widget.dart';
import '../models/survey_model.dart';
import './widgets/survey_settings.dart';

class EditorScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSurvey = ref.watch(selectedSurveyProvider);
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descController = TextEditingController();
    final TextEditingController _startDateController = TextEditingController();
    final TextEditingController _endDateController = TextEditingController();
    final TextEditingController _facultyController = TextEditingController();
    final TextEditingController _groupController = TextEditingController();
    final TextEditingController _isActivatedController =
      TextEditingController();

    if (selectedSurvey != null) {
      _titleController.text = selectedSurvey.title;
      _descController.text = selectedSurvey.description;
      _startDateController.text =
          selectedSurvey.startDate?.toIso8601String() ?? '';
      _endDateController.text = selectedSurvey.endDate?.toIso8601String() ?? '';
      _facultyController.text = selectedSurvey.faculty.join(', ');
      _groupController.text = selectedSurvey.group.join(', ');
      _isActivatedController.text =
        selectedSurvey.isActivated ? 'Активне' : 'Неактивне';
    }

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
                    title: _titleController.text,
                    description: _descController.text,
                    questions: selectedSurvey.questions,
                    startDate: DateTime.tryParse(_startDateController.text),
                    endDate: DateTime.tryParse(_endDateController.text),
                    faculty: _facultyController.text
                        .split(',')
                        .map((e) => e.trim())
                        .toList(), // Розбиваємо рядок на список

                    group: _groupController.text
                        .split(',')
                        .map((e) => e.trim())
                        .toList(), // Розбиваємо рядок на список
                    isActivated: selectedSurvey.isActivated,
                  );

                  ref
                      .read(surveyListProvider.notifier)
                      .updateSurvey(updatedSurvey);
                  ref
                      .read(selectedSurveyProvider.notifier)
                      .update((_) => updatedSurvey);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Зміни збережено'),
                        duration: Duration(seconds: 1)),
                  );
                }
              },
              icon: const Icon(Icons.save_outlined),
              label: Text('Зберегти зміни'),
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
                  ? Center(child: Text('Оберіть опитування для редагування'))
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
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Назва опитування',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                   
                      SurveySettings(),
                      const SizedBox(height: 24),
                      // Опис
                      TextField(
                        controller: _descController,
                        decoration: InputDecoration(
                          labelText: 'Опис опитування',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),

                      // // Список питань
                      SurveyFormWidget(
                        survey: selectedSurvey,
                        onSubmit: (updatedAnswers) {
                          final updatedQuestions = selectedSurvey.questions.map((q) {
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
                            startDate: DateTime.tryParse(_startDateController.text),
                            endDate: DateTime.tryParse(_endDateController.text),
                            faculty: _facultyController.text
                                .split(',')
                                .map((e) => e.trim())
                                .toList(), // Розбиваємо рядок на список

                            group: _groupController.text
                                .split(',')
                                .map((e) => e.trim())
                                .toList(), // Розбиваємо рядок на список
                            isActivated: selectedSurvey.isActivated,
                          );
                          ref.read(surveyListProvider.notifier).updateSurvey(updatedSurvey);
                          ref.read(selectedSurveyProvider.notifier).state = updatedSurvey;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Зміни збережено'), duration: Duration(seconds: 1)),
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
