import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/survey_provider.dart';
import '../view/widgets/survey_list_widget.dart';
import '../models/survey_model.dart';
import './widgets/survey_settings.dart';

class EditorScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSurvey = ref.watch(selectedSurveyProvider);
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descController = TextEditingController();
    final TextEditingController _startDateController = TextEditingController();
    final TextEditingController _endDateController = TextEditingController();
    final TextEditingController _facultyController = TextEditingController();
    final TextEditingController _groupController = TextEditingController();
    final TextEditingController _isActivatedController = TextEditingController();

    if (selectedSurvey != null) {
      _titleController.text = selectedSurvey.title;
      _descController.text = selectedSurvey.description;
      _startDateController.text =
          selectedSurvey.startDate?.toIso8601String() ?? '';
      _endDateController.text = selectedSurvey.endDate?.toIso8601String() ?? '';
      _facultyController.text = selectedSurvey.faculty.join(', ');
      _groupController.text = selectedSurvey.group.join(', ');
      _isActivatedController.text =
        selectedSurvey.isActivated ? 'Активне' : 'Неактивне';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактор опитувань'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: FilledButton.icon(
              onPressed: () {
                if (selectedSurvey != null) {
                  final updatedSurvey = Survey(
                    id: selectedSurvey.id,
                    title: _titleController.text,
                    description: _descController.text,
                    questions: selectedSurvey.questions,
                    startDate: DateTime.tryParse(_startDateController.text),
                    endDate: DateTime.tryParse(_endDateController.text),
                    faculty: _facultyController.text
                        .split(',')
                        .map((e) => e.trim())
                        .toList(), // Розбиваємо рядок на список

                    group: _groupController.text
                        .split(',')
                        .map((e) => e.trim())
                        .toList(), // Розбиваємо рядок на список
                    isActivated: selectedSurvey.isActivated,
                  );

                  ref
                      .read(surveyListProvider.notifier)
                      .updateSurvey(updatedSurvey);
                  ref
                      .read(selectedSurveyProvider.notifier)
                      .update((_) => updatedSurvey);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Зміни збережено'),
                        duration: Duration(seconds: 1)),
                  );
                }
              },
              icon: const Icon(Icons.save_outlined),
              label: Text('Зберегти зміни'),
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
                        'Список опитувань',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: SurveyListWidget(
                        onSelectSurvey: (id) {
                          final surveys = ref.read(surveyListProvider);
                            final selected =
                            surveys.firstWhere((survey) => survey.id == id);
                            ref.read(selectedSurveyProvider.notifier).state =
                                selected;
                          },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const VerticalDivider(width: 1),

            // Права панель - редагування
            Expanded(
              child: selectedSurvey == null
                  ? Center(child: Text('Оберіть опитування для редагування'))
                  : Card(

                elevation: 1,
                margin: EdgeInsets.zero,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Назва опитування',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),

                      SurveySettings(),
                      const SizedBox(height: 24),
                      // Опис
                      TextField(
                        controller: _descController,
                        decoration: InputDecoration(
                          labelText: 'Опис опитування',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),

                            // Список питань
                            Text('Питання:',
                                style: Theme.of(context).textTheme.titleLarge),
                            const Divider(),
                            ...selectedSurvey.questions
                                     .map((question) {
                                    final controllers = ref.watch(questionControllersProvider);
                                    final questionController = controllers.putIfAbsent(
                                      question.id,
                                          () => TextEditingController(text: question.text),
                                    );
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
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
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child:
                                            TextField(
                                              controller: questionController,
                                              decoration: InputDecoration(
                                                labelText: 'Текст питання',
                                                border: UnderlineInputBorder(),
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                                    onChanged: (newText) {
                                                      final updatedQuestions = selectedSurvey.questions.map((q) {
                                                        if (q.id == question.id) {
                                                          return q.copyWith(text: newText);
                                                        }
                                                        return q;
                                                      }).toList();

                                                      ref.read(selectedSurveyProvider.notifier).state = selectedSurvey.copyWith(
                                                        questions: updatedQuestions,
                                                      );
                                                    },
                                                  ),
                                                ),
                                                //видалення
                                                IconButton(
                                                  icon: Icon(Icons.close_rounded, color: Colors.grey),
                                                  onPressed: () {
                                                    final updatedQuestions = selectedSurvey.questions
                                                        .where((q) => q.id != question.id)
                                                        .toList();
                                                    final newControllers = Map<String, TextEditingController>.from(controllers);
                                                    newControllers.remove(question.id);
                                                    ref.read(questionControllersProvider.notifier).state = newControllers;

                                                    ref.read(selectedSurveyProvider.notifier).state = selectedSurvey.copyWith(
                                                      questions: updatedQuestions,
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Wrap(
                                              spacing: 8,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
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
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondaryContainer,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  })
                                .toList(),
                      // додавання
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white)
                        ),
                        child: DropdownButton<QuestionType>(
                          value: ref.watch(selectedQuestionTypeProvider),
                          onChanged: (QuestionType? newValue) {
                            if (newValue != null) {
                              ref.read(selectedQuestionTypeProvider.notifier).state = newValue;
                            }
                          },
                          items: QuestionType.values.map((QuestionType type) {
                            return DropdownMenuItem<QuestionType>(
                              value: type,
                              child: Text(type.toString().split('.').last),
                            );
                          }).toList(),
                          icon: const Icon(Icons.arrow_downward_outlined),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final selectedType = ref.read(selectedQuestionTypeProvider);
                          List<String>? options;
                          int? minScale;
                          int? maxScale;
                          if (selectedType == QuestionType.singleChoice || selectedType == QuestionType.multipleChoice) {
                            options = ["Варіант 1", "Варіант 2"];
                          } else if (selectedType == QuestionType.scale) {
                            minScale = 1;
                            maxScale = 2;
                          }
                          final newQuestion = Question(
                            id: DateTime.now().toString(),
                            text: '',
                            type: selectedType,
                            options: options,
                            minScale: minScale,
                            maxScale: maxScale,
                          );

                          ref.read(selectedSurveyProvider.notifier).state = Survey(
                            id: selectedSurvey.id,
                            title: selectedSurvey.title,
                            description: selectedSurvey.description,
                            questions: [...selectedSurvey.questions, newQuestion],
                            startDate: selectedSurvey.startDate,
                            endDate: selectedSurvey.endDate,
                            faculty: [...selectedSurvey.faculty],
                            group: [...selectedSurvey.group],
                            isActivated: selectedSurvey.isActivated,
                          );
                        },
                        child: Text('Додати питання'),
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
