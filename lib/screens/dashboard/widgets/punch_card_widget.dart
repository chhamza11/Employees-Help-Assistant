import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/colors.dart';
import '../../../core/time_utils.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/attendance_provider.dart';

class PunchCardWidget extends ConsumerWidget {
  final DateTime currentTime;
  const PunchCardWidget({Key? key, required this.currentTime}) : super(key: key);

  /// Calculate hours from clockIn to clockOut (or now), matching web's calcSplit logic.
  /// Returns {total, regular, overtime, breakHrs} in hours.
  Map<String, double> _calcHours(String? clockIn, String? clockOut, DateTime now, String? scheduledEnd) {
    if (clockIn == null) return {'total': 0, 'regular': 0, 'overtime': 0, 'break': 0};

    final inTime = DateTime.tryParse(clockIn);
    if (inTime == null) return {'total': 0, 'regular': 0, 'overtime': 0, 'break': 0};

    final outTime = clockOut != null ? (DateTime.tryParse(clockOut) ?? now) : now;
    final totalMs = outTime.difference(inTime).inMilliseconds;
    final totalMins = totalMs / 60000;

    // 1 hour break if session > 60 minutes (matching web)
    final applyBreak = totalMins > 60;
    final brkMs = applyBreak ? 3600000 : 0;
    final brkHrs = applyBreak ? 1.0 : 0.0;

    double regular = 0;
    double overtime = 0;

    if (scheduledEnd != null && scheduledEnd.contains(':')) {
      final parts = scheduledEnd.split(':');
      final eh = int.tryParse(parts[0]) ?? 0;
      final em = int.tryParse(parts[1]) ?? 0;
      final schedEnd = DateTime(inTime.year, inTime.month, inTime.day, eh, em);
      final schedMs = schedEnd.millisecondsSinceEpoch;
      final outMs = outTime.millisecondsSinceEpoch;
      final inMs = inTime.millisecondsSinceEpoch;

      if (outMs > schedMs) {
        regular = ((schedMs - inMs - brkMs).clamp(0, double.infinity)) / 3600000;
        overtime = (outMs - schedMs) / 3600000;
      } else {
        regular = ((outMs - inMs - brkMs).clamp(0, double.infinity)) / 3600000;
        overtime = 0;
      }
    } else {
      regular = ((totalMs - brkMs).clamp(0, double.infinity)) / 3600000;
      overtime = 0;
    }

    // Round to 2 decimals
    regular = (regular * 100).roundToDouble() / 100;
    overtime = (overtime * 100).roundToDouble() / 100;
    final total = regular + overtime + brkHrs;

    return {'total': total, 'regular': regular, 'overtime': overtime, 'break': brkHrs};
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final attendState = ref.watch(attendanceProvider);
    final attendance = attendState.todayAttendance;

    if (user == null) return const SizedBox();

    final hasClockedIn = attendance != null && attendance.clockIn != null;
    final isClockedOut = attendance != null && attendance.isClockedOut;

    // Calculate elapsed time for the live counter
    int elapsedHours = 0;
    int elapsedMinutes = 0;
    int elapsedSeconds = 0;
    if (hasClockedIn && attendance?.clockIn != null) {
      final clockInTime = DateTime.tryParse(attendance!.clockIn!);
      if (clockInTime != null) {
        final end = isClockedOut && attendance.clockOut != null
            ? DateTime.tryParse(attendance.clockOut!) ?? currentTime
            : currentTime;
        final diff = end.difference(clockInTime);
        elapsedHours = diff.inHours;
        elapsedMinutes = diff.inMinutes % 60;
        elapsedSeconds = diff.inSeconds % 60;
      }
    }

    // Calculate work/remaining/overtime/break from clock times (matching web logic)
    final hours = _calcHours(
      attendance?.clockIn,
      attendance?.clockOut,
      currentTime,
      user.scheduledEnd,
    );
    final totalHours = hours['total']!;
    final overtime = hours['overtime']!;
    final breakHrs = hours['break']!;
    final scheduled = 8.0;
    final remaining = (scheduled - totalHours).clamp(0.0, scheduled);

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
                    // Live hours:minutes:seconds counter
                    Row(
                      children: [
                        _TimeBox(value: elapsedHours.toString().padLeft(2, '0')),
                        const _TimeSeparator(),
                        _TimeBox(value: elapsedMinutes.toString().padLeft(2, '0')),
                        const _TimeSeparator(),
                        _TimeBox(value: elapsedSeconds.toString().padLeft(2, '0')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _TimeLabel('HOURS'),
                    const SizedBox(width: 12),
                    _TimeLabel('MIN'),
                    const SizedBox(width: 12),
                    _TimeLabel('SEC'),
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
                _StatItem(label: 'Break', value: '${(breakHrs * 60).toInt()}m'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeSeparator extends StatelessWidget {
  const _TimeSeparator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 3),
      child: Text(':', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
    );
  }
}

class _TimeLabel extends StatelessWidget {
  final String text;
  const _TimeLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter',
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 8,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
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
