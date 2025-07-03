import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:teciza_hr/utils/constants.dart';
import 'package:teciza_hr/utils/preferences.dart';
import 'package:teciza_hr/utils/snackbar_helper.dart';
import 'package:http/http.dart' as http;

class FaceRecognize extends StatefulWidget {
  const FaceRecognize({super.key});

  @override
  State<FaceRecognize> createState() => _FaceRecognizeState();
}

class _FaceRecognizeState extends State<FaceRecognize> {
  CameraController? _cameraController;
  late List<CameraDescription> cameras;
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(frontCamera, ResolutionPreset.high);

      await _cameraController!.initialize();
      setState(() {
        isCameraInitialized = true;
      });

      Future.delayed(Duration(seconds: 1), captureImage); 
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      debugPrint("Camera is not initialized");
      return;
    }

    try {
      final token = await Preferences.getData<String>('token');
      var empData = await Preferences.getData<Map<String, dynamic>>("emp_info");

      final image = await _cameraController!.takePicture();
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('${AppApiService.baseUrl}/method/traffictech.api.portal.hrms.validate_face_recognition'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'token $token'
        },
        body: jsonEncode({'employee': empData?["name"], 'image': base64Image}),
      );

      if (response.statusCode != 200) {
        debugPrint("Failed to send image: ${response.statusCode}");
        return;
      }

      final data = jsonDecode(response.body);
      final isRecognized = data['message']['is_recognized'];
      debugPrint("Face recognized: $isRecognized");

      if (isRecognized) {
        _showSnackBar('Face Recognized');
        await Preferences.saveData({"isFaceActive": true});

        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        _showSnackBar('Face Not Recognized');
        Future.delayed(Duration(seconds: 1), captureImage); 
      }
    } catch (e) {
      debugPrint("Error capturing image: $e");
    }
  }

  void _showSnackBar(String message) {
    SnackBarHelper.showSnackBar(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Recognize Scanner'),
      ),
      body: isCameraInitialized
          ? Column(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: _cameraController!.value.aspectRatio,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
