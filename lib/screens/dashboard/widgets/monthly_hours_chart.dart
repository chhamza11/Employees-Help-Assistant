import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/colors.dart';
import '../../../core/time_utils.dart';
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
    // Start animation after build
    Future(() => _animController.forward());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Count working days (Mon-Fri) in the given month
  int _workingDaysInMonth(int year, int month) {
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

  /// Count working days elapsed so far this month (up to today)
  int _workingDaysElapsed(int year, int month, int today) {
    int count = 0;
    for (int d = 1; d <= today; d++) {
      final weekday = DateTime(year, month, d).weekday;
      if (weekday != DateTime.saturday && weekday != DateTime.sunday) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final now = nowPKT();
    final workingDays = _workingDaysInMonth(now.year, now.month);
    final totalRequired = workingDays * 8.0;
    final elapsedWorkDays = _workingDaysElapsed(now.year, now.month, now.day);
    final expectedSoFar = elapsedWorkDays * 8.0;

    // Get completed hours from attendance provider
    final attendState = ref.watch(attendanceProvider);
    final todayHours = attendState.todayAttendance?.totalHours ?? 0.0;
    // For now use today's hours as a base — in production this would sum all month's records
    final completedHours = todayHours;

    final completedPercent = totalRequired > 0
        ? (completedHours / totalRequired).clamp(0.0, 1.0)
        : 0.0;
    final expectedPercent = totalRequired > 0
        ? (expectedSoFar / totalRequired).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
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
                '${completedHours.toStringAsFixed(1)} / ${totalRequired.toStringAsFixed(0)} hrs',
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
                value: '${completedHours.toStringAsFixed(1)} hrs',
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
                    value: '$elapsedWorkDays / $workingDays days',
                    percent: (elapsedWorkDays / max(workingDays, 1)) * _animation.value,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 10),
                  _ProgressBar(
                    label: 'Hours Progress',
                    value: '${completedHours.toStringAsFixed(1)} / ${totalRequired.toStringAsFixed(0)}',
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

    // Background track
    final bgPaint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Expected arc (white translucent)
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

    // Completed arc (primary color)
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
