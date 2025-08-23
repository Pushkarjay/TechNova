import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class TFLiteService {
  Interpreter _interpreter;
  List<String> _labels;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('tflite_model.tflite');
      String labelsContent = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsContent.split('\n');
    } catch (e) {
      print('Failed to load model or labels.');
      print(e);
    }
  }

  Future<List> runModel(img.Image image) async {
    var input = _preprocessImage(image);
    var output = List.filled(1 * _labels.length, 0).reshape([1, _labels.length]);
    _interpreter.run(input, output);
    return _postprocessOutput(output);
  }

  Uint8List _preprocessImage(img.Image image) {
    img.Image resizedImage = img.copyResize(image, width: 224, height: 224);
    var imageBytes = resizedImage.getBytes();
    var buffer = Uint8List(224 * 224 * 3);
    int pixelIndex = 0;
    for (int i = 0; i < 224 * 224; i++) {
      buffer[pixelIndex++] = img.getRed(imageBytes[i]);
      buffer[pixelIndex++] = img.getGreen(imageBytes[i]);
      buffer[pixelIndex++] = img.getBlue(imageBytes[i]);
    }
    return buffer.buffer.asUint8List();
  }

  List _postprocessOutput(List output) {
    var results = <Map<String, dynamic>>[];
    for (int i = 0; i < _labels.length; i++) {
      if (output[0][i] > 0.5) { // Confidence threshold
        results.add({
          "label": _labels[i],
          "confidence": output[0][i],
        });
      }
    }
    results.sort((a, b) => b['confidence'].compareTo(a['confidence']));
    return results;
  }
}
