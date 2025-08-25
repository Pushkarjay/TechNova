import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const _kKey = 'tn_notifications';
  List<String> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kKey) ?? <String>[];
    if (!mounted) return;
    setState(() => _items = list.reversed.toList());
  }

  Future<void> _clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
    if (!mounted) return;
    setState(() => _items = []);
  }

  Future<void> _addTest() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kKey) ?? <String>[];
    final now = DateTime.now();
    list.add('Test notification at ${now.toIso8601String()}');
    await prefs.setStringList(_kKey, list);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _items.isEmpty
          ? const Center(child: Text('No notifications'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) => ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(_items[i]),
              ),
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'addNotif',
            onPressed: _addTest,
            label: const Text('Add test'),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            heroTag: 'clearNotif',
            onPressed: _clear,
            label: const Text('Clear'),
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
