import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'dashboard_page.dart';
import 'notification_service.dart';

const String baseUrl = 'http://localhost:3000/api';

class LostItemPage extends StatefulWidget {
  final int? userId;
  final String? fullName;
  final String? email;
  final int creditScore;
  final Function(int)? onScoreUpdated;

  const LostItemPage({
    super.key,
    this.userId,
    this.fullName,
    this.email,
    this.creditScore = 0,
    this.onScoreUpdated,
  });

  @override
  State<LostItemPage> createState() => _LostItemPageState();
}

class _LostItemPageState extends State<LostItemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  XFile? selectedImageFile;
  Uint8List? selectedImageBytes;
  DateTime? selectedDate;
  bool isLoading = false;

  int get userId => widget.userId ?? 1;

  Future<String?> imageToBase64() async {
    if (selectedImageFile == null) return null;
    try {
      final bytes = await selectedImageFile!.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> submitLostItemToDb({
    required String lostDate,
    required String lostPlace,
    required String description,
  }) async {
    try {
      String? photoBase64 = await imageToBase64();

      final body = <String, dynamic>{
        'user_id': userId,
        'lost_date': lostDate,
        'lost_place': lostPlace,
        'description': description,
      };

      if (photoBase64 != null) {
        body['photo'] = photoBase64;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/lost-items'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        print('Server error: ${response.body}');
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  final List<String> places = [
    "Tunis",
    "Ariana",
    "Ben Arous",
    "Manouba",
    "Sousse",
    "Sfax",
    "Bizerte",
    "Nabeul",
    "Gabès",
    "Kairouan",
    "Monastir",
    "Mahdia",
    "Gafsa",
    "Kasserine",
    "Médenine",
    "Tataouine",
    "Kébili",
  ];

  String? selectedPlace;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 800,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        selectedImageFile = picked;
        selectedImageBytes = bytes;
      });
    }
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF6B6B),
              onPrimary: Colors.white,
              surface: Color(0xFF2C3E50),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      String formattedDate = selectedDate != null
          ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
          : DateTime.now().toIso8601String().split('T')[0];

      final result = await submitLostItemToDb(
        lostDate: formattedDate,
        lostPlace: selectedPlace!,
        description: descriptionController.text,
      );

      setState(() => isLoading = false);
      if (!mounted) return;

      if (result['success']) {
        // ✅ Read new credit score from server response and notify parent
        final newScore = result['data']['credit_score'];
        final int updatedScore = newScore != null
            ? newScore as int
            : widget.creditScore + 10;

        // ✅ Save updated score to SharedPreferences so it persists across logout/login
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('creditScore', updatedScore);

        if (newScore != null && widget.onScoreUpdated != null) {
          widget.onScoreUpdated!(updatedScore);
        }

        await NotificationService.show(
          notificationTitle: "✅ Lost Item Reported",
          notificationBody: "Your lost item has been saved to database",
        );
        _showSnackBar("Lost item reported successfully! +10 points 🎉", true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardPage(
              userId: widget.userId,
              fullName: widget.fullName,
              email: widget.email,
              creditScore: updatedScore,
              isLoggedIn: true,
            ),
          ),
        );
      } else {
        _showSnackBar("Error: ${result['error']}", false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("An error occurred: $e", false);
    }
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: isSuccess
            ? const Color(0xFF06D6A0)
            : const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (selectedImageBytes != null) {
      return Image.memory(
        selectedImageBytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Lost Something?",
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Let's help you find it",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            _buildLabel("When did you lose it? *"),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: pickDate,
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: dateController,
                                  decoration: _inputDecoration(
                                    "Select Date",
                                    Icons.calendar_today_rounded,
                                  ),
                                  validator: (v) => v == null || v.isEmpty
                                      ? "Date is required"
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildLabel("Where did you lose it? *"),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: selectedPlace,
                              isExpanded: true,
                              decoration: _inputDecoration(
                                "Select Location",
                                Icons.location_on_rounded,
                              ),
                              items: places
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p,
                                      child: Text(p),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => selectedPlace = v),
                              validator: (v) =>
                                  v == null ? "Location is required" : null,
                              dropdownColor: Colors.white,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF2C3E50),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildLabel("Description *"),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: descriptionController,
                              maxLines: 4,
                              decoration: _inputDecoration(
                                "Describe what you lost...",
                                Icons.description_rounded,
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? "Description is required"
                                  : null,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildLabel("Add Photo (Optional)"),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: pickImage,
                              child: Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0),
                                    width: 2,
                                  ),
                                ),
                                child: selectedImageBytes == null
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFFFF6B6B,
                                              ).withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.add_a_photo_rounded,
                                              size: 40,
                                              color: Color(0xFFFF6B6B),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            "Tap to add photo",
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            child: _buildImagePreview(),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 8,
                                                  ),
                                                ],
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Color(0xFFFF6B6B),
                                                ),
                                                onPressed: () => setState(() {
                                                  selectedImageFile = null;
                                                  selectedImageBytes = null;
                                                }),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 8,
                                            left: 8,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFF6B6B),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                "✓ Photo Added",
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Container(
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B6B),
                                    Color(0xFFEE5A6F),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFF6B6B,
                                    ).withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: isLoading ? null : submit,
                                  borderRadius: BorderRadius.circular(30),
                                  child: Center(
                                    child: Text(
                                      "Submit Report",
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFFF6B6B),
                          ),
                          strokeWidth: 4,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Submitting...",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Saving to database",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2C3E50),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      prefixIcon: Icon(icon, color: const Color(0xFFFF6B6B)),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
      ),
    );
  }
}
