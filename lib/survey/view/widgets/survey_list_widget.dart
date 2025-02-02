import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_model/survey_provider.dart';

class SurveyListWidget extends ConsumerWidget {
  final Function(String id) onSelectSurvey;

  const SurveyListWidget({required this.onSelectSurvey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveys = ref.watch(surveyListProvider);
    final selectedSurvey = ref.watch(selectedSurveyProvider);

    if (surveys.isEmpty) {
      return const Center(child: Text('Немає доступних опитувань.'));
    }

    return ListView.builder(
      itemCount: surveys.length,
      itemBuilder: (context, index) {
        final survey = surveys[index];
        final isSelected = selectedSurvey?.id == survey.id;

        return ListTile(
          title: Text(survey.title),
          subtitle: Text(survey.description,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          selected: isSelected,
          selectedTileColor: Colors.blue.withOpacity(0.2),
          onTap: () => onSelectSurvey(survey.id),
        );
      },
    );
  }
}
