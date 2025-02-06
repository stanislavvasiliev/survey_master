import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_model/faculties_provider.dart';
import '../../models/faculty_model.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class FacultyMultiSelectDropdown extends ConsumerWidget {
  final void Function(List<EduInstitution>) onFacultiesSelected;

  const FacultyMultiSelectDropdown({
    super.key,
    required this.onFacultiesSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facultiesAsync = ref.watch(facultiesProvider);

    return facultiesAsync.when(
      data: (faculties) {
        return MultiDropdown<EduInstitution>(
          items: faculties
              .map((faculty) => DropdownItem(
                    label: faculty.name,
                    value: faculty,
                  ))
              .toList(),
          enabled: true,
          searchEnabled: true,
          chipDecoration: ChipDecoration(
            wrap: true,
            runSpacing: 2,
            spacing: 10,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          fieldDecoration: FieldDecoration(
            hintText: 'Виберіть факультети',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
          dropdownDecoration: DropdownDecoration(
            marginTop: 2,
            maxHeight: 500,
            backgroundColor: Theme.of(context).colorScheme.surface,
            header: Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Виберіть факультет(и)',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          dropdownItemDecoration: DropdownItemDecoration(
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedBackgroundColor:
                Theme.of(context).colorScheme.primaryContainer,
            textColor: Theme.of(context).colorScheme.onSurface,
            selectedTextColor: Theme.of(context).colorScheme.onPrimary,
            selectedIcon: Icon(
              Icons.check_box,
              color: Theme.of(context).colorScheme.primary,
            ),
            disabledIcon: Icon(
              Icons.lock,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: .12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select at least one faculty';
            }
            return null;
          },
          onSelectionChange: (selectedItems) {
            onFacultiesSelected(selectedItems);
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text("Failed to load faculties"),
      ),
    );
  }
}
