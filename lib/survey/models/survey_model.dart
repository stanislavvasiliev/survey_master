// Типи питань (можна розширювати)
enum QuestionType {
  text,        // Відкрите текстове питання
  singleChoice,// Питання з одним варіантом відповіді
  multipleChoice, // Питання з кількома варіантами відповідей
  scale,       // Шкала (наприклад, від 1 до 5)
}

// Модель питання
class Question {
  final String id;
  final String text;
  final QuestionType type;
  final List<String>? options; // Варіанти відповідей (для single/multiple choice)
  final int? minScale; // Мінімальне значення шкали
  final int? maxScale; // Максимальне значення шкали

  Question({
    required this.id,
    required this.text,
    required this.type,
    this.options,
    this.minScale,
    this.maxScale,
  }) {
    // Валідація даних (приклад)
    assert(
    (type == QuestionType.singleChoice || type == QuestionType.multipleChoice)
        ? options != null && options!.isNotEmpty
        : true,
    'Для типу single/multiple choice необхідні варіанти відповідей',
    );

    assert(
    type == QuestionType.scale
        ? (minScale != null && maxScale != null && minScale! < maxScale!)
        : true,
    'Для шкали вкажіть minScale та maxScale',
    );
  }
}

// Оновлена модель опитування
class Survey {
  final String id;
  final String title;
  final String description;
  final List<Question> questions; // Список питань

  Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
  });
}