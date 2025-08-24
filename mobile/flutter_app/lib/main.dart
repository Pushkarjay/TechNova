import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load local environment variables from mobile/flutter_app/.env (ignored)
  // If the file doesn't exist, continue with empty/default env values.
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // `.env` is optional for local development; log and continue.
    print('dotenv.load failed (continuing without .env): $e');
  }
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: ${e.code}\nError Message: ${e.description}');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Billboard Tipper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(cameras: cameras),
    );
  }
}
