import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'home_screen.dart';
import 'statistics_screen.dart';
import 'income_screen.dart';
import 'expense_screen.dart';
import 'loan_screen.dart';
import 'settings_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isMenuOpen = false;

  final List<Widget> _screens = const [
    HomeScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  void _toggleMenu() {
    setState(() => _isMenuOpen = !_isMenuOpen);
  }

  void _navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page)).then((_) {
      setState(() => _isMenuOpen = false);
    });
  }

  Widget _buildOptionButton({
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _screens[_currentIndex],

          // Dim background overlay when menu open
          if (_isMenuOpen)
            GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                color: Colors.black54,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          // Floating popup menu
          // Floating circular popup menu
          // Curved circular popup menu (no black background)
          Positioned(
            bottom: 100,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: AnimatedScale(
              scale: _isMenuOpen ? 1 : 0,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Top center - Income
                  Transform.translate(
                    offset: const Offset(0, -85),
                    child: _buildOptionButton(
                      color: Colors.greenAccent.shade400,
                      icon: FontAwesomeIcons.coins,
                      label: 'Income',
                      onTap: () => _navigateTo(const IncomeScreen()),
                    ),
                  ),

                  // Left upper diagonal - Expense
                  Transform.translate(
                    offset: const Offset(-75, -25),
                    child: _buildOptionButton(
                      color: Colors.orangeAccent.shade400,
                      icon: FontAwesomeIcons.fileInvoiceDollar,
                      label: 'Expense',
                      onTap: () => _navigateTo(const ExpenseScreen()),
                    ),
                  ),

                  // Right upper diagonal - Loan
                  Transform.translate(
                    offset: const Offset(75, -25),
                    child: _buildOptionButton(
                      color: Colors.blueAccent.shade400,
                      icon: FontAwesomeIcons.handHoldingDollar,
                      label: 'Loan',
                      onTap: () => _navigateTo(const LoanScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),

      // ✅ Bottom Navigation Bar (with inline + button)
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavIcon(Icons.home_filled, 0, accent),
              _buildNavIcon(Icons.bar_chart_rounded, 1, accent),

              // + Button inside nav bar
              GestureDetector(
                onTap: _toggleMenu,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isMenuOpen ? Icons.close_rounded : Icons.add_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),

              _buildNavIcon(Icons.settings_rounded, 2, accent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, Color accent) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          _isMenuOpen = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 26,
          color: isSelected ? accent : Colors.grey,
        ),
      ),
    );
  }
}
