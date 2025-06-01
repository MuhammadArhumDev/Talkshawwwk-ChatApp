import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Color Constants
class AppColors {
  static const Color black = Color(0xFF0B1014);
  static const Color darkGrey = Color(0xFF23282C);
  static const Color darkGreen = Color(0xFF0E3728);
  static const Color lightGreen = Color(0xFFAFD5B4);
  static const Color brightGreen = Color(0xFF21C063);
  static const Color lightGrey = Color(0xFF868A8D);
  static const Color chatGrey = Color(0xFF134D37);
  static const Color white = Color(0xFFFFFFFF);
  static const Color replyPane = Color.fromARGB(255, 6, 44, 30);
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: GoogleFonts.manrope(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
