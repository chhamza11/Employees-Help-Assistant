import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/colors.dart';
import '../../../core/styles.dart';
import '../../../core/time_utils.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/attendance_provider.dart';
import '../../../widgets/app_card.dart';

class AttendanceClockWidget extends ConsumerWidget {
  const AttendanceClockWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final attendState = ref.watch(attendanceProvider);
    final attendance = attendState.todayAttendance;

    if (user == null) return const SizedBox();

    // Has clocked in today (record exists with clockIn set)
    final hasClockedIn = attendance != null && attendance.clockIn != null;
    // Currently clocked out (has both clockIn and clockOut)
    final isClockedOut = attendance != null && attendance.isClockedOut;

    String statusText;
    Color statusColor;
    if (isClockedOut) {
      statusText = 'Clocked Out';
      statusColor = AppColors.white70;
    } else if (hasClockedIn) {
      statusText = 'Clocked In';
      statusColor = AppColors.primary;
    } else {
      statusText = 'Not Clocked In';
      statusColor = const Color(0xFFE74C3C);
    }

    return AppCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(statusText, style: AppStyles.cardTitle),
                    ],
                  ),
                  if (attendance?.clockIn != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'In: ${formatTimePKT(attendance!.clockIn!)}',
                      style: AppStyles.cardDescription,
                    ),
                  ],
                  if (attendance?.clockOut != null) ...[
                    Text(
                      'Last Out: ${formatTimePKT(attendance!.clockOut!)}',
                      style: AppStyles.cardDescription.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
              if (attendance?.totalHours != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${attendance!.totalHours!.toStringAsFixed(1)}h',
                      style: AppStyles.dashboardNumber,
                    ),
                    Text('Today', style: AppStyles.dashboardLabel),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              // Once clocked in for the day, button always does Clock Out
              // (updates the clockOut time on the same record, like the web app)
              // Only disabled while actively processing
              onPressed: attendState.isClocking
                  ? null
                  : () async {
                      if (hasClockedIn) {
                        // Clock out (or update clock out time)
                        await ref
                            .read(attendanceProvider.notifier)
                            .clockOut(user.id);
                      } else {
                        // First clock in of the day
                        await ref
                            .read(attendanceProvider.notifier)
                            .clockIn(user.id);
                      }
                      final error = ref.read(attendanceProvider).error;
                      if (error != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error),
                            backgroundColor: const Color(0xFFE74C3C),
                          ),
                        );
                      }
                    },
              icon: attendState.isClocking
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      hasClockedIn ? Iconsax.logout : Iconsax.login,
                      size: 20,
                    ),
              label: Text(
                hasClockedIn ? 'Clock Out' : 'Clock In',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.card,
                disabledForegroundColor: AppColors.white70,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
