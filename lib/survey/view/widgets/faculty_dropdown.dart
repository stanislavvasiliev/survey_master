import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../../view_model/faculties_provider.dart';
import '../../models/faculty_model.dart';

class FacultyMultiSelectDropdown extends StatefulWidget {
  final List<EduInstitution> initialSelectedFaculties;
  final Function(List<EduInstitution>) onFacultiesSelected;

  const FacultyMultiSelectDropdown({
    required this.initialSelectedFaculties,
    required this.onFacultiesSelected,
    Key? key,
  }) : super(key: key);

  @override
  _FacultyMultiSelectDropdownState createState() =>
      _FacultyMultiSelectDropdownState();
}

class _FacultyMultiSelectDropdownState
    extends State<FacultyMultiSelectDropdown> {
  late List<EduInstitution> selectedFaculties;

  @override
  void initState() {
    super.initState();
    selectedFaculties = widget.initialSelectedFaculties;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final facultiesAsync = ref.watch(facultiesProvider);

        return facultiesAsync.when(
          data: (faculties) {
            return DropdownButtonFormField<EduInstitution>(
              value:
                  selectedFaculties.isNotEmpty ? selectedFaculties.first : null,
              items: faculties.map((faculty) {
                return DropdownMenuItem<EduInstitution>(
                  value: faculty,
                  child: Text(faculty.name),
                );
              }).toList(),
              onChanged: (newSelection) {
                if (newSelection != null) {
                  setState(() {
                    selectedFaculties = [newSelection];
                  });
                  widget.onFacultiesSelected(selectedFaculties);
                }
              },
            );
          },
          loading: () => CircularProgressIndicator(),
          error: (error, _) => Text('Failed to load faculties'),
        );
      },
    );
  }
}
