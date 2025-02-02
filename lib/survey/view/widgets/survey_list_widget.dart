import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_model/survey_provider.dart';

class SurveyListWidget extends ConsumerWidget {
  final Function(String id) onSelectSurvey;

  const SurveyListWidget({required this.onSelectSurvey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveys = ref.watch(surveyListProvider);

    return surveys.when(
      data: (data) => ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final survey = data[index];
          return ListTile(
            title: Text(survey.title),
            subtitle: Text(survey.description),
            onTap: () => onSelectSurvey(survey.id),
          );
        },
      ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Ошибка загрузки данных')),
    );
  }
}
