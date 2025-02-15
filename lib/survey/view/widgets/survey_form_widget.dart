import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:survey_master/survey/view/widgets/survey_response_model.dart';
import '../../models/survey_model.dart';
import '../../view_model/survey_provider.dart';

class SurveyFormWidget extends ConsumerStatefulWidget {
  final Survey survey;
  final Function(Map<String, dynamic>) onSubmit;
  final bool showSubmitButton;

  const SurveyFormWidget({
    super.key,
    required this.survey,
    required this.onSubmit,
    this.showSubmitButton = true,
  });

  @override
  ConsumerState<SurveyFormWidget> createState() => _SurveyFormWidgetState();
}

class _SurveyFormWidgetState extends ConsumerState<SurveyFormWidget> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> answers = {};

  // Метод для форматування відповідей перед збереженням
  Map<String, dynamic> _formatAnswersForSubmission(Map<String, dynamic> rawAnswers) {
    final formattedAnswers = <String, dynamic>{};

    for (var question in widget.survey.questions) {
      final answer = rawAnswers[question.id];

      // Форматуємо відповідь в залежності від типу питання
      switch (question.type) {
        case QuestionType.multipleChoice:
        // Переконуємося що multiple choice завжди повертає список
          formattedAnswers[question.id] = answer is List ? answer : [answer];
          break;

        case QuestionType.scale:
        // Конвертуємо значення шкали в число
          formattedAnswers[question.id] = (answer as double).round();
          break;

        case QuestionType.numeric:
        // Конвертуємо строкове представлення в число
          formattedAnswers[question.id] = num.tryParse(answer.toString()) ?? answer;

        default:
        // Для інших типів залишаємо як є
          formattedAnswers[question.id] = answer;
      }
    }

    return formattedAnswers;
  }

  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      // Отримуємо сирі дані з форми
      final rawAnswers = _formKey.currentState!.value;

      // Форматуємо відповіді
      final formattedAnswers = _formatAnswersForSubmission(rawAnswers);

      // Створюємо об'єкт відповіді
      final response = SurveyResponse(
        surveyId: widget.survey.id,
        submissionDate: DateTime.now(),
        answers: formattedAnswers,
      );

      // Зберігаємо відповідь через провайдер
      ref.read(surveyResponseProvider.notifier).addResponse(response);

      // Викликаємо колбек onSubmit з відформатованими відповідями
      widget.onSubmit(formattedAnswers);

      // Показуємо повідомлення про успіх
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Відповіді успішно збережено'),
          duration: Duration(seconds: 2),
        ),
      );

      // Опціонально: очищаємо форму
      _formKey.currentState?.reset();
      setState(() {
        answers = {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.survey.questions.map((question) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(question.text, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _buildQuestionWidget(question),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          if (widget.showSubmitButton)
          ElevatedButton(
            onPressed: _submitForm,
            child: const Text('Відправити відповіді'),
          ),
        ],
      ),
    );
  }
  @override
  void didUpdateWidget(covariant SurveyFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (var question in widget.survey.questions) {
      if (question.type == QuestionType.scale) {
        final field = _formKey.currentState?.fields[question.id];
        final currentValue = field?.value as double?;
        if (currentValue == null ||
            currentValue < question.minScale! ||
            currentValue > question.maxScale!) {
          _formKey.currentState?.patchValue({question.id: question.minScale!.toDouble()});
        }
      }
    }
  }

  Widget _buildQuestionWidget(Question question) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return FormBuilderCheckboxGroup<String>(
          name: question.id,
          options: question.options!
              .map((option) => FormBuilderFieldOption<String>(
            value: option,
            child: Text(option),
          ))
              .toList(),
          orientation: OptionsOrientation.vertical,
          separator: const SizedBox(height: 8),
          validator: (value) => (value == null || value.isEmpty)
              ? 'Будь ласка, оберіть хоча б один варіант'
              : null,
        );

      case QuestionType.singleChoice:
        return FormBuilderRadioGroup<String>(
          name: question.id,
          options: question.options!
              .map((option) => FormBuilderFieldOption<String>(
            value: option,
            child: Text(option),
          ))
              .toList(),
          orientation: OptionsOrientation.vertical,
          separator: const SizedBox(height: 8),
          validator: (value) => value == null ? 'Будь ласка, оберіть варіант' : null,
        );

      case QuestionType.dropdown:
        return FormBuilderDropdown<String>(
          name: question.id,
          decoration: const InputDecoration(labelText: 'Оберіть варіант'),
          items: question.options!
              .map((option) => DropdownMenuItem(value: option, child: Text(option)))
              .toList(),
          validator: (value) => value == null ? 'Будь ласка, оберіть варіант' : null,
        );

      case QuestionType.scale:
        return Column(
          children: [
            FormBuilderSlider(
              name: question.id,
              min: question.minScale!.toDouble(),
              max: question.maxScale!.toDouble(),
              initialValue: question.minScale!.toDouble(),
              divisions: question.maxScale! - question.minScale!,
              validator: (value) => value == null ? 'Будь ласка, оберіть значення' : null,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    answers[question.id] = value;
                  });
                }
              },
            ),
            Text(
              'Поточне значення: ${answers[question.id]?.round() ?? question.minScale}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        );

      case QuestionType.text:
        return FormBuilderTextField(
          name: question.id,
          decoration: const InputDecoration(hintText: 'Введіть вашу відповідь'),
          validator: (value) => (value == null || value.isEmpty)
              ? 'Будь ласка, введіть відповідь'
              : null,
        );

      case QuestionType.numeric:
        return FormBuilderTextField(
          name: question.id,
          decoration: const InputDecoration(hintText: 'Введіть число'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*$')) // Дозволяє лише цифри та одну крапку/кому
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Будь ласка, введіть число';
            }
            final numValue = num.tryParse(value);
            if (numValue == null) {
              return 'Введіть коректне число';
            }
            return null;
          },
        );


      case QuestionType.tablesingle:
        return FormBuilderField<Map<String, String?>>(
          name: question.id,
          validator: (value) {
            return null;
          },
          builder: (FormFieldState<Map<String, String?>> field) {
            final currentValue = field.value ?? <String, String?>{};
            return Table(
              border: TableBorder.all(),
              columnWidths: const {0: IntrinsicColumnWidth()},
              children: [
                TableRow(
                  children: [
                    Container(padding: const EdgeInsets.all(8), child: const Text('')),
                    ...question.options!.map((option) =>
                        Container(
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.center,
                          child: Text(option),
                        )
                    ).toList(),
                  ],
                ),
                ...question.tablequest!.map((rowLabel) {
                  final selected = currentValue[rowLabel];
                  return TableRow(
                    children: [
                      Container(padding: const EdgeInsets.all(8), child: Text(rowLabel)),
                      ...question.options!.map((option) {
                        return Container(
                          padding: const EdgeInsets.all(0),
                          alignment: Alignment.center,
                          child: RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            value: option,
                            groupValue: selected,
                            title: const SizedBox.shrink(),
                            onChanged: (value) {
                              final newValue = (selected == value) ? null : value;
                              final updatedMap = Map<String, String?>.from(currentValue);
                              updatedMap[rowLabel] = newValue;
                              field.didChange(updatedMap);
                            },
                          ),
                        );
                      }).toList(),
                    ],
                  );
                }).toList(),
              ],
            );
          },
        );


      case QuestionType.tablemultiple:
        return FormBuilderField<Map<String, List<String>?>>(
          name: question.id,
          validator: (value) {
            return null;
          },
          builder: (FormFieldState<Map<String, List<String>? >> field) {
            final currentValue = field.value ?? <String, List<String >> {};
            return Table(
              border: TableBorder.all(),
              columnWidths: const {0: IntrinsicColumnWidth()},
              children: [
                TableRow(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: const Text(''),
                    ),
                    ...question.options!.map((option) => Container(
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: Text(option),
                    )),
                  ],
                ),
                ...question.tablequest!.map((rowLabel) {
                  final selectedOptions = currentValue[rowLabel] ?? <String>[];
                  return TableRow(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: Text(rowLabel),
                      ),
                      ...question.options!.map((option) {
                        final isSelected = selectedOptions.contains(option);
                        return Container(
                          padding: const EdgeInsets.all(0),
                          alignment: Alignment.center,
                          child: Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              final updated = Map<String, List<String>>.from(currentValue);
                              final rowSelections = List<String>.from(selectedOptions);
                              if (value == true) {
                                if (!rowSelections.contains(option)) {
                                  rowSelections.add(option);
                                }
                              } else {
                                rowSelections.remove(option);
                              }
                              updated[rowLabel] = rowSelections;
                              field.didChange(updated);
                            },
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ],
            );
          },
        );
    }
  }
}
