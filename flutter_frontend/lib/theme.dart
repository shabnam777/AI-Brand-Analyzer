import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFFF5F6FF);
  static const bgDeep = Color(0xFFEEEFFB);
  static const white = Color(0xFFFFFFFF);
  static const indigo = Color(0xFF4F46E5);
  static const indigoDark = Color(0xFF3730A3);
  static const indigoLight = Color(0xFFEEF2FF);
  static const violet = Color(0xFF7C3AED);
  static const gold = Color(0xFFF59E0B);
  static const goldLight = Color(0xFFFFFBEB);
  static const textPrimary = Color(0xFF0F0A2C);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFFADB5BD);
  static const gradeA = Color(0xFF059669);
  static const gradeB = Color(0xFF0EA5E9);
  static const gradeC = Color(0xFFF59E0B);
  static const gradeD = Color(0xFFF97316);
  static const gradeF = Color(0xFFEF4444);
  static const border = Color(0xFFE5E7EB);
  static const borderFocus = Color(0xFF4F46E5);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.light(
          primary: AppColors.indigo,
          surface: AppColors.white,
        ),
        textTheme: GoogleFonts.dmSansTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderFocus, width: 2),
          ),
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );

  static Color gradeColor(String grade) {
    switch (grade) {
      case 'A': return AppColors.gradeA;
      case 'B': return AppColors.gradeB;
      case 'C': return AppColors.gradeC;
      case 'D': return AppColors.gradeD;
      default:  return AppColors.gradeF;
    }
  }

  static Color gradeBg(String grade) {
    switch (grade) {
      case 'A': return const Color(0xFFECFDF5);
      case 'B': return const Color(0xFFE0F2FE);
      case 'C': return const Color(0xFFFFFBEB);
      case 'D': return const Color(0xFFFFF7ED);
      default:  return const Color(0xFFFEF2F2);
    }
  }
}

class AppText {
  static TextStyle display(double size, {FontWeight weight = FontWeight.w700, Color? color}) =>
      GoogleFonts.syne(fontSize: size, fontWeight: weight, color: color ?? AppColors.textPrimary, height: 1.2);

  static TextStyle body(double size, {FontWeight weight = FontWeight.w400, Color? color, double? height}) =>
      GoogleFonts.dmSans(fontSize: size, fontWeight: weight, color: color ?? AppColors.textPrimary, height: height);

  static TextStyle mono(double size, {Color? color, FontWeight weight = FontWeight.w400}) =>
      GoogleFonts.jetBrainsMono(fontSize: size, color: color ?? AppColors.textSecondary, fontWeight: weight);
}
