import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/exercise.dart';
import '../models/session.dart';
import '../services/db_service.dart';
import '../services/auth_service.dart';
import '../widgets/web_camera_view_stub.dart' if (dart.library.html) '../widgets/web_camera_view_web.dart';

class CameraTrackerScreen extends StatefulWidget {
  final Exercise exercise;
  const CameraTrackerScreen({super.key, required this.exercise});

  @override
  State<CameraTrackerScreen> createState() => _CameraTrackerScreenState();
}

class _CameraTrackerScreenState extends State<CameraTrackerScreen> {
  CameraController? _cameraController;
  final PoseDetector _poseDetector = PoseDetector(options: PoseDetectorOptions(mode: PoseDetectionMode.stream));
  bool _canProcess = true;
  bool _isBusy = false;
  String _ankleStatus = "Iniciando cámara...";
  double _maxAngle = 0;
  List<double> _anglesHistory = [];
  
  // ===== CONFIGURACIÓN DE TIEMPO =====
  // Modifica esta variable para cambiar el tiempo de retraso de actualización.
  // 500 = medio segundo.
  final int updateDelayMs = 250;
  int _lastUpdateTime = 0;
  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();
    _initCamerasAndStart();
  }

  Future<void> _initCamerasAndStart() async {
    if (kIsWeb) return;
    try {
      cameras = await availableCameras();
      _initializeCamera();
    } catch (e) {
      print('Error getting cameras: $e');
    }
  }

  Future<void> _initializeCamera() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      if (cameras.isEmpty) return;
      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController?.initialize();
      if (!mounted) return;
      
      _cameraController?.startImageStream(_processCameraImage);
      setState(() {});
    } else {
      setState(() {
        _ankleStatus = "Permiso de cámara denegado.";
      });
    }
  }

  double _calculateAngle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    double radians = math.atan2(c.y - b.y, c.x - b.x) - math.atan2(a.y - b.y, a.x - b.x);
    double angle = (radians * 180.0 / math.pi).abs();
    if (angle > 180.0) angle = 360.0 - angle;
    return angle;
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isBusy || kIsWeb) return;
    _isBusy = true;

    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
      
      final imageRotation = InputImageRotationValue.fromRawValue(
          cameras[0].sensorOrientation) ?? InputImageRotation.rotation0deg;

      final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw)
          ?? InputImageFormat.yuv420;

      final planeData = image.planes.map(
        (Plane plane) {
          return InputImageMetadata(
            bytesPerRow: plane.bytesPerRow,
            size: Size(plane.width?.toDouble() ?? 0, plane.height?.toDouble() ?? 0),
            rotation: imageRotation,
            format: inputImageFormat,
          );
        },
      ).toList();

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: imageSize,
          rotation: imageRotation,
          format: inputImageFormat,
          bytesPerRow: planeData.isNotEmpty ? planeData[0].bytesPerRow : 0,
        ),
      );

      final poses = await _poseDetector.processImage(inputImage);
      
      if (poses.isNotEmpty) {
        final pose = poses.first;
        final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];
        final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];
        final rightFootIndex = pose.landmarks[PoseLandmarkType.rightFootIndex];

        final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
        final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
        final leftFootIndex = pose.landmarks[PoseLandmarkType.leftFootIndex];

        int activeAnkles = 0;
        double currentMaxAngle = 0;
        String statusText = "";

        int now = DateTime.now().millisecondsSinceEpoch;
        bool shouldUpdate = (now - _lastUpdateTime) >= updateDelayMs;
        if (shouldUpdate) {
            _lastUpdateTime = now;
        }

        if (rightKnee != null && rightAnkle != null && rightFootIndex != null && rightAnkle.likelihood > 0.4) {
          double angleR = _calculateAngle(rightKnee, rightAnkle, rightFootIndex);
          double movement = (angleR - 90).abs();
          
          if (shouldUpdate) {
             if (movement > _maxAngle) _maxAngle = movement;
             currentMaxAngle = math.max(currentMaxAngle, movement);
             _anglesHistory.add(movement);
             statusText += "Der: ${angleR.toStringAsFixed(3)}° ";
          }
          activeAnkles++;
        }

        if (leftKnee != null && leftAnkle != null && leftFootIndex != null && leftAnkle.likelihood > 0.4) {
          double angleL = _calculateAngle(leftKnee, leftAnkle, leftFootIndex);
          double movement = (angleL - 90).abs();
          
          if (shouldUpdate) {
             if (movement > _maxAngle) _maxAngle = movement;
             currentMaxAngle = math.max(currentMaxAngle, movement);
             _anglesHistory.add(movement);
             statusText += "Izq: ${angleL.toStringAsFixed(3)}° ";
          }
          activeAnkles++;
        }

        if (shouldUpdate) {
          if (activeAnkles > 0) {
            setState(() {
              _ankleStatus = "Detectando: $statusText";
            });
          } else {
            setState(() {
              _ankleStatus = "Cuerpo detectado, pero no se ven los tobillos. ¡Aléjate más!";
            });
          }
        }
      } else {
        setState(() {
          _ankleStatus = "No se detecta ningún cuerpo en cámara. Ilumina el cuarto y párate frente al celular.";
        });
      }
    } catch (e) {
      print(e);
    } finally {
      _isBusy = false;
    }
  }

  void _finishSession() {
    final user = authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes iniciar sesión')));
      return;
    }

    final session = Session(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.id,
      exerciseId: widget.exercise.id,
      date: DateTime.now(),
      maxAngle: _maxAngle,
      anglesHistory: _anglesHistory,
    );
    DBService.saveSession(session);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesión guardada exitosamente')));
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    if (!kIsWeb) _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.exercise.name),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            buildWebCameraView((angle, status) {
              if (mounted) {
                if (angle > _maxAngle) _maxAngle = angle;
                if (angle > 0) _anglesHistory.add(angle);
                setState(() {
                  _ankleStatus = status;
                });
              }
            }),
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                ),
                child: Text(
                  _ankleStatus,
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: _finishSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: const Text('FINALIZAR EJERCICIO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_cameraController!),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _ankleStatus,
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _finishSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Finalizar Ejercicio', style: TextStyle(fontSize: 18)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
