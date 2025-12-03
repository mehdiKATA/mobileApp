import 'package:flutter/material.dart';

class FoundPage extends StatelessWidget {
  const FoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Found an Item"),
        backgroundColor: const Color(0xFF2ECC71),
      ),
      body: const Center(
        child: Text(
          "Found Page",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
