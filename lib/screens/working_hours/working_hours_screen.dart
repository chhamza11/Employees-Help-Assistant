import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/colors.dart';
import '../../core/styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/working_hours_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';

class WorkingHoursScreen extends ConsumerStatefulWidget {
  const WorkingHoursScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WorkingHoursScreen> createState() => _WorkingHoursScreenState();
}

class _WorkingHoursScreenState extends ConsumerState<WorkingHoursScreen> {
  @override
  void initState() {
    super.initState();
    Future(() {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.read(workingHoursProvider.notifier).loadWeeklyHours(user.id);
        ref.read(workingHoursProvider.notifier).loadHistory(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workingHoursProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Working Hours', style: AppStyles.appBarTitle),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatColumn('Regular', '${state.totalWeeklyRegular.toStringAsFixed(1)}h', AppColors.primary),
                        Container(width: 1, height: 40, color: AppColors.divider),
                        _StatColumn('Overtime', '${state.totalWeeklyOvertime.toStringAsFixed(1)}h', AppColors.secondary),
                        Container(width: 1, height: 40, color: AppColors.divider),
                        _StatColumn('Total', '${state.totalWeeklyHours.toStringAsFixed(1)}h', AppColors.primary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (state.weeklyHours.isNotEmpty) ...[
                    Text('This Week', style: AppStyles.sectionTitle),
                    const SizedBox(height: 12),
                    AppCard(
                      child: SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 12,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  getTitlesWidget: (value, _) => Text(
                                    '${value.toInt()}h',
                                    style: const TextStyle(color: AppColors.white70, fontSize: 10),
                                  ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, _) {
                                    final idx = value.toInt();
                                    if (idx >= state.weeklyHours.length) return const SizedBox();
                                    final date = state.weeklyHours[idx].date;
                                    try {
                                      return Text(
                                        DateFormat('EEE').format(DateTime.parse(date)),
                                        style: const TextStyle(color: AppColors.white70, fontSize: 10),
                                      );
                                    } catch (_) {
                                      return const SizedBox();
                                    }
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: AppColors.divider,
                                strokeWidth: 0.5,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: state.weeklyHours
                                .asMap()
                                .entries
                                .map((entry) => BarChartGroupData(
                                      x: entry.key,
                                      barRods: [
                                        BarChartRodData(
                                          toY: entry.value.regularHours,
                                          color: AppColors.primary,
                                          width: 12,
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                        ),
                                        if (entry.value.overtimeHours > 0)
                                          BarChartRodData(
                                            toY: entry.value.overtimeHours,
                                            color: AppColors.secondary,
                                            width: 12,
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                          ),
                                      ],
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text('Recent History', style: AppStyles.sectionTitle),
                  const SizedBox(height: 12),
                  if (state.history.isEmpty)
                    const EmptyState(icon: Iconsax.clock, message: 'No working hours recorded')
                  else
                    ...state.history.take(15).map((h) => Padding(
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
                                        _formatDate(h.date),
                                        style: AppStyles.cardTitle.copyWith(fontSize: 14),
                                      ),
                                      if (h.projectName != null)
                                        Text(h.projectName!, style: AppStyles.cardDescription),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${h.regularHours.toStringAsFixed(1)}h', style: AppStyles.tileValue),
                                    if (h.overtimeHours > 0)
                                      Text(
                                        '+${h.overtimeHours.toStringAsFixed(1)}h OT',
                                        style: AppStyles.cardDescription.copyWith(color: AppColors.secondary),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
                ],
              ),
            ),
    );
  }

  String _formatDate(String date) {
    try {
      return DateFormat('EEE, MMM d').format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatColumn(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppStyles.dashboardNumber.copyWith(fontSize: 22, color: color)),
        const SizedBox(height: 2),
        Text(label, style: AppStyles.dashboardLabel),
      ],
    );
  }
}
