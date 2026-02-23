import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://localhost:3000/api';

class HistoryPage extends StatefulWidget {
  final int? userId;
  final bool isLoggedIn;

  const HistoryPage({super.key, this.userId, this.isLoggedIn = false});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> lostItems = [];
  List<dynamic> foundItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.isLoggedIn && widget.userId != null) {
      fetchHistory();
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchHistory() async {
    setState(() => isLoading = true);
    try {
      final lostRes = await http.get(
        Uri.parse('$baseUrl/lost-items/user/${widget.userId}'),
      );
      final foundRes = await http.get(
        Uri.parse('$baseUrl/found-items/user/${widget.userId}'),
      );
      if (lostRes.statusCode == 200) {
        lostItems = jsonDecode(lostRes.body);
      }
      if (foundRes.statusCode == 200) {
        foundItems = jsonDecode(foundRes.body);
      }
    } catch (e) {
      print('Error fetching history: $e');
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ← FIXES the Material error
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "My History",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: fetchHistory,
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Tab bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded, size: 18),
                          const SizedBox(width: 6),
                          Text("Lost (${lostItems.length})"),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text("Found (${foundItems.length})"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Content
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildItemList(lostItems, isLost: true),
                          _buildItemList(foundItems, isLost: false),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemList(List<dynamic> items, {required bool isLost}) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLost ? Icons.search_off_rounded : Icons.inventory_2_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              isLost ? "No lost items reported" : "No found items reported",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchHistory,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildItemCard(items[index], isLost: isLost);
        },
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, {required bool isLost}) {
    final color = isLost ? const Color(0xFFFF6B6B) : const Color(0xFF06D6A0);
    final String date = isLost
        ? (item['lost_date'] ?? '')
        : (item['found_date'] ?? '');
    final String place = isLost
        ? (item['lost_place'] ?? '')
        : (item['found_place'] ?? '');
    final String description = item['description'] ?? '';
    final String? photoBase64 = item['photo'];
    final String status = item['status'] ?? '';

    String formattedDate = date;
    try {
      final parsed = DateTime.parse(date);
      formattedDate = "${parsed.day}/${parsed.month}/${parsed.year}";
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo
          if (photoBase64 != null && photoBase64.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.memory(
                base64Decode(photoBase64),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isLost ? "🔴 Lost" : "🟢 Found",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isLost && status.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(status),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2C3E50),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      place,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'found':
        return const Color(0xFF06D6A0);
      case 'cancelled':
        return Colors.grey;
      default:
        return const Color(0xFFFF9800);
    }
  }
}
