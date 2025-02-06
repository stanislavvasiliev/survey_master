import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../../models/survey_model.dart';

class SurveyFormWidget extends StatefulWidget {
  final Survey survey;
  final Function(Map<String, dynamic>) onSubmit;

  const SurveyFormWidget({
    super.key,
    required this.survey,
    required this.onSubmit,
  });

  @override
  State<SurveyFormWidget> createState() => _SurveyFormWidgetState();
}

class _SurveyFormWidgetState extends State<SurveyFormWidget> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> answers = {};

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
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.saveAndValidate() ?? false) {
                setState(() {
                  answers = _formKey.currentState!.value;
                });
                widget.onSubmit(answers);
              }
            },
            child: const Text('Відправити відповіді'),
          ),
        ],
      ),
    );
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
    }
  }
}
