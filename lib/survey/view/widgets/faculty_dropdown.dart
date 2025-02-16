import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../models/faculty_model.dart';
import '../../view_model/faculties_provider.dart';

class FacultyMultiSelectDropdown extends ConsumerWidget {
  final List<EduInstitution> initialSelectedFaculties;
  final Function(List<EduInstitution>) onFacultiesSelected;

  const FacultyMultiSelectDropdown({
    required this.initialSelectedFaculties,
    required this.onFacultiesSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facultiesAsync = ref.watch(facultiesProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return facultiesAsync.when(
      data: (faculties) {
        return MultiSelectDialogField<EduInstitution>(
          items: faculties
              .map((faculty) =>
                  MultiSelectItem<EduInstitution>(faculty, faculty.name))
              .toList(),
          initialValue: initialSelectedFaculties,
          searchable: true,
          title: Text(
            'Обрати факультети',
          ),
          buttonText: Text(
            'Оберіть факультети',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          chipDisplay: MultiSelectChipDisplay(
            chipColor: colorScheme.primaryContainer,
            textStyle: TextStyle(color: colorScheme.onPrimaryContainer),
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(color: colorScheme.outline),
            borderRadius: BorderRadius.circular(4),
          ),
          dialogWidth: 600,
          dialogHeight: 500,
          onConfirm: (values) =>
              onFacultiesSelected(List<EduInstitution>.from(values)),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text(
        'Failed to load faculties',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
