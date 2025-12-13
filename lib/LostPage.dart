import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  // Tunisian places
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
  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => selectedImage = File(picked.path));
    }
  }

  // Pick date (disable typing)
  Future pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: "Ikhtar el date",
      cancelText: "Annuler",
      confirmText: "OK",
    );

    if (picked != null) {
      setState(() {
        dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void submit() {
    if (!_formKey.currentState!.validate()) return;

    // Description mandatory ONLY if no photo
    if (selectedImage == null && descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La description obligatoire si ma fama ch photo"),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Thabtna fi adhika, merci !")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00C0E8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF00C0E8),
        elevation: 0,
        title: const Text(
          "Dhayya3t 7aja",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
        ),
      ),

      body: Center(
        child: Container(
          width: 330,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),

          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 20),

                // DATE FIELD (now picker)
                GestureDetector(
                  onTap: pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: dateController,
                      decoration: _dec(
                        "Date (obligatoire)",
                        Icons.calendar_today,
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? "Wakteh dhayya3tha?"
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // PLACE FIELD FIXED (NO OVERFLOW)
                Container(
                  width: double.infinity, // makes sure it never overflows
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedPlace,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.place),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    isExpanded:
                        true, // 🔥 IMPORTANT: fixes overflow automatically
                    hint: const Text("Win dhayya3tha (obligatoire)?"),
                    items: places
                        .map(
                          (place) => DropdownMenuItem(
                            value: place,
                            child: Text(place, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => selectedPlace = value),
                    validator: (value) =>
                        value == null ? "Win dhayya3tha" : null,
                  ),
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Description",
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                      child: Icon(Icons.description),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // PHOTO PICKER
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
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
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

                const SizedBox(height: 35),

                // SUBMIT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF41D5AB),
                      side: const BorderSide(
                        color: Color(0xFF444444),
                        width: 2,
                      ),
                    ),
                    onPressed: submit,
                    child: Text(
                      "Sajjil el Ma3loumet",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
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
