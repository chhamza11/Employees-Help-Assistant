import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/colors.dart';
import '../../core/styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leave_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';

class LeaveScreen extends ConsumerStatefulWidget {
  const LeaveScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends ConsumerState<LeaveScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future(() => _loadData());
  }

  void _loadData() {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    ref.read(leaveProvider.notifier).loadLeaves(user.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leaveState = ref.watch(leaveProvider);
    final balance = leaveState.balance;

    return Column(
      children: [
        if (balance != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                _BalanceChip('Annual', balance.remainingAnnual, balance.annualLeaves, AppColors.primary),
                const SizedBox(width: 8),
                _BalanceChip('Casual', balance.remainingCasual, balance.casualLeaves, AppColors.primary),
                const SizedBox(width: 8),
                _BalanceChip('Sick', balance.remainingSick, balance.sickLeaves, AppColors.primary),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/leave/request'),
              icon: const Icon(Iconsax.add, size: 18),
              label: const Text('Apply for Leave',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.white70,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'All'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _LeaveList(
                leaves: leaveState.leaves.where((l) => l.status == 'pending').toList(),
                isLoading: leaveState.isLoading,
              ),
              _LeaveList(
                leaves: leaveState.leaves.where((l) => l.status == 'approved').toList(),
                isLoading: leaveState.isLoading,
              ),
              _LeaveList(
                leaves: leaveState.leaves,
                isLoading: leaveState.isLoading,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BalanceChip extends StatelessWidget {
  final String label;
  final int remaining;
  final int total;
  final Color color;

  const _BalanceChip(this.label, this.remaining, this.total, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          children: [
            Text(
              '$remaining/$total',
              style: AppStyles.cardTitle.copyWith(color: color),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppStyles.dashboardLabel),
          ],
        ),
      ),
    );
  }
}

class _LeaveList extends StatelessWidget {
  final List leaves;
  final bool isLoading;

  const _LeaveList({required this.leaves, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (leaves.isEmpty) {
      return const EmptyState(
        icon: Iconsax.note,
        message: 'No leave requests found',
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {},
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: leaves.length,
        itemBuilder: (context, index) {
          final leave = leaves[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard(
              onTap: () => context.push('/leave/${leave.id}'),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        leave.leaveTypeEnum.label,
                        style: AppStyles.cardTitle,
                      ),
                      StatusBadge(label: leave.leaveStatus.label),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_formatDate(leave.startDate)} - ${_formatDate(leave.endDate)} (${leave.days} day${leave.days > 1 ? 's' : ''})',
                    style: AppStyles.cardDescription,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    leave.reason,
                    style: AppStyles.cardDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String date) {
    try {
      return DateFormat('MMM d').format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }
}
