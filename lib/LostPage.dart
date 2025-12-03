import 'package:flutter/material.dart';

class LostPage extends StatelessWidget {
  const LostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lost an Item"),
        backgroundColor: const Color(0xFFE74C3C),
      ),
      body: const Center(
        child: Text(
          "Lost Page",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
