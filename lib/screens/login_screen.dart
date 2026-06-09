import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/students.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final FocusNode passwordFocus = FocusNode();

  bool loading = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  bool showPassword = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0,
      end: 30,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    passwordFocus.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Future<void> login() async {
  //   if (phoneController.text.trim().isEmpty ||
  //       passwordController.text.trim().isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Please enter mobile and password")),
  //     );
  //     return;
  //   }
  //
  //   setState(() => loading = true);
  //
  //   try {
  //     Student? student = await ApiService.login(
  //       phoneController.text.trim(),
  //       passwordController.text.trim(),
  //     );
  //
  //     setState(() => loading = false);
  //
  //     if (student != null) {
  //       final prefs = await SharedPreferences.getInstance();
  //
  //       // Save login session
  //       await prefs.setBool("isLoggedIn", true);
  //
  //       // Save student details
  //       await prefs.setString("student_id", student.id.toString());
  //
  //       await prefs.setString("user_name", student.name);
  //
  //       await prefs.setString("role", student.role);
  //
  //       if (!mounted) return;
  //
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //           builder: (_) => HomeScreen(
  //             userId: student.id,
  //             role: student.role,
  //             userName: student.name,
  //             // userId: student.id.toString(),
  //           ),
  //         ),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Invalid Mobile or Password")),
  //       );
  //     }
  //   } catch (e) {
  //     setState(() => loading = false);
  //
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text("Error: $e")));
  //   }
  // }

  Future<void> login() async {
    if (phoneController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter mobile and password")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      Student? student = await ApiService.login(
        phoneController.text.trim(),
        passwordController.text.trim(),
      );

      setState(() => loading = false);

      if (student != null) {
        // 🚫 BLOCK LOGIN IF DISABLED
        if (student.status.toLowerCase() == "disabled") {
          if (!mounted) return;

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Account Disabled"),
              content: const Text(
                "Your account is disabled. Please contact admin.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );

          return;
        }

        final prefs = await SharedPreferences.getInstance();

        // Save login session
        await prefs.setBool("isLoggedIn", true);

        // Save student details
        await prefs.setString("student_id", student.id.toString());
        await prefs.setString("user_name", student.name);
        await prefs.setString("role", student.role);

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              userId: student.id,
              role: student.role,
              userName: student.name,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid Mobile or Password")),
        );
      }
    } catch (e) {
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return Stack(
            children: [
              // 🌌 BACKGROUND
              Container(
                decoration: const BoxDecoration(
                  // gradient: LinearGradient(
                  //   colors: [
                  //     Color(0xFF0F172A),
                  //     Color(0xFF1E293B),
                  //     Color(0xFF0B1220),
                  //   ],
                  //   begin: Alignment.topLeft,
                  //   end: Alignment.bottomRight,
                  // ),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFE0F2FF),
                      Color(0xFFB3E5FC),
                      Color(0xFF81D4FA),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              // 🌊 BLUR BLOBS
              Positioned(
                top: -80 + _animation.value,
                left: -80 + _animation.value,
                child: _blob(const Color(0xFF3B82F6)),
              ),
              Positioned(
                bottom: -80 - _animation.value,
                right: -80 - _animation.value,
                child: _blob(const Color(0xFF8B5CF6)),
              ),

              // 🧊 LOGIN CARD
              Center(
                child: Container(
                  width: 380,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.15),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          "assets/logo/logo.png",
                          height: 60,
                          width: 60,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "Attendance Portal",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),

                      const SizedBox(height: 25),

                      _field(
                        controller: phoneController,
                        hint: "Mobile Number",
                        icon: Icons.phone,
                        keyboard: TextInputType.phone,
                        onChanged: (v) {
                          if (v.length == 10) {
                            FocusScope.of(context).requestFocus(passwordFocus);
                          }
                        },
                      ),

                      const SizedBox(height: 15),

                      _field(
                        controller: passwordController,
                        hint: "Password",
                        icon: Icons.lock,
                        obscure: !showPassword,
                        focusNode: passwordFocus,
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: loading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "LOGIN",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
    FocusNode? focusNode,
    Function(String)? onChanged,
    Widget? suffixIcon, // 👈 ADD THIS
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      keyboardType: keyboard,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.black87),
      inputFormatters: keyboard == TextInputType.phone
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ]
          : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue),

        suffixIcon: suffixIcon, // 👈 ADD THIS

        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black45),
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  Widget _blob(Color color) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.25),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 120,
            spreadRadius: 60,
          ),
        ],
      ),
    );
  }
}
