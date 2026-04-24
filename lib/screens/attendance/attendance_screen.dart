import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/colors.dart';
import '../../core/styles.dart';
import '../../core/time_utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../models/attendance_model.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future(() => _loadData());
  }

  void _loadData() {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    ref.read(attendanceProvider.notifier).loadTodayAttendance(user.id);
    ref.read(attendanceProvider.notifier).loadHistory(user.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.background,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.white70,
            tabs: const [
              Tab(text: 'Today'),
              Tab(text: 'History'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _TodayTab(),
              _HistoryTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodayTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final state = ref.watch(attendanceProvider);
    final attendance = state.todayAttendance;

    if (user == null) return const SizedBox();

    final hasClockedIn = attendance != null && attendance.clockIn != null;
    final isClockedOut = attendance != null && attendance.isClockedOut;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.read(attendanceProvider.notifier).loadTodayAttendance(user.id);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Column(
                children: [
                  Icon(
                    hasClockedIn ? Iconsax.tick_circle : Iconsax.login,
                    size: 48,
                    color: hasClockedIn ? AppColors.primary : AppColors.white70,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    !hasClockedIn
                        ? 'You have not clocked in yet'
                        : isClockedOut
                            ? 'You have clocked out'
                            : 'You are currently clocked in',
                    style: AppStyles.cardTitle,
                    textAlign: TextAlign.center,
                  ),
                  if (attendance?.clockIn != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Clock In: ${_formatTime(attendance!.clockIn!)}',
                      style: AppStyles.cardDescription,
                    ),
                  ],
                  if (attendance?.clockOut != null)
                    Text(
                      'Last Clock Out: ${_formatTime(attendance!.clockOut!)}',
                      style: AppStyles.cardDescription.copyWith(color: AppColors.primary),
                    ),
                  if (attendance?.totalHours != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Total: ${attendance!.totalHours!.toStringAsFixed(1)} hours',
                      style: AppStyles.cardTitle.copyWith(
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: state.isClocking
                          ? null
                          : () async {
                              if (hasClockedIn) {
                                await ref
                                    .read(attendanceProvider.notifier)
                                    .clockOut(user.id);
                              } else {
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.card,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.isClocking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              hasClockedIn ? 'Clock Out' : 'Clock In',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            if (hasClockedIn && !isClockedOut) ...[
              const SizedBox(height: 16),
              Text('Breaks', style: AppStyles.sectionTitle),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => ref
                          .read(attendanceProvider.notifier)
                          .startBreak(user.id, 'lunch'),
                      icon: const Icon(Iconsax.coffee, size: 18),
                      label: const Text('Lunch Break'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.card,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => ref
                          .read(attendanceProvider.notifier)
                          .startBreak(user.id, 'short'),
                      icon: const Icon(Iconsax.cup, size: 18),
                      label: const Text('Short Break'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.card,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (state.todayBreaks.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...state.todayBreaks.map((brk) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(
                              brk.breakType == 'lunch'
                                  ? Iconsax.coffee
                                  : Iconsax.cup,
                              color: AppColors.white70,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${brk.breakType[0].toUpperCase()}${brk.breakType.substring(1)} Break',
                                style: AppStyles.cardDescription,
                              ),
                            ),
                            if (brk.isActive)
                              TextButton(
                                onPressed: () => ref
                                    .read(attendanceProvider.notifier)
                                    .endBreak(brk.id),
                                child: const Text(
                                  'End',
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              )
                            else
                              Text(
                                '${brk.duration ?? 0} min',
                                style: AppStyles.cardDescription,
                              ),
                          ],
                        ),
                      ),
                    )),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(String isoString) {
    return formatTimePKT(isoString);
  }
}

class _HistoryTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends ConsumerState<_HistoryTab> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  String _statusFilter = 'all'; // all, present, absent

  @override
  void initState() {
    super.initState();
    Future(() => _loadMonth());
  }

  void _loadMonth() {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    ref.read(attendanceProvider.notifier).loadHistoryForMonth(
          user.id,
          _selectedYear,
          _selectedMonth,
        );
  }

  /// Generate all working days (Mon-Fri) for the selected month,
  /// then merge with actual attendance records.
  /// Days with no record and before today = Absent.
  List<AttendanceModel> _buildFullHistory(List<AttendanceModel> records) {
    final firstDay = DateTime(_selectedYear, _selectedMonth, 1);
    final lastDay = DateTime(_selectedYear, _selectedMonth + 1, 0);
    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T')[0];

    // Map existing records by date
    final recordMap = <String, AttendanceModel>{};
    for (final r in records) {
      recordMap[r.date] = r;
    }

    final result = <AttendanceModel>[];

    for (var day = firstDay;
        !day.isAfter(lastDay);
        day = day.add(const Duration(days: 1))) {
      // Skip weekends (Saturday=6, Sunday=7)
      if (day.weekday == 6 || day.weekday == 7) continue;

      final dateStr = day.toIso8601String().split('T')[0];

      if (recordMap.containsKey(dateStr)) {
        result.add(recordMap[dateStr]!);
      } else if (day.isBefore(today) && dateStr != todayStr) {
        // Past working day with no record = absent
        result.add(AttendanceModel(
          id: 'absent-$dateStr',
          userId: '',
          date: dateStr,
          status: 'absent',
        ));
      }
    }

    // Sort descending (newest first)
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  void _showFilterSheet() {
    final months = List.generate(12, (i) => i + 1);
    int tempMonth = _selectedMonth;
    int tempYear = _selectedYear;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select Month', style: AppStyles.sectionTitle),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.white70),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Year selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: AppColors.white),
                        onPressed: () => setSheetState(() => tempYear--),
                      ),
                      Text(
                        '$tempYear',
                        style: AppStyles.cardTitle.copyWith(fontSize: 18),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: AppColors.white),
                        onPressed: tempYear < DateTime.now().year
                            ? () => setSheetState(() => tempYear++)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Month grid
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.2,
                    physics: const NeverScrollableScrollPhysics(),
                    children: months.map((m) {
                      final isFuture = tempYear == DateTime.now().year &&
                          m > DateTime.now().month;
                      final label = DateFormat('MMM').format(DateTime(2024, m));
                      return GestureDetector(
                        onTap: isFuture
                            ? null
                            : () => setSheetState(() => tempMonth = m),
                        child: Container(
                          decoration: BoxDecoration(
                            color: m == tempMonth
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isFuture
                                  ? AppColors.white70.withAlpha(80)
                                  : m == tempMonth
                                      ? Colors.white
                                      : AppColors.white,
                              fontWeight: m == tempMonth
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _selectedMonth = tempMonth;
                          _selectedYear = tempYear;
                        });
                        _loadMonth();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceProvider);
    final monthLabel =
        DateFormat('MMM yyyy').format(DateTime(_selectedYear, _selectedMonth));

    // Build full history with absent days
    final fullHistory = state.isLoading ? <AttendanceModel>[] : _buildFullHistory(state.history);

    // Apply status filter
    final filteredHistory = _statusFilter == 'all'
        ? fullHistory
        : fullHistory.where((r) {
            if (_statusFilter == 'present') {
              return r.status != 'absent';
            } else {
              return r.status == 'absent';
            }
          }).toList();

    // Count stats
    final presentCount = fullHistory.where((r) => r.status != 'absent').length;
    final absentCount = fullHistory.where((r) => r.status == 'absent').length;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return CustomScrollView(
      slivers: [
        // Summary counts (scrolls away)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Row(
              children: [
                _SummaryChip('Total', '${fullHistory.length}', AppColors.white70),
                const SizedBox(width: 8),
                _SummaryChip('Present', '$presentCount', const Color(0xFF2ECC71)),
                const SizedBox(width: 8),
                _SummaryChip('Absent', '$absentCount', const Color(0xFFE74C3C)),
              ],
            ),
          ),
        ),
        // Filter row: chips + month picker — STICKY
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyFilterDelegate(
            child: Container(
              color: AppColors.background,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  _FilterChip('All', _statusFilter == 'all',
                      () => setState(() => _statusFilter = 'all')),
                  const SizedBox(width: 6),
                  _FilterChip('Present', _statusFilter == 'present',
                      () => setState(() => _statusFilter = 'present')),
                  const SizedBox(width: 6),
                  _FilterChip('Absent', _statusFilter == 'absent',
                      () => setState(() => _statusFilter = 'absent')),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showFilterSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(monthLabel,
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  color: AppColors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(width: 2),
                          const Icon(Icons.keyboard_arrow_down,
                              color: AppColors.white70, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Records list
        if (filteredHistory.isEmpty)
          const SliverFillRemaining(
            child: EmptyState(
              icon: Iconsax.clock,
              message: 'No records for this filter',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final record = filteredHistory[index];
                  final isAbsent = record.status == 'absent';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formatDateShort(record.date),
                                  style: AppStyles.cardTitle.copyWith(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isAbsent
                                      ? 'No attendance recorded'
                                      : record.clockIn != null
                                          ? '${formatTimePKT(record.clockIn!)}${record.clockOut != null ? ' - ${formatTimePKT(record.clockOut!)}' : ' - Present'}'
                                          : 'No record',
                                  style: AppStyles.cardDescription.copyWith(
                                    color: isAbsent
                                        ? const Color(0xFFE74C3C).withAlpha(180)
                                        : AppColors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isAbsent && record.totalHours != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                '${record.totalHours!.toStringAsFixed(1)}h',
                                style: AppStyles.cardTitle,
                              ),
                            ),
                          StatusBadge(label: record.attendanceStatus.label),
                        ],
                      ),
                    ),
                  );
                },
                childCount: filteredHistory.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip(this.label, this.isSelected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.white70,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: AppStyles.dashboardNumber.copyWith(fontSize: 22, color: color)),
            const SizedBox(height: 2),
            Text(label, style: AppStyles.dashboardLabel.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyFilterDelegate({required this.child});

  @override
  double get minExtent => 50;

  @override
  double get maxExtent => 50;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickyFilterDelegate oldDelegate) => true;
}
