import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'screens/main_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  runApp(
    ChangeNotifierProvider.value(
      value: settingsProvider,
      child: const BudgetMateApp(),
    ),
  );
}

class BudgetMateApp extends StatelessWidget {
  const BudgetMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final darkPrimary = const Color(0xFF1B1D2B);
    final accent = const Color(0xFF8B5CF6);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Budget Mate',
      themeMode: settings.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: accent,
        colorScheme:
        ColorScheme.fromSwatch(accentColor: accent, brightness: Brightness.light),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkPrimary,
        colorScheme: ColorScheme.fromSwatch(
            accentColor: accent, brightness: Brightness.dark),
      ),
      home: const MainWrapper(),
    );
  }
}
