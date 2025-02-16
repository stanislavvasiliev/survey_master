import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/faculty_model.dart';

// Future Provider for loading faculties
final facultiesProvider = FutureProvider<List<EduInstitution>>((ref) async {
  try {
    return await fetchFaculties();
  } catch (e) {
    throw Exception("Error fetching faculties: $e");
  }
});

// Fetching faculties (Simulated API call)
Future<List<EduInstitution>> fetchFaculties() async {
  await Future.delayed(Duration(seconds: 1)); // Simulate delay
  return [
    EduInstitution(
      name: "Біологічний факультет",
      groups: ["КН-101", "КН-102", "КН-103", "КН-201", "КН-202"],
      hashId: 'def456uvw1237890mnopqrstuvabcxyz',
    ),
    EduInstitution(
      name: "Географічний факультет",
      groups: ["ІНЖ-101", "ІНЖ-102", "ІНЖ-103", "ІНЖ-201", "ІНЖ-301"],
      hashId: 'abc123xyz4567890defghijklmnopqrstuv',
    ),
    EduInstitution(
      name: "Економічний факультет",
      groups: ["БІЗ-101", "БІЗ-102", "БІЗ-201", "БІЗ-301"],
      hashId: 'xyz789def1234567ghijklmnopqrstuvabc',
    ),
    EduInstitution(
      name: "Факультет Інформаційних технологій",
      groups: ["З-101", "З-102", "З-201", "З-301"],
      hashId: '12z789def1234567ghijklmnopqrstuvabc',
    ),
  ];
}

// State Provider for selected faculties
final selectedFacultiesProvider =
    StateProvider<List<EduInstitution>>((ref) => []);

// Derived Provider for filtered groups
final filteredGroupsProvider = Provider<List<String>>((ref) {
  final selectedFaculties = ref.watch(selectedFacultiesProvider);
  final facultiesAsync = ref.watch(facultiesProvider);

  return facultiesAsync.when(
    data: (faculties) {
      if (selectedFaculties.isEmpty) return [];
      return selectedFaculties.expand((faculty) => faculty.groups).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
