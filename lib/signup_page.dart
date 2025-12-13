import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'welcome_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;

  // ================= VALIDATION FUNCTIONS =================

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

  String? validateAge(String? value) {
    if (value == null || value.isEmpty) return "Age is required";
    final age = int.tryParse(value);
    if (age == null) return "Age must be a number";
    if (age < 1 || age > 120) return "Enter a valid age (1–120)";
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return "Phone is required";
    final phoneRegex = RegExp(r'^[0-9]{8,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return "Phone must be 8 digits";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password is required";
    if (value.length < 6) return "Min 6 characters";
    return null;
  }

  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00C0E8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF00C0E8),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
        ),
      ),

      body: Center(
        child: Container(
          width: 330,
          padding: const EdgeInsets.symmetric(horizontal: 18),

          child: Form(
            key: _formKey,

            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(height: 10),

                // TITLE
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_add, color: Colors.white, size: 34),
                    const SizedBox(width: 10),
                    Text(
                      "Create Account",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                // FULL NAME
                _inputField(
                  controller: nameController,
                  hint: "Full Name",
                  icon: Icons.person,
                  validator: validateFullName,
                ),

                const SizedBox(height: 15),

                // EMAIL
                _inputField(
                  controller: emailController,
                  hint: "Email",
                  icon: Icons.email,
                  validator: validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 15),

                // PHONE — digits only
                _inputField(
                  controller: phoneController,
                  hint: "Phone Number",
                  icon: Icons.phone,
                  validator: validatePhone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),

                const SizedBox(height: 15),

                // AGE — digits only
                _inputField(
                  controller: ageController,
                  hint: "Age",
                  icon: Icons.cake,
                  validator: validateAge,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),

                const SizedBox(height: 15),

                // PASSWORD
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  validator: validatePassword,
                  decoration: _decoration(
                    hint: "Password",
                    icon: Icons.lock,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // SIGNUP BUTTON
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Optional success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Account Created!")),
                        );

                        // Navigate to Welcome Page (Login / Signup)
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WelcomePage(),
                          ),
                          (route) => false, // removes signup from back stack
                        );
                      }
                    },

                    child: Text(
                      "Sign Up",
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

  // ================= INPUT DECORATION REUSE =================

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: _decoration(hint: hint, icon: icon),
    );
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
