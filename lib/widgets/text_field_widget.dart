import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whatsapp/utils/utils.dart';

class KWidgetTextField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final int? maxLines;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final EdgeInsetsGeometry? contentPadding;
  final bool? enabled;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final double? borderRadius; // ✅ New property

  const KWidgetTextField({
    super.key,
    this.hintText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.fillColor = AppColors.darkGrey,
    this.borderColor = AppColors.lightGrey,
    this.focusedBorderColor = AppColors.lightGreen,
    this.errorBorderColor = Colors.red,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    this.enabled = true,
    this.hintStyle,
    this.textStyle,
    this.borderRadius = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius ?? 8.0);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText ?? false,
      maxLines: obscureText == true ? 1 : maxLines,
      validator: validator,
      enabled: enabled,
      style:
          textStyle ?? GoogleFonts.manrope(fontSize: 16, color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle ?? GoogleFonts.manrope(color: AppColors.lightGrey),
        filled: true,
        fillColor: fillColor,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: contentPadding,
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: borderColor ?? Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: focusedBorderColor ?? Colors.blue,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: errorBorderColor ?? Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(
            color: errorBorderColor ?? Colors.red,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

Widget buildField({
  required TextEditingController controller,
  required String hint,
  IconData? icon,
  TextInputType keyboardType = TextInputType.text,
  bool obscureText = false,
  Widget? suffix,
  String? Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
    child: KWidgetTextField(
      hintText: hint,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: 1,
      validator: validator,
      prefixIcon: Icon(icon, color: AppColors.lightGreen),
      suffixIcon: suffix,
      fillColor: AppColors.darkGrey,
      borderColor: AppColors.lightGrey,
      focusedBorderColor: AppColors.lightGreen,
      errorBorderColor: Colors.red,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabled: true,
      hintStyle: const TextStyle(color: AppColors.lightGrey),
      textStyle: GoogleFonts.manrope(
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
  );
}
