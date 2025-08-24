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
        TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Display name'),
          onChanged: (v) => _username = v,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Sign Up / Login (local)'),
          onPressed: () {
            if (controller.text.isNotEmpty) {
              setState(() {
                _username = controller.text;
                _loggedIn = true;
              });
            }
          },
        ),
        const SizedBox(height: 12),
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
          onPressed: () {
            setState(() {
              _loggedIn = false;
              _username = '';
            });
          },
        )
      ],
    );
  }
}
