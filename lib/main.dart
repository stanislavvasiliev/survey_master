import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:survey_master/survey/view/widgets/theme_switcher.dart';
import 'survey/view/editor_screen.dart';
import 'survey/view/survey_screen.dart';
import 'survey/view_model/theme_provider.dart';
import 'theme.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    const materialTheme = MaterialTheme(TextTheme());

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SurveyMaster',
      theme: materialTheme.lightMediumContrast(),
      darkTheme: materialTheme.darkMediumContrast(),
      themeMode: themeMode,
      home: MainScreen(), // Главный экран с глобальным AppBar
    );
  }
}

class MainScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('SurveyMaster', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        actions: [ThemeSwitcher()],
      ),
      body: Navigator(
        initialRoute: '/surveys',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/surveys':
              return MaterialPageRoute(builder: (_) => SurveyScreen());
            case '/editor':
              return MaterialPageRoute(builder: (_) => EditorScreen());
            default:
              return MaterialPageRoute(builder: (_) => SurveyScreen());
          }
        },
      ),
    );
  }
}
