import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/students.dart';
import '../models/attendance.dart';

class ApiService {
  static const String baseUrl ="https://attendance360.dacnis.net/attendance_api";
  // static const String baseUrl = "http://192.168.29.32/attendance_api";

  /* =========================
      GET ATTENDANCE
  ========================= */

  static Future<List<Attendance>> getAttendance({
    required String studentId,
    String? fromDate,
    String? toDate,
  }) async {
    String url = "$baseUrl/get_attendance.php?student_id=$studentId";

    if (fromDate != null &&
        toDate != null &&
        fromDate.isNotEmpty &&
        toDate.isNotEmpty) {
      url += "&fromDate=$fromDate&toDate=$toDate";
    }

    print("Attendance URL => $url");

    final response = await http.get(Uri.parse(url));

    print("Status Code => ${response.statusCode}");
    print("Response => ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData["data"] == null || jsonData["data"].isEmpty) {
        return [];
      }

      List data = jsonData["data"];

      return data.map((e) => Attendance.fromJson(e)).toList();
    }

    return [];
  }

  /* =========================
      GET STUDENTS
  ========================= */
  static Future<List<Student>> getStudents() async {
    try {
      print("API CALL START");

      final url = Uri.parse("$baseUrl/get_students.php");
      print("Request URL: $url");

      final response = await http.get(url);

      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((e) => Student.fromJson(e)).toList();
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("ERROR OCCURRED: $e");
      rethrow;
    }
  }

  /* =========================
      ADD STUDENT
  ========================= */

  static Future<Map<String, dynamic>> addStudent(
    String name,
    String phone,
    String password,
    String email,
    String aadharNumber,
    String guardianName,
    String address,
    String dob,
    String emergencyContact,
    String role,
    File image,
    List<double> embedding,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/upload_photo.php"),
      );

      request.fields['name'] = name;
      request.fields['phone'] = phone;
      request.fields['password'] = password;

      request.fields['email'] = email;
      request.fields['aadhar_number'] = aadharNumber;
      request.fields['guardian_name'] = guardianName;
      request.fields['address'] = address;
      request.fields['dob'] = dob;
      request.fields['emergency_contact'] = emergencyContact;

      // NEW FIELD
      request.fields['role'] = role;

      request.fields['embedding'] = jsonEncode(embedding);

      request.files.add(await http.MultipartFile.fromPath('photo', image.path));

      var response = await request.send();

      var responseString = await response.stream.bytesToString();

      print("ADD STUDENT:");
      print(responseString);

      return jsonDecode(responseString);
    } catch (e) {
      print("Add Student Error: $e");

      return {"status": false, "message": e.toString()};
    }
  }

  /* =========================
      MATCH FACE
========================= */

  // static Future<Map<String, dynamic>?> matchFace(List<double> embedding) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse("$baseUrl/match_face.php"),
  //
  //       headers: {"Content-Type": "application/json"},
  //
  //       body: jsonEncode({"embedding": embedding}),
  //     );
  //
  //     print("MATCH FACE:");
  //     print(response.body);
  //
  //     var data = jsonDecode(response.body);
  //
  //     if (data["status"] == true) {
  //       return {
  //         "student_id": int.parse(data["student_id"].toString()),
  //
  //         "name": data["name"],
  //
  //         "distance": data["distance"],
  //       };
  //     } else {
  //       print("Face not matched");
  //
  //       return null;
  //     }
  //   } catch (e) {
  //     print("Match Error: $e");
  //
  //     return null;
  //   }
  // }
  static Future<Map<String, dynamic>?> matchFace(
    List<double> embedding,
    int studentId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/match_face.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "embedding": embedding,
          "student_id": studentId, // 🔥 IMPORTANT
        }),
      );

      print("MATCH FACE:");
      print(response.body);

      var data = jsonDecode(response.body);

      if (data["status"] == true) {
        return {
          "student_id": int.parse(data["student_id"].toString()),
          "name": data["name"],
          "distance": data["distance"],
        };
      } else {
        print(data["message"]);
        return null;
      }
    } catch (e) {
      print("Match Error: $e");
      return null;
    }
  }
  /* =========================
    MARK ATTENDANCE WITH LOCATION
========================= */

  static Future<Map<String, dynamic>?> markAttendance(
    int studentId, {
    required double latitude,
    required double longitude,
    required String address,
    required String dateTime,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/mark_attendance.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "student_id": studentId,
          "latitude": latitude,
          "longitude": longitude,
          "address": address,
          "date_time": dateTime,
        }),
      );

      print("MARK ATTENDANCE:");
      print(response.body);

      return jsonDecode(response.body);
    } catch (e) {
      print("Mark Attendance Error: $e");
      return null;
    }
  }

  static Future<bool> disableStudent(int id) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/disable_student.php"),
        body: {"id": id.toString()},
      );

      print("DISABLE STUDENT:");
      print(response.body);

      final data = jsonDecode(response.body);

      return data["status"] == true;
    } catch (e) {
      print("Disable Student Error: $e");
      return false;
    }
  }

  // static Future<bool> updateStudent(
  //   int id,
  //   String name,
  //   String phone,
  //   String password,
  //   String email,
  //   String aadharNumber,
  //   String guardianName,
  //   String address,
  //   String dob,
  //   String emergencyContact,
  // ) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse("$baseUrl/update_student.php"),
  //       body: {
  //         "id": id.toString(),
  //         "name": name,
  //         "phone": phone,
  //         "password": password,
  //         "email": email,
  //         "aadhar_number": aadharNumber,
  //         "guardian_name": guardianName,
  //         "address": address,
  //         "dob": dob,
  //         "emergency_contact": emergencyContact,
  //       },
  //     );
  //
  //     print("UPDATE STUDENT:");
  //     print(response.body);
  //
  //     final data = jsonDecode(response.body);
  //
  //     return data["status"] == true;
  //   } catch (e) {
  //     print("Update Student Error: $e");
  //     return false;
  //   }
  // }

  static Future<bool> updateStudent(
      String id,
      String name,
      String phone,
      String password,
      String email,
      String aadharNumber,
      String guardianName,
      String address,
      String dob,
      String emergencyContact,
      String role,
      ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/update_student.php"),
        body: {
          "id": id,
          "name": name,
          "phone": phone,
          "password": password,
          "email": email,
          "aadhar_number": aadharNumber,
          "guardian_name": guardianName,
          "address": address,
          "dob": dob,
          "emergency_contact": emergencyContact,
          "role": role,
        },
      );

      final data = jsonDecode(response.body);

      return data["status"] == true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> updateStatus(int id, String status) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/update_status.php"),
        body: {"id": id.toString(), "status": status},
      );

      print(response.body);

      final data = jsonDecode(response.body);

      return data["status"] == true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<Student?> login(String phone, String password) async {
    try {
      final students = await getStudents();

      for (var student in students) {
        if (student.phone == phone && student.password == password) {
          return student; // role comes from DB
        }
      }

      return null;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>> getRoles() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/get_roles.php"));

      return jsonDecode(response.body);
    } catch (e) {
      return {"status": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> addRole(String roleName) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/add_role.php"),
        body: {"role_name": roleName},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"status": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> searchMobile(String mobile) async {
    final response = await http.post(
      Uri.parse("$baseUrl/search_mobile.php"),
      body: {"phone": mobile},
    );

    return jsonDecode(response.body);
  }

  static Future<String?> checkStatus(int id) async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}/check_status.php"),
        body: {"id": id.toString()},
      );

      final data = jsonDecode(response.body);

      return data["status"];
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> matchFaceWeb(
    Uint8List imageBytes,
    int studentId,
  ) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("${baseUrl}/match_face_web.php"),
    );

    request.fields["student_id"] = studentId.toString();

    request.files.add(
      http.MultipartFile.fromBytes("image", imageBytes, filename: "face.jpg"),
    );

    final response = await request.send();

    final body = await response.stream.bytesToString();

    return jsonDecode(body);
  }

  static Future<List<dynamic>> getNotifications() async {
    try {
      final response = await http.get(
        Uri.parse(
          "$baseUrl/get_notifications.php",
        ),
      );

      final data = jsonDecode(response.body);

      if (data["status"] == true) {
        return data["data"];
      }

      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }


  static Future<void> saveFcmToken({
    required int userId,
    required String role,
    required String token,
  }) async {
    try {
      await http.post(
        Uri.parse("$baseUrl/save_fcm_token.php"),
        body: {
          "user_id": userId.toString(),
          "role": role,
          "token": token,
        },
      );
    } catch (e) {
      print("SAVE TOKEN ERROR => $e");
    }
  }
}
