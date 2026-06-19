import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_version_update/app_version_update.dart';

import '../screens/update_screen.dart';

class OtaUpdateProvider extends ChangeNotifier {
  Future<void> checkPlayerid() async {
    try {
      final result = await AppVersionUpdate.checkForUpdates();

      if (result.canUpdate ?? false) {
        Get.offAll(
              () => UpdateScreen(
            url: result.storeUrl ?? "",
          ),
        );
      }
    } catch (e) {
      debugPrint("Error checking app update: $e");
    }
  }
}