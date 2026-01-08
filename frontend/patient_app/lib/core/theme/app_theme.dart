import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Refined Apple Color Palette
  // Refined Apple Color Palette (Matches Landing Page)
  static const Color background = Color(0xFFF5F5F7); 
  static const Color cardColor = Colors.white;
  static const Color primary = Color(0xFF0071E3); // Exact match to Landing Page
  static const Color textPrimary = Color(0xFF1D1D1F); // Apple Black
  static const Color textSecondary = Color(0xFF86868B); // Apple Gray
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
        secondary: textSecondary, // Use textSecondary as secondary color
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: const TextStyle(
          fontSize: 34, 
          fontWeight: FontWeight.w700, // Bold
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: const TextStyle(
          fontSize: 22, // Slightly larger
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.4,
        ),
        bodyLarge: const TextStyle(
          fontSize: 17,
          color: textPrimary,
          height: 1.3,
        ),
        bodyMedium: const TextStyle(
          fontSize: 15,
          color: textSecondary, // Soft Gray
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
