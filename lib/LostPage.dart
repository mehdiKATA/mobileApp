import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'dashboard_page.dart';
import 'notification_service.dart'; // ✅ ADD THIS

class LostItemPage extends StatefulWidget {
  const LostItemPage({super.key});

  @override
  State<LostItemPage> createState() => _LostItemPageState();
}

class _LostItemPageState extends State<LostItemPage> {
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

    if (selectedImage == null && descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "La description est obligatoire ken ma3andekch taswira.",
          ),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // ✅ SHOW SYSTEM NOTIFICATION (ANDROID + IOS)
    await NotificationService.show(
      notificationTitle: "✔ Informations reçues",
      notificationBody: "Nous avons bien reçu vos informations",
    );

    setState(() => isLoading = false);

    // ✅ NAVIGATE TO DASHBOARD
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
          backgroundColor: const Color(0xFF00C0E8),

          appBar: AppBar(
            backgroundColor: const Color(0xFF00C0E8),
            elevation: 0,
            title: const Text(
              "Dhayya3t 7aja",
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

                    // DATE
                    GestureDetector(
                      onTap: pickDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: dateController,
                          decoration: _dec("Date", Icons.calendar_today),
                          validator: (v) =>
                              v == null || v.isEmpty ? "Wakteh dhaya3t?" : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // PLACE
                    DropdownButtonFormField<String>(
                      value: selectedPlace,
                      isExpanded: true,
                      decoration: _dec("Win dhaya3t?", Icons.place),
                      items: places
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedPlace = v),
                      validator: (v) => v == null ? "Win dhaya3t?" : null,
                    ),

                    const SizedBox(height: 20),

                    // DESCRIPTION
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: _dec("Description", Icons.description),
                    ),

                    const SizedBox(height: 20),

                    // IMAGE
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black26),
                        ),
                        child: selectedImage == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(height: 10),
                                  Text("Ajout photo (ikhtiyari)"),
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

                    // SUBMIT
                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF41D5AB),
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
            color: Colors.black.withOpacity(0.6),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 6,
                color: Color(0xFF41D5AB),
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
