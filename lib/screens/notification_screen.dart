import 'package:flutter/material.dart';

import '../services/api_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState
    extends State<NotificationScreen> {

  List notifications = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {

    final data =
    await ApiService.getNotifications();

    setState(() {
      notifications = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),

      body: loading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount:
        notifications.length,
        itemBuilder:
            (context,index){

          final item =
          notifications[index];

          return Card(
            margin:
            const EdgeInsets.all(8),

            child: ListTile(
              leading: const Icon(
                Icons.notifications,
                color: Colors.blue,
              ),

              title: Text(
                item["title"]
                    .toString(),
              ),

              subtitle: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [

                  Text(
                    item["message"]
                        .toString(),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    item["created_at"]
                        .toString(),
                    style:
                    const TextStyle(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}