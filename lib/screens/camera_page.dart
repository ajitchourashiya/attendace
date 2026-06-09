// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
//
// class CameraPage extends StatefulWidget {
//   const CameraPage({super.key});
//
//   @override
//   State<CameraPage> createState() => _CameraPageState();
// }
//
// class _CameraPageState extends State<CameraPage> {
//   CameraController? controller;
//   List<CameraDescription> cameras = [];
//
//   int selectedCameraIndex = 0;
//   bool isCameraReady = false;
//
//   @override
//   void initState() {
//     super.initState();
//     initCamera();
//   }
//
//   // =========================
//   // INIT CAMERA
//   // =========================
//   Future initCamera() async {
//     try {
//       cameras = await availableCameras();
//
//       if (cameras.isEmpty) {
//         throw Exception("No camera found");
//       }
//
//       // ✅ FORCE FRONT CAMERA
//       selectedCameraIndex = cameras.indexWhere(
//             (camera) => camera.lensDirection == CameraLensDirection.front,
//       );
//
//       if (selectedCameraIndex == -1) {
//         selectedCameraIndex = 0;
//       }
//
//       controller = CameraController(
//         cameras[selectedCameraIndex],
//         ResolutionPreset.medium,
//         enableAudio: false,
//       );
//
//       await controller!.initialize();
//
//       setState(() {
//         isCameraReady = true;
//       });
//     } catch (e) {
//       print("Camera error: $e");
//     }
//   }
//
//   // =========================
//   // CAPTURE IMAGE
//   // =========================
//   Future captureImage() async {
//     try {
//       final image = await controller!.takePicture();
//
//       File file = File(image.path);
//
//       // ✅ RETURN IMAGE TO PREVIOUS SCREEN
//       Navigator.pop(context, file);
//     } catch (e) {
//       print("Capture error: $e");
//     }
//   }
//
//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!isCameraReady || controller == null) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Capture Face"),
//       ),
//       body: Stack(
//         children: [
//           CameraPreview(controller!),
//
//           Positioned(
//             bottom: 30,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: FloatingActionButton(
//                 onPressed: captureImage,
//                 child: const Icon(Icons.camera_alt),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() =>
      _CameraPageState();
}

class _CameraPageState
    extends State<CameraPage> {

  CameraController? controller;
  List<CameraDescription> cameras = [];

  int selectedCameraIndex = 0;
  bool isCameraReady = false;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  /// ================= INIT CAMERA =================

  Future initCamera() async {
    try {
      cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception("No camera found");
      }

      selectedCameraIndex =
          cameras.indexWhere(
                (camera) =>
            camera.lensDirection ==
                CameraLensDirection.front,
          );

      if (selectedCameraIndex == -1) {
        selectedCameraIndex = 0;
      }

      controller = CameraController(
        cameras[selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller!.initialize();

      setState(() {
        isCameraReady = true;
      });

    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  /// ================= SWITCH CAMERA =================

  Future switchCamera() async {
    if (cameras.length < 2) return;

    selectedCameraIndex =
        (selectedCameraIndex + 1) %
            cameras.length;

    controller = CameraController(
      cameras[selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await controller!.initialize();

    setState(() {});
  }

  /// ================= CAPTURE =================

  Future captureImage() async {
    try {
      final image =
      await controller!.takePicture();

      File file = File(image.path);

      Navigator.pop(context, file);

    } catch (e) {
      debugPrint("Capture error: $e");
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  /// ================= LOADING SCREEN =================

  Widget loadingScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF1a1a1a)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(height: 15),
              Text(
                "Initializing Camera...",
                style: TextStyle(
                  color: Colors.white70,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (!isCameraReady || controller == null) {
      return loadingScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [

          /// CAMERA PREVIEW
          CameraPreview(controller!),

          /// DARK OVERLAY (FOCUS EFFECT)
          Container(
            color: Colors.black.withOpacity(0.4),
          ),

          /// FACE CUTOUT
          Center(
            child: Container(
              width: 260,
              height: 320,
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(160),
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
              ),
            ),
          ),

          /// TOP TEXT
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Text(
                  "Keep Smiling",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Align your face inside the frame",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          /// BACK BUTTON
          Positioned(
            top: 50,
            left: 20,
            child: glassButton(
              icon: Icons.arrow_back,
              onTap: () =>
                  Navigator.pop(context),
            ),
          ),

          /// SWITCH CAMERA
          // Positioned(
          //   top: 50,
          //   right: 20,
          //   child: glassButton(
          //     icon: Icons.flip_camera_ios,
          //     onTap: switchCamera,
          //   ),
          // ),

          /// CAPTURE BUTTON
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: captureImage,
                child: Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                  child: const Center(
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor:
                      Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= GLASS BUTTON =================

  Widget glassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}