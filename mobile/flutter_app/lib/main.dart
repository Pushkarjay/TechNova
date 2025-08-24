import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load local environment variables from mobile/flutter_app/.env (ignored)
  // If the file doesn't exist, continue with empty/default env values.
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // `.env` is optional for local development; log and continue.
    debugPrint('dotenv.load failed (continuing without .env): $e');
  }
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: ${e.code}\nError Message: ${e.description}');
  }
  // Initialize Firebase for Firestore usage in SyncService
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase.initializeApp failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Colors.tealAccent;
    return MaterialApp(
      title: 'Billboard Tipper',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
            seedColor: primary, brightness: Brightness.dark),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: primary,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
        ),
        cardColor: const Color(0xFF1E1E1E),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: primary,
          unselectedItemColor: Colors.white70,
        ),
        textTheme: ThemeData.dark()
            .textTheme
            .apply(bodyColor: Colors.white, displayColor: Colors.white),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(cameras: cameras),
    );
  }
}
