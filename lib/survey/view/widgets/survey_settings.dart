import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_model/survey_provider.dart';
import '../widgets/settings_modal.dart';
import '../../services/date_formatter.dart';

class SurveySettings extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSurvey = ref.watch(selectedSurveyProvider);

    if (selectedSurvey == null) {
      return SnackBar(
          content: Text(
        'Щось пішло не так',
      ));
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Налаштування',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text(
                    'Start Date: ${customFormatDate(selectedSurvey.startDate)}'),
                Text('End Date: ${customFormatDate(selectedSurvey.endDate)}'),
                Text('Faculty: ${selectedSurvey.faculty.join(", ")}'),
                Text('Course: ${selectedSurvey.course.join(", ")}'),
                Text('Group: ${selectedSurvey.group.join(", ")}'),
              ],
            ),
            Column(
              children: [
                FilledButton.icon(
                  onPressed: () {
                    showCustomDialog(context);
                  },
                  icon: Icon(Icons.settings),
                  label: Text('Налаштування опитування'),
                  style: ElevatedButton.styleFrom(elevation: 8),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(),
      ],
    );
  }
}

class SurveySettingsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSurvey = ref.watch(selectedSurveyProvider);

    if (selectedSurvey == null) {
      return SnackBar(
          content: Text(
        'Щось пішло не так',
      ));
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Налаштування',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text(
                    'Start Date: ${customFormatDate(selectedSurvey.startDate)}'),
                Text('End Date: ${customFormatDate(selectedSurvey.endDate)}'),
                Text('Faculty: ${selectedSurvey.faculty.join(", ")}'),
                Text('Course: ${selectedSurvey.course.join(", ")}'),
                Text('Group: ${selectedSurvey.group.join(", ")}'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(),
      ],
    );
  }
}
