import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/colors.dart';
import '../../../core/time_utils.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/attendance_provider.dart';

class MonthlyHoursChart extends ConsumerStatefulWidget {
  const MonthlyHoursChart({Key? key}) : super(key: key);

  @override
  ConsumerState<MonthlyHoursChart> createState() => _MonthlyHoursChartState();
}

class _MonthlyHoursChartState extends ConsumerState<MonthlyHoursChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    Future(() => _animController.forward());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Count working days (Mon-Fri) in the entire month
  int _totalWorkingDaysInMonth(int year, int month) {
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    int count = 0;
    for (int d = 1; d <= daysInMonth; d++) {
      final weekday = DateTime(year, month, d).weekday;
      if (weekday != DateTime.saturday && weekday != DateTime.sunday) {
        count++;
      }
    }
    return count;
  }

  /// Count working days elapsed so far (Mon-Fri up to today)
  int _workingDaysElapsed(int year, int month, int today) {
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final maxDay = today > daysInMonth ? daysInMonth : today;
    int count = 0;
    for (int d = 1; d <= maxDay; d++) {
      final weekday = DateTime(year, month, d).weekday;
      if (weekday != DateTime.saturday && weekday != DateTime.sunday) {
        count++;
      }
    }
    return count;
  }

  /// Calculate hours from clockIn to clockOut, matching web's calcSplit.
  /// total = regular + overtime + break (1hr if session > 60min)
  double _calcHoursForRecord(String? clockIn, String? clockOut, String? scheduledEnd) {
    if (clockIn == null || clockOut == null) return 0;
    final inTime = DateTime.tryParse(clockIn);
    final outTime = DateTime.tryParse(clockOut);
    if (inTime == null || outTime == null) return 0;

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
      }
    } else {
      regular = ((totalMs - brkMs).clamp(0, double.infinity)) / 3600000;
    }

    regular = (regular * 100).roundToDouble() / 100;
    overtime = (overtime * 100).roundToDouble() / 100;
    return regular + overtime + brkHrs;
  }

  @override
  Widget build(BuildContext context) {
    final now = nowPKT();
    final user = ref.watch(authProvider).user;
    final attendState = ref.watch(attendanceProvider);
    final history = attendState.history;
    final scheduledEnd = user?.scheduledEnd;

    // Calculate working days for the full month
    final totalWorkingDays = _totalWorkingDaysInMonth(now.year, now.month);
    final totalRequired = totalWorkingDays * 8.0;

    // Working days elapsed so far
    final elapsedWorkDays = _workingDaysElapsed(now.year, now.month, now.day);
    final expectedSoFar = elapsedWorkDays * 8.0;

    // Sum completed hours from all attendance records this month
    // Calculate from clockIn/clockOut times (matching web's calcSplit logic)
    final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    double completedHours = 0.0;

    final countedIds = <String>{};
    for (final record in history) {
      if (record.date.startsWith(monthStr) && record.clockIn != null && record.clockOut != null) {
        completedHours += _calcHoursForRecord(record.clockIn, record.clockOut, scheduledEnd);
        countedIds.add(record.id);
      }
    }

    // Add today's live hours if currently clocked in (no clockOut yet)
    final today = attendState.todayAttendance;
    if (today != null && today.clockIn != null && !countedIds.contains(today.id)) {
      if (today.clockOut != null) {
        // Clocked out today but not in history yet
        completedHours += _calcHoursForRecord(today.clockIn, today.clockOut, scheduledEnd);
      } else {
        // Still clocked in — use current time as clockOut
        completedHours += _calcHoursForRecord(today.clockIn, now.toIso8601String(), scheduledEnd);
      }
    }

    completedHours = (completedHours * 100).roundToDouble() / 100;

    final completedPercent = totalRequired > 0
        ? (completedHours / totalRequired).clamp(0.0, 1.0)
        : 0.0;
    final expectedPercent = totalRequired > 0
        ? (expectedSoFar / totalRequired).clamp(0.0, 1.0)
        : 0.0;

    // Format hours as Xh Ym
    String fmtHours(double h) {
      final hrs = h.floor();
      final mins = ((h - hrs) * 60).round();
      if (hrs == 0) return '${mins}m';
      if (mins == 0) return '${hrs}h';
      return '${hrs}h ${mins}m';
    }

    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Working Hours',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${fmtHours(completedHours)} / ${totalRequired.toStringAsFixed(0)} hrs',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Animated circular chart
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Center(
                child: SizedBox(
                  height: 160,
                  width: 160,
                  child: CustomPaint(
                    painter: _CircularChartPainter(
                      completedPercent: completedPercent * _animation.value,
                      expectedPercent: expectedPercent * _animation.value,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(completedPercent * 100 * _animation.value).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'Completed',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              _StatDot(
                color: AppColors.primary,
                label: 'Completed',
                value: fmtHours(completedHours),
              ),
              _StatDot(
                color: AppColors.white70,
                label: 'Expected',
                value: '${expectedSoFar.toStringAsFixed(0)} hrs',
              ),
              _StatDot(
                color: AppColors.divider,
                label: 'Total',
                value: '${totalRequired.toStringAsFixed(0)} hrs',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bar breakdown
          AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              return Column(
                children: [
                  _ProgressBar(
                    label: 'Working Days',
                    value: '$elapsedWorkDays / $totalWorkingDays days',
                    percent: (elapsedWorkDays / max(totalWorkingDays, 1)) *
                        _animation.value,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 10),
                  _ProgressBar(
                    label: 'Hours Progress',
                    value:
                        '${fmtHours(completedHours)} / ${totalRequired.toStringAsFixed(0)}',
                    percent: completedPercent * _animation.value,
                    color: AppColors.primary,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CircularChartPainter extends CustomPainter {
  final double completedPercent;
  final double expectedPercent;

  _CircularChartPainter({
    required this.completedPercent,
    required this.expectedPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 14.0;
    const startAngle = -pi / 2;

    final bgPaint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (expectedPercent > 0) {
      final expectedPaint = Paint()
        ..color = AppColors.white70.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        2 * pi * expectedPercent,
        false,
        expectedPaint,
      );
    }

    if (completedPercent > 0) {
      final completedPaint = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        2 * pi * completedPercent,
        false,
        completedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularChartPainter old) =>
      old.completedPercent != completedPercent ||
      old.expectedPercent != expectedPercent;
}

class _StatDot extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _StatDot({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final String label;
  final String value;
  final double percent;
  final Color color;
  const _ProgressBar({
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                Container(color: AppColors.divider),
                FractionallySizedBox(
                  widthFactor: percent.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
