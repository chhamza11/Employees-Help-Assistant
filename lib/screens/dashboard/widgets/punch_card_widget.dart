import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/colors.dart';
import '../../../core/styles.dart';
import '../../../core/time_utils.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/attendance_provider.dart';

class PunchCardWidget extends ConsumerWidget {
  final DateTime currentTime;
  const PunchCardWidget({Key? key, required this.currentTime}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final attendState = ref.watch(attendanceProvider);
    final attendance = attendState.todayAttendance;

    if (user == null) return const SizedBox();

    final hasClockedIn = attendance != null && attendance.clockIn != null;
    final isClockedOut = attendance != null && attendance.isClockedOut;

    // Calculate elapsed time since clock in
    int elapsedHours = 0;
    int elapsedMinutes = 0;
    if (hasClockedIn && attendance?.clockIn != null) {
      final clockInTime = DateTime.tryParse(attendance!.clockIn!);
      if (clockInTime != null) {
        final end = isClockedOut && attendance.clockOut != null
            ? DateTime.tryParse(attendance.clockOut!) ?? currentTime
            : currentTime;
        final diff = end.difference(clockInTime);
        elapsedHours = diff.inHours;
        elapsedMinutes = diff.inMinutes % 60;
      }
    }

    final totalHours = attendance?.totalHours ?? 0.0;
    final overtime = attendance?.overtimeHours ?? 0.0;
    final breakMins = attendance?.breakMinutes ?? 0;
    final remaining = (8.0 - totalHours).clamp(0.0, 8.0);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Top section — name + punch button + timer
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              children: [
                // Employee name and button
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          user.name,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 42,
                      child: ElevatedButton(
                        onPressed: attendState.isClocking
                            ? null
                            : () async {
                                if (hasClockedIn) {
                                  await ref.read(attendanceProvider.notifier).clockOut(user.id);
                                } else {
                                  await ref.read(attendanceProvider.notifier).clockIn(user.id);
                                }
                                final error = ref.read(attendanceProvider).error;
                                if (error != null && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error), backgroundColor: Colors.red[800]),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          disabledBackgroundColor: Colors.white54,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: attendState.isClocking
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                              )
                            : Text(
                                hasClockedIn ? 'Punch Out' : 'Punch In',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Punch-in time and live counter
                Row(
                  children: [
                    // Punch in info
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.clock,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasClockedIn ? 'Punch in at' : 'Not punched in',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 11,
                                ),
                              ),
                              if (hasClockedIn && attendance?.clockIn != null)
                                Text(
                                  '${formatTimePKT(attendance!.clockIn!)} ${DateFormat('EEEE').format(currentTime)}',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Live hours:minutes counter
                    Row(
                      children: [
                        _TimeBox(value: elapsedHours.toString().padLeft(2, '0')),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            ':',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _TimeBox(value: elapsedMinutes.toString().padLeft(2, '0')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Hours / Minutes labels under counter
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        'HOURS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 40,
                      child: Text(
                        'MINUTES',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom stats row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                _StatItem(label: 'Work Hours', value: '${totalHours.toStringAsFixed(1)} Hrs'),
                _StatItem(label: 'Remaining', value: '${remaining.toStringAsFixed(1)} Hrs'),
                _StatItem(label: 'Overtime', value: '${overtime.toStringAsFixed(1)} Hrs'),
                _StatItem(label: 'Break', value: '${breakMins}m'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String value;
  const _TimeBox({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: const TextStyle(
          fontFamily: 'Inter',
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
