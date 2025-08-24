import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/local_storage.dart';
import '../services/sync_service.dart';
import '../services/sample_data.dart';

class ReviewScreen extends StatefulWidget {
  final String imagePath;
  const ReviewScreen({super.key, required this.imagePath});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  String? _suggestion;
  String? _violationType;
  final List<String> _violationTypes = [
    'Size',
    'Placement',
    'Hazard',
    'Content'
  ];
  bool _submitting = false;
  File get _imageFile => File(widget.imagePath);

  @override
  void initState() {
    super.initState();
    final sample = SampleData.getRandomReport();
    _suggestion = sample['aiSuggestion'];
    _violationType = sample['violationType'];
  }

  Future<Map<String, double>?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location services are disabled. Please enable the services')));
      }
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')));
        }
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.')));
      }
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return {'lat': position.latitude, 'lng': position.longitude};
    } catch (e) {
      debugPrint('Could not get location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error getting location: $e')));
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_imageFile.existsSync())
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_imageFile,
                            height: 300, fit: BoxFit.cover),
                      ),
                    const SizedBox(height: 12),
                    Text('AI suggestion',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(_suggestion ?? 'Processing...',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _violationType,
                      items: _violationTypes
                          .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _violationType = v ?? ''),
                      decoration:
                          const InputDecoration(labelText: 'Violation Type'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text('Submit Report'),
                      onPressed: _submitting
                          ? null
                          : () async {
                              setState(() => _submitting = true);
                              final loc = await _getCurrentLocation();
                              await LocalStorage().insertReport({
                                'title': _violationType,
                                'description': _suggestion ?? '',
                                'lat': loc?['lat'],
                                'lng': loc?['lng'],
                                'image_path': _imageFile.path,
                                'status': 0,
                              });
                              setState(() => _submitting = false);

                              // Attempt to sync but don't fail submission if sync errors.
                              try {
                                await SyncService().syncPendingReports();
                              } catch (e) {
                                // ignore sync errors for now; report is saved locally
                              }

                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Report submitted')),
                              );

                              // Give the user a moment to read the confirmation then close.
                              await Future.delayed(
                                  const Duration(milliseconds: 800));
                              if (mounted) Navigator.pop(context);
                            },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
