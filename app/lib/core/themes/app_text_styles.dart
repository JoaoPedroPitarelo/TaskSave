import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static final TextStyle displayLarge = GoogleFonts.roboto(
    fontWeight: FontWeight.normal,
    fontSize: 36,
  );

  static final TextStyle displayMedium = GoogleFonts.sansitaSwashed(
    fontWeight: FontWeight.bold,
    fontSize: 25,
  );

  static final TextStyle bodyMedium = GoogleFonts.roboto(
    fontWeight: FontWeight.normal,
    fontSize: 16
  );

  static final TextStyle bodySmall = GoogleFonts.roboto(
    fontWeight: FontWeight.normal,
    fontSize: 16,
    color: Colors.white
  );

  static final TextStyle displaySmall = GoogleFonts.schibstedGrotesk(
    fontSize: 13
  );

  // For tasks
  static final TextStyle labelMedium = GoogleFonts.schibstedGrotesk(
    fontWeight: FontWeight.normal,
    fontSize: 22,
  );
  static final TextStyle labelSmall = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
}
