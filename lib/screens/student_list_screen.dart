import 'package:flutter/material.dart';
import '../models/students.dart';
import '../services/api_service.dart';
class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});
  @override
  State<StudentListScreen> createState() =>
      _StudentListScreenState();
}
class _StudentListScreenState
    extends State<StudentListScreen> {
  late Future<List<Student>> studentsFuture;
  List<Student> allStudents = [];
  List<Student> filteredStudents = [];

  void initState() {
    super.initState();
    loadStudents();
  }
  /// ================= LOAD =================
  void loadStudents() {
    studentsFuture =
        ApiService.getStudents();
    studentsFuture.then((data) {
      allStudents = data;
      filteredStudents = data;
      setState(() {});
    });
  }
  /// ================= SEARCH =================
  void searchStudents(String query) {
    filteredStudents =
        allStudents.where((student) {
          final name =
          student.name.toLowerCase();
          final phone =
          student.phone.toLowerCase();
          return name.contains(
              query.toLowerCase()) ||
              phone.contains(
                  query.toLowerCase());
        }).toList();
    setState(() {});
  }
  /// ================= IMAGE =================
  String getImageUrl(String photo) =>
      "${ApiService.baseUrl}/$photo";

  /// ================= REFRESH =================
  Future refreshStudents() async {
    loadStudents();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      Colors.grey.shade100,
      appBar: AppBar(
        title:
        const Text("Employee List"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// ================= SEARCH BAR =================
          Container(
            padding:
            const EdgeInsets.all(12),
            color: Colors.white,
            child: TextField(
              decoration: InputDecoration(
                hintText:
                "Search Employee...",
                prefixIcon:
                const Icon(Icons.search),
                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
              onChanged:
              searchStudents,
            ),
          ),
          /// ================= LIST =================
          Expanded(
            child:
            filteredStudents.isEmpty
                ? emptyWidget()
                : RefreshIndicator(
              onRefresh:
              refreshStudents,
              child:
              ListView.builder(
                padding:
                const EdgeInsets.all(12),
                itemCount:
                filteredStudents.length,
                itemBuilder:
                    (context, index) {
                  final student =
                  filteredStudents[index];
                  final imageUrl =
                  getImageUrl(
                      student.photo);
                  return studentCard(
                      student,
                      imageUrl);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  /// ================= CARD =================
  Widget studentCard(
      Student student,
      String imageUrl) {
    return GestureDetector(
      onTap: () {
        _showStudentDialog(
            student,
            imageUrl);
      },
      child: Container(
        margin:
        const EdgeInsets.only(
            bottom: 12),
        padding:
        const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
              Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset:
              const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [

            /// PROFILE IMAGE
            GestureDetector(
              onTap: () => _showFullImage(imageUrl),
              child: CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(imageUrl),
                onBackgroundImageError: (_, __) {},
              ),
            ),

            const SizedBox(width: 14),

            /// DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "📱 ${student.phone}",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "🔑 ${student.password}",
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "👤 ${student.role}",
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: student.status == "active"
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      student.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: student.status == "active"
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// ACTIONS
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// VIEW BUTTON
                IconButton(
                  icon: const Icon(
                    Icons.visibility,
                    color: Colors.blue,
                  ),
                  tooltip: "View Employee",
                  onPressed: () {
                    _showStudentDialog(
                      student,
                      imageUrl,
                    );
                  },
                ),

                /// ACTIVE / DISABLE SWITCH
                Switch(
                  value: student.status == "active",
                  activeColor: Colors.green,
                  // onChanged: (value) async {
                  //
                  //   bool success =
                  //   await ApiService.updateStatus(
                  //     student.id,
                  //     value ? "active" : "disabled",
                  //   );
                  //
                  //   if (success) {
                  //
                  //     setState(() {
                  //       student.status =
                  //       value ? "active" : "disabled";
                  //     });
                  //
                  //     ScaffoldMessenger.of(context)
                  //         .showSnackBar(
                  //       SnackBar(
                  //         content: Text(
                  //           value
                  //               ? "${student.name} Activated"
                  //               : "${student.name} Disabled",
                  //         ),
                  //         backgroundColor: value
                  //             ? Colors.green
                  //             : Colors.red,
                  //       ),
                  //     );
                  //   } else {
                  //
                  //     ScaffoldMessenger.of(context)
                  //         .showSnackBar(
                  //       const SnackBar(
                  //         content: Text(
                  //           "Failed to update status",
                  //         ),
                  //         backgroundColor: Colors.red,
                  //       ),
                  //     );
                  //   }
                  // },
                    onChanged: (value) async {
                      print("🔄 TOGGLE CLICKED");
                      print("Student ID: ${student.id}");
                      print("New Status: ${value ? "active" : "disabled"}");

                      bool success = await ApiService.updateStatus(
                        student.id,
                        value ? "active" : "disabled",
                      );

                      print("📡 API RESPONSE: $success");

                      if (success) {
                        setState(() {
                          student.status = value ? "active" : "disabled";
                        });

                        print("✅ STATUS UPDATED IN UI");

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              value
                                  ? "${student.name} Activated"
                                  : "${student.name} Disabled",
                            ),
                            backgroundColor: value ? Colors.green : Colors.red,
                          ),
                        );
                      } else {
                        print("❌ FAILED TO UPDATE STATUS");

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Failed to update status"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  /// ================= EMPTY =================
  Widget emptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 70,
            color:
            Colors.grey.shade400,
          ),
          const SizedBox(height: 10),
          const Text(
            "No Students Found",
            style: TextStyle(
              fontSize: 16,
              fontWeight:
              FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  /// ================= DIALOG =================
  void _showStudentDialog(Student student, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(student.name),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// PROFILE IMAGE
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showFullImage(imageUrl);
                  },
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                ),

                const SizedBox(height: 15),

                /// ALL DETAILS CARD
                _infoTile("Phone", student.phone),
                _infoTile("Password", student.password),
                _infoTile("Email", student.email),
                _infoTile("Role", student.role),
                _infoTile("Aadhar", student.aadharNumber),
                _infoTile("Guardian", student.guardianName),
                _infoTile("DOB", student.dob),
                _infoTile("Emergency", student.emergencyContact.isEmpty ? "N/A" : student.emergencyContact),
                _infoTile("Address", student.address),
                _infoTile("Status", student.status.toUpperCase()),


                const SizedBox(height: 10),

                /// WARNING IF DISABLED
                if (student.status != "active")
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red),
                    ),
                    child: const Text(
                      "⚠ This employee is DISABLED",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          actions: [

            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showEditDialog(student);
              },
              icon: const Icon(Icons.edit),
              label: const Text("Edit"),
            ),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
  /// ================= FULL IMAGE =================
  void _showFullImage(
      String imageUrl) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor:
          Colors.black,
          child: GestureDetector(
            onTap: () =>
                Navigator.pop(context),
            child:
            InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder:
                    (context,
                    child,
                    progress) {
                  if (progress == null)
                    return child;
                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                },
                errorBuilder:
                    (context,
                    error,
                    stackTrace) {
                  return const Center(
                    child: Text(
                      "Image not found",
                      style: TextStyle(
                          color:
                          Colors.white),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
  void _showEditDialog(Student student) {

    final nameController =
    TextEditingController(text: student.name);

    final phoneController =
    TextEditingController(text: student.phone);

    final passwordController =
    TextEditingController(text: student.password);

    final emailController =
    TextEditingController(text: student.email);

    final aadharController =
    TextEditingController(text: student.aadharNumber);

    final guardianController =
    TextEditingController(text: student.guardianName);

    final addressController =
    TextEditingController(text: student.address);

    final dobController =
    TextEditingController(text: student.dob);

    final emergencyController =
    TextEditingController(text: student.emergencyContact);

    /// Current Role
    String selectedRole = student.role;

    /// Available Roles
    final List<String> roles = [
      "Admin",
      "HR",
      "Manager",
      "User",
    ];

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {

            return AlertDialog(
              title: const Text("Edit Employee"),

              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Employee Name",
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: phoneController,
                        readOnly: true,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Phone Number",
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "Email",
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: aadharController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Aadhar Number",
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: guardianController,
                        decoration: const InputDecoration(
                          labelText: "Father/Husband Name",
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: addressController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: "Address",
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: dobController,
                        decoration: const InputDecoration(
                          labelText: "Date of Birth",
                          hintText: "YYYY-MM-DD",
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: emergencyController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Emergency Contact",
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// ROLE DROPDOWN
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(
                          labelText: "Role",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.admin_panel_settings),
                        ),
                        items: roles.map((role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedRole = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              actions: [

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed: () async {

                    bool success =
                    await ApiService.updateStudent(
                      student.id.toString(),
                      nameController.text,
                      phoneController.text,
                      passwordController.text,
                      emailController.text,
                      aadharController.text,
                      guardianController.text,
                      addressController.text,
                      dobController.text,
                      emergencyController.text,
                      selectedRole,
                    );

                    if (success) {

                      setState(() {
                        student.name = nameController.text;
                        student.password = passwordController.text;
                        student.email = emailController.text;
                        student.aadharNumber = aadharController.text;
                        student.guardianName = guardianController.text;
                        student.address = addressController.text;
                        student.dob = dobController.text;
                        student.emergencyContact =
                            emergencyController.text;
                        student.role = selectedRole;
                      });

                      Navigator.pop(context);

                      loadStudents();

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Employee Updated Successfully",
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );

                    } else {

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Failed to Update Employee",
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "$label: $value",
        style: const TextStyle(
          fontSize: 13,
        ),
      ),
    );
  }}

