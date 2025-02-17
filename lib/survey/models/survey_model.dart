// Типи питань (можна розширювати)
enum QuestionType {
  text, // Відкрите текстове питання
  singleChoice, // Питання з одним варіантом відповіді
  multipleChoice, // Питання з кількома варіантами відповідей
  scale,       // Шкала (наприклад, від 1 до 5)
  dropdown,
  numeric,
  tablesingle, // таблиця з одним варіантом відповіді
  tablemultiple // таблиця з кількома варіантами відповідей
}

// Модель питання
class Question {
  final String id;
  final String text;
  final QuestionType type;
  final List<String>?
      options; // Варіанти відповідей (для single/multiple choice)
  int? minScale; // Мінімальне значення шкали
  int? maxScale; // Максимальне значення шкали
  List<String>? tablequest;

  Question({
    required this.id,
    required this.text,
    required this.type,
    this.options,
    this.minScale,
    this.maxScale,
    this.tablequest
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
  Question copyWith({
    String? id,
    String? text,
    QuestionType? type,
    List<String>? options,
    int? minScale,
    int? maxScale,
    List<String>?tablequest,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      options: options ?? this.options,
      minScale: minScale ?? this.minScale,
      maxScale: maxScale ?? this.maxScale,
      tablequest: tablequest ?? this.tablequest,
    );
  }
}

// Оновлена модель опитування
class Survey {
  final String id;
  final String title;
  final String description;
  final List<Question> questions; // Список питань
  final DateTime? startDate;
  final DateTime? endDate;
  final List faculty;
  final List group;
  final bool isActivated;

  Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.startDate,
    required this.endDate,
    required this.faculty,
    required this.group,
    required this.isActivated,
  });

  // Метод для роботи з налаштуваннями опитування
  Survey copyWith({
    String? id,
    String? title,
    String? description,
    List<Question>? questions,
    DateTime? startDate,
    DateTime? endDate,
    List? faculty,
    List? group,
    bool? isActivated, // Change to bool instead of required
  }) {
    return Survey(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      questions: questions ?? this.questions,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      faculty: faculty ?? this.faculty,
      group: group ?? this.group,
      isActivated:
          isActivated ?? this.isActivated, // Update with new property type
    );
  }
}

final allFaculties =
    0; //якщо ім'я буде 0, то буде розповсюджуватися на всі факультети.
