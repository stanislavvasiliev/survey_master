import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'survey/view/editor_screen.dart';
import 'survey/view/survey_screen.dart';
import 'theme.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const materialTheme = MaterialTheme(TextTheme());
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SurveyMaster',
        theme: materialTheme.lightMediumContrast(),
        darkTheme: materialTheme.darkMediumContrast(),
        themeMode:  ThemeMode.system,
      initialRoute: '/surveys',
      routes: {
        '/surveys': (context) => SurveyScreen(),
        '/editor': (context) => EditorScreen(),
      }
    );
  }
}