import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import 'api_service.dart';

class NotificationService {
  static final FirebaseMessaging _fcm =
      FirebaseMessaging.instance;

  static Future<void> initialize({
    required int userId,
    required String role,
  }) async {
    try {
      // Request permission
      await _fcm.requestPermission();

      // Get FCM token
      final token = await _fcm.getToken();

      print("FCM TOKEN => $token");

      if (token != null) {
        await saveToken(
          userId,
          role,
          token,
        );
      }

      // Token refresh
      _fcm.onTokenRefresh.listen((newToken) async {
        print("NEW FCM TOKEN => $newToken");

        await saveToken(
          userId,
          role,
          newToken,
        );
      });

      // Foreground notifications
      FirebaseMessaging.onMessage.listen(
            (RemoteMessage message) {
          print(
            "Notification Title => ${message.notification?.title}",
          );
          print(
            "Notification Body => ${message.notification?.body}",
          );
        },
      );
    } catch (e) {
      print("Notification Initialize Error: $e");
    }
  }

  static Future<bool> saveToken(
      int userId,
      String role,
      String token,
      ) async {
    try {
      final response = await http.post(
        Uri.parse(
          "${ApiService.baseUrl}/save_fcm_token.php",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "user_id": userId,
          "role": role,
          "token": token,
        }),
      );

      print("SAVE TOKEN RESPONSE:");
      print(response.body);

      final data = jsonDecode(response.body);

      return data["status"] == true;
    } catch (e) {
      print("Save Token Error: $e");
      return false;
    }
  }

  static Future<bool> deleteToken(
      int userId,
      ) async {
    try {
      final response = await http.post(
        Uri.parse(
          "${ApiService.baseUrl}/delete_fcm_token.php",
        ),
        body: {
          "user_id": userId.toString(),
        },
      );

      final data = jsonDecode(response.body);

      return data["status"] == true;
    } catch (e) {
      print("Delete Token Error: $e");
      return false;
    }
  }
}