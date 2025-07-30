import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

SnackBar showSuccessSnackBar(String content) {
  return SnackBar(
    content: Text(
      content,
      style: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500
      ),
    ),
    backgroundColor: Colors.green,
    showCloseIcon: true,
    closeIconColor: Colors.white,
    duration: Duration(seconds: 5),
    elevation: 2,
  );
}