import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient_app/main.dart'; // Import for authProvider

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showWelcome = false;
  String _userName = "";
  
  // Re-adding missing variables
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    setState(() {
      _isLoading = true;
      _userName = _emailController.text.isNotEmpty ? _emailController.text.split('@')[0] : "John"; 
    });
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Login and Redirect
    if (mounted) {
       try {
         ref.read(welcomeMessageProvider.notifier).state = "Welcome back, $_userName";
         await ref.read(authProvider.notifier).login(
           _emailController.text, 
           _passwordController.text
         );
         
         // After login call, check state
         if (!ref.read(authProvider)) {
            // Login failed
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Login failed. Please check credentials or sign up if you haven't recently."))
            );
         }
       } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("An error occurred: $e"))
         );
       } finally {
         if (mounted) {
           setState(() => _isLoading = false);
         }
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated MedX Logo imitating Apple's "Dots"
                const _BreathingLogo(),
                const SizedBox(height: 30),
                
                Text(
                  "Sign in to MedX",
                  style: GoogleFonts.inter(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.black,
                    letterSpacing: -0.5
                  ),
                ),
                const SizedBox(height: 40),

                // Apple-style Input Group - Constrained Width
                Container(
                  width: 320, // Reduced length
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _MinimalInput(
                        controller: _emailController, 
                        placeholder: "Email",
                        isLast: false,
                      ),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                      _MinimalInput(
                        controller: _passwordController, 
                        placeholder: "Password", 
                        obscureText: true,
                        isLast: true,
                        onSubmitted: (_) => _handleLogin(),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),

                // Login Button with Arrow
                SizedBox(
                  width: 320, // Reduced length to match inputs
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Apple Black
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Text("Sign In", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                             const SizedBox(width: 8),
                             const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                  ),
                ),
                
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: true, 
                      onChanged: (_) {},
                      activeColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    Text("Keep me signed in", style: GoogleFonts.inter(color: Colors.grey[700])),
                  ],
                ),

                const SizedBox(height: 40),
                TextButton(
                  onPressed: () {},
                  child: Text("Forgot MedX ID or password? ↗", style: GoogleFonts.inter(color: Colors.blue[700])),
                ),
                TextButton(
                  onPressed: () => context.push('/signup'),
                  child: Text("Create MedX ID", style: GoogleFonts.inter(color: Colors.blue[700])),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BreathingLogo extends StatefulWidget {
  const _BreathingLogo();
  @override
  State<_BreathingLogo> createState() => _BreathingLogoState();
}

class _BreathingLogoState extends State<_BreathingLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.1 + (_controller.value * 0.1)),
                Colors.purple.withOpacity(0.1 + (_controller.value * 0.1)),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(Icons.health_and_safety, size: 64, color: Colors.black.withOpacity(0.8)),
        );
      },
    );
  }
}

class _MinimalInput extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final bool obscureText;
  final bool isLast;
  final Function(String)? onSubmitted;

  const _MinimalInput({
    required this.controller,
    required this.placeholder,
    this.obscureText = false,
    this.isLast = false,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onSubmitted: onSubmitted,
      style: const TextStyle(fontSize: 17, color: Colors.black),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: isLast ? const Icon(Icons.arrow_circle_right_outlined, color: Colors.transparent) : null, // Spacer
      ),
    );
  }
}
