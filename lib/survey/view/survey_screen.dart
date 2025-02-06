import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:survey_master/survey/view/widgets/survey_form_widget.dart';
import '../view_model/survey_provider.dart';
import '../view/widgets/survey_list_widget.dart';
import '../view/widgets/survey_action_buttons.dart';
import '../view/widgets/survey_settings.dart';

class SurveyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSurvey = ref.watch(selectedSurveyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Проходження опитувань'),
        automaticallyImplyLeading: false,
        actions: [
          const Padding(
            padding: EdgeInsets.all(5),
            child: SurveyActionButtons(),
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
                            SurveySettingsView(),
                      // Форма з питаннями
                      SurveyFormWidget(
                        survey: selectedSurvey,
                        onSubmit: (answers) {
                          // Тут можна зберегти відповіді або передати далі
                          print('Отримані відповіді: $answers');
                        },
                      ),
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
