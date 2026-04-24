import 'package:flutter/material.dart';
import 'colors.dart';

class AppStyles {
  static const String _font = 'Inter';

  static const TextStyle splashTitle = TextStyle(
    fontFamily: _font,
    color: AppColors.white,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
  );

  static const TextStyle loginTitle = TextStyle(
    fontFamily: _font,
    color: AppColors.white,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  static const TextStyle homeGreeting = TextStyle(
    fontFamily: _font,
    color: AppColors.white,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle homeSubtitle = TextStyle(
    fontFamily: _font,
    color: AppColors.white70,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: _font,
    color: AppColors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: _font,
    color: AppColors.white,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle cardDescription = TextStyle(
    fontFamily: _font,
    color: AppColors.white70,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: _font,
    color: AppColors.white,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle dashboardNumber = TextStyle(
    fontFamily: _font,
    color: AppColors.white,
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle dashboardLabel = TextStyle(
    fontFamily: _font,
    color: AppColors.white70,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle badgeText = TextStyle(
    fontFamily: _font,
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle tileLabel = TextStyle(
    fontFamily: _font,
    color: AppColors.white70,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle tileValue = TextStyle(
    fontFamily: _font,
    color: AppColors.white,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle appBarTitle = TextStyle(
    fontFamily: _font,
    color: AppColors.white,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle emptyState = TextStyle(
    fontFamily: _font,
    color: AppColors.white70,
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );
}
