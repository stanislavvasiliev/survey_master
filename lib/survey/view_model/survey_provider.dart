import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/survey_model.dart';
import '../services/survey_service.dart';

final surveyListProvider = FutureProvider<List<Survey>>((ref) async {
  final service = ref.read(surveyServiceProvider);
  return service.getSurveys();
});

final selectedSurveyProvider = StateProvider<Survey?>((ref) => null);
