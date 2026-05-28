import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Cores de Destaque / Marca (Fintech Premium)
  static const Color primaryGreen = Color(0xFF00C853); // Verde Vibrante
  static const Color darkGreen = Color(0xFF008744);    // Verde Floresta Profundo
  static const Color lightGreen = Color(0xFFE8F5E9);   // Verde Pastel Suave
  static const Color accentMint = Color(0xFF00E676);   // Verde Menta Elétrico

  // Cores Semânticas
  static const Color incomeGreen = Color(0xFF10B981);  // Esmeralda 500
  static const Color expenseRed = Color(0xFFEF4444);   // Vermelho 500
  static const Color balanceBlue = Color(0xFF3B82F6);  // Azul 500

  // Cores Neutras (Escala Slate do Tailwind - Premium)
  static const Color backgroundWhite = Color(0xFFF8FAFC); // Slate 50
  static const Color cardWhite = Color(0xFFFFFFFF);        // Puro Branco
  static const Color textDark = Color(0xFF0F172A);         // Slate 900
  static const Color textMedium = Color(0xFF475569);       // Slate 600
  static const Color textLight = Color(0xFF94A3B8);        // Slate 400
  static const Color dividerColor = Color(0xFFF1F5F9);     // Slate 100

  static const Color textPrimary = textDark;
  static const Color textSecondary = textMedium;

  // Sombras Orgânicas e Suaves
  static List<BoxShadow> get premiumShadow => [
        BoxShadow(
          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static ThemeData get lightTheme {
    // Sora para Títulos/Headers e Inter para Corpo do Texto (Combinação Premium 2026)
    final textTheme = GoogleFonts.interTextTheme();
    final headerFont = GoogleFonts.sora();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryGreen,
        onPrimary: Colors.white,
        primaryContainer: lightGreen,
        onPrimaryContainer: darkGreen,
        secondary: darkGreen,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFDCFCE7), // Green 100
        onSecondaryContainer: const Color(0xFF166534), // Green 800
        surface: cardWhite,
        onSurface: textDark,
        error: expenseRed,
        onError: Colors.white,
        outline: dividerColor,
      ),
      scaffoldBackgroundColor: backgroundWhite,
      textTheme: textTheme.copyWith(
        headlineLarge: headerFont.copyWith(
          color: textDark,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineMedium: headerFont.copyWith(
          color: textDark,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineSmall: headerFont.copyWith(
          color: textDark,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: headerFont.copyWith(
          color: textDark,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          color: textDark,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: textTheme.titleSmall?.copyWith(
          color: textMedium,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: textDark,
          fontSize: 15,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: textMedium,
          fontSize: 14,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          color: textLight,
          fontSize: 12,
        ),
        labelLarge: headerFont.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundWhite,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.sora(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: primaryGreen, size: 24),
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: dividerColor, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.sora(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.sora(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          textStyle: GoogleFonts.sora(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: expenseRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: expenseRed, width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(color: textMedium),
        hintStyle: GoogleFonts.inter(color: textLight),
        errorStyle: GoogleFonts.inter(color: expenseRed, fontSize: 12),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: textDark,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: CircleBorder(),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardWhite,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.sora(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.sora(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1.5,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: textDark,
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: dividerColor),
        ),
        titleTextStyle: GoogleFonts.sora(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.inter(
          color: textMedium,
          fontSize: 15,
        ),
      ),
    );
  }
}
