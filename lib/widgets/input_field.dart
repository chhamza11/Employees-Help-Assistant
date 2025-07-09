import 'package:flutter/material.dart';
import '../core/colors.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final Color? cursorColor;
  final ValueChanged<String>? onChanged;

  const InputField({
    Key? key,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.onChanged, required TextInputType keyboardType,
    this.cursorColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.white70),
        filled: true,
        fillColor: AppColors.inputBackground,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.white70) : null,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppColors.white70) : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
