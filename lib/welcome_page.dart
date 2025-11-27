import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00C0E8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo circle
            Container(
              child: ClipOval(
                child: Image.asset(
                  'assets/images/icon.png',
                  width: 400,
                  height: 400,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 40),

            Text(
              "L9itha ?",
              style: GoogleFonts.julee(
                fontSize: 96,
                color: Color.fromRGBO(68, 68, 68, 1),
                fontWeight: FontWeight.normal,
                letterSpacing: .06,
              ),
            ),

            const SizedBox(height: 60),

            // LOGIN BUTTON
            SizedBox(
              width: 250,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF41D5AB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: const Text("Login"),
              ),
            ),

            const SizedBox(height: 20),

            // SIGN UP BUTTON
            SizedBox(
              width: 250,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF444444),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpPage()),
                  );
                },
                child: const Text("Sign Up"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
