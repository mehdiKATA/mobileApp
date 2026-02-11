import 'package:flutter/material.dart';
import 'add_page.dart';
import 'messages_page.dart';
import 'notifications_page.dart';
import 'dashboard_home.dart';
import 'welcome_page.dart';

class DashboardPage extends StatefulWidget {
  final String? fullName;
  final String? email;
  final int? userId;
  final int creditScore;
  final bool isLoggedIn;

  const DashboardPage({
    super.key,
    this.fullName,
    this.email,
    this.userId,
    this.creditScore = 0,
    this.isLoggedIn = false,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;
  late int currentCreditScore;

  @override
  void initState() {
    super.initState();
    currentCreditScore = widget.creditScore;
  }

  void updateCreditScore(int newScore) {
    setState(() {
      currentCreditScore = newScore;
    });
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.lock_outline_rounded,
              color: Colors.orange[700],
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text("Login Required"),
          ],
        ),
        content: const Text(
          "You need to login to access this feature.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WelcomePage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Login", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DashboardHome(
        fullName: widget.fullName,
        email: widget.email,
        userId: widget.userId,
        creditScore: currentCreditScore,
        isLoggedIn: widget.isLoggedIn,
      ),
      AddPage(
        userId: widget.userId,
        fullName: widget.fullName,
        email: widget.email,
        creditScore: currentCreditScore,
        onScoreUpdated: updateCreditScore,
      ),
      const MessagesPage(),
      const NotificationsPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: "Home",
                  index: 0,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                ),
                _buildNavItem(
                  icon: Icons.add_circle_rounded,
                  label: "Add",
                  index: 1,
                  isCenter: true,
                  requiresLogin: true,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B9D), Color(0xFFC06C84)],
                  ),
                ),
                _buildNavItem(
                  icon: Icons.message_rounded,
                  label: "Messages",
                  index: 2,
                  requiresLogin: true,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF06D6A0), Color(0xFF00B4D8)],
                  ),
                ),
                _buildNavItem(
                  icon: Icons.notifications_rounded,
                  label: "Alerts",
                  index: 3,
                  requiresLogin: true,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required Gradient gradient,
    bool isCenter = false,
    bool requiresLogin = false,
  }) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (requiresLogin && !widget.isLoggedIn) {
          _showLoginRequiredDialog();
          return;
        }
        setState(() => selectedIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isCenter ? 20 : 12,
          vertical: isCenter ? 12 : 8,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: !isSelected ? Colors.transparent : null,
          borderRadius: BorderRadius.circular(isCenter ? 20 : 16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (gradient.colors.first).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isCenter ? 32 : 26,
              color: isSelected ? Colors.white : Colors.grey[400],
            ),
            if (!isCenter) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? gradient.colors.first : Colors.grey[400],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
