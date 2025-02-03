import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:html' as html;
import '../../models/survey_model.dart';
import '../../view_model/survey_provider.dart';

class SurveyActionButtons extends ConsumerWidget {
  const SurveyActionButtons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSurvey = ref.watch(selectedSurveyProvider);

    return Row(
      mainAxisSize: MainAxisSize.min,
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
                  text: 'Чи було створення опитувальника успішним?',
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
        const SizedBox(width: 8),
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
                      const SnackBar(
                        content: Text('Опитування видалено'),
                        duration: Duration(seconds: 1),
                      ),
                    );

                    ref
                        .read(surveyListProvider.notifier)
                        .deleteSurvey(selectedSurvey.id);
                    ref.read(selectedSurveyProvider.notifier).state = null;
                  }
                },
          icon: const Icon(Icons.delete_forever),
          label: const Text('Видалити опитування'),
        ),
      ],
    );
  }
}
