import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'settings_page.dart';
class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER =====
            Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    'images/avatar3.jpg',
                    width: 45,
                    height: 45,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Foulen Ben Foulen",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ===== MENU BUTTONS =====
            _buildMenuButton(Icons.history, "History"),
            _buildMenuButton(Icons.bar_chart, "View Stats"),

            const SizedBox(height: 20),

            // ===== CREDIT SCORE =====
            Row(
              children: [
                const Icon(Icons.star, color: Colors.white, size: 30),
                const SizedBox(width: 10),
                Text(
                  "Credit Score",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "500",
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF444444),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ===== WHATSAPP BOX =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    "كان عندك أي سؤال\nكلمنا على الواتساب",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.black87,
                      fontSize: 18,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      FaIcon(
                        FontAwesomeIcons.whatsapp,
                        size: 28,
                        color: Colors.green,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "WhatsApp",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white, width: 1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 14),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 19,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white),
        ],
      ),
    );
  }
}
