import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://localhost:3000/api';

class StatsPage extends StatefulWidget {
  final int? userId;
  final bool isLoggedIn;

  const StatsPage({super.key, this.userId, this.isLoggedIn = false});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Map<String, dynamic>? stats;
  bool isLoading = true;
  String debugMessage = '';

  @override
  void initState() {
    super.initState();
    print(
      '🚀 StatsPage init — userId: ${widget.userId}, isLoggedIn: ${widget.isLoggedIn}',
    );
    if (widget.isLoggedIn && widget.userId != null) {
      fetchStats();
    } else {
      print(
        '⚠️ Not fetching: isLoggedIn=${widget.isLoggedIn}, userId=${widget.userId}',
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchStats() async {
    setState(() {
      isLoading = true;
      debugMessage = '';
    });

    try {
      final url = '$baseUrl/stats/${widget.userId}';
      print('🌐 Calling: $url');

      final res = await http.get(Uri.parse(url));

      print('📦 Status: ${res.statusCode}');
      print(
        '📦 Body: ${res.body.length > 300 ? res.body.substring(0, 300) : res.body}',
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        print('✅ Decoded stats: $decoded');
        setState(() {
          stats = decoded;
          debugMessage =
              'OK - totalLost: ${_getRawCount(decoded, "totalLost")}, totalFound: ${_getRawCount(decoded, "totalFound")}';
        });
      } else {
        setState(() => debugMessage = 'Server error: ${res.statusCode}');
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() => debugMessage = 'Error: $e');
    }

    setState(() => isLoading = false);
  }

  // Raw count extractor for debug
  int _getRawCount(Map<String, dynamic> data, String key) {
    try {
      final list = data[key] as List;
      if (list.isEmpty) return 0;
      final val = list[0]['count'];
      return int.parse(val.toString());
    } catch (e) {
      return -1;
    }
  }

  int _getCount(String key) {
    if (stats == null || stats![key] == null) return 0;
    try {
      final data = stats![key] as List;
      if (data.isEmpty) return 0;
      return int.parse(data[0]['count'].toString());
    } catch (e) {
      print('❌ _getCount error for $key: $e');
      return 0;
    }
  }

  int _getStatusCount(String status) {
    if (stats == null || stats!['lostByStatus'] == null) return 0;
    try {
      final data = stats!['lostByStatus'] as List;
      for (final item in data) {
        if (item['status'] == status) {
          return int.parse(item['count'].toString());
        }
      }
    } catch (e) {
      print('❌ _getStatusCount error: $e');
    }
    return 0;
  }

  String _getTopPlace(String key) {
    if (stats == null || stats![key] == null) return 'N/A';
    try {
      final data = stats![key] as List;
      if (data.isEmpty) return 'N/A';
      return data[0]['place'] ?? 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  List<Map<String, dynamic>> _getMonthlyData(String key) {
    if (stats == null || stats![key] == null) return [];
    try {
      final data = stats![key] as List;
      return data
          .map(
            (e) => {
              'month': e['month'] ?? '',
              'count': int.parse(e['count'].toString()),
            },
          )
          .toList()
          .reversed
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      "My Stats",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: fetchStats,
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: !widget.isLoggedIn
                    ? _buildNotLoggedIn()
                    : isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchStats,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            const SizedBox(height: 8),

                            // Debug banner — remove after fixing
                            if (debugMessage.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: debugMessage.startsWith('OK')
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: debugMessage.startsWith('OK')
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                child: Text(
                                  debugMessage,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                            _buildTopCards(),
                            const SizedBox(height: 16),
                            _buildReturnedCard(),
                            const SizedBox(height: 16),
                            _buildStatusBreakdown(),
                            const SizedBox(height: 16),
                            _buildTopPlaces(),
                            const SizedBox(height: 16),
                            _buildMonthlyChart(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "Login to see your stats",
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCards() {
    final totalLost = _getCount('totalLost');
    final totalFound = _getCount('totalFound');

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.search_off_rounded,
            label: "Lost Reported",
            value: "$totalLost",
            gradientColors: [const Color(0xFFFF6B6B), const Color(0xFFEE5A6F)],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle_outline_rounded,
            label: "Found Reported",
            value: "$totalFound",
            gradientColors: [const Color(0xFF06D6A0), const Color(0xFF1DD1A1)],
          ),
        ),
      ],
    );
  }

  Widget _buildReturnedCard() {
    final returned = _getCount('returnedToOwner');
    final totalLost = _getCount('totalLost');
    final rate = totalLost > 0
        ? ((returned / totalLost) * 100).toStringAsFixed(0)
        : '0';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.handshake_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Returned to Owner",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Items successfully reunited",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$returned",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "$rate% rate",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown() {
    final active = _getStatusCount('active');
    final found = _getStatusCount('found');
    final cancelled = _getStatusCount('cancelled');
    final total = active + found + cancelled;

    return _buildSectionCard(
      title: "Lost Items Status",
      icon: Icons.pie_chart_rounded,
      child: Column(
        children: [
          _buildStatusRow(
            "Still Searching",
            active,
            total,
            const Color(0xFFFF9800),
          ),
          const SizedBox(height: 10),
          _buildStatusRow(
            "Returned to Owner",
            found,
            total,
            const Color(0xFF06D6A0),
          ),
          const SizedBox(height: 10),
          _buildStatusRow("Cancelled", cancelled, total, Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, int total, Color color) {
    final percent = total > 0 ? count / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF2C3E50),
              ),
            ),
            Text(
              "$count",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildTopPlaces() {
    final topLost = _getTopPlace('topLostPlace');
    final topFound = _getTopPlace('topFoundPlace');

    return _buildSectionCard(
      title: "Top Locations",
      icon: Icons.location_on_rounded,
      child: Row(
        children: [
          Expanded(
            child: _buildPlaceChip(
              label: "Most Lost",
              place: topLost,
              color: const Color(0xFFFF6B6B),
              icon: Icons.search_off_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPlaceChip(
              label: "Most Found",
              place: topFound,
              color: const Color(0xFF06D6A0),
              icon: Icons.check_circle_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceChip({
    required String label,
    required String place,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            place,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C3E50),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    final lostData = _getMonthlyData('lostByMonth');
    final foundData = _getMonthlyData('foundByMonth');

    final Map<String, Map<String, int>> merged = {};
    for (final item in lostData) {
      merged[item['month']] = {'lost': item['count'], 'found': 0};
    }
    for (final item in foundData) {
      if (merged.containsKey(item['month'])) {
        merged[item['month']]!['found'] = item['count'];
      } else {
        merged[item['month']] = {'lost': 0, 'found': item['count']};
      }
    }

    final months = merged.keys.toList()..sort();
    final maxVal = merged.values.fold<int>(1, (prev, e) {
      final m = e['lost']! > e['found']! ? e['lost']! : e['found']!;
      return m > prev ? m : prev;
    });

    return _buildSectionCard(
      title: "Activity by Month",
      icon: Icons.bar_chart_rounded,
      child: months.isEmpty
          ? Center(
              child: Text(
                "No activity yet",
                style: GoogleFonts.poppins(
                  color: Colors.grey[500],
                  fontSize: 13,
                ),
              ),
            )
          : Column(
              children: [
                Row(
                  children: [
                    _buildLegendDot(const Color(0xFFFF6B6B), "Lost"),
                    const SizedBox(width: 16),
                    _buildLegendDot(const Color(0xFF06D6A0), "Found"),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 140,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: months.map((month) {
                      final lost = merged[month]!['lost']!;
                      final found = merged[month]!['found']!;
                      final shortMonth = month.length >= 7
                          ? month.substring(5)
                          : month;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _buildBar(lost, maxVal, const Color(0xFFFF6B6B)),
                              const SizedBox(width: 3),
                              _buildBar(found, maxVal, const Color(0xFF06D6A0)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            shortMonth,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBar(int value, int maxVal, Color color) {
    final height = maxVal > 0 ? (value / maxVal) * 100.0 : 0.0;
    return Container(
      width: 14,
      height: height.clamp(4.0, 100.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF667eea), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}
/*

After replacing the file, open the Stats page and check the **F12 console** for these prints:
```
🚀 StatsPage init — userId: X, isLoggedIn: true
🌐 Calling: http://localhost:3000/api/stats/X
📦 Status: 200
📦 Body: {...}
```

Also visit this in your browser directly and paste what you see:
```
http://localhost:3000/api/stats/YOUR_USER_ID*/