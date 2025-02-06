import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../../models/faculty_model.dart';

class GroupMultiSelectDropdown extends ConsumerWidget {
  final List<EduInstitution> selectedFaculties;

  GroupMultiSelectDropdown({Key? key, required this.selectedFaculties})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (selectedFaculties.isEmpty) {
      return Container();
    }

    List<String> availableGroups =
        selectedFaculties.expand((faculty) => faculty.groups).toSet().toList();

    return MultiDropdown<String>(
      items: availableGroups
          .map((group) => DropdownItem(label: group, value: group))
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
        hintText: 'Виберіть групи',
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
            'Виберіть групу(и)',
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
        selectedBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
        textColor: Theme.of(context).colorScheme.onSurface,
        selectedTextColor: Theme.of(context).colorScheme.onPrimary,
        selectedIcon: Icon(
          Icons.check_box,
          color: Theme.of(context).colorScheme.primary,
        ),
        disabledIcon: Icon(
          Icons.lock,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select at least one group';
        }
        return null;
      },
      onSelectionChange: (selectedItems) {
        debugPrint("Selected Groups: $selectedItems");
      },
    );
  }
}
