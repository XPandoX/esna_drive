import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // inDrive Brand Colors
  static const Color primaryLime = Color(0xFFA7E92F);
  static const Color primaryGreen = Color(0xFF2DBE60);
  static const Color darkBg = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF282828);
  static const Color darkBorder = Color(0xFF383838);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFA0A0A0);
  static const Color textSubtle = Color(0xFF707070);
  static const Color alertRed = Color(0xFFFF4D4F);
  static const Color warningOrange = Color(0xFFFAAD14);
  static const Color infoBlue = Color(0xFF1890FF);

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    final cairoText = GoogleFonts.cairoTextTheme(base.textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: primaryLime,
      colorScheme: const ColorScheme.dark(
        primary: primaryLime,
        secondary: primaryGreen,
        surface: darkSurface,
        error: alertRed,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: textLight,
      ),
      textTheme: cairoText.apply(
        bodyColor: textLight,
        displayColor: textLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textLight,
        ),
        iconTheme: const IconThemeData(color: primaryLime),
      ),
      cardTheme: CardTheme(
        color: darkCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLime,
          foregroundColor: Colors.black,
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLime,
          side: const BorderSide(color: primaryLime, width: 1.5),
          textStyle: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryLime, width: 2),
        ),
        hintStyle: GoogleFonts.cairo(color: textMuted, fontSize: 14),
        labelStyle: GoogleFonts.cairo(color: textMuted, fontSize: 14),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        modalBackgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: darkBg,
      ),
    );
  }
}
