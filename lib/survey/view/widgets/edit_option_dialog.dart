import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/survey_model.dart';
import '../../view_model/survey_provider.dart';

class EditOptionsDialog extends StatefulWidget {
  final Question question;
  final WidgetRef ref;

  const EditOptionsDialog({
    Key? key,
    required this.question,
    required this.ref,
  }) : super(key: key);

  @override
  _EditOptionsDialogState createState() => _EditOptionsDialogState();
}

class _EditOptionsDialogState extends State<EditOptionsDialog> {
  late List<String> updatedOptions;
  late TextEditingController optionController;
  late TextEditingController minScaleController;
  late TextEditingController maxScaleController;

  @override
  void initState() {
    super.initState();
    updatedOptions = List<String>.from(widget.question.options ?? []);
    optionController = TextEditingController();
    minScaleController = TextEditingController(text: widget.question.minScale?.toString() ?? '');
    maxScaleController = TextEditingController(text: widget.question.maxScale?.toString() ?? '');
  }

  @override
  void dispose() {
    optionController.dispose();
    minScaleController.dispose();
    maxScaleController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final updatedQuestion = widget.question.copyWith(
      options: widget.question.type == QuestionType.scale ? null : updatedOptions,
      minScale: widget.question.type == QuestionType.scale ? int.tryParse(minScaleController.text) : null,
      maxScale: widget.question.type == QuestionType.scale ? int.tryParse(maxScaleController.text) : null,
    );

    final selectedSurvey = widget.ref.read(selectedSurveyProvider);
    final updatedQuestions = selectedSurvey!.questions.map((q) {
      return q.id == widget.question.id ? updatedQuestion : q;
    }).toList();

    widget.ref.read(selectedSurveyProvider.notifier).state =
        selectedSurvey.copyWith(questions: updatedQuestions);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редагування параметрів питання'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.question.type == QuestionType.scale) ...[
            TextField(
              controller: minScaleController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Мінімальне значення'),
            ),
            TextField(
              controller: maxScaleController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Максимальне значення'),
            ),
          ] else ...[
            ...updatedOptions.map((option) {
              return ListTile(
                title: Text(option),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      updatedOptions.remove(option);
                    });
                  },
                ),
              );
            }).toList(),
            const Divider(),
            TextField(
              controller: optionController,
              decoration: const InputDecoration(labelText: 'Новий варіант відповіді'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (optionController.text.isNotEmpty) {
                  setState(() {
                    updatedOptions.add(optionController.text);
                  });
                  optionController.clear();
                }
              },
              child: const Text('Додати варіант'),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Скасувати'),
        ),
        ElevatedButton(
          onPressed: _saveChanges,
          child: const Text('Зберегти'),
        ),
      ],
    );
  }
}
