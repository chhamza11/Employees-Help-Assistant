import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';
import '../../core/time_utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/leave_provider.dart';
import 'widgets/punch_card_widget.dart';
import 'widgets/leave_summary_widget.dart';
import 'widgets/monthly_hours_chart.dart';
import 'widgets/quick_actions_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late Timer _clockTimer;
  DateTime _currentTime = nowPKT();

  @override
  void initState() {
    super.initState();
    Future(() => _loadData());
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = nowPKT());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  void _loadData() {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    ref.read(attendanceProvider.notifier).loadTodayAttendance(user.id);
    ref.read(leaveProvider.notifier).loadBalance(user.id);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => _loadData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Punch Card — attendance + timer + stats
            PunchCardWidget(currentTime: _currentTime),
            const SizedBox(height: 16),

            // Leave Balance Summary
            const LeaveSummaryWidget(),
            const SizedBox(height: 20),

            // Monthly Working Hours Chart
            const MonthlyHoursChart(),
            const SizedBox(height: 20),

            // Quick Actions
            const QuickActionsWidget(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
