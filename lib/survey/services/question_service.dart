import '../models/survey_model.dart';
class QuestionProvider {
  Question defaultQuestion(QuestionType type, {List<String>? options,int? minScale, int? maxScale}) {

    switch (type) {
      case QuestionType.singleChoice:
      case QuestionType.multipleChoice:
      case QuestionType.dropdown:
        final Options = options ?? ["А", "Б"];
        if (Options.isEmpty) {
          throw ArgumentError(
              'Для типів singleChoice, multipleChoice и dropdown options не можуть бути пустими');
        }
        return Question(
          id: DateTime.now().toString(),
          text: '',
          type: type,
          options: Options,
        );
      case QuestionType.scale:
        final MinScale = minScale ?? 1;
        final MaxScale = maxScale ?? 5;

        if (MinScale >= MaxScale) {
          throw ArgumentError('minScale повинен бути меньше maxScale');
        }
        return Question(
          id: DateTime.now().toString(),
          text: '',
          type: type,
          minScale: MinScale,
          maxScale: MaxScale,
        );
      case QuestionType.tablesingle:
        final tablequest = ["Варіант 1", "Варіант 2"];
        final TableOptions = options ?? ["А", "Б"];
        return Question(
          id: DateTime.now().toString(),
          text: '',
          type: type,
          options: TableOptions,
          tablequest: tablequest,
        );

      case QuestionType.tablemultiple:
        final tablequest = ["Варіант 1", "Варіант 2"];
        final TableOptions = options ?? ["А", "Б"];
        return Question(
          id: DateTime.now().toString(),
          text: '',
          type: type,
          options: TableOptions,
          tablequest: tablequest,
        );

      default:
        return Question(
          id: DateTime.now().toString(),
          text: '',
          type: type,
        );
    }
  }
}