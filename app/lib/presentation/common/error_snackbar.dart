import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

SnackBar showErrorSnackBar(String content) {
  return SnackBar(
    content: Text(
      content,
      style: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500
      ),
    ),
    elevation: 2,
    duration: Duration(seconds: 2),
    showCloseIcon: true,
    closeIconColor: Colors.white,
    backgroundColor: Colors.red,
  );
}
