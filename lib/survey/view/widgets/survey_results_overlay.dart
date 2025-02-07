import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:survey_master/survey/view/widgets/survey_response_model.dart';

import '../../models/survey_model.dart';
import '../../view_model/role_provider.dart';
import '../../view_model/survey_provider.dart';



class SurveyResultsOverlay extends ConsumerWidget {
  final Survey survey;
  final VoidCallback onClose;

  const SurveyResultsOverlay({
    Key? key,
    required this.survey,
    required this.onClose,
  }) : super(key: key);

  List<PlutoColumn> _createColumns() {
    return [
      PlutoColumn(
        title: 'Дата подання',
        field: 'submissionDate',
        type: PlutoColumnType.date(),
        width: 150,
      ),
      ...survey.questions.map((question) => PlutoColumn(
        title: question.text,
        field: question.id,
        type: PlutoColumnType.text(),
        width: 200,
      )),
    ];
  }

  List<PlutoRow> _createRows(List<SurveyResponse> responses) {
    return responses.map((response) {
      final Map<String, PlutoCell> cells = {
        'submissionDate': PlutoCell(
            value: response.submissionDate.toString().substring(0, 16)),
      };

      for (var question in survey.questions) {
        cells[question.id] = PlutoCell(
          value: _formatAnswer(response.answers[question.id], question.type),
        );
      }

      return PlutoRow(cells: cells);
    }).toList();
  }

  String _formatAnswer(dynamic answer, QuestionType type) {
    if (answer == null) return 'Немає відповіді';

    switch (type) {
      case QuestionType.multipleChoice:
        if (answer is List) {
          return answer.join(', ');
        }
        return answer.toString();
      case QuestionType.scale:
        return '$answer';
      case QuestionType.singleChoice:
      case QuestionType.dropdown:
        return answer.toString();
      case QuestionType.numeric:
        return answer.toString();
      case QuestionType.text:
        return answer.toString();
      }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responses = ref
        .watch(surveyResponseProvider)
        .where((response) => response.surveyId == survey.id)
        .toList();

    final isAdmin = ref.watch(isAdminProvider);

    return Material(
      color: Colors.black54,
      child: Stack(
        children: [
          Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Результати опитування: ${survey.title}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Row(
                        children: [
                          if (isAdmin)
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                ref
                                    .read(surveyResponseProvider.notifier)
                                    .clearResponses(survey.id);
                              },
                              tooltip: 'Очистити всі відповіді',
                            ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: onClose,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (responses.isEmpty)
                    Center(
                      child: Text(
                        'Поки що немає відповідей',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  else
                    Expanded(
                      child: PlutoGrid(
                        columns: _createColumns(),
                        rows: _createRows(responses),
                        configuration: PlutoGridConfiguration(
                          columnSize: const PlutoGridColumnSizeConfig(
                            autoSizeMode: PlutoAutoSizeMode.scale,
                          ),
                          style: PlutoGridStyleConfig(
                            gridBorderColor: Theme.of(context).dividerColor,
                            gridBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
                            cellTextStyle: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(),
                            columnTextStyle: (Theme.of(context).textTheme.titleMedium ?? const TextStyle())
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}