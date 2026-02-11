import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui';
import 'settings_page.dart';
import 'welcome_page.dart';

class DashboardHome extends StatefulWidget {
  final String? fullName;
  final String? email;
  final int? userId;
  final int creditScore;
  final bool isLoggedIn;

  const DashboardHome({
    super.key,
    this.fullName,
    this.email,
    this.userId,
    this.creditScore = 0,
    this.isLoggedIn = false,
  });

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                _buildMenuCard(
                  icon: Icons.history_rounded,
                  title: "History",
                  subtitle: "View your activity",
                  gradientColors: [
                    const Color(0xFFFF6B9D),
                    const Color(0xFFC06C84),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMenuCard(
                  icon: Icons.bar_chart_rounded,
                  title: "View Stats",
                  subtitle: "Track your progress",
                  gradientColors: [
                    const Color(0xFF06D6A0),
                    const Color(0xFF00B4D8),
                  ],
                ),
                const SizedBox(height: 25),
                _buildCreditScore(),
                const SizedBox(height: 25),
                _buildWhatsAppCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF06D6A0), Color(0xFFFF6B9D)],
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: ClipOval(
              child: Image.asset(
                'images/avatar3.jpg',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isLoggedIn ? "Welcome back! 👋" : "Hello! 👋",
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.isLoggedIn
                    ? (widget.fullName ?? "Guest User")
                    : "Guest User",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              widget.isLoggedIn ? Icons.settings_rounded : Icons.login_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              if (widget.isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsPage(
                      fullName: widget.fullName ?? "Guest User",
                      email: widget.email ?? "guest@example.com",
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomePage()),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreditScore() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Credit Score",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.isLoggedIn
                          ? "Post items to earn points!"
                          : "Login to see your score",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.isLoggedIn ? "${widget.creditScore}" : "--",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhatsAppCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.support_agent_rounded,
            size: 50,
            color: Color(0xFF25D366),
          ),
          const SizedBox(height: 16),
          Text(
            "كان عندك أي سؤال",
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "كلمنا على الواتساب",
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF25D366),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  "WhatsApp Support",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
