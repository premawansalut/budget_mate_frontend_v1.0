import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> currencies = ['€', '\$', '₨', '£', '¥'];
  String? _userName;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Budget Mate User';
      _userEmail = prefs.getString('email') ?? '';
    });
  }

  Widget _buildHeader(Color accent) {
    final name = _userName ?? 'Budget Mate User';
    final email = _userEmail ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'B';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, accent.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.18),
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: const [
                Icon(Icons.verified_user, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(
                  "Profile",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required List<Widget> children,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final accent = Theme.of(context).colorScheme.secondary;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ?? Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(accent),
            const SizedBox(height: 20),
            _buildCard(
              title: "Preferences",
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Currency",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Current: ${settings.currency}",
                          style: TextStyle(color: textColor.withOpacity(0.65)),
                        ),
                      ],
                    ),
                    DropdownButton<String>(
                      value: settings.currency,
                      borderRadius: BorderRadius.circular(12),
                      items: currencies
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) settings.setCurrency(value);
                      },
                    ),
                  ],
                ),
                const Divider(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Dark Theme",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          settings.themeMode == ThemeMode.dark
                              ? "Enabled"
                              : "Disabled",
                          style: TextStyle(color: textColor.withOpacity(0.65)),
                        ),
                      ],
                    ),
                    Switch(
                      value: settings.themeMode == ThemeMode.dark,
                      activeColor: accent,
                      onChanged: (v) => settings.toggleTheme(v),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildCard(
              title: "Security",
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: Colors.redAccent,
                    ),
                  ),
                  title: const Text(
                    "Logout",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text("Sign out of your account"),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: textColor.withOpacity(0.6),
                  ),
                  onTap: () async {
                    await ApiService.logoutUser();
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
