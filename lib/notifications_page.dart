import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFF41D5AB),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text(
          "No notifications",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
