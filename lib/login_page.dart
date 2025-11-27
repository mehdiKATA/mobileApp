import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: const Color(0xFF00C0E8),
      ),
      body: const Center(
        child: Text("Login Page — UI comes later"),
      ),
    );
  }
}
