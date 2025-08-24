import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

/// Cloudinary helper that avoids accessing `dotenv.env` at library load /
/// field-initialization time to prevent NotInitializedError when dotenv
/// hasn't been loaded yet (for example during some hot-reload/hot-restart
/// scenarios). It will attempt to read values from dotenv but fall back to
/// constructor arguments when dotenv is not available.
class CloudinaryService {
  CloudinaryPublic? cloudinary;
  final String uploadPreset;

  CloudinaryService({String? cloudName, String? uploadPreset})
      : uploadPreset = uploadPreset ?? 'Technova' {
    String cn = '';
    try {
      // Access dotenv inside try/catch: if dotenv hasn't been initialized
      // this will throw and we fall back to constructor args.
      cn = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    } catch (e) {
      cn = cloudName ?? '';
    }

    // Final fallback: prefer provided constructor value if dotenv value is
    // empty.
    if (cn.isEmpty) {
      cn = cloudName ?? '';
    }

    // Initialize CloudinaryPublic only if we have a cloud name. Otherwise
    // leave it uninitialized and `uploadFile` will return null so SyncService
    // can fall back to placeholder behavior.
    if (cn.isNotEmpty) {
      cloudinary = CloudinaryPublic(cn, this.uploadPreset, cache: false);
    }
  }

  Future<String?> uploadFile(String imagePath) async {
    if (cloudinary == null) {
      // Cloudinary not configured; return a placeholder image URL so the
      // report can still be created in Firestore for demo purposes.
      return 'https://example.com/placeholder-image.jpg';
    }

    try {
      // If the imagePath looks like a remote URL, just return it (already hosted)
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        return imagePath;
      }

      CloudinaryResponse response = await cloudinary!.uploadFile(
        CloudinaryFile.fromFile(imagePath,
            resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      debugPrint(e.message);
      debugPrint(e.request.toString());
      return null;
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      return null;
    }
  }
}
