import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_model/survey_provider.dart';
import '../widgets/settings_modal.dart';
import '../../services/date_formatter.dart';

class SurveySettingsWidget extends ConsumerWidget {
  final bool showButton;

  const SurveySettingsWidget({
    super.key,
    this.showButton = true, // Default value is true to show the button
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSurvey = ref.watch(selectedSurveyProvider);

    if (selectedSurvey == null) {
      return SnackBar(
        content: Text('Щось пішло не так'),
      );
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
                    'Статус Опитування: ${selectedSurvey.isActivated ? 'Активне' : 'Неактивне'}'),
                Text(
                    'Дата почтку: ${customFormatDate(selectedSurvey.startDate)}'),
                Text(
                    'Дата закінченння: ${customFormatDate(selectedSurvey.endDate)}'),
                Text('Факультет(и): ${selectedSurvey.faculty.join(", ")}'),
                Text('Група(и): ${selectedSurvey.group.join(", ")}'),
              ],
            ),
            if (showButton)
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

class SurveySettings extends ConsumerWidget {
  const SurveySettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SurveySettingsWidget(showButton: true);
  }
}

class SurveySettingsView extends ConsumerWidget {
  const SurveySettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SurveySettingsWidget(showButton: false);
  }
}
