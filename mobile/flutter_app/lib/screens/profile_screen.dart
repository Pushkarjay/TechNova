import 'package:flutter/material.dart';
import '../services/sample_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loggedIn = false;
  String _username = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _loggedIn ? _buildLoggedIn() : _buildLoginForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    final controller = TextEditingController(text: _username);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Sign Up / Login'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            if (controller.text.isNotEmpty) {
              setState(() {
                _username = controller.text;
                _loggedIn = true;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a display name.')),
              );
            }
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Display name'),
          onChanged: (v) => _username = v,
        ),
        const Divider(height: 32),
        const Text('Demo Actions',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.cloud_download),
          label: const Text('Seed Demo Reports'),
          onPressed: () async {
            await SampleData.seedLocalReports();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Seeded demo reports locally')));
            }
          },
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.person_search),
          label: const Text('Load Sample Profile'),
          onPressed: () {
            final user = SampleData.sampleUser();
            setState(() {
              _username = user['displayName'];
              _loggedIn = true;
            });
          },
        ),
        const Divider(height: 32),
        ElevatedButton.icon(
          icon: const Icon(Icons.settings),
          label: const Text('Settings'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Settings'),
                content: const Text(
                    'Settings placeholder. No real settings in prototype.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoggedIn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Signed in as: $_username',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Confirm Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              setState(() {
                _loggedIn = false;
                _username = '';
              });
            }
          },
        ),
        const Divider(height: 32),
        ElevatedButton.icon(
          icon: const Icon(Icons.settings),
          label: const Text('Settings'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Settings'),
                content: const Text(
                    'Settings placeholder. No real settings in prototype.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
