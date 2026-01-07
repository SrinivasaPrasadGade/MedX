import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Refined Apple Color Palette
  static const Color background = Color(0xFFF5F5F7); // Slightly warmer/lighter gray
  static const Color cardColor = Colors.white;
  static const Color primary = Color(0xFF007AFF); // San Francisco Blue
  static const Color secondary = Color(0xFF8E8E93); 
  static const Color destructive = Color(0xFFFF3B30);
  static const Color success = Color(0xFF34C759);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        background: background,
        surface: cardColor,
        error: destructive,
        secondary: secondary,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: const TextStyle(
          fontSize: 34, 
          fontWeight: FontWeight.w700, // Bold
          color: Colors.black,
          letterSpacing: -0.5,
        ),
        headlineMedium: const TextStyle(
          fontSize: 22, // Slightly larger
          fontWeight: FontWeight.w700,
          color: Colors.black,
          letterSpacing: -0.4,
        ),
        bodyLarge: const TextStyle(
          fontSize: 17,
          color: Colors.black,
          height: 1.3,
        ),
        bodyMedium: const TextStyle(
          fontSize: 15,
          color: Color(0xFF8E8E93), // Soft Gray
          height: 1.3,
        ),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0, // Flat look
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Softer corners
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontFamily: 'Inter',
          fontSize: 17, 
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: primary),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E5EA), 
        thickness: 1,
      ),
    );
  }
}
