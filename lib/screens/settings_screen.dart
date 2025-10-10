import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<String> currencies = ['€', '\$', '₨', '£', '¥'];

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            const Text(
              "General",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),

            // Currency Selection
            ListTile(
              title: const Text("Currency"),
              subtitle: Text("Current: ${settings.currency}"),
              trailing: DropdownButton<String>(
                value: settings.currency,
                items: currencies.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(c, style: const TextStyle(fontSize: 18)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    settings.setCurrency(value);
                  }
                },
              ),
            ),

            const Divider(),

            // Theme Toggle
            SwitchListTile(
              title: const Text("Dark Theme"),
              subtitle: Text(settings.themeMode == ThemeMode.dark
                  ? "Enabled"
                  : "Disabled"),
              value: settings.themeMode == ThemeMode.dark,
              onChanged: (value) => settings.toggleTheme(value),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }
}
