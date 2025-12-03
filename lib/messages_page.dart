import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: const Color(0xFF41D5AB),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text(
          "No messages yet",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
