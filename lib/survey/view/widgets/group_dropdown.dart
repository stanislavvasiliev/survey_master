import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../../models/faculty_model.dart';

class GroupMultiSelectDropdown extends ConsumerStatefulWidget {
  final List<EduInstitution> selectedFaculties;
  final List<String> initialGroups;
  final void Function(List<String>) onGroupsSelected;

  const GroupMultiSelectDropdown({
    Key? key,
    required this.selectedFaculties,
    required this.onGroupsSelected,
    this.initialGroups = const [],
  }) : super(key: key);

  @override
  ConsumerState<GroupMultiSelectDropdown> createState() =>
      _GroupMultiSelectDropdownState();
}

class _GroupMultiSelectDropdownState
    extends ConsumerState<GroupMultiSelectDropdown> {
  // Keep track of selected groups internally
  List<String> _selectedGroups = [];
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize selected groups only once
    if (!_isInitialized) {
      _initializeGroups();
      _isInitialized = true;
    }
  }

  @override
  void didUpdateWidget(GroupMultiSelectDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If selected faculties change, we need to update available groups
    if (!listEquals(oldWidget.selectedFaculties, widget.selectedFaculties)) {
      _updateGroupsAfterFacultyChange();
    }
  }

  // Initialize groups with the initial values that are available in selected faculties
  void _initializeGroups() {
    final availableGroups = widget.selectedFaculties
        .expand((faculty) => faculty.groups)
        .toSet()
        .toList();

    // Filter initial groups to only include those that are still available
    _selectedGroups = widget.initialGroups
        .where((group) => availableGroups.contains(group))
        .toList();

    // Notify parent about initial selection
    widget.onGroupsSelected(_selectedGroups);
  }

  // Update groups when faculties change
  void _updateGroupsAfterFacultyChange() {
    final availableGroups = widget.selectedFaculties
        .expand((faculty) => faculty.groups)
        .toSet()
        .toList();

    // Keep only the groups that are still available after faculty change
    setState(() {
      _selectedGroups = _selectedGroups
          .where((group) => availableGroups.contains(group))
          .toList();
    });

    // Notify parent about the updated selection
    widget.onGroupsSelected(_selectedGroups);
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if no faculties are selected
    if (widget.selectedFaculties.isEmpty) {
      return Container();
    }

    // Get all available groups from selected faculties
    final availableGroups = widget.selectedFaculties
        .expand((faculty) => faculty.groups)
        .toSet()
        .toList();

    // Convert current selection to a set for easier lookup
    final selectedGroupsSet = _selectedGroups.toSet();

    return MultiDropdown<String>(
      items: availableGroups
          .map((group) => DropdownItem(
                label: group,
                value: group,
                selected: selectedGroupsSet.contains(group), // Pre-select items
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
      onSelectionChange: (selectedGroups) {
        setState(() {
          _selectedGroups = selectedGroups;
        });
        widget.onGroupsSelected(selectedGroups);
      },
    );
  }
}
