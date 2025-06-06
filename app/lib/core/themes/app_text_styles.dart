import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static final TextStyle displayLarge = GoogleFonts.sansitaSwashed(
    fontWeight: FontWeight.bold,
    fontSize: 25,
  );

  // For tasks
  static final TextStyle labelMedium = GoogleFonts.schibstedGrotesk(
    fontWeight: FontWeight.normal,
    fontSize: 22,
  );
  static final TextStyle labelSmall = GoogleFonts.schibstedGrotesk(
    fontSize: 14,
  );
}