import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/colors.dart';
import '../../../core/styles.dart';
import '../../../widgets/app_card.dart';

class ShiftInfoWidget extends StatelessWidget {
  final String scheduledStart;
  final String scheduledEnd;

  const ShiftInfoWidget({
    Key? key,
    required this.scheduledStart,
    required this.scheduledEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Iconsax.clock, color: AppColors.white70, size: 20),
          const SizedBox(width: 12),
          Text("Today's Shift", style: AppStyles.cardDescription),
          const Spacer(),
          Text(
            '${_formatTime(scheduledStart)} - ${_formatTime(scheduledEnd)}',
            style: AppStyles.cardTitle.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return time;
    int hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute $period';
  }
}
