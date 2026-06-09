// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../screens/login_screen.dart';
// import 'api_service.dart';
//
// class StatusService {
//   static Timer? _timer;
//
//   static void start(BuildContext context, String userId) {
//     _timer?.cancel();
//
//     _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
//       try {
//         final status = await ApiService.checkStatus();
//
//         debugPrint("⏳ STATUS CHECK => $status at ${DateTime.now()}");
//
//         if (status == "disabled") {
//           timer.cancel();
//           await forceLogout(context);
//         }
//       } catch (e) {
//         debugPrint("Status check error: $e");
//       }
//     });
//   }
//
//   static Future<void> forceLogout(BuildContext context) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//
//     if (!context.mounted) return;
//
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const LoginScreen()),
//           (route) => false,
//     );
//   }
//
//   static void stop() {
//     _timer?.cancel();
//   }
// }