import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ================= Validation functions =================
  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) return "Full name is required";
    final nameRegex = RegExp(r"^[a-zA-Z ]+$");
    if (!nameRegex.hasMatch(value)) return "Name must contain only letters";
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email is required";
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return "Enter a valid email";
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return "Phone is required";
    final phoneRegex = RegExp(r'^[0-9]{8,15}$');
    if (!phoneRegex.hasMatch(value)) return "Phone must be 8-15 digits";
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password is required";
    if (value.length < 6) return "Min 6 characters";
    return null;
  }

  // ================= Signup HTTP request =================
  Future<void> signupUser() async {
    try {
      final url = Uri.parse("http://localhost:3000/signup");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "full_name": nameController.text,
          "email": emailController.text,
          "phone": phoneController.text,
          "password": passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account Created Successfully! 🎉"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF06D6A0),
          ),
        );

        // Navigate to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData['error'] ?? "Signup failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF6B9D), Color(0xFFC06C84), Color(0xFF6C5B7B)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 60,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Create Account",
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Join our community today",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Glass card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildGlassField(
                                  controller: nameController,
                                  hint: "Full Name",
                                  icon: Icons.person_outline,
                                  validator: validateFullName,
                                ),
                                const SizedBox(height: 16),
                                _buildGlassField(
                                  controller: emailController,
                                  hint: "Email",
                                  icon: Icons.email_outlined,
                                  validator: validateEmail,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 16),
                                _buildGlassField(
                                  controller: phoneController,
                                  hint: "Phone Number",
                                  icon: Icons.phone_outlined,
                                  validator: validatePhone,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildGlassField(
                                  controller: passwordController,
                                  hint: "Password",
                                  icon: Icons.lock_outline,
                                  validator: validatePassword,
                                  obscureText: _obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 30),
                                // Sign up button
                                Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF06D6A0),
                                        Color(0xFF00B4D8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF06D6A0,
                                        ).withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        if (_formKey.currentState!.validate()) {
                                          signupUser();
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(28),
                                      child: const Center(
                                        child: Text(
                                          "Sign Up",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
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
          ),
        ),
      ),
    );
  }

  Widget _buildGlassField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.6),
            fontSize: 16,
          ),
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
