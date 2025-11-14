import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

ThemeData buildAppTheme() {
  final base = ThemeData.light(useMaterial3: true);

  final scheme = ColorScheme.fromSeed(
    seedColor: kBrandPrimary,
    primary: kBrandPrimary,
    secondary: kBrandAccent,
    surface: kSurface,
    background: kSurface,
    primaryContainer: kBrandPrimaryDark,
  );

  final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: kTextPrimary,
    displayColor: kTextPrimary,
  ).copyWith(
    displayLarge: GoogleFonts.inter(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      height: 1.15,
      letterSpacing: -0.3,
      color: kTextPrimary,
    ),
    titleLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: kTextPrimary),
    titleMedium: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: kTextPrimary),
    bodyLarge: GoogleFonts.inter(fontSize: 16, height: 1.4, color: kTextPrimary),
    bodyMedium: GoogleFonts.inter(fontSize: 14, height: 1.45, color: kTextSecondary),
    labelSmall: GoogleFonts.inter(fontSize: 11, letterSpacing: 0.2, color: kTextSecondary),
  );

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: kSurface,
    dividerTheme: const DividerThemeData(thickness: 1, space: 24, color: kSoftDivider),
    cardTheme: CardThemeData(
      color: kCard,
      elevation: 2,
      margin: const EdgeInsets.all(0),
      shadowColor: Colors.black.withOpacity(0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kCardRadius)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: kCard,
      foregroundColor: kTextPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kBrandPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith(
          (states) => states.contains(MaterialState.pressed) ? kBrandPrimaryDark : null,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kBrandPrimary,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: kTextSecondary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kSoftDivider)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kSoftDivider)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBrandPrimary)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: kCard,
      indicatorColor: scheme.primary.withOpacity(0.12),
      labelTextStyle: MaterialStatePropertyAll(textTheme.bodyMedium),
    ),
    textTheme: textTheme,
  );
}
