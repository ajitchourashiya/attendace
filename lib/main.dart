import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {

  runApp(const AttendanceApp());
}

class AttendanceApp
    extends StatelessWidget {

  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: "Face Attendance",

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      home: const SplashScreen(),
    );
  }
}