import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'local_storage.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseSync {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final LocalStorage _localStorage = LocalStorage();

  Future<void> syncReports() async {
    await Firebase.initializeApp();
    var reports = await _localStorage.getReports();
    for (var report in reports) {
      File imageFile = File(report['imagePath']);
      String fileName = imageFile.path.split('/').last;
      try {
        await _storage.ref('uploads/$fileName').putFile(imageFile);
        String downloadURL =
            await _storage.ref('uploads/$fileName').getDownloadURL();
        await _firestore.collection('reports').add({
          'imageUrl': downloadURL,
          'violationType': report['violationType'],
          'location': GeoPoint(report['lat'], report['lng']),
          'timestamp': DateTime.parse(report['timestamp']),
        });
        await _localStorage.updateReport(report['id']);
      } catch (e) {
        print(e);
      }
    }
  }
}
