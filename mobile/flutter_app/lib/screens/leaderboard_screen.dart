import 'package:flutter/material.dart';
import '../services/local_storage.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  Map<String, int> _counts = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await LocalStorage().getReports();
    final map = <String, int>{};
    for (final it in items) {
      final t = (it['violationType'] as String?) ?? 'Unknown';
      map[t] = (map[t] ?? 0) + 1;
    }
    if (!mounted) return;
    setState(() => _counts = map);
  }

  @override
  Widget build(BuildContext context) {
    final entries = _counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Scaffold(
      body: entries.isEmpty
          ? const Center(child: Text('No reports yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) {
                final e = entries[i];
                return ListTile(
                  leading: CircleAvatar(child: Text('${i + 1}')),
                  title: Text(e.key),
                  trailing: Text('${e.value}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _load,
        icon: const Icon(Icons.refresh),
        label: const Text('Refresh'),
      ),
    );
  }
}
