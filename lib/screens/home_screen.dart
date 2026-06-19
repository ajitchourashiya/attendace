import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/api_service.dart';
import 'add_student_screen.dart';
import 'attendance_list_screen.dart';
import 'login_screen.dart';

import 'student_list_screen.dart';
import 'camera_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final String role;
  final String userName;

  const HomeScreen({
    super.key,
    required this.userId,
    required this.role,
    required this.userName,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _statusTimer;
  String appVersion = "";
  @override
  void initState() {
    super.initState();
    loadAppVersion();

    _statusTimer = Timer.periodic(
      const Duration(seconds: 2),
          (_) => checkUserStatus(),
    );
  }
  Future<void> loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();

    setState(() {
      appVersion = "v${info.version} (${info.buildNumber})";
    });
  }
  // Future<void> checkUserStatus() async {
  //   print("🔍 Checking status for user: ${widget.userId}");
  //
  //   final status = await ApiService.checkStatus(widget.userId);
  //
  //   print("📊 SERVER STATUS: $status");
  //
  //   if (status == "disabled") {
  //     print("🚨 USER IS DISABLED → LOGOUT STARTED");
  //
  //     _statusTimer?.cancel();
  //
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.clear();
  //
  //     print("🧹 PREFS CLEARED");
  //
  //     if (!mounted) return;
  //
  //     Navigator.pushAndRemoveUntil(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => const LoginScreen(),
  //       ),
  //           (route) => false,
  //     );
  //
  //     print("🚪 USER LOGGED OUT SUCCESSFULLY");
  //   } else {
  //     print("🟢 USER STILL ACTIVE");
  //   }
  // }

  Future<void> checkUserStatus() async {
    final status = await ApiService.checkStatus(widget.userId);

    if (status == "disabled") {
      _statusTimer?.cancel();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
            (route) => false,
      );
    } else {
      // print("🟢 USER STILL ACTIVE");
    }
  }
  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentRole = widget.role.trim().toLowerCase();

    final isAdmin = currentRole == "admin";
    final isHr = currentRole == "hr";
    final isManager = currentRole == "manager";
    final isUser = currentRole == "user";

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Attendance System",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final logout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text(
                    "Are you sure you want to logout?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context, true),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (logout == true) {
                final prefs =
                await SharedPreferences.getInstance();

                await prefs.clear();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                      (route) => false,
                );
              }
            },
          ),
        ],

      ),



      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2196F3),
                  Color(0xFF673AB7),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome 👋 ${widget.userName}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Manage Attendance Easily",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  if (isAdmin || isHr)
                    dashboardCard(
                      context,
                      title: "Add Employee",
                      icon: Icons.person_add,
                      color: Colors.blue,
                      screen: const AddStudentScreen(),
                    ),

                  if (isAdmin || isHr || isManager)
                    dashboardCard(
                      context,
                      title: "View Employee",
                      icon: Icons.people,
                      color: Colors.green,
                      screen: const StudentListScreen(),
                    ),

                  dashboardCard(
                    context,
                    title: "View Attendance",
                    icon: Icons.list_alt,
                    color: Colors.orange,
                    screen: const AttendanceListScreen(),
                  ),

                  if (isAdmin || isHr || isUser)
                    dashboardCard(
                      context,
                      title: "Mark Attendance",
                      icon: Icons.camera_alt,
                      color: Colors.purple,
                      screen: const CameraScreen(),
                    ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Text(
              "App Version: $appVersion",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget dashboardCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required Widget screen,
      }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}