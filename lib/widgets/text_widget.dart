import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KWidgetText extends StatelessWidget {
  final String text;
  final double? size;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;

  const KWidgetText({
    super.key,
    required this.text,
    this.size,
    this.color,
    this.fontWeight,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.manrope(
        fontSize: size ?? 16.0,
        color: color ?? Colors.black,
        fontWeight: fontWeight ?? FontWeight.normal,
      ),
    );
  }
}
