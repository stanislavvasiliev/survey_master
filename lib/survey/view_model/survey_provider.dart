import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/survey_model.dart';
import '../services/survey_service.dart';
import '../view/widgets/survey_response_model.dart';

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

  Future<void> updateSurvey(Survey updatedSurvey) async {
    state = state.map((survey) {
      return survey.id == updatedSurvey.id ? updatedSurvey : survey;
    }).toList();
  }

  Future<void> addSurvey(Survey newSurvey) async {
    state = [...state, newSurvey];
  }
}

final selectedSurveyProvider = StateProvider<Survey?>((ref) => null);

final surveyResponseProvider =
StateNotifierProvider<SurveyResponseNotifier, List<SurveyResponse>>((ref) {
  return SurveyResponseNotifier();
});