import '../services/api_service.dart';

class Student {
  final int id;
  String name;
  String phone;
  String photo;
  String password;
  String role;
  String email;
  String aadharNumber;
  String guardianName;
  String address;
  String dob;
  String emergencyContact;

  String status;

  Student({
    required this.id,
    required this.name,
    required this.phone,
    required this.photo,
    required this.password,
    required this.role,

    required this.email,
    required this.aadharNumber,
    required this.guardianName,
    required this.address,
    required this.dob,
    required this.emergencyContact,

    required this.status,
  });

  factory Student.fromJson(
      Map<String, dynamic> json,
      ) {
    return Student(
      id: int.parse(json['id'].toString()),

      name: json['name'] ?? '',

      phone: json['phone'] ?? '',

      photo: json['photo'] ?? '',

      email: json['email'] ?? '',

      aadharNumber:
      json['aadhar_number'] ?? '',

      guardianName:
      json['guardian_name'] ?? '',

      address:
      json['address'] ?? '',

      dob:
      json['dob'] ?? '',

      emergencyContact:
      json['emergency_contact'] ?? '',
      password: json['password'] ?? '',

      // if role column exists in DB
      role: json['role'] ?? 'user',
      status:
      json['status'] ?? 'active',
    );
  }

  String get imageUrl {
    return "${ApiService.baseUrl}/$photo";
  }
}