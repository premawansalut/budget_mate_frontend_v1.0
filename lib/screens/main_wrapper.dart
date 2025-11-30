import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'home_screen.dart';
import 'statistics/statistics_screen.dart';
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

  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Widget> _screens = const [
    HomeScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _safeNavigate(Widget page) async {
    setState(() => _isMenuOpen = false);
    _controller.reverse();
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Widget _buildNavIcon(IconData icon, int index, Color accent) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() {
        _currentIndex = index;
        _isMenuOpen = false;
        _controller.reverse();
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 26, color: isSelected ? accent : Colors.grey),
      ),
    );
  }

  Widget _buildOptionButton({
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: _isMenuOpen ? 1 : 0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.45),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(width: 14),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: .3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🧩 Floating stack menu (animated + fixed hitboxes)
  Widget _buildAnimatedStackMenu(Color accent) {
    final width = MediaQuery.of(context).size.width;
    final centerX = width / 2;

    return Positioned(
      bottom: 120,
      left: centerX - 100,
      child: IgnorePointer(
        ignoring: !_isMenuOpen,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final value = _animation.value.clamp(0.0, 1.0);
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: value,
                child: SizedBox(
                  width: 200,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [
                      // Loan
                      Positioned(
                        bottom: 0,
                        child: _buildOptionButton(
                          color: Colors.blue.shade700,
                          icon: FontAwesomeIcons.handHoldingDollar,
                          label: 'Loan',
                          onTap: () => _safeNavigate(const LoanScreen()),
                        ),
                      ),
                      // Expense
                      Positioned(
                        bottom: 80 * value,
                        child: _buildOptionButton(
                          color: Colors.orange.shade700,
                          icon: FontAwesomeIcons.fileInvoiceDollar,
                          label: 'Expense',
                          onTap: () => _safeNavigate(const ExpenseScreen()),
                        ),
                      ),
                      // Income
                      Positioned(
                        bottom: 160 * value,
                        child: _buildOptionButton(
                          color: Colors.green.shade600,
                          icon: FontAwesomeIcons.coins,
                          label: 'Income',
                          onTap: () => _safeNavigate(const IncomeScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 🌫️ Blur overlay
  Widget _buildBlurOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _toggleMenu,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: _isMenuOpen ? 1 : 0,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),
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
          if (_isMenuOpen) _buildBlurOverlay(),
          _buildAnimatedStackMenu(accent),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 75,
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
              GestureDetector(
                onTap: _toggleMenu,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.45),
                        blurRadius: 18,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isMenuOpen ? Icons.close_rounded : Icons.add_rounded,
                    color: Colors.white,
                    size: 34,
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
}
