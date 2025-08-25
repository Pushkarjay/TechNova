import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';
import 'review_screen.dart';
import '../services/sync_service.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'leaderboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
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
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Sync started')));
    await _sync.syncPendingReports();
    await _refreshPending();
    if (!mounted) return;
    messenger.showSnackBar(const SnackBar(content: Text('Sync complete')));
    // persist a minimal notification for the notifications tab
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('tn_notifications') ?? <String>[];
      list.add('Sync completed at ${DateTime.now().toIso8601String()}');
      await prefs.setStringList('tn_notifications', list);
    } catch (_) {
      // ignore
    }
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
              onPressed: () async {
                final outerContext = context;
                showModalBottomSheet(
                  context: outerContext,
                  builder: (sheetContext) {
                    return SafeArea(
                      child: Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Take Photo'),
                            onTap: () {
                              Navigator.pop(sheetContext);
                              if (widget.cameras != null &&
                                  widget.cameras!.isNotEmpty) {
                                Navigator.of(outerContext).push(
                                  MaterialPageRoute(
                                    builder: (ctx) =>
                                        CameraScreen(cameras: widget.cameras!),
                                  ),
                                );
                              } else {
                                if (!mounted) return;
                                ScaffoldMessenger.of(outerContext).showSnackBar(
                                  const SnackBar(
                                      content: Text('Cameras not available.')),
                                );
                              }
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Choose from Gallery'),
                            onTap: () async {
                              Navigator.pop(sheetContext);
                              final picker = ImagePicker();
                              final navigator = Navigator.of(outerContext);
                              final picked = await picker.pickImage(
                                  source: ImageSource.gallery);
                              if (picked != null) {
                                if (!mounted) return;
                                navigator.push(
                                  MaterialPageRoute(
                                    builder: (ctx) =>
                                        ReviewScreen(imagePath: picked.path),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
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
    } else if (_selectedIndex == 2) {
      body = const LeaderboardScreen();
    } else if (_selectedIndex == 3) {
      body = const NotificationsScreen();
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
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
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
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withAlpha((0.4 * 255).toInt()),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Dashboard'),
        ],
      ),
    );
  }

  Future<void> _openDashboard() async {
    final dashboardUrl =
        Uri.parse('https://pushkarjay.github.io/TechNova/dashboard/');
    try {
      final can = await canLaunchUrl(dashboardUrl);
      if (!mounted) return;
      if (can) {
        await launchUrl(dashboardUrl, mode: LaunchMode.externalApplication);
      } else {
        await Clipboard.setData(ClipboardData(text: dashboardUrl.toString()));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Could not open dashboard automatically — URL copied to clipboard. Paste it in your browser.')));
        });
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: dashboardUrl.toString()));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Cannot open dashboard. URL copied to clipboard.')));
      });
    }
  }

  Future<void> _seedSampleData() async {
    final messenger = ScaffoldMessenger.of(context);
    await SampleData.seedLocalReports();
    await _refreshPending();
    if (!mounted) return;
    messenger
        .showSnackBar(const SnackBar(content: Text('Seeded demo reports')));
    setState(() {});
  }

  Future<void> _listPending() async {
    final messenger = ScaffoldMessenger.of(context);
    final reports = await LocalStorage().getReports();
    final count = reports.length;
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text('Pending reports: $count')));
  }
}
