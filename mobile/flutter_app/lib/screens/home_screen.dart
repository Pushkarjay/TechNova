import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';
import '../services/sync_service.dart';
import 'profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter/services.dart';
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
      body = SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.public, size: 36),
                      title: Text('Dashboard'),
                      subtitle:
                          Text('Open the public dashboard or manage demo data'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.open_in_browser),
                          label: const Text('Open Dashboard'),
                          onPressed: _openDashboard,
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.cloud_download),
                          label: const Text('Seed Data'),
                          onPressed: _seedSampleData,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.list),
                      label: const Text('List Pending Reports'),
                      onPressed: _listPending,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Local Pending Reports:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: LocalStorage().getReports(),
              builder: (context, snap) {
                if (!snap.hasData)
                  return const Center(child: CircularProgressIndicator());
                final items = snap.data!;
                if (items.isEmpty) return const Text('No pending reports');
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final it = items[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.report),
                        title: Text(it['title'] ?? 'Report #${it['id'] ?? i}'),
                        subtitle: Text(it['description'] ?? ''),
                        trailing:
                            Text(it['status'] == 1 ? 'Synced' : 'Pending'),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Billboard Tipper',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: 20,
            color: Theme.of(context).colorScheme.primary,
            shadows: [
              Shadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 0),
              ),
            ],
          ),
        ),
      ),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Dashboard'),
        ],
      ),
    );
  }

  Future<void> _openDashboard() async {
    final candidates = <Uri>[];
    candidates.add(Uri.parse('http://10.0.128.248:8000'));
    candidates.add(Uri.parse('http://10.0.2.2:8000'));
    candidates.add(Uri.parse('http://localhost:8000'));
    try {
      final ifaces = await NetworkInterface.list();
      for (final iface in ifaces) {
        for (final addr in iface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            candidates.insert(0, Uri.parse('http://${addr.address}:8000'));
          }
        }
      }
    } catch (e) {}

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Trying to open dashboard at ${candidates.first}')));

    bool opened = false;
    for (final uri in candidates) {
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          opened = true;
          break;
        }
        final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (ok) {
          opened = true;
          break;
        }
      } catch (e) {
        continue;
      }
    }

    if (!opened) {
      try {
        await Clipboard.setData(
            ClipboardData(text: candidates.first.toString()));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Could not open dashboard automatically — URL copied to clipboard. Paste it in your phone browser.')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Cannot open dashboard. Make sure your PC and phone are on the same Wi‑Fi and run the dashboard server on port 8000.')));
      }
    }
  }

  Future<void> _seedSampleData() async {
    await SampleData.seedLocalReports();
    await _refreshPending();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Seeded demo reports')));
    setState(() {});
  }

  Future<void> _listPending() async {
    final reports = await LocalStorage().getReports();
    final count = reports.length;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Pending reports: $count')));
  }
}
