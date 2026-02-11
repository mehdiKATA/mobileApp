import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'LostPage.dart';
import 'FoundPage.dart';

class AddPage extends StatelessWidget {
  const AddPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // dynamically scale text and images
    final textScale = screenHeight / 900; // based on original design height
    final imageScaleLost = screenHeight / 5.6; // ~160px original
    final imageScaleFound = screenHeight / 5; // ~180px original

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // ================= RED SECTION (LOST) =================
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LostItemPage()),
                );
              },
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Dhaya3t ?",
                      style: GoogleFonts.righteous(
                        color: Colors.white,
                        fontSize: 80 * textScale,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30 * textScale),
                    Image.asset(
                      "images/scared.png",
                      height: imageScaleLost,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ================= GREEN SECTION (FOUND) =================
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FoundPage()),
                );
              },
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF06D6A0), Color(0xFF1DD1A1)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "L9it ?",
                      style: GoogleFonts.righteous(
                        color: Colors.white,
                        fontSize: 80 * textScale,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30 * textScale),
                    Image.asset(
                      "images/found.png",
                      height: imageScaleFound,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
