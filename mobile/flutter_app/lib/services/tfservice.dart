import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  Interpreter _interpreter;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('tflite_model.tflite');
    } catch (e) {
      print('Failed to load model.');
      print(e);
    }
  }

  Future<List> runModel(var input) async {
    var output = List.filled(1 * 10, 0).reshape([1, 10]);
    _interpreter.run(input, output);
    return output;
  }
}
