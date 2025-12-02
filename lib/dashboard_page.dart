import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00C0E8),

      // ======== APP BAR ========
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C0E8),
        elevation: 0,
        centerTitle: false,
        title: Row(
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
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.settings, size: 28, color: Colors.white),
          ),
        ],
      ),

      // ======== BODY ========
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HISTORY
            _buildMenuButton(
              icon: Icons.history,
              text: "History",
              onTap: () {},
            ),

            // VIEW STATS
            _buildMenuButton(
              icon: Icons.bar_chart,
              text: "View Stats",
              onTap: () {},
            ),

            const SizedBox(height: 20),

            // CREDIT SCORE
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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

            // WHATSAPP BOX
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
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),

      // ======= BOTTOM NAVIGATION ========
      bottomNavigationBar: Container(
  decoration: const BoxDecoration(
    color: Color(0xFF41D5AB),
    border: Border(
      top: BorderSide(
        color: Color(0xFF444444), // stroke color
        width: 2,
      ),
    ),
  ),
  child: BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.transparent,
    elevation: 0,

    // CENTER ICONS
    selectedFontSize: 0,
    unselectedFontSize: 0,

    // REMOVE ANIMATIONS
    enableFeedback: false,

    currentIndex: selectedIndex,
    onTap: (i) => setState(() => selectedIndex = i),

    // COLORS
    selectedItemColor: Colors.black,
    unselectedItemColor: Colors.grey,

    // ICON THEMES (STRONG BLACK WHEN SELECTED)
    selectedIconTheme: const IconThemeData(
      color: Colors.black,
      size: 30, // you can adjust
    ),
    unselectedIconTheme: const IconThemeData(
      color: Colors.white,
      size: 28,
    ),

    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
      BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: ""),
      BottomNavigationBarItem(icon: Icon(Icons.message), label: ""),
      BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ""),
    ],
  ),
),
);
    
  }

  // ======== CUSTOM MENU ITEM WIDGET ========
  Widget _buildMenuButton({
    required IconData icon,
    required String text,
    required Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
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
      ),
    );
  }
}
