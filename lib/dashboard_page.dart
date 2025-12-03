import 'package:flutter/material.dart';

// ===== IMPORT YOUR PAGES =====
import 'add_page.dart';
import 'messages_page.dart';
import 'notifications_page.dart';
import 'dashboard_home.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;

  // All pages to show in the bottom navigation
  final List<Widget> pages = [
    const DashboardHome(), // PAGE 0 = HOME
    const AddPage(), // PAGE 1 = ADD ITEM
    const MessagesPage(), // PAGE 2 = MESSAGES
    const NotificationsPage(), // PAGE 3 = NOTIFICATIONS
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00C0E8),

      // ====== BODY SWITCHES BETWEEN PAGES ======
      body: IndexedStack(index: selectedIndex, children: pages),

      // ====== BOTTOM NAVBAR ======
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF41D5AB),
          border: Border(top: BorderSide(color: Color(0xFF444444), width: 2)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,

          selectedFontSize: 0,
          unselectedFontSize: 0,
          enableFeedback: false,

          currentIndex: selectedIndex,
          onTap: (i) {
            if (i == 1) {
              // The ADD button index
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddPage()),
              );
            } else {
              setState(() => selectedIndex = i);
            }
          },

          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,

          selectedIconTheme: const IconThemeData(color: Colors.black, size: 30),
          unselectedIconTheme: const IconThemeData(
            color: Colors.white,
            size: 28,
          ),

          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: "",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.message), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ""),
          ],
        ),
      ),
    );
  }
}
