import 'package:flutter/material.dart';
import '../core/colors.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final Color? cursorColor;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final VoidCallback? onSuffixTap;
  final int maxLines;
  final bool enabled;

  const InputField({
    Key? key,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.cursorColor,
    this.controller,
    this.validator,
    this.onSuffixTap,
    this.maxLines = 1,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      cursorColor: cursorColor ?? AppColors.primary,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.white70),
        filled: true,
        fillColor: AppColors.inputBackground,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.white70) : null,
        suffixIcon: suffixIcon != null
            ? GestureDetector(
                onTap: onSuffixTap,
                child: Icon(suffixIcon, color: AppColors.white70),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Color(0xFFE74C3C)),
      ),
    );
  }
}
