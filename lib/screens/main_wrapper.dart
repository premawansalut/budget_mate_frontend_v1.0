import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'home_screen.dart';
import 'income_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [

    HomeScreen(),
    StatisticsScreen(),
    IncomeScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.themeMode == ThemeMode.dark;
    final accent = const Color(0xFF8B5CF6);

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),

      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B1D2B) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
              child: GNav(
                rippleColor: accent.withOpacity(0.2),
                hoverColor: accent.withOpacity(0.1),
                gap: 6,
                activeColor: Colors.white,
                iconSize: 25,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                duration: const Duration(milliseconds: 400),
                tabBackgroundColor: accent,
                color: isDark ? Colors.white70 : Colors.black87,
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 12.5),

                tabs: const [
                  GButton(icon: Icons.home, text: 'Home'),
                  GButton(icon: Icons.bar_chart_rounded, text: 'Statistics'),
                  GButton(icon: Icons.add_circle_outline, text: 'Income'),
                  GButton(icon: Icons.account_balance_wallet_rounded, text: 'Budget'),
                  GButton(icon: Icons.settings, text: 'Settings'),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() => _selectedIndex = index);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
