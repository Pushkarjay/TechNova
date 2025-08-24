import 'dart:io';
import 'package:flutter/material.dart';
import '../services/cloudinary_service.dart';
import 'package:geolocator/geolocator.dart';
import '../services/tfservice.dart';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewScreen extends StatefulWidget {
  final String imagePath;
  const ReviewScreen({super.key, required this.imagePath});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  String? _violationType;
  late final CloudinaryService _cloudinaryService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Position? _currentPosition;
  final TFLiteService _tfLiteService = TFLiteService();
  List? _recognitions;
  bool _loading = true;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _cloudinaryService = CloudinaryService();
    _getCurrentLocation();
    _tfLiteService.loadModel().then((value) {
      predict();
    });
  }

  Future<void> predict() async {
    img.Image? image =
        img.decodeImage(File(widget.imagePath).readAsBytesSync());
    if (image != null) {
      var recognitions = await _tfLiteService.runModel(image);
      if (mounted) {
        setState(() {
          _recognitions = recognitions;
          _loading = false;
        });
      }
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
                  Image.file(File(widget.imagePath)),
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
                          onPressed: (_violationType != null &&
                                  _currentPosition != null)
                              ? () async {
                                  setState(() {
                                    _uploading = true;
                                  });
                                  String? imageUrl = await _cloudinaryService
                                      .uploadFile(widget.imagePath);
                                  if (imageUrl != null) {
                                    await _firestore.collection('reports').add({
                                      'imageUrl': imageUrl,
                                      'violationType': _violationType,
                                      'aiSuggestion': _recognitions != null &&
                                              _recognitions!.isNotEmpty
                                          ? _recognitions![0]['label']
                                          : 'N/A',
                                      'location': GeoPoint(
                                          _currentPosition!.latitude,
                                          _currentPosition!.longitude),
                                      'timestamp': FieldValue.serverTimestamp(),
                                    });
                                    if (mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content:
                                                  Text('Report Submitted!')));
                                    }
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Upload Failed. Please try again.')));
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
