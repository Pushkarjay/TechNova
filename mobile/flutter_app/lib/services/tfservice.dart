import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class TFLiteService {
  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('model.tflite');
      String labelsContent = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsContent.split('\n');
    } catch (e) {
      print('Failed to load model or labels.');
      print(e);
    }
  }

  Future<List<Map<String, dynamic>>> runModel(img.Image image) async {
    if (_interpreter == null || _labels == null) {
      print("Model or labels not loaded");
      return [];
    }
    var input = _preprocessImage(image);
    var output = List.filled(
      1 * _labels!.length,
      0.0,
    ).reshape([1, _labels!.length]);
    _interpreter!.run(input, output);
    return _postprocessOutput(output);
  }

  Uint8List _preprocessImage(img.Image image) {
    img.Image resizedImage = img.copyResize(image, width: 224, height: 224);
    var imageBytes = resizedImage.getBytes();
    var buffer = Float32List(1 * 224 * 224 * 3);
    var bufferIndex = 0;
    for (var y = 0; y < resizedImage.height; y++) {
      for (var x = 0; x < resizedImage.width; x++) {
        var pixel = resizedImage.getPixel(x, y);
        buffer[bufferIndex++] = (pixel.r - 127.5) / 127.5;
        buffer[bufferIndex++] = (pixel.g - 127.5) / 127.5;
        buffer[bufferIndex++] = (pixel.b - 127.5) / 127.5;
      }
    }
    return buffer.buffer.asUint8List();
  }

  List<Map<String, dynamic>> _postprocessOutput(List<dynamic> output) {
    var results = <Map<String, dynamic>>[];
    if (_labels == null) return results;

    for (int i = 0; i < _labels!.length; i++) {
      if (output[0][i] > 0.5) {
        // Confidence threshold
        results.add({"label": _labels![i], "confidence": output[0][i]});
      }
    }
    results.sort(
      (a, b) =>
          (b['confidence'] as double).compareTo(a['confidence'] as double),
    );
    return results;
  }
}
