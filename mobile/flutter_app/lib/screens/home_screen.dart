import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_screen.dart';
import '../services/firebase_sync.dart';

class HomeScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  HomeScreen({this.cameras});

  final FirebaseSync _firebaseSync = FirebaseSync();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Billboard Tipper'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CameraScreen(cameras: cameras),
                  ),
                );
              },
              child: Text('Report a Billboard'),
            ),
            ElevatedButton(
              onPressed: () {
                _firebaseSync.syncReports();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Syncing reports...'))
                );
              },
              child: Text('Sync Reports'),
            ),
          ],
        ),
      ),
    );
  }
}
