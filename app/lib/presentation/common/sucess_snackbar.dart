import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_save/presentation/common/animated_snackbar.dart';

SnackBar showSuccessSnackBar(String content, {SnackBarAction? action}) {
  return SnackBar(
    content: AnimatedSnackBar(
      content: Text(
        content,
        style: GoogleFonts.roboto(
          color: const Color.fromARGB(255, 121, 232, 121),
          fontSize: 15,
          fontWeight: FontWeight.w500
        ),
      ),
      backgroundColor: const Color.fromARGB(192, 2, 117, 33),
      elevation: 2,
      showCloseIcon: true,
      closeIconColor:  const Color.fromARGB(255, 121, 232, 121),
      action: action,
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    behavior: SnackBarBehavior.fixed,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    duration: const Duration(seconds: 5),
  );
}
