import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/theme_service.dart';

List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('dotenv.load failed (continuing without .env): $e');
  }
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: ${e.code}\nError Message: ${e.description}');
  }

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase.initializeApp failed: $e');
  }

  // Initialize persisted theme preference before building UI.
  try {
    await ThemeService.init();
  } catch (e) {
    debugPrint('ThemeService init failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    ThemeService.isDark.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final primary = Colors.tealAccent;
    final dark = ThemeData.dark().copyWith(
      colorScheme:
          ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark),
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
    );

    final lightPrimary = Colors.teal;
    final light = ThemeData.light().copyWith(
      colorScheme: ColorScheme.fromSeed(
          seedColor: lightPrimary, brightness: Brightness.light),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.grey[50],
      primaryColor: lightPrimary,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
        ),
      ),
      cardColor: Colors.white,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: lightPrimary,
        unselectedItemColor: Colors.black54,
      ),
    );

    return MaterialApp(
      title: 'prtotype 1',
      theme: ThemeService.isDark.value ? dark : light,
      home: HomeScreen(cameras: cameras),
    );
  }
}
