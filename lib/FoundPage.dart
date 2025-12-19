import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'dashboard_page.dart';
import 'notification_service.dart';

class FoundPage extends StatefulWidget {
  const FoundPage({super.key});

  @override
  State<FoundPage> createState() => _FoundPageState();
}

class _FoundPageState extends State<FoundPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  File? selectedImage;
  bool isLoading = false;

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

  // Pick image
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => selectedImage = File(picked.path));
    }
  }

  // Pick date
  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    // All fields are mandatory for found items
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La photo est obligatoire."),
        ),
      );
      return;
    }

    if (descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La description est obligatoire."),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Show system notification
    await NotificationService.show(
      notificationTitle: "✔ Informations reçues",
      notificationBody: "Nous avons bien reçu vos informations",
    );

    setState(() => isLoading = false);

    // Navigate to dashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFF41D5AB),

          appBar: AppBar(
            backgroundColor: const Color(0xFF41D5AB),
            elevation: 0,
            title: const Text(
              "L9it 7aja",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          body: Center(
            child: Container(
              width: 330,
              padding: const EdgeInsets.all(16),

              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 20),

                    // DATE (OBLIGATORY)
                    GestureDetector(
                      onTap: pickDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: dateController,
                          decoration: _dec("Date (obligatoire)", Icons.calendar_today),
                          validator: (v) =>
                              v == null || v.isEmpty ? "Wakteh l9it?" : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // PLACE (OBLIGATORY)
                    DropdownButtonFormField<String>(
                      value: selectedPlace,
                      isExpanded: true,
                      decoration: _dec("Win l9it? (obligatoire)", Icons.place),
                      items: places
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedPlace = v),
                      validator: (v) => v == null ? "Win l9it?" : null,
                    ),

                    const SizedBox(height: 20),

                    // DESCRIPTION (OBLIGATORY)
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: _dec("Description (obligatoire)", Icons.description),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Description obligatoire" : null,
                    ),

                    const SizedBox(height: 20),

                    // IMAGE (OBLIGATORY)
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedImage == null 
                                ? Colors.red.withOpacity(0.5) 
                                : Colors.black26,
                            width: selectedImage == null ? 2 : 1,
                          ),
                        ),
                        child: selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.red,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Photo (obligatoire)",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  selectedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // SUBMIT BUTTON
                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C0E8),
                          side: const BorderSide(
                            color: Color(0xFF444444),
                            width: 2,
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: isLoading ? null : submit,
                        child: Text(
                          "Submit",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // LOADING OVERLAY
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated circular progress with gradient effect
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF41D5AB).withOpacity(0.2),
                            const Color(0xFF00C0E8).withOpacity(0.2),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF41D5AB)),
                          strokeWidth: 6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C0E8).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF00C0E8),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Jari el ta7mil...",
                      style: GoogleFonts.inter(
                        color: const Color(0xFF444444),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Ettasjil fi adhika",
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  InputDecoration _dec(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}