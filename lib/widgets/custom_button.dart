import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? background;
  final Color? textColor;
  final VoidCallback? onPressed;
  final bool useGradient;
  final int? iconSize;
  final String? imageUrl;


  const CustomButton({
    super.key,
    required this.text,
    this.icon,
    this.background,
    this.textColor,
    this.onPressed,
    this.iconSize,
    this.useGradient = false,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final Widget child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: textColor ?? AppColors.white, size: 20),
          const SizedBox(width: 8),
        ],
        Text(text, style: AppStyles.buttonText.copyWith(color: textColor ?? AppColors.white)),
      ],
    );

    final ButtonStyle style = ElevatedButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      backgroundColor: useGradient ? Colors.transparent : (background ?? AppColors.primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    );

    if (useGradient) {
      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton(
          style: style,
          onPressed: onPressed,
          child: child,
        ),
      );
    }
    return ElevatedButton(
      style: style,
      onPressed: onPressed,
      child: child,
    );
  }
}
