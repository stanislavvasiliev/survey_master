import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/survey_model.dart';

final surveyServiceProvider = Provider<SurveyService>((ref) => SurveyService());

class SurveyService {
  List<Survey> _surveys = [];
  SurveyService() {
    _initializeSurveys();
  }

  void _initializeSurveys() {
    _surveys = [
      // Опитування 1 - Задоволеність додатком
      Survey(
        id: '1',
        title: 'Ваша вподобаність додатку',
        description: 'Допоможіть нам покращити ваш досвід',
        questions: [
          Question(
            id: 'q1',
            text: 'Як часто ви користуєтесь додатком?',
            type: QuestionType.singleChoice,
            options: ['Щодня', 'Кілька разів на тиждень', 'Раз на місяць'],
          ),
          Question(
            id: 'q2',
            text: 'Оцініть зручність інтерфейсу (1 - погано, 5 - відмінно)',
            type: QuestionType.scale,
            minScale: 1,
            maxScale: 5,
          ),
          Question(
            id: 'q3',
            text: 'Що вам подобається найбільше?',
            type: QuestionType.multipleChoice,
            options: ['Дизайн', 'Швидкість', 'Функціонал', 'Інше'],
          ),
        ],
      ),

      // Опитування 2 - Звички користувачів
      Survey(
        id: '2',
        title: 'Ваші цифрові звички',
        description: 'Дослідження поводження користувачів',
        questions: [
          Question(
            id: 'q4',
            text: 'Скільки часу ви проводите в додатку за день?',
            type: QuestionType.singleChoice,
            options: ['До 30 хв', '1-2 години', 'Більше 3 годин'],
          ),
          Question(
            id: 'q5',
            text: 'Ваші пропозиції щодо зменшення часу використання:',
            type: QuestionType.text,
          ),
        ],
      ),

      // Опитування 3 - Технічні питання
      Survey(
        id: '3',
        title: 'Технічна підтримка',
        description: 'Допоможіть виправити помилки',
        questions: [
          Question(
            id: 'q6',
            text: 'Чи стикались ви з вилетами додатку?',
            type: QuestionType.singleChoice,
            options: ['Так', 'Ні'],
          ),
          Question(
            id: 'q7',
            text: 'Опишіть проблему детально:',
            type: QuestionType.text,
          ),
        ],
      ),
    ];
  }

  Future<List<Survey>> getSurveys() async {
    await Future.delayed(const Duration(seconds: 1)); // Імітація затримки
    return _surveys;
  }

  Future<void> deleteSurvey(String id) async {
    _surveys.removeWhere((survey) => survey.id == id);
  }
}




// This code defines a survey management service in Flutter:

// surveyServiceProvider: A Riverpod provider that creates a SurveyService instance
// SurveyService class:


// Contains getSurveys() method that returns mock survey data
// Includes 1-second delay to simulate network request
// Returns 3 predefined surveys:

// App satisfaction survey (3 questions: usage frequency, interface rating, favorite features)
// User habits survey (2 questions: daily usage time, reduction suggestions)
// Technical support survey (2 questions: app crashes, problem description)



// Each survey contains:

// Unique ID
// Title and description
// List of questions with different types (single choice, multiple choice, scale, text)

// This service provides mock data for development/testing of the survey functionality.