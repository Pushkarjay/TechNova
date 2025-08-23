import 'dart:io';
import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  final String imagePath;
  ReviewScreen({this.imagePath});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  String _violationType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Review and Report')),
      body: Column(
        children: [
          Image.file(File(widget.imagePath)),
          Text('Select Violation Type:'),
          DropdownButton<String>(
            value: _violationType,
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
          ElevatedButton(
            onPressed: () {
              // TODO: Implement report submission
            },
            child: Text('Submit Report'),
          )
        ],
      ),
    );
  }
}
