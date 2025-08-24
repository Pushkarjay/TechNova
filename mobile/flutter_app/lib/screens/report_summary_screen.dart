import 'dart:io';
import 'package:flutter/material.dart';

class ReportSummaryScreen extends StatelessWidget {
  final String imagePath;
  final double? lat;
  final double? lng;
  final String status;
  const ReportSummaryScreen({
    super.key,
    required this.imagePath,
    required this.lat,
    required this.lng,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (File(imagePath).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    Image.file(File(imagePath), height: 220, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            Text('Status: $status',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Location:', style: Theme.of(context).textTheme.titleMedium),
            Text('Latitude: ${lat ?? "-"}'),
            Text('Longitude: ${lng ?? "-"}'),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.home),
              label: const Text('Back to Home'),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}
