import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00C0E8),
      body: SingleChildScrollView(
        // <-- FIX : scroll automatique si petit écran
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo circle
                ClipOval(
                  child: Image.asset(
                    'assets/images/icon.png',
                    width: 300, // <-- réduit pour éviter overflow
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  "L9itha ?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.julee(
                    fontSize: 70, // <-- réduit pour éviter overflow
                    color: const Color(0xFF444444),
                    fontWeight: FontWeight.normal,
                  ),
                ),

                const SizedBox(height: 40),

                // LOGIN BUTTON
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF41D5AB),
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        // <-- THIS ADDS THE STROKE
                        color: Color(0xFF444444), // stroke color
                        width: 2, // thickness
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: Text(
                      "Login",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        // keeps your color
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // SIGN UP BUTTON
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF41D5AB),
                      side: BorderSide(
                        // <-- THIS ADDS THE STROKE
                        color: Color(0xFF444444), // stroke color
                        width: 2, // thickness
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpPage()),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        color: const Color(0xFF41D5AB), // keeps your color
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                GestureDetector(
                  onTap: () {
                    // Later: Navigate to ForgotPasswordPage
                    print("Forgot password clicked");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  child: Text(
                    "Forgot password?",
                    style: GoogleFonts.inter(
                      color: Color(0xFF444444),
                      fontWeight: FontWeight.normal,
                      fontSize: 18,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
