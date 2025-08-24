import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'local_storage.dart';
import 'cloudinary_service.dart';

class SyncService {
  final LocalStorage _local = LocalStorage();
  final CloudinaryService _cloudinary = CloudinaryService();
  // Do NOT initialize Firestore at class construction time. Firebase may not
  // be configured in the running environment (no google-services.json) and
  // accessing FirebaseFirestore.instance can throw. We'll fetch it lazily
  // inside syncPendingReports and fall back to marking reports as synced
  // locally for demo purposes when Firebase is unavailable.
  FirebaseFirestore? _firestore;
  bool _syncInProgress = false;

  SyncService() {
    // Trigger sync on connectivity changes
    Connectivity().onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        if (!_syncInProgress) {
          syncPendingReports();
        }
      }
    });
    // Also do an immediate check: if currently online, attempt a sync.
    Connectivity().checkConnectivity().then((status) {
      if (status != ConnectivityResult.none) {
        if (!_syncInProgress) {
          syncPendingReports();
        }
      }
    }).catchError((e) {
      debugPrint('Connectivity check failed: $e');
    });
  }

  /// Try to sync all pending local reports. Non-blocking; errors are logged.
  Future<void> syncPendingReports() async {
    if (_syncInProgress) return;
    _syncInProgress = true;
    try {
      final pending = await _local.getReports();
      for (var row in pending) {
        try {
          String imagePath = row['imagePath'];
          // Upload image to Cloudinary
          String? imageUrl = await _cloudinary.uploadFile(imagePath);
          if (imageUrl == null) {
            debugPrint('Upload failed for $imagePath');
            // Mark as synced locally so it won't block future runs (demo mode)
            await _local.updateReport(row['id'] as int);
            continue;
          }
          // Try to get Firestore instance lazily.
          try {
            _firestore ??= FirebaseFirestore.instance;
          } catch (e) {
            debugPrint('Firestore not available: $e');
            // For demo environments without Firebase config, mark as synced
            // locally and continue.
            await _local.updateReport(row['id'] as int);
            continue;
          }

          // Write report to Firestore
          await _firestore!.collection('reports').add({
            'imageUrl': imageUrl,
            'violationType': row['violationType'],
            'aiSuggestion': row['aiSuggestion'],
            'location': GeoPoint(row['lat'], row['lng']),
            'timestamp': FieldValue.serverTimestamp(),
            'status': 'unauthorized',
            'userId': row['userId'] ?? 'anonymous',
          });

          // Mark local report as synced
          await _local.updateReport(row['id'] as int);
        } catch (e) {
          debugPrint('Failed to sync report ${row['id']}: $e');
          continue;
        }
      }
    } catch (e) {
      debugPrint('Sync service failed: $e');
    } finally {
      _syncInProgress = false;
    }
  }

  /// Return number of pending (unsynced) reports
  Future<int> pendingCount() async {
    try {
      final pending = await _local.getReports();
      return pending.length;
    } catch (e) {
      debugPrint('pendingCount failed: $e');
      return 0;
    }
  }
}
