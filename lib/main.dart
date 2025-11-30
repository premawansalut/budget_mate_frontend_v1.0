import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/settings_provider.dart';
import 'screens/login_screen.dart';
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

  // ✅ Check if user is already logged in
  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    const darkPrimary = Color(0xFF1B1D2B);
    const accent = Color(0xFF8B5CF6);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Budget Mate',
      themeMode: settings.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: accent,
        colorScheme: ColorScheme.fromSwatch(
          accentColor: accent,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkPrimary,
        colorScheme: ColorScheme.fromSwatch(
          accentColor: accent,
          brightness: Brightness.dark,
        ),
      ),

      // ✅ Automatically decide whether to show Login or MainWrapper
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          // Show loading indicator while checking login status
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: accent),
              ),
            );
          }

          // If logged in → go to MainWrapper, else → LoginScreen
          if (snapshot.data == true) {
            return const MainWrapper();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
