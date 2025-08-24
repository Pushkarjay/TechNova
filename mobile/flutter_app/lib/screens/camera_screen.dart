// ignore_for_file: library_private_types_in_public_api

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
  int _cameraIndex = 0;
  bool _permissionGranted = false;
  String? _initError;
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    _checkAndInitCamera();
  }

  Future<void> _checkAndInitCamera() async {
    final status = await Permission.camera.status;
    if (!status.isGranted) {
      final result = await Permission.camera.request();
      if (!result.isGranted) {
        if (!mounted) {
          return;
        }
        setState(() {
          _permissionGranted = false;
        });
        return;
      }
    }
    if (!mounted) return;
    setState(() {
      _permissionGranted = true;
    });

    if (widget.cameras.isNotEmpty) {
      try {
        _controller = CameraController(
          widget.cameras[_cameraIndex],
          ResolutionPreset.high,
        );
        await _controller!.initialize();
        if (!mounted) {
          return;
        }
        setState(() {});
      } catch (e) {
        if (!mounted) {
          return;
        }
        setState(() {
          _initError = e.toString();
        });
      }
    } else {
      if (!mounted) {
        return;
      }
      setState(() {
        _initError = 'No cameras detected on device.';
      });
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) {
      return;
    }
    try {
      if (_flashMode == FlashMode.off) {
        _flashMode = FlashMode.auto;
      } else if (_flashMode == FlashMode.auto) {
        _flashMode = FlashMode.torch;
      } else {
        _flashMode = FlashMode.off;
      }
      await _controller!.setFlashMode(_flashMode);
      if (!mounted) {
        return;
      }
      setState(() {});
    } catch (e) {
      debugPrint('Flash toggle error: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (widget.cameras.length < 2) return;
    _cameraIndex = (_cameraIndex + 1) % widget.cameras.length;
    try {
      await _controller?.dispose();
      _controller =
          CameraController(widget.cameras[_cameraIndex], ResolutionPreset.high);
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint('Switch camera error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildOverlay(BuildContext context) {
    final w = MediaQuery.of(context).size.width * 0.9;
    final h = w * (9 / 16);
    return Center(
      child: SizedBox(
        width: w,
        height: h,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70, width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _GuidePainter(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
      body: Stack(
        children: [
          CameraPreview(_controller!),
          _buildOverlay(context),
          Positioned(
            top: 16,
            right: 12,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _flashMode == FlashMode.off
                        ? Icons.flash_off
                        : _flashMode == FlashMode.auto
                            ? Icons.flash_auto
                            : Icons.flash_on,
                    color: Colors.white,
                  ),
                  onPressed: _toggleFlash,
                ),
                IconButton(
                  icon: const Icon(Icons.cameraswitch, color: Colors.white),
                  onPressed: _switchCamera,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt),
        onPressed: () async {
          try {
            final navigator = Navigator.of(context);
            final image = await _controller!.takePicture();
            if (!mounted) return;
            final route = MaterialPageRoute(
              builder: (ctx) => ReviewScreen(imagePath: image.path),
            );
            navigator.push(route);
          } catch (e) {
            debugPrint('Capture error: $e');
          }
        },
      ),
    );
  }
}

class _GuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    // vertical thirds
    final dx1 = size.width / 3;
    final dx2 = 2 * size.width / 3;
    canvas.drawLine(Offset(dx1, 0), Offset(dx1, size.height), paint);
    canvas.drawLine(Offset(dx2, 0), Offset(dx2, size.height), paint);
    // horizontal thirds
    final dy1 = size.height / 3;
    final dy2 = 2 * size.height / 3;
    canvas.drawLine(Offset(0, dy1), Offset(size.width, dy1), paint);
    canvas.drawLine(Offset(0, dy2), Offset(size.width, dy2), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
