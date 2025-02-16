import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../view_model/faculties_provider.dart';

class GroupMultiSelectDropdown extends ConsumerWidget {
  final List<String> initialSelectedGroups;
  final Function(List<String>) onGroupsSelected;

  const GroupMultiSelectDropdown({
    required this.initialSelectedGroups,
    required this.onGroupsSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredGroups = ref.watch(filteredGroupsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MultiSelectDialogField<String>(
      items: filteredGroups
          .map((group) => MultiSelectItem<String>(group, group))
          .toList(),
      initialValue: initialSelectedGroups,
      searchable: true,
      title: const Text('Обрати групи'),
      buttonText: Text(
        'Оберіть групи',
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
      onConfirm: (values) => onGroupsSelected(List<String>.from(values)),
    );
  }
}
