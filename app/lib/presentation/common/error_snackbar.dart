import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_save/presentation/common/animated_snackbar.dart';

SnackBar showErrorSnackBar(String content, {SnackBarAction? action}) {
  return SnackBar(
    content: AnimatedSnackBar(
      content: Text(
        content,
        style: GoogleFonts.roboto(
          color: const Color.fromARGB(255, 245, 175, 175),
          fontSize: 15,
          fontWeight: FontWeight.w500
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 134, 24, 24),
      elevation: 2,
      showCloseIcon: true,
      closeIconColor: const Color.fromARGB(255, 245, 175, 175),
      action: action,
    ),
    duration: const Duration(seconds: 2),
    backgroundColor: Colors.transparent,
    behavior: SnackBarBehavior.fixed,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
}