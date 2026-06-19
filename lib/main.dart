// import 'package:flutter/material.dart';
// import 'screens/splash_screen.dart';
// void main() {
//   runApp(const AttendanceApp());
// }
// class AttendanceApp
//     extends StatelessWidget {
//   const AttendanceApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: "Face Attendance",
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const SplashScreen(),
//     );
//   }
// }
//


// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import 'screens/splash_screen.dart';
// import 'providers/ota_update_provider.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Check app update before launching
//   await OtaUpdateProvider().checkPlayerid();
//
//   runApp(const AttendanceApp());
// }
//
// class AttendanceApp extends StatelessWidget {
//   const AttendanceApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: "Face Attendance",
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const SplashScreen(),
//     );
//   }
// }

//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
//
// import 'screens/splash_screen.dart';
// import 'providers/ota_update_provider.dart';
//
// Future<void> _firebaseMessagingBackgroundHandler(
//     RemoteMessage message) async {
//   await Firebase.initializeApp();
//
//   print(
//     "Background Message: ${message.messageId}",
//   );
// }
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Firebase Init
//   await Firebase.initializeApp();
//
//   // Background Notifications
//   FirebaseMessaging.onBackgroundMessage(
//     _firebaseMessagingBackgroundHandler,
//   );
//
//   // Request Notification Permission
//   await FirebaseMessaging.instance
//       .requestPermission(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
//
//   // Check App Update
//   await OtaUpdateProvider()
//       .checkPlayerid();
//
//   runApp(
//     const AttendanceApp(),
//   );
// }
//
// class AttendanceApp extends StatelessWidget {
//   const AttendanceApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: "Face Attendance",
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const SplashScreen(),
//     );
//   }
// }
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
//
// import 'firebase_options.dart';
// import 'screens/splash_screen.dart';
// import 'providers/ota_update_provider.dart';
//
// Future<void> _firebaseMessagingBackgroundHandler(
//     RemoteMessage message) async {
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
// }
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   FirebaseMessaging.onBackgroundMessage(
//     _firebaseMessagingBackgroundHandler,
//   );
//
//   await FirebaseMessaging.instance.requestPermission();
//
//   final token =
//   await FirebaseMessaging.instance.getToken();
//
//   print("FCM TOKEN => $token");
//
//   await OtaUpdateProvider().checkPlayerid();
//
//   runApp(
//     const AttendanceApp(),
//   );
// }
//
// class AttendanceApp extends StatelessWidget {
//   const AttendanceApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: "Face Attendance",
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const SplashScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'providers/ota_update_provider.dart';

/// Background handler (mobile only usage)
Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Background messaging (safe)
  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  // 🔥 WEB SAFE BLOCK
  try {
    if (!GetPlatform.isWeb) {
      await FirebaseMessaging.instance.requestPermission();

      final token = await FirebaseMessaging.instance.getToken();
      print("FCM TOKEN => $token");
    }
  } catch (e) {
    print("FCM error: $e");
  }

  // 🔥 WEB SAFE BLOCK (OTA update only for mobile)
  try {
    if (!GetPlatform.isWeb) {
      await OtaUpdateProvider().checkPlayerid();
    }
  } catch (e) {
    print("OTA error: $e");
  }

  runApp(const AttendanceApp());
}

class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Face Attendance",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}