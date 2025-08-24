import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Cloudinary helper that avoids accessing `dotenv.env` at library load /
/// field-initialization time to prevent NotInitializedError when dotenv
/// hasn't been loaded yet (for example during some hot-reload/hot-restart
/// scenarios). It will attempt to read values from dotenv but fall back to
/// constructor arguments when dotenv is not available.
class CloudinaryService {
  late final CloudinaryPublic cloudinary;
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

    // Initialize CloudinaryPublic with the resolved cloud name and preset.
    cloudinary = CloudinaryPublic(cn, this.uploadPreset, cache: false);
  }

  Future<String?> uploadFile(String imagePath) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imagePath,
            resourceType: CloudinaryResourceType.Image),
      );
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      print(e.message);
      print(e.request);
      return null;
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }
}
