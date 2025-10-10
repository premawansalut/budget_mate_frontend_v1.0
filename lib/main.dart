import 'package:budget_mate_frontend_v1/screens/home_screen.dart';
import 'package:budget_mate_frontend_v1/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'screens/income_screen.dart';
import 'screens/main_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  runApp(
    ChangeNotifierProvider(
      create: (_) => settingsProvider,
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

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkPrimary,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      colorScheme: ColorScheme.fromSwatch(
        brightness: Brightness.dark,
        accentColor: accent,
      ),
    );

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
      colorScheme: ColorScheme.fromSwatch(
        brightness: Brightness.light,
        accentColor: accent,
      ),
    );


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Budget Mate',
      themeMode: settings.themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      initialRoute: '/',
      routes: {
        '/': (_) => const MainWrapper(),
        '/income': (_) => const IncomeScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
