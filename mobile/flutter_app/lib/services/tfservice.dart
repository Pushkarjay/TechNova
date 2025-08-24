// Lightweight stub for the on-device TFLite service.
// The real implementation is optional for the demo build and requires the
// `tflite_flutter` dependency plus a model asset. To keep the app runnable
// without that dependency, we expose the same API surface but return empty
// results.

import 'package:image/image.dart' as img;

class TFLiteService {
  // No-op loader for demo/offline builds.
  Future<void> loadModel() async {
    // Intentionally left blank; app will continue without on-device inference.
    return;
  }

  // Returns an empty list when model is not present.
  Future<List<Map<String, dynamic>>> runModel(img.Image image) async {
    return <Map<String, dynamic>>[];
  }
}
