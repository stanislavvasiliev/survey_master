import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/survey_provider.dart';
import '../view/widgets/survey_list_widget.dart';
import 'dart:html' as html;
import '../models/survey_model.dart';

class SurveyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSurvey = ref.watch(selectedSurveyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Проходження опитувань'),
        automaticallyImplyLeading: false,
        actions: [
          Container(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min, // Prevents Row from taking full width
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    final newSurvey = Survey(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: 'Нове опитування',
                      description: 'Додайте опис опитування',
                      questions: [
                        Question(
                          id: 'q1',
                          text: 'Чи було стоврення опитувальника успішним?',
                          type: QuestionType.text,
                        ),
                      ],
                    );

                    ref.read(surveyListProvider.notifier).addSurvey(newSurvey);
                    ref.read(selectedSurveyProvider.notifier).state = newSurvey;

                    Navigator.pushNamed(context, '/editor');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Створити опитування'),
                ),
                const SizedBox(width: 8), // Adds spacing between buttons
                OutlinedButton.icon(
                  onPressed: selectedSurvey == null
                      ? null
                      : () {
                          Navigator.pushNamed(context, '/editor');
                        },
                  icon: const Icon(Icons.edit),
                  label: const Text('Редагувати опитування'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: selectedSurvey == null
                      ? null
                      : () {
                          bool confirmDelete = html.window.confirm(
                              "Ви впевнені, що хочете видалити це опитування?");
                          if (confirmDelete) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Опитування видалено'),
                                  duration: Duration(seconds: 1)),
                            );

                            ref
                                .read(surveyListProvider.notifier)
                                .deleteSurvey(selectedSurvey.id);
                            ref.read(selectedSurveyProvider.notifier).state =
                                null;
                          }
                        },
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Видалити опитування'),
                ),
              ],
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
                        'Доступні опитування',
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

            // Права панель - перегляд опитування
            Expanded(
              child: selectedSurvey == null
                  ? Center(
                      child: Text(
                        'Оберіть опитування зі списку',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : Card(
                      elevation: 1,
                      margin: EdgeInsets.zero,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Заголовок
                            Text(
                              selectedSurvey.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(height: 16),

                            // Опис
                            Text(
                              selectedSurvey.description,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 24),
                            const Divider(),

                            // Список питань
                            Text(
                              'Питання:',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            ...selectedSurvey.questions.map((question) => Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
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
                                        Text(
                                          question.text,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 8,
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
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryContainer,
                                            ),
                                            if (question.options != null)
                                              ...question.options!.map(
                                                (option) => Chip(
                                                  label: Text(option),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
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
