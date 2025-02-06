import '../models/survey_model.dart';
class QuestionProvider {
  Question defaultQuestion(QuestionType type) {
    switch (type) {
      case QuestionType.singleChoice:
      case QuestionType.multipleChoice:
      case QuestionType.dropdown:
        final options = ["Варіант 1", "Варіант 2"];
        if (options.isEmpty) {
          throw ArgumentError('singleChoice, multipleChoice и dropdown options не можуть бути пустими');
        }
        return Question(
          id: DateTime.now().toString(),
          text: '',
          type: type,
          options: options,
        );
      case QuestionType.scale:
        final minScale = 1;
        final maxScale = 2;
        if (minScale >= maxScale) {
          throw ArgumentError('minScale повинен бути меньше maxScale');
        }
        return Question(
          id: DateTime.now().toString(),
          text: '',
          type: type,
          minScale: minScale,
          maxScale: maxScale,
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