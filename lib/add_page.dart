import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'LostPage.dart';
import 'FoundPage.dart';

class AddPage extends StatelessWidget {
  const AddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE74C3C), // Red background

      // APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFFE74C3C),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);  // ✔ FIXED — goes back correctly
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE74C3C),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),

      // PAGE BODY
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // ================= RED SECTION =================
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LostPage()),
                    );
                  },
                  child: Container(
                    height: 350,
                    color: const Color(0xFFE74C3C),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Dhaya3t ?",
                          style: GoogleFonts.julee(
                            color: Colors.black,
                            fontSize: 90,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Image.asset(
                          "images/scared.png",
                          height: 140,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),

                // ================= GREEN SECTION =================
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FoundPage()),
                    );
                  },
                  child: Container(
                    height: 350,
                    color: const Color(0xFF2ECC71),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "L9it ?",
                          style: GoogleFonts.julee(
                            color: Colors.black,
                            fontSize: 90,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Image.asset(
                          "images/found.png",
                          height: 170,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
