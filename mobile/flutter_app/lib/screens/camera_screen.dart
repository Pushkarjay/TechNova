import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'review_screen.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({super.key, required this.cameras});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _permissionGranted = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _checkAndInitCamera();
  }

  Future<void> _checkAndInitCamera() async {
    // Check camera permission
    final status = await Permission.camera.status;
    if (!status.isGranted) {
      final result = await Permission.camera.request();
      if (!result.isGranted) {
        setState(() {
          _permissionGranted = false;
        });
        return;
      }
    }
    setState(() {
      _permissionGranted = true;
    });

    if (widget.cameras.isNotEmpty) {
      try {
        _controller = CameraController(
          widget.cameras.first,
          ResolutionPreset.medium,
        );
        _initializeControllerFuture = _controller!.initialize();
        await _initializeControllerFuture;
        setState(() {});
      } catch (e) {
        setState(() {
          _initError = e.toString();
        });
      }
    } else {
      setState(() {
        _initError = 'No cameras detected on device.';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionGranted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Take a picture')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Camera permission is required.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _checkAndInitCamera(),
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        ),
      );
    }

    if (_initError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Take a picture')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Camera error: $_initError'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _checkAndInitCamera(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Take a picture')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller!);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller!.takePicture();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReviewScreen(imagePath: image.path),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
      ),
    );
  }
}
