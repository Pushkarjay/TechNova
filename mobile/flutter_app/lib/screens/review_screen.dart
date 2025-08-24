import 'dart:io';
import 'package:flutter/material.dart';
import '../services/local_storage.dart';
import '../services/sync_service.dart';
import 'package:geolocator/geolocator.dart';
import '../services/tfservice.dart';
import '../services/sample_data.dart';
import 'package:image/image.dart' as img;

class ReviewScreen extends StatefulWidget {
  final String imagePath;
  const ReviewScreen({super.key, required this.imagePath});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  String? _violationType;
  Position? _currentPosition;
  final TFLiteService _tfLiteService = TFLiteService();
  List? _recognitions;
  bool _loading = true;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    // Cloudinary uploads are handled by SyncService during sync; keep firestore instance if needed later
    _getCurrentLocation();
    // Defensive model load: continue even if model is missing or fails
    _tfLiteService.loadModel().then((value) {
      predict();
    }).catchError((e) {
      debugPrint('TFLite load failed: $e');
      // still allow user to submit without model
      if (mounted) setState(() => _loading = false);
    });
  }

  Future<void> predict() async {
    try {
      if (widget.imagePath.startsWith('http')) {
        // Can't run local TF model on a remote image here in prototype.
        // Leave recognitions null and allow user to tap the image to load a sample.
        return;
      }

      final bytes = await File(widget.imagePath).readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      if (image != null) {
        var recognitions = await _tfLiteService.runModel(image);
        if (mounted) {
          setState(() {
            _recognitions = recognitions;
          });
        }
      }
    } catch (e) {
      debugPrint('Predict failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location services are disabled. Please enable the services')));
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')));
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.')));
      }
      return;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      debugPrint("Could not get location: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error getting location: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review and Report')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Load a random demo suggestion and fill form
                      final sample = SampleData.getRandomReport();
                      setState(() {
                        _violationType = sample['violationType'];
                        _recognitions = [
                          {'label': sample['aiSuggestion']}
                        ];
                        if (_currentPosition == null) {
                          _currentPosition = Position(
                            latitude: sample['lat'],
                            longitude: sample['lng'],
                            timestamp: DateTime.now(),
                            accuracy: 0.0,
                            altitude: 0.0,
                            heading: 0.0,
                            speed: 0.0,
                            speedAccuracy: 0.0,
                            altitudeAccuracy: 0.0,
                            headingAccuracy: 0.0,
                          );
                        }
                      });
                    },
                    child: widget.imagePath.startsWith('http')
                        ? Image.network(widget.imagePath)
                        : Image.file(File(widget.imagePath)),
                  ),
                  if (_recognitions != null && _recognitions!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          'AI Suggestion: ${_recognitions![0]['label']}',
                          style: Theme.of(context).textTheme.titleLarge),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Confirm Violation Type:',
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  DropdownButton<String>(
                    value: _violationType,
                    hint: const Text('Select Violation'),
                    onChanged: (String? newValue) {
                      setState(() {
                        _violationType = newValue;
                      });
                    },
                    items: <String>['Size', 'Placement', 'Hazard', 'Content']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  if (_currentPosition != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          'Location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}'),
                    ),
                  _uploading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: (_violationType != null)
                              ? () async {
                                  setState(() {
                                    _uploading = true;
                                  });

                                  final aiSuggestion = _recognitions != null &&
                                          _recognitions!.isNotEmpty
                                      ? _recognitions![0]['label']
                                      : 'N/A';

                                  // If we don't have a GPS position, use a sample report location
                                  final sample = (_currentPosition == null)
                                      ? SampleData.getRandomReport()
                                      : null;

                                  final lat = _currentPosition?.latitude ??
                                      sample!['lat'];
                                  final lng = _currentPosition?.longitude ??
                                      sample!['lng'];

                                  // Insert into local DB for offline-first behavior
                                  final local = LocalStorage();
                                  await local.insertReport({
                                    'imagePath': widget.imagePath,
                                    'violationType': _violationType,
                                    'aiSuggestion': aiSuggestion,
                                    'lat': lat,
                                    'lng': lng,
                                    'timestamp':
                                        DateTime.now().toIso8601String(),
                                    'synced': 0,
                                  });

                                  // Trigger an immediate user-initiated sync (not background)
                                  try {
                                    await SyncService().syncPendingReports();
                                    if (mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text('Report Submitted!')));
                                    }
                                  } catch (e) {
                                    debugPrint('Sync failed: $e');
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Saved locally. Will sync later.')));
                                    }
                                  }

                                  if (mounted) {
                                    setState(() {
                                      _uploading = false;
                                    });
                                  }
                                }
                              : null,
                          child: const Text('Submit Report'),
                        )
                ],
              ),
            ),
    );
  }
}
