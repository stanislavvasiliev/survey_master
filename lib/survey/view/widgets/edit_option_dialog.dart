import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/survey_model.dart';
import '../../view_model/survey_provider.dart';

class TableRowList {
  final String title;
  final List<String> list;

  TableRowList({required this.title, required this.list});

  factory TableRowList.fromJson(Map<String, dynamic> json) {
    return TableRowList(
      title: json['title'] as String,
      list: List<String>.from(json['list'] as List),
    );
  }

  @override
  bool operator == (Object other) =>
      identical(this, other) ||
          (other is TableRowList && title == other.title);

  @override
  int get hashCode => title.hashCode;
}

Future<List<TableRowList>> loadTableRowLists() async {
  final jsonString = await rootBundle.loadString('lib/survey/models/tabletest.json'); // для тестів
  final List<dynamic> jsonData = json.decode(jsonString);
  return jsonData.map((item) => TableRowList.fromJson(item)).toList();
}

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
  String? errorMessage;

  TableRowList? _selectedTableRowList;
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
    int? minScale = int.tryParse(minScaleController.text);
    int? maxScale = int.tryParse(maxScaleController.text);

    if (widget.question.type == QuestionType.scale && minScale == maxScale) {
      setState(() {
        errorMessage = 'Мінімальне і максимальне значення не можуть бути однаковими.';
      });
      return;
    }

    final updatedQuestion = widget.question.copyWith(
      options: widget.question.type == QuestionType.scale ? null : updatedOptions,
      minScale: widget.question.type == QuestionType.scale ? minScale : null,
      maxScale: widget.question.type == QuestionType.scale ? maxScale : null,
      tablequest: (widget.question.type == QuestionType.tablesingle || widget.question.type == QuestionType.tablemultiple) ? widget.question.tablequest : null,
    );

    final selectedSurvey = widget.ref.read(selectedSurveyProvider);
    final updatedQuestions = selectedSurvey!.questions.map((q) {
      return q.id == widget.question.id ? updatedQuestion : q;
    }).toList();

    widget.ref.read(selectedSurveyProvider.notifier).state =
        selectedSurvey.copyWith(questions: updatedQuestions);

    Navigator.pop(context);
  }

  void _addOption() {
    String newOption = optionController.text.trim();
    if (newOption.isEmpty) return;
    if (updatedOptions.contains(newOption)) {
      setState(() {
        errorMessage = 'Такий варіант вже існує.';
      });
      return;
    }
    setState(() {
      updatedOptions.add(newOption);
      errorMessage = null;
    });
    optionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редагування параметрів питання'),
      content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.question.type == QuestionType.scale) ...[
            TextField(
              controller: minScaleController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Мінімальне значення:'),
            ),
            TextField(
              controller: maxScaleController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Максимальне значення:'),
            ),
              if (errorMessage != null) ...[
                const SizedBox(height: 5),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
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
              if (errorMessage != null) ...[
                const SizedBox(height: 5),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addOption,
                child: const Text('Додати варіант'),
              ),
            ],
            if (widget.question.type == QuestionType.tablesingle ||
                widget.question.type == QuestionType.tablemultiple) ...[
              const Divider(),
              FutureBuilder<List<TableRowList>>(
                future: loadTableRowLists(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Помилка завантаження списків');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Списки відсутні');
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Оберіть список рядків:'),
                        DropdownButton<TableRowList>(
                          value: _selectedTableRowList,
                          hint: const Text('Виберіть список'),
                          items: snapshot.data!.map((rowList) {
                            return DropdownMenuItem<TableRowList>(
                              value: rowList,
                              child: Text(rowList.title),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTableRowList = value;
                              widget.question.tablequest = value?.list;
                            });
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ],
        ),
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
