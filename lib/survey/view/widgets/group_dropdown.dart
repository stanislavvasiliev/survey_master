import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../../models/faculty_model.dart';

class GroupMultiSelectDropdown extends ConsumerStatefulWidget {
  final List<EduInstitution> selectedFaculties;
  final void Function(List<String>)? onGroupsSelected;
  final List<String> value; // Початково вибрані елементи
  final List<String> availableGroups;

  const GroupMultiSelectDropdown({
    super.key,
    required this.selectedFaculties,
    this.onGroupsSelected,
    required this.value,
    required this.availableGroups,
  });

  @override
  ConsumerState<GroupMultiSelectDropdown> createState() =>
      _GroupMultiSelectDropdownState();
}

class _GroupMultiSelectDropdownState
    extends ConsumerState<GroupMultiSelectDropdown> {
  late MultiSelectController<String> _controller;

  @override
  void initState() {
    super.initState();
    // Ініціалізуємо контролер без параметра `items`
    _controller = MultiSelectController<String>();

    // Встановлюємо початковий вибір елементів, якщо вони є
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.selectWhere((item) => widget.value.contains(item));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Формуємо список доступних груп на основі вибраних факультетів
    List<String> availableGroups = widget.selectedFaculties
        .expand((faculty) => faculty.groups)
        .toSet()
        .toList();

    return MultiDropdown<String>(
      controller: _controller, // Використовуємо контролер
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
        hintText: 'Групи обраних факультетів',
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
            'Групи обраних факультетів',
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
      onSelectionChange: (selectedItems) {
        // Викликаємо callback, якщо він є
        if (widget.onGroupsSelected != null) {
          widget.onGroupsSelected!(selectedItems);
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Будь ласка, оберіть хоча б одну групу';
        }
        return null;
      },
    );
  }
}
