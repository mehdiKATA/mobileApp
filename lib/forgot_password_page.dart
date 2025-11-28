import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: Color(0xFF00C0E8),
      ),
      body: const Center(
        child: Text("Reset password page (UI later)"),
      ),
    );
  }
}
