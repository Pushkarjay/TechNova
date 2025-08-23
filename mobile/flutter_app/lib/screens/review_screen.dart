import 'dart:io';
import 'package:flutter/material.dart';
import '../services/local_storage.dart';
import '../services/firebase_sync.dart';
import 'package:geolocator/geolocator.dart';

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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.file(File(widget.imagePath)),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Select Violation Type:', style: Theme.of(context).textTheme.headline6),
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
