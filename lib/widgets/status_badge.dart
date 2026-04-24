import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/styles.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const StatusBadge({
    Key? key,
    required this.label,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? _getColorForStatus(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppStyles.badgeText.copyWith(color: Colors.white),
      ),
    );
  }

  static Color _getColorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'present':
      case 'completed':
      case 'verified':
        return const Color(0xFF2ECC71);
      case 'pending':
      case 'in_progress':
      case 'in progress':
        return AppColors.primary;
      case 'rejected':
      case 'absent':
      case 'cancelled':
      case 'urgent':
        return const Color(0xFFE74C3C);
      case 'half-day':
      case 'half day':
      case 'on-leave':
      case 'on leave':
      case 'low':
        return AppColors.white70;
      case 'medium':
      case 'high':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }
}
