import 'dart:io';
import 'package:flutter/material.dart';
import '../services/local_storage.dart';
import '../services/firebase_sync.dart';
import 'package:geolocator/geolocator.dart';
import '../services/tfservice.dart';
import 'package:image/image.dart' as img;

class ReviewScreen extends StatefulWidget {
  final String imagePath;
  ReviewScreen({this.imagePath});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  String _violationType;
  final LocalStorage _localStorage = LocalStorage();
  final FirebaseSync _firebaseSync = FirebaseSync();
  Position _currentPosition;
  final TFLiteService _tfLiteService = TFLiteService();
  List _recognitions;
  bool _loading = true;

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
                  ElevatedButton(
                    onPressed: (_violationType != null && _currentPosition != null) ? () async {
                      Map<String, dynamic> report = {
                        'imagePath': widget.imagePath,
                        'violationType': _violationType,
                        'aiSuggestion': _recognitions != null && _recognitions.isNotEmpty ? _recognitions[0]['label'] : 'N/A',
                        'lat': _currentPosition.latitude,
                        'lng': _currentPosition.longitude,
                        'timestamp': DateTime.now().toIso8601String(),
                        'synced': 0,
                      };
                      await _localStorage.insertReport(report);
                      _firebaseSync.syncReports();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Report Saved!'))
                      );
                    } : null,
                    child: Text('Submit Report'),
                  )
                ],
              ),
            ),
    );
  }
}
