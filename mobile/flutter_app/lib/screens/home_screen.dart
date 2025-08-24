import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';
import '../services/sync_service.dart';
import 'profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/local_storage.dart';
import '../services/sample_data.dart';

class HomeScreen extends StatefulWidget {
  final List<CameraDescription>? cameras;
  const HomeScreen({super.key, this.cameras});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _pending = 0;
  final SyncService _sync = SyncService();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _refreshPending();
  }

  Future<void> _refreshPending() async {
    final count = await _sync.pendingCount();
    if (mounted) setState(() => _pending = count);
  }

  Future<void> _doSync() async {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Sync started')));
    await _sync.syncPendingReports();
    await _refreshPending();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Sync complete')));
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_selectedIndex == 0) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                if (widget.cameras != null && widget.cameras!.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CameraScreen(cameras: widget.cameras!),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cameras not available.')),
                  );
                }
              },
              child: const Text('Report a Billboard'),
            ),
            const SizedBox(height: 20),
            Text('Pending reports: $_pending',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pending > 0 ? _doSync : null,
              icon: const Icon(Icons.sync),
              label: const Text('Sync Now'),
            ),
          ],
        ),
      );
    } else if (_selectedIndex == 1) {
      body = const ProfileScreen();
    } else {
      body = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Open Dashboard in Browser'),
              onPressed: () async {
                final uri = Uri.parse('http://localhost:8000');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cannot open browser')));
                }
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_box),
              label: const Text('Seed Demo Reports (local)'),
              onPressed: () async {
                await SampleData.seedLocalReports();
                await _refreshPending();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seeded demo reports')));
                setState(() {});
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.sync),
              label: const Text('Sync Now'),
              onPressed: _pending > 0 ? _doSync : null,
            ),
            const SizedBox(height: 20),
            const Text('Local Pending Reports:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: LocalStorage().getReports(),
                builder: (context, snap) {
                  if (!snap.hasData)
                    return const Center(child: CircularProgressIndicator());
                  final items = snap.data!;
                  if (items.isEmpty) return const Text('No pending reports');
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final it = items[i];
                      return ListTile(
                        title: Text(it['violationType'] ?? 'Report'),
                        subtitle: Text(it['aiSuggestion'] ?? ''),
                        trailing:
                            Text(it['synced'] == 0 ? 'Pending' : 'Synced'),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Billboard Tipper')),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Dashboard'),
        ],
      ),
    );
  }
}
