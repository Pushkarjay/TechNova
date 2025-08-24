import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    ThemeService.isDark.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService.isDark.value;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(isDark ? 'Dark (default)' : 'Light'),
            trailing: Switch(
              value: !isDark,
              onChanged: (v) {
                ThemeService.toggle();
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Export my reports'),
            subtitle: const Text(
                'Available in production (local export placeholder)'),
            trailing: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Export available in production')));
              },
              child: const Text('Export'),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Privacy & Data',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              'Reports are anonymous by default. Full export and deletion tools available in production.'),
        ],
      ),
    );
  }
}
