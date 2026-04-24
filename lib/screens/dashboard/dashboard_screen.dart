import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/colors.dart';
import '../../core/styles.dart';
import '../../core/time_utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/leave_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/section_header.dart';
import 'widgets/attendance_clock_widget.dart';
import 'widgets/leave_balance_widget.dart';
import 'widgets/shift_info_widget.dart';
import 'widgets/quick_actions_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late Timer _clockTimer;
  DateTime _currentTime = nowPKT();
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    Future(() => _loadData());
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _currentTime = nowPKT());
      }
    });
    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 60;
      if (scrolled != _isScrolled) {
        setState(() => _isScrolled = scrolled);
      }
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    ref.read(attendanceProvider.notifier).loadTodayAttendance(user.id);
    ref.read(leaveProvider.notifier).loadBalance(user.id);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _formatShiftTime(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return time;
    int hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final notifications = ref.watch(notificationProvider).notifications;
    if (user == null) return const SizedBox();

    final shiftStart = user.scheduledStart ?? '09:00';
    final shiftEnd = user.scheduledEnd ?? '18:00';

    return Column(
      children: [
        // Compact info bar — only visible when scrolled
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _isScrolled ? 36 : 0,
          color: AppColors.background,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _isScrolled
              ? Row(
                  children: [
                    Text(
                      DateFormat('hh:mm:ss a').format(_currentTime),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_formatShiftTime(shiftStart)} - ${_formatShiftTime(shiftEnd)}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
        ),
        // Main scrollable content
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => _loadData(),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getGreeting()}, ${user.firstName}',
                    style: AppStyles.homeGreeting,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMMM d, y').format(_currentTime),
                    style: AppStyles.homeSubtitle,
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            DateFormat('hh:mm:ss  a').format(_currentTime),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEE, MMM d').format(_currentTime),
                            style: AppStyles.cardDescription,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AttendanceClockWidget(),
                  const SizedBox(height: 16),
                  ShiftInfoWidget(
                    scheduledStart: shiftStart,
                    scheduledEnd: shiftEnd,
                  ),
                  const SizedBox(height: 16),
                  const LeaveBalanceWidget(),
                  const SizedBox(height: 20),
                  const QuickActionsWidget(),
                  const SizedBox(height: 20),
                  if (notifications.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Recent Notifications',
                      trailing: TextButton(
                        onPressed: () => context.push('/notifications'),
                        child: const Text(
                          'See All',
                          style: TextStyle(color: AppColors.primary, fontSize: 13),
                        ),
                      ),
                    ),
                    ...notifications.take(3).map((n) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: n.isRead
                                        ? Colors.transparent
                                        : AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        n.title,
                                        style: AppStyles.cardTitle.copyWith(fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        n.message,
                                        style: AppStyles.cardDescription.copyWith(fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
