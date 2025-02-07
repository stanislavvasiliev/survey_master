import 'package:flutter_riverpod/flutter_riverpod.dart';

// Abstract base class for survey responses
abstract class BaseSurveyResponse {
  String get surveyId;
  DateTime get submissionDate;
  Map<String, dynamic> get answers;
  String? get respondentId; // Optional: track who submitted the response
}

// Concrete implementation
class SurveyResponse implements BaseSurveyResponse {
  @override
  final String surveyId;
  @override
  final DateTime submissionDate;
  @override
  final Map<String, dynamic> answers;
  @override
  final String? respondentId;

  SurveyResponse({
    required this.surveyId,
    required this.submissionDate,
    required this.answers,
    this.respondentId,
  });
}

// State notifier for managing survey responses
class SurveyResponseNotifier extends StateNotifier<List<SurveyResponse>> {
  SurveyResponseNotifier() : super([]);

  void addResponse(SurveyResponse response) {
    state = [...state, response];
  }

  List<SurveyResponse> getResponsesBySurveyId(String surveyId) {
    return state.where((response) => response.surveyId == surveyId).toList();
  }

  // Additional methods for future expansion
  void deleteResponse(String surveyId, DateTime submissionDate) {
    state = state
        .where((response) =>
    !(response.surveyId == surveyId &&
        response.submissionDate == submissionDate))
        .toList();
  }

  void clearResponses(String surveyId) {
    state = state.where((response) => response.surveyId != surveyId).toList();
  }
}
