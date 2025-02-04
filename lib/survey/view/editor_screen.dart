import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final TextEditingController _courseController = TextEditingController();
    final TextEditingController _groupController = TextEditingController();

    if (selectedSurvey != null) {
      _titleController.text = selectedSurvey.title;
      _descController.text = selectedSurvey.description;
      _startDateController.text =
          selectedSurvey.startDate?.toIso8601String() ?? '';
      _endDateController.text = selectedSurvey.endDate?.toIso8601String() ?? '';
      _facultyController.text = selectedSurvey.faculty.join(', ');
      _courseController.text = selectedSurvey.course.join(', ');
      _groupController.text = selectedSurvey.group.join(', ');
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
                        .split(','), // Розбиваємо рядок на список
                    course: _courseController.text
                        .split(',')
                        .map(int.parse)
                        .toList(), // Перетворюємо в List<int>
                    group: _groupController.text
                        .split(',')
                        .map((e) => e.trim())
                        .toList(), // Розбиваємо рядок на список
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
                          if (surveys != null) {
                            final selected =
                                surveys.firstWhere((survey) => survey.id == id);
                            ref.read(selectedSurveyProvider.notifier).state =
                                selected;
                          }
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
                            SurveySettings(),

                            // Список питань
                            Text('Питання:',
                                style: Theme.of(context).textTheme.titleLarge),
                            const Divider(),
                            ...selectedSurvey.questions
                                .map((question) => Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextField(
                                              controller: TextEditingController(
                                                  text: question.text),
                                              decoration: InputDecoration(
                                                labelText: 'Текст питання',
                                                border: UnderlineInputBorder(),
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                            const SizedBox(height: 12),
                                            Wrap(
                                              spacing: 8,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                Chip(
                                                  label: Text(
                                                    question.type
                                                        .toString()
                                                        .split('.')
                                                        .last,
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSecondaryContainer,
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondaryContainer,
                                                ),
                                                if (question.options != null)
                                                  Text(
                                                    'Варіанти: ${question.options!.join(', ')}',
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .outline,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
