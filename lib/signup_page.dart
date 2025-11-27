import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: const Color(0xFF00C0E8),
      ),
      body: const Center(
        child: Text("Sign Up Page — UI comes later"),
      ),
    );
  }
}
