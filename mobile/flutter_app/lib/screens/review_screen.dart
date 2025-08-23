import 'dart:io';
import 'package:flutter/material.dart';
import '../services/local_storage.dart';
import '../services/cloudinary_service.dart';
import 'package:geolocator/geolocator.dart';
import '../services/tfservice.dart';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewScreen extends StatefulWidget {
  final String imagePath;
  ReviewScreen({this.imagePath});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  String _violationType;
  final LocalStorage _localStorage = LocalStorage();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Position _currentPosition;
  final TFLiteService _tfLiteService = TFLiteService();
  List _recognitions;
  bool _loading = true;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _tfLiteService.loadModel().then((value) {
      predict();
    });
  }

  Future<void> predict() async {
    img.Image image = img.decodeImage(File(widget.imagePath).readAsBytesSync());
    var recognitions = await _tfLiteService.runModel(image);
    setState(() {
      _recognitions = recognitions;
      _loading = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print("Could not get location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Review and Report')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Image.file(File(widget.imagePath)),
                  if (_recognitions != null && _recognitions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('AI Suggestion: ${_recognitions[0]['label']}', style: Theme.of(context).textTheme.headline6),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Confirm Violation Type:', style: Theme.of(context).textTheme.headline6),
                  ),
                  DropdownButton<String>(
                    value: _violationType,
                    hint: Text('Select Violation'),
                    onChanged: (String newValue) {
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
                      child: Text('Location: ${_currentPosition.latitude}, ${_currentPosition.longitude}'),
                    ),
                  _uploading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: (_violationType != null && _currentPosition != null)
                              ? () async {
                                  setState(() {
                                    _uploading = true;
                                  });
                                  String imageUrl = await _cloudinaryService.uploadFile(widget.imagePath);
                                  if (imageUrl != null) {
                                    await _firestore.collection('reports').add({
                                      'imageUrl': imageUrl,
                                      'violationType': _violationType,
                                      'aiSuggestion': _recognitions != null && _recognitions.isNotEmpty ? _recognitions[0]['label'] : 'N/A',
                                      'location': GeoPoint(_currentPosition.latitude, _currentPosition.longitude),
                                      'timestamp': FieldValue.serverTimestamp(),
                                    });
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Report Submitted!')));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload Failed. Please try again.')));
                                  }
                                  setState(() {
                                    _uploading = false;
                                  });
                                }
                              : null,
                          child: Text('Submit Report'),
                        )
                ],
              ),
            ),
    );
  }
}
