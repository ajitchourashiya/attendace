  // // class Attendance {
  // //
  // //   final int id;
  // //   final String name;
  // //   final String date;
  // //   final String time;
  // //   final String status;
  // //
  // //   Attendance({
  // //
  // //     required this.id,
  // //     required this.name,
  // //     required this.date,
  // //     required this.time,
  // //     required this.status,
  // //   });
  // //
  // //   factory Attendance.fromJson(
  // //       Map<String,dynamic> json) {
  // //
  // //     return Attendance(
  // //
  // //       id: int.parse(json["id"]),
  // //
  // //       name: json["name"],
  // //
  // //       date: json["date"],
  // //
  // //       time: json["time"],
  // //
  // //       status: json["status"],
  // //     );
  // //   }
  // // }
  //
  // class Attendance {
  //
  //   final int id;
  //   final String name;
  //   final String date;
  //   final String time;
  //   final String status;
  //
  //   final double? latitude;
  //   final double? longitude;
  //   final String? address;
  //   final String? dateTime;
  //
  //   Attendance({
  //
  //     required this.id,
  //     required this.name,
  //     required this.date,
  //     required this.time,
  //     required this.status,
  //
  //     this.latitude,
  //     this.longitude,
  //     this.address,
  //     this.dateTime,
  //   });
  //
  //   factory Attendance.fromJson(
  //       Map<String, dynamic> json) {
  //
  //     return Attendance(
  //
  //       id: int.parse(json['id'].toString()),
  //
  //       name: json['name'] ?? "",
  //
  //       date: json['date'] ?? "",
  //
  //       time: json['time'] ?? "",
  //
  //       status: json['status'] ?? "",
  //
  //       latitude:
  //       json['latitude'] != null
  //           ? double.tryParse(
  //           json['latitude'].toString())
  //           : null,
  //
  //       longitude:
  //       json['longitude'] != null
  //           ? double.tryParse(
  //           json['longitude'].toString())
  //           : null,
  //
  //       address:
  //       json['address'],
  //
  //       dateTime:
  //       json['date_time'],
  //     );
  //   }
  // }

  class Attendance {

    final String id;
    final String name;
    final String date;
    final String status;

    final double? latitude;
    final double? longitude;
    final String? address;
    final String? dateTime;

    Attendance({

      required this.id,
      required this.name,
      required this.date,
      required this.status,

      this.latitude,
      this.longitude,
      this.address,
      this.dateTime,
    });

    factory Attendance.fromJson(
        Map<String, dynamic> json) {

      return Attendance(

        id: json['id'].toString(),

        name: json['name'] ?? '',

        date: json['date'] ?? '',

        status: json['status'] ?? '',

        latitude:
        json['latitude'] != null
            ? double.tryParse(
            json['latitude'].toString())
            : null,

        longitude:
        json['longitude'] != null
            ? double.tryParse(
            json['longitude'].toString())
            : null,

        address: json['address'],

        dateTime:
        json['date_time'],
      );
    }
  }