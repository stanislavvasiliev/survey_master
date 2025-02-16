import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/faculty_model.dart';

final facultiesProvider = FutureProvider<List<EduInstitution>>((ref) async {
  try {
    return await fetchFaculties();
  } catch (e) {
    throw Exception("Error fetching faculties: $e");
  }
});

Future<List<EduInstitution>> fetchFaculties() async {
  await Future.delayed(Duration(seconds: 0));
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

final selectedFacultiesProvider =
    StateProvider<List<EduInstitution>>((ref) => []);

final filteredGroupsProvider = FutureProvider<List<String>>((ref) async {
  final faculties = await fetchFaculties();
  return faculties.expand((faculty) => faculty.groups).toList();
});
