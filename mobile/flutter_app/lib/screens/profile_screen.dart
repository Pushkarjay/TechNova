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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loggedIn ? _buildLoggedIn() : _buildLoginForm(),
      ),
    );
  }

  Widget _buildLoginForm() {
    final controller = TextEditingController(text: _username);
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Display name'),
          onChanged: (v) => _username = v,
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              setState(() {
                _username = controller.text;
                _loggedIn = true;
              });
            }
          },
          child: const Text('Sign Up / Login (local)'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () async {
            // seed demo sample reports into local DB
            await SampleData.seedLocalReports();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Seeded demo reports locally')));
            }
          },
          child: const Text('Seed Demo Reports'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            final user = SampleData.sampleUser();
            setState(() {
              _username = user['displayName'];
              _loggedIn = true;
            });
          },
          child: const Text('Load Sample Profile'),
        ),
      ],
    );
  }

  Widget _buildLoggedIn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Signed in as: $_username'),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _loggedIn = false;
              _username = '';
            });
          },
          child: const Text('Logout'),
        )
      ],
    );
  }
}
