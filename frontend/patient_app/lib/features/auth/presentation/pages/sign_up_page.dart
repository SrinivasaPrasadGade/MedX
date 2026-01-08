import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/main.dart'; // Import for authProvider

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // New Controllers
  final _dobController = TextEditingController();
  final _genderController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  
  bool _isLoading = false;

  void _handleSignUp() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill required fields")));
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // Call AuthNotifier to register
      await ref.read(authProvider.notifier).register(
        email: _emailController.text,
        password: _passwordController.text,
        fullName: _nameController.text,
        dob: _dobController.text,
        gender: _genderController.text,
        phone: _phoneController.text,
        address: _addressController.text,
      );
      
      if (mounted) {
         // Check if registration was actually successful (state should be true)
         if (!ref.read(authProvider)) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration Failed. Email might be in use.")));
         }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Create MedX ID",
                style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Text(
                "Start your health journey today",
                style: GoogleFonts.inter(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Grouped Inputs
              Container(
                 width: 320,
                 decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _MinimalInput(
                      controller: _nameController, 
                      placeholder: "Full Name", 
                      icon: Icons.person_outline,
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                    _MinimalInput(
                      controller: _emailController, 
                      placeholder: "Email", 
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                    _MinimalInput(
                      controller: _passwordController, 
                      placeholder: "Password", 
                      icon: Icons.lock_outline, 
                      obscureText: true,
                    ),
                     const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                     
                     // Extra Fields
                     _MinimalInput(
                      controller: _dobController, 
                      placeholder: "Birth Date (YYYY-MM-DD)", 
                      icon: Icons.calendar_today_outlined,
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                    _MinimalInput(
                      controller: _genderController, 
                      placeholder: "Gender", 
                      icon: Icons.people_outline,
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                    _MinimalInput(
                      controller: _phoneController, 
                      placeholder: "Phone", 
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                    _MinimalInput(
                      controller: _addressController, 
                      placeholder: "Address", 
                      icon: Icons.home_outlined,
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: 320,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : const Text("Create Account", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MinimalInput extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final IconData? icon;
  final bool obscureText;
  final bool isLast;
  final TextInputType? keyboardType;

  const _MinimalInput({
    required this.controller,
    required this.placeholder,
    this.icon,
    this.obscureText = false,
    this.isLast = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16, color: Colors.black),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey[400], size: 20) : null,
      ),
    );
  }
}
