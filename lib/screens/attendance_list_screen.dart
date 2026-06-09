import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceListScreen extends StatefulWidget {
  const AttendanceListScreen({super.key});

  @override
  State<AttendanceListScreen> createState() =>
      _AttendanceListScreenState();
}

class _AttendanceListScreenState
    extends State<AttendanceListScreen> {

  late Future<List<Attendance>> futureAttendance;

  List<Attendance> allAttendance = [];
  List<Attendance> filteredAttendance = [];

  DateTime? fromDate;
  DateTime? toDate;

  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  /// ================= LOAD DATA =================

  void loadAttendance() async {
    final prefs = await SharedPreferences.getInstance();

    String studentId = prefs.getString("student_id") ?? "";

    if (studentId.isEmpty) {
      print("No student ID found");
      return;
    }

    futureAttendance = ApiService.getAttendance(
      studentId: studentId,
    );

    futureAttendance.then((data) {
      allAttendance = data;
      filteredAttendance = data;
      setState(() {});
    });
  }

  Future refreshAttendance() async {

    loadAttendance();
  }

  /// ================= SEARCH =================

  void searchAttendance(String query) {

    searchQuery = query;

    filteredAttendance =
        allAttendance.where((item) {

          final name =
          item.name.toLowerCase();

          return name.contains(
              query.toLowerCase());
        }).toList();

    setState(() {});
  }

  /// ================= DATE PICKERS =================

  Future pickFromDate() async {

    DateTime? picked =
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {

      setState(() {

        fromDate = picked;
      });
    }
  }

  Future pickToDate() async {

    DateTime? picked =
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {

      setState(() {

        toDate = picked;
      });
    }
  }

  /// ================= APPLY DATE FILTER =================

  void applyFilter() {

    if (fromDate == null ||
        toDate == null) return;

    filteredAttendance =
        allAttendance.where((item) {

          try {

            DateTime itemDate =
            DateTime.parse(item.date);

            return itemDate.isAfter(
                fromDate!.subtract(
                    const Duration(days: 1))) &&
                itemDate.isBefore(
                    toDate!.add(
                        const Duration(days: 1)));

          } catch (e) {

            return false;
          }

        }).toList();

    setState(() {});
  }

  /// ================= RESET FILTER =================

  void resetFilter() {

    fromDate = null;
    toDate = null;

    filteredAttendance =
        allAttendance;

    setState(() {});
  }

  /// ================= DATE FORMAT =================

  String formatDate(DateTime? date) {

    if (date == null)
      return "Select Date";

    return
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      Colors.grey.shade100,

      appBar: AppBar(

        elevation: 0,

        backgroundColor:
        Colors.white,

        centerTitle: true,

        title: const Text(
          "Attendance Records",
          style: TextStyle(
            color: Colors.black,
            fontWeight:
            FontWeight.w600,
          ),
        ),
      ),

      body: Column(

        children: [

          /// ================= SEARCH BAR =================

          Container(

            padding:
            const EdgeInsets.all(10),

            color: Colors.white,

            child: TextField(

              decoration: InputDecoration(

                hintText:
                "Search by name...",

                prefixIcon:
                const Icon(Icons.search),

                border:
                OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),

              onChanged:
              searchAttendance,
            ),
          ),

          /// ================= DATE FILTER =================

          Container(

            padding:
            const EdgeInsets.all(12),

            color: Colors.white,

            child: Column(

              children: [

                Row(

                  children: [

                    Expanded(

                      child:
                      OutlinedButton.icon(

                        icon:
                        const Icon(
                          Icons.calendar_today,
                          color:
                          Colors.blue,
                        ),

                        label:
                        Text(
                          formatDate(
                              fromDate),
                        ),

                        onPressed:
                        pickFromDate,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(

                      child:
                      OutlinedButton.icon(

                        icon:
                        const Icon(
                          Icons.calendar_today,
                          color:
                          Colors.deepPurple,
                        ),

                        label:
                        Text(
                          formatDate(
                              toDate),
                        ),

                        onPressed:
                        pickToDate,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(

                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [

                    ElevatedButton.icon(

                      icon:
                      const Icon(Icons.search),

                      label:
                      const Text("Apply"),

                      onPressed:
                      applyFilter,
                    ),

                    const SizedBox(width: 12),

                    ElevatedButton.icon(

                      icon:
                      const Icon(Icons.refresh),

                      label:
                      const Text("Reset"),

                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        Colors.grey,
                      ),

                      onPressed:
                      resetFilter,
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// ================= LIST =================

          Expanded(

            child: filteredAttendance.isEmpty

                ? Center(

              child: Column(

                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [

                  Icon(
                    Icons.search_off,
                    size: 60,
                    color:
                    Colors.grey.shade400,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "No Data Found",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )

                : RefreshIndicator(

              onRefresh:
              refreshAttendance,

              child:
              ListView.builder(

                padding:
                const EdgeInsets.all(12),

                itemCount:
                filteredAttendance.length,

                itemBuilder:
                    (context, index) {

                  final item =
                  filteredAttendance[index];

                  return attendanceCard(
                      item);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= CARD =================

  Widget attendanceCard(
      Attendance item) {

    final isPresent =
        item.status.toLowerCase() ==
            "present";

    return Container(

      margin:
      const EdgeInsets.only(bottom: 14),

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

            blurRadius: 10,

            offset:
            const Offset(0, 4),
          ),
        ],
      ),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          /// NAME + STATUS

          Row(

            children: [

              const CircleAvatar(

                backgroundColor:
                Color(0xFFE3F2FD),

                child: Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(

                child: Text(

                  item.name,

                  style:
                  const TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),

              Container(

                padding:
                const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6),

                decoration:
                BoxDecoration(

                  color: (isPresent
                      ? Colors.green
                      : Colors.red)
                      .withOpacity(0.1),

                  borderRadius:
                  BorderRadius.circular(20),
                ),

                child: Text(

                  item.status,

                  style: TextStyle(

                    color: isPresent
                        ? Colors.green
                        : Colors.red,

                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 20),

          iconRow(
              Icons.calendar_today,
              "Date",
              item.date),

          if (item.dateTime != null)
            iconRow(
                Icons.schedule,
                "DateTime",
                item.dateTime!),

          if (item.address != null)
            iconRow(
                Icons.location_on,
                "Address",
                item.address!),

          if (item.latitude != null)
            iconRow(
                Icons.my_location,
                "Latitude",
                item.latitude.toString()),

          if (item.longitude != null)
            iconRow(
                Icons.place,
                "Longitude",
                item.longitude.toString()),
        ],
      ),
    );
  }

  /// ================= COMMON ROW =================

  Widget iconRow(
      IconData icon,
      String label,
      String value) {

    return Padding(

      padding:
      const EdgeInsets.only(bottom: 8),

      child: Row(

        children: [

          Icon(
            icon,
            size: 18,
            color:
            Colors.grey.shade600,
          ),

          const SizedBox(width: 8),

          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight:
              FontWeight.w500,
            ),
          ),

          Expanded(

            child: Text(

              value,

              style: TextStyle(
                color:
                Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}