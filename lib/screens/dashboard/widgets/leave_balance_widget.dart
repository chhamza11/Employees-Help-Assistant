import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/colors.dart';
import '../../../core/styles.dart';
import '../../../providers/leave_provider.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/section_header.dart';

class LeaveBalanceWidget extends ConsumerWidget {
  const LeaveBalanceWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(leaveProvider).balance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Leave Balance'),
        balance == null
            ? const Center(
                child: Text(
                  'Loading balance...',
                  style: TextStyle(color: AppColors.white70),
                ),
              )
            : GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.2,
                children: [
                  _BalanceCard(
                    label: 'Annual',
                    remaining: balance.remainingAnnual,
                    total: balance.annualLeaves,
                  ),
                  _BalanceCard(
                    label: 'Casual',
                    remaining: balance.remainingCasual,
                    total: balance.casualLeaves,
                  ),
                  _BalanceCard(
                    label: 'Sick',
                    remaining: balance.remainingSick,
                    total: balance.sickLeaves,
                  ),
                  _BalanceCard(
                    label: 'Total',
                    remaining: balance.totalRemaining,
                    total: balance.totalLeaves,
                  ),
                ],
              ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String label;
  final int remaining;
  final int total;

  const _BalanceCard({
    required this.label,
    required this.remaining,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: AppStyles.dashboardLabel),
              const SizedBox(height: 2),
              Text(
                '$remaining/$total',
                style: AppStyles.cardTitle.copyWith(fontSize: 17),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
