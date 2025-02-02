import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/survey_model.dart';
import '../services/survey_service.dart';

final surveyListProvider =
    StateNotifierProvider<SurveyNotifier, List<Survey>>((ref) {
  final service = ref.read(surveyServiceProvider);
  return SurveyNotifier(service);
});

class SurveyNotifier extends StateNotifier<List<Survey>> {
  final SurveyService _service;

  SurveyNotifier(this._service) : super([]) {
    _loadSurveys();
  }

  Future<void> _loadSurveys() async {
    state = await _service.getSurveys();
  }

  Future<void> deleteSurvey(String id) async {
    await _service.deleteSurvey(id);
    state = state.where((survey) => survey.id != id).toList();
  }
}

final selectedSurveyProvider = StateProvider<Survey?>((ref) => null);


// This Flutter code defines two providers using Riverpod for state management:

// surveyListProvider: A FutureProvider that asynchronously fetches a list of surveys


// Uses surveyServiceProvider to access the survey service
// Returns the result of getSurveys() method
// Automatically handles loading and error states
// Can be used to display a list of surveys in the UI


// selectedSurveyProvider: A StateProvider that tracks the currently selected survey


// Initially set to null
// Can be updated to store the selected survey
// Enables state management for survey selection across widgets

// Both providers can be accessed by widgets wrapped in a ProviderScope to manage survey data and selection state in the application.