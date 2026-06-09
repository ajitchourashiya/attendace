import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../services/api_service.dart';
import '../services/face_service.dart';
import 'camera_page.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final aadharController = TextEditingController();
  final guardianController = TextEditingController();
  final addressController = TextEditingController();
  final dobController = TextEditingController();
  final emergencyController = TextEditingController();


  File? image;
  bool isLoading = false;
  bool _obscurePassword = true;
  bool mobileExists = false;
  Map<String, dynamic>? existingEmployee;

  Timer? _debounce;

  final FaceService faceService = FaceService();

  List<String> roles = [];
  String? selectedRole;

  late FaceDetector faceDetector;

  @override
  void initState() {
    super.initState();

    faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
      ),
    );

    initModel();
    loadRoles();
  }


  // Future<void> checkMobileNumber(String mobile) async {
  //   if (mobile.length != 10) {
  //     setState(() {
  //       mobileExists = false;
  //       existingEmployee = null;
  //     });
  //     return;
  //   }
  //
  //   try {
  //     final result = await ApiService.checkMobile(mobile);
  //
  //     if (result["status"] == true) {
  //       setState(() {
  //         mobileExists = true;
  //         existingEmployee = result;
  //       });
  //     } else {
  //       setState(() {
  //         mobileExists = false;
  //         existingEmployee = null;
  //       });
  //     }
  //   } catch (e) {
  //     debugPrint("Mobile Check Error: $e");
  //   }
  // }



  Future<void> loadRoles() async {
    try {
      final result = await ApiService.getRoles();

      if (result["status"] == true) {
        setState(() {
          roles = List<String>.from(
            result["data"].map((e) => e["role_name"]),
          );
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  Future initModel() async {
    await faceService.loadModel();
  }

  /// ================= CAMERA =================

  Future pickImage() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CameraPage(),
        ),
      );

      if (result != null && result is File) {
        File imgFile = result;

        final inputImage = InputImage.fromFile(imgFile);

        final faces = await faceDetector.processImage(inputImage);

        if (faces.isEmpty) {
          showError("No face detected");
          return;
        }

        if (faces.length > 1) {
          showError("Multiple faces detected");
          return;
        }

        setState(() {
          image = imgFile;
        });
      }
    } catch (e) {
      showError("Camera Error: $e");
    }
  }



  /// ================= SAVE =================

  Future saveStudent() async {

    if (mobileExists) {
      showError(
        "Mobile number already exists for ${existingEmployee?["name"]}",
      );
      return;
    }
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    String email = emailController.text.trim();
    String aadhar = aadharController.text.trim();
    String guardian = guardianController.text.trim();
    String address = addressController.text.trim();
    String dob = dobController.text.trim();
    String emergency = emergencyController.text.trim();
    if (selectedRole == null) {
      showError("Please select role");
      return;
    }

    /// Required fields
    if (name.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        email.isEmpty ||
        aadhar.isEmpty ||
        guardian.isEmpty ||
        address.isEmpty ||
        dob.isEmpty) {
      showError("Please fill all required fields");
      return;
    }

    /// Phone validation
    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      showError("Phone number must be 10 digits");
      return;
    }

    /// Email validation
    if (!RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email)) {
      showError("Please enter a valid email address");
      return;
    }

    /// Aadhaar validation
    if (!RegExp(r'^[0-9]{12}$').hasMatch(aadhar)) {
      showError("Aadhaar number must be 12 digits");
      return;
    }

    /// Emergency contact validation (optional)
    if (emergency.isNotEmpty &&
        !RegExp(r'^[0-9]{10}$').hasMatch(emergency)) {
      showError(
        "Emergency contact must be 10 digits or leave it blank",
      );
      return;
    }

    /// Image validation
    if (image == null) {
      showError("Please capture photo");
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final inputImage = InputImage.fromFile(image!);

      final faces = await faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        setState(() {
          isLoading = false;
        });

        showError("No face detected");
        return;
      }

      /// Generate Face Embedding
      List<double> embedding = faceService.generateEmbedding(
        image!,
        faces.first,
      );

      /// API Call
      final result = await ApiService.addStudent(
        name,
        phone,
        password,
        email,
        aadhar,
        guardian,
        address,
        dob,
        emergency,
        selectedRole!,
        image!,
        embedding,
      );

      setState(() {
        isLoading = false;
      });

      if (result["status"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Employee Saved Successfully"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else {
        showError(
          result["message"] ??
              "Failed to save employee",
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      showError("Error: $e");
    }
  }

  /// ================= ERROR =================

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // @override
  // void dispose() {
  //   nameController.dispose();
  //   phoneController.dispose();
  //   passwordController.dispose();
  //   faceDetector.close();
  //   super.dispose();
  // }
  @override
  void dispose() {
    _debounce?.cancel();

    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();

    faceDetector.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Add Employee"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// IMAGE
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage:
                    image != null ? FileImage(image!) : null,
                    child: image == null
                        ? const Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: Colors.blue,
                    )
                        : null,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Tap to Capture Photo",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 25),
                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: "Role",
                    prefixIcon: const Icon(Icons.admin_panel_settings),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    ...roles.map(
                          (role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      ),
                    ),
                    const DropdownMenuItem(
                      value: "ADD_ROLE",
                      child: Text("+ Add New Role"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == "ADD_ROLE") {
                      _showAddRoleDialog();
                      return;
                    }

                    setState(() {
                      selectedRole = value;
                    });
                  },
                ),

                const SizedBox(height: 25),
                /// FORM CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [


                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        onChanged: (value) {
                          if (_debounce?.isActive ?? false) {
                            _debounce!.cancel();
                          }

                          if (value.length == 10) {
                            _debounce = Timer(const Duration(milliseconds: 300), () {
                              searchMobile(value);
                            });
                          } else {
                            setState(() {
                              existingEmployee = null;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      if (existingEmployee != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person, color: Colors.orange),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "${existingEmployee!["name"]} (${existingEmployee!["phone"]}) already exists",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 15),
                      /// NAME
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Employee Name",
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      /// PHONE
                      // TextField(
                      //   controller: phoneController,
                      //   keyboardType: TextInputType.phone,
                      //   decoration: InputDecoration(
                      //     labelText: "Phone Number",
                      //     prefixIcon: const Icon(Icons.phone),
                      //     border: OutlineInputBorder(
                      //       borderRadius:
                      //       BorderRadius.circular(12),
                      //     ),
                      //   ),
                      // ),

                      const SizedBox(height: 15),

                      /// PASSWORD
                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword =
                                !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// EMAIL
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// AADHAR NUMBER
                      TextField(
                        controller: aadharController,
                        keyboardType: TextInputType.number,
                        maxLength: 12,
                        decoration: InputDecoration(
                          counterText: "",
                          labelText: "Aadhar Number",
                          prefixIcon: const Icon(Icons.badge),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// FATHER/HUSBAND NAME
                      TextField(
                        controller: guardianController,
                        decoration: InputDecoration(
                          labelText: "Father/Husband Name",
                          prefixIcon: const Icon(Icons.family_restroom),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// ADDRESS
                      TextField(
                        controller: addressController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Address",
                          prefixIcon: const Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// DOB
                      TextField(
                        controller: dobController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Date of Birth",
                          prefixIcon: const Icon(Icons.calendar_month),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                          );

                          if (picked != null) {
                            dobController.text =
                            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                          }
                        },
                      ),

                      const SizedBox(height: 15),

                      /// EMERGENCY CONTACT
                      TextField(
                        controller: emergencyController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Emergency Contact",
                          prefixIcon: const Icon(Icons.contact_phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// SAVE BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : saveStudent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Save Employee",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                              FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// LOADING
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showAddRoleDialog() async {
    TextEditingController roleController =
    TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Add New Role"),
          content: TextField(
            controller: roleController,
            decoration: const InputDecoration(
              hintText: "Enter role name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String role =
                roleController.text.trim();

                if (role.isEmpty) {
                  return;
                }

                final result =
                await ApiService.addRole(role);

                if (result["status"] == true) {

                  Navigator.pop(context);

                  await loadRoles();

                  setState(() {
                    selectedRole = role;
                  });

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content:
                      Text("Role added successfully"),
                    ),
                  );
                } else {
                  showError(
                    result["message"] ??
                        "Failed to add role",
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Map<String, dynamic>? existingEmployee;

  Future<void> searchMobile(String mobile) async {
    try {
      final result = await ApiService.searchMobile(mobile);

      if (!mounted) return;

      setState(() {
        existingEmployee = result["status"] == true ? result : null;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}