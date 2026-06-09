import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/face_service.dart';
import 'home_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  List<CameraDescription> cameras = [];

  bool isCameraReady = false;
  bool isProcessing = false;

  late FaceDetector faceDetector;
  final FaceService faceService = FaceService();

  String currentAddress = "Fetching location...";
  double latitude = 0;
  double longitude = 0;

  // @override
  // void initState() {
  //   super.initState();
  //
  //   initFaceDetector();
  //
  //   requestLocationPermission();
  //   fetchLocation();
  //
  //   // 🚨 ONLY INIT CAMERA ON MOBILE
  //   if (!kIsWeb) {
  //     initCamera();
  //   }
  // }
  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      initFaceDetector();
    }

    requestLocationPermission();
    fetchLocation();

    // Camera for both Mobile & Web
    initCamera();
  }

  // @override
  // void dispose() {
  //   controller?.dispose();
  //
  //   if (!kIsWeb) {
  //     faceDetector.close();
  //   }
  //
  //   super.dispose();
  // }
  @override
  void dispose() {
    controller?.dispose();

    if (!kIsWeb) {
      faceDetector.close();
    }

    super.dispose();
  }
  /* ================= LOCATION ================= */

  Future<void> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      showError("Location permission permanently denied");
    }
  }

  // Future<void> fetchLocation() async {
  //   try {
  //     Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high,
  //     );
  //
  //     List<Placemark> placemarks = await placemarkFromCoordinates(
  //       position.latitude,
  //       position.longitude,
  //     );
  //
  //     Placemark place = placemarks.first;
  //
  //     setState(() {
  //       latitude = position.latitude;
  //       longitude = position.longitude;
  //
  //       currentAddress =
  //       "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
  //     });
  //   } catch (e) {
  //     setState(() {
  //       currentAddress = "Location unavailable";
  //     });
  //   }
  // }
  Future<void> fetchLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("Permission denied");

        setState(() {
          latitude = 0;
          longitude = 0;
          currentAddress = "Permission denied";
        });

        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude = position.latitude;
      longitude = position.longitude;

      print("LAT: $latitude");
      print("LNG: $longitude");

      String? realAddress;

      try {
        List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;

          realAddress = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.postalCode,
            place.country
          ].where((e) => e != null && e.toString().trim().isNotEmpty)
              .join(", ");
        }
      } catch (e) {
        print("GEOCODING ERROR: $e");
      }

      setState(() {
        currentAddress = (realAddress != null && realAddress.trim().isNotEmpty)
            ? realAddress
            : "Unknown Location";
      });

      print("FINAL ADDRESS: $currentAddress");

    } catch (e) {
      print("LOCATION ERROR: $e");

      setState(() {
        latitude = 0;
        longitude = 0;
        currentAddress = "Location unavailable";
      });
    }
  }
  /* ================= FACE DETECTOR ================= */

  void initFaceDetector() {
    faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: true,
      ),
    );
  }

  /* ================= CAMERA (ONLY MOBILE) ================= */

  // Future initCamera() async {
  //   try {
  //     cameras = await availableCameras();
  //
  //     final frontCamera = cameras.firstWhere(
  //           (c) => c.lensDirection == CameraLensDirection.front,
  //       orElse: () => cameras.first,
  //     );
  //
  //     controller = CameraController(
  //       frontCamera,
  //       ResolutionPreset.high,
  //       enableAudio: false,
  //     );
  //
  //     await controller!.initialize();
  //     await faceService.loadModel();
  //
  //     setState(() {
  //       isCameraReady = true;
  //     });
  //   } catch (e) {
  //     showError("Camera error: $e");
  //   }
  // }
  Future<void> initCamera() async {
    try {
      cameras = await availableCameras();

      final frontCamera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller!.initialize();

      // Load ML model only on Android/iOS
      if (!kIsWeb) {
        await faceService.loadModel();
      }

      if (mounted) {
        setState(() {
          isCameraReady = true;
        });
      }
    } catch (e) {
      showError("Camera error: $e");
    }
  }
  /* ================= POPUP ================= */

  Future<void> showPopup({
    required String title,
    required String message,
    required bool isSuccess,
  }) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(title)),
            ],
          ),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                final prefs = await SharedPreferences.getInstance();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(
                      role: prefs.getString("role") ?? "user",
                      userName: prefs.getString("user_name") ?? "",
                      userId: int.parse(prefs.getString("user_id") ?? "0"),
                    ),
                  ),
                      (route) => false,
                );
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  /* ================= MOBILE ATTENDANCE ================= */

  // Future<void> captureImage() async {
  //   try {
  //     setState(() => isProcessing = true);
  //
  //     await fetchLocation();
  //
  //     final image = await controller!.takePicture();
  //     File file = File(image.path);
  //
  //     final inputImage = InputImage.fromFile(file);
  //     final faces = await faceDetector.processImage(inputImage);
  //
  //     if (faces.isEmpty) {
  //       setState(() => isProcessing = false);
  //
  //       await showPopup(
  //         title: "Face Detection",
  //         message: "No face detected",
  //         isSuccess: false,
  //       );
  //       return;
  //     }
  //
  //     if (faces.length > 1) {
  //       setState(() => isProcessing = false);
  //
  //       await showPopup(
  //         title: "Face Detection",
  //         message: "Multiple faces detected",
  //         isSuccess: false,
  //       );
  //       return;
  //     }
  //
  //     final embedding = faceService.generateEmbedding(file, faces.first);
  //
  //     final result = await ApiService.matchFace(embedding);
  //
  //     if (result == null) {
  //       setState(() => isProcessing = false);
  //
  //       await showPopup(
  //         title: "Attendance",
  //         message: "Face not matched",
  //         isSuccess: false,
  //       );
  //       return;
  //     }
  //
  //     double distance = (result["distance"] as num).toDouble();
  //
  //     if (distance >= 0.9) {
  //       setState(() => isProcessing = false);
  //
  //       await showPopup(
  //         title: "Face Not Recognized",
  //         message: "Please try again",
  //         isSuccess: false,
  //       );
  //       return;
  //     }
  //
  //     int studentId = result["student_id"];
  //     String name = result["name"];
  //
  //     String dateTime = DateFormat(
  //       "EEEE, dd/MM/yyyy hh:mm a",
  //     ).format(DateTime.now());
  //
  //     final attendanceResult = await ApiService.markAttendance(
  //       studentId,
  //       latitude: latitude,
  //       longitude: longitude,
  //       address: currentAddress,
  //       dateTime: dateTime,
  //     );
  //
  //     setState(() => isProcessing = false);
  //
  //     if (attendanceResult != null && attendanceResult["status"] == true) {
  //       await showPopup(
  //         title: attendanceResult["type"] == "IN"
  //             ? "Check-In Successful"
  //             : "Check-Out Successful",
  //         message: "Student: $name\nAttendance marked successfully",
  //         isSuccess: true,
  //       );
  //     } else {
  //       await showPopup(
  //         title: "Failed",
  //         message: attendanceResult?["message"] ?? "Error occurred",
  //         isSuccess: false,
  //       );
  //     }
  //   } catch (e) {
  //     setState(() => isProcessing = false);
  //
  //     await showPopup(title: "Error", message: e.toString(), isSuccess: false);
  //   }
  // }
  Future<void> captureImage() async {
    try {
      setState(() => isProcessing = true);

      await fetchLocation();

      final image = await controller!.takePicture();
      File file = File(image.path);

      final inputImage = InputImage.fromFile(file);
      final faces = await faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        setState(() => isProcessing = false);

        await showPopup(
          title: "Face Detection",
          message: "No face detected",
          isSuccess: false,
        );
        return;
      }

      if (faces.length > 1) {
        setState(() => isProcessing = false);

        await showPopup(
          title: "Face Detection",
          message: "Multiple faces detected",
          isSuccess: false,
        );
        return;
      }

      final embedding = faceService.generateEmbedding(file, faces.first);

      // final result = await ApiService.matchFace(embedding);
      final prefs = await SharedPreferences.getInstance();
      int studentId = int.parse(prefs.getString("student_id") ?? "0");

      final result = await ApiService.matchFace(embedding, studentId);
      if (result == null) {
        setState(() => isProcessing = false);

        await showPopup(
          title: "Attendance",
          message: "Face not matched",
          isSuccess: false,
        );
        return;
      }

      double distance = (result["distance"] as num).toDouble();

      if (distance >= 0.9) {
        setState(() => isProcessing = false);

        await showPopup(
          title: "Face Not Recognized",
          message: "Please try again",
          isSuccess: false,
        );
        return;
      }

      // ✅ ONLY VERIFIED ID FROM SERVER
      // int studentId = result["student_id"];
      String name = result["name"];

      String dateTime = DateFormat(
        "EEEE, dd/MM/yyyy hh:mm a",
      ).format(DateTime.now());

      final attendanceResult = await ApiService.markAttendance(
        studentId,
        latitude: latitude,
        longitude: longitude,
        address: currentAddress,
        dateTime: dateTime,
      );

      setState(() => isProcessing = false);

      if (attendanceResult != null && attendanceResult["status"] == true) {
        await showPopup(
          title: attendanceResult["type"] == "IN"
              ? "Check-In Successful"
              : "Check-Out Successful",
          message: "Student: $name\nAttendance marked successfully",
          isSuccess: true,
        );
      } else {
        await showPopup(
          title: "Failed",
          message: attendanceResult?["message"] ?? "Error occurred",
          isSuccess: false,
        );
      }
    } catch (e) {
      setState(() => isProcessing = false);

      await showPopup(title: "Error", message: e.toString(), isSuccess: false);
    }
  }

  /* ================= WEB ATTENDANCE ================= */

  // Future<void> markAttendanceWeb() async {
  //   try {
  //     setState(() => isProcessing = true);
  //
  //     await fetchLocation();
  //
  //     final prefs = await SharedPreferences.getInstance();
  //
  //     int studentId = int.parse(prefs.getString("user_id") ?? "0");
  //     String name = prefs.getString("user_name") ?? "";
  //
  //     String dateTime = DateFormat(
  //       "EEEE, dd/MM/yyyy hh:mm a",
  //     ).format(DateTime.now());
  //
  //     final attendanceResult = await ApiService.markAttendance(
  //       studentId,
  //       latitude: latitude,
  //       longitude: longitude,
  //       address: currentAddress,
  //       dateTime: dateTime,
  //     );
  //
  //     setState(() => isProcessing = false);
  //
  //     if (attendanceResult != null && attendanceResult["status"] == true) {
  //       await showPopup(
  //         title: attendanceResult["type"] == "IN"
  //             ? "Check-In Successful"
  //             : "Check-Out Successful",
  //         message: "Attendance marked successfully for $name",
  //         isSuccess: true,
  //       );
  //     } else {
  //       await showPopup(
  //         title: "Failed",
  //         message: attendanceResult?["message"] ?? "Error occurred",
  //         isSuccess: false,
  //       );
  //     }
  //   } catch (e) {
  //     setState(() => isProcessing = false);
  //
  //     await showPopup(title: "Error", message: e.toString(), isSuccess: false);
  //   }
  // }
  Future<void> markAttendanceWeb() async {
    try {
      setState(() => isProcessing = true);

      // Get current location
      await fetchLocation();

      final prefs = await SharedPreferences.getInstance();

      // Save location locally
      await prefs.setDouble("latitude", latitude);
      await prefs.setDouble("longitude", longitude);
      await prefs.setString("address", currentAddress);

      print("Saved Latitude: $latitude");
      print("Saved Longitude: $longitude");
      print("Saved Address: $currentAddress");

      // Get student id
      final String? studentIdStr = prefs.getString("student_id");

      if (studentIdStr == null || studentIdStr.isEmpty) {
        setState(() => isProcessing = false);

        await showPopup(
          title: "Login Required",
          message: "Student ID not found. Please login again.",
          isSuccess: false,
        );
        return;
      }

      final int studentId = int.parse(studentIdStr);

      final String userName =
          prefs.getString("user_name") ?? "Unknown";

      final String dateTime =
      DateFormat("EEEE, dd/MM/yyyy hh:mm a")
          .format(DateTime.now());

      print("Student ID: $studentId");
      print("Latitude: $latitude");
      print("Longitude: $longitude");
      print("Address: $currentAddress");

      final attendanceResult = await ApiService.markAttendance(
        studentId,
        latitude: latitude,
        longitude: longitude,
        address: currentAddress,
        dateTime: dateTime,
      );

      setState(() => isProcessing = false);

      if (attendanceResult != null &&
          attendanceResult["status"] == true) {
        await showPopup(
          title: attendanceResult["type"] == "IN"
              ? "Check-In Successful"
              : "Check-Out Successful",
          message:
          "Attendance marked successfully for $userName\n\n📍 $currentAddress",
          isSuccess: true,
        );
      } else {
        await showPopup(
          title: "Failed",
          message: attendanceResult?["message"] ?? "Error occurred",
          isSuccess: false,
        );
      }
    } catch (e) {
      setState(() => isProcessing = false);

      print("Attendance Error: $e");

      await showPopup(
        title: "Error",
        message: e.toString(),
        isSuccess: false,
      );
    }
  }
  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }



  /* ================= UI ================= */

  Future<void> captureImageWeb() async {
    try {
      setState(() => isProcessing = true);

      await fetchLocation();

      final XFile image = await controller!.takePicture();

      final bytes = await image.readAsBytes();

      final prefs = await SharedPreferences.getInstance();

      final int studentId =
      int.parse(prefs.getString("student_id") ?? "0");

      final result =
      await ApiService.matchFaceWeb(
        bytes,
        studentId,
      );

      if (result == null) {
        setState(() => isProcessing = false);

        await showPopup(
          title: "Attendance",
          message: "Face not matched",
          isSuccess: false,
        );
        return;
      }

      final double distance =
      (result["distance"] as num).toDouble();

      if (distance >= 0.9) {
        setState(() => isProcessing = false);

        await showPopup(
          title: "Face Not Recognized",
          message: "Please try again",
          isSuccess: false,
        );
        return;
      }

      final String name = result["name"];

      final String dateTime =
      DateFormat("EEEE, dd/MM/yyyy hh:mm a")
          .format(DateTime.now());

      final attendanceResult =
      await ApiService.markAttendance(
        studentId,
        latitude: latitude,
        longitude: longitude,
        address: currentAddress,
        dateTime: dateTime,
      );

      setState(() => isProcessing = false);

      if (attendanceResult != null &&
          attendanceResult["status"] == true) {
        await showPopup(
          title: attendanceResult["type"] == "IN"
              ? "Check-In Successful"
              : "Check-Out Successful",
          message:
          "Student: $name\nAttendance marked successfully",
          isSuccess: true,
        );
      } else {
        await showPopup(
          title: "Failed",
          message:
          attendanceResult?["message"] ??
              "Error occurred",
          isSuccess: false,
        );
      }
    } catch (e) {
      setState(() => isProcessing = false);

      await showPopup(
        title: "Error",
        message: e.toString(),
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Face Attendance")),

      body: Stack(
        children: [

          if (isCameraReady && controller != null)
            kIsWeb
                ? Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller!.value.previewSize!.width,
                  height: controller!.value.previewSize!.height,
                  child: CameraPreview(controller!),
                ),
              ),
            )
                : CameraPreview(controller!)
          else
            const Center(
              child: CircularProgressIndicator(),
            ),
          /// LOCATION CARD
          Positioned(
            top: kIsWeb ? 20 : 20,
            left: kIsWeb ? 20 : 10,
            right: kIsWeb ? 20 : 10,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 18,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        "📍 $currentAddress\nLat: ${latitude.toStringAsFixed(6)} | "
                            "Lng: ${longitude.toStringAsFixed(6)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// FACE GUIDE ONLY FOR WEB
          if (kIsWeb)
            Center(
              child: IgnorePointer(
                child: Container(
                  width: 320,
                  height: 420,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

          /// BUTTON
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: isProcessing
                  ? Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
                  : SizedBox(
                width: kIsWeb ? 260 : null,
                height: kIsWeb ? 50 : null,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (kIsWeb) {
                      captureImageWeb();
                    } else {
                      captureImage();
                    }
                  },
                  icon: Icon(
                    kIsWeb
                        ? Icons.verified_user
                        : Icons.camera_alt,
                  ),
                  label: Text(
                    kIsWeb
                        ? "Mark Attendance"
                        : "Scan Face",
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}