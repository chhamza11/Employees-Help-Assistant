import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/colors.dart';
import '../../../providers/leave_provider.dart';

class LeaveSummaryWidget extends ConsumerWidget {
  const LeaveSummaryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(leaveProvider).balance;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with title and action button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Leave Balance',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: () => context.push('/leave/request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: const Text(
                    'Leave Request',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats row
          balance == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Loading...',
                      style: TextStyle(color: AppColors.white70, fontSize: 13),
                    ),
                  ),
                )
              : Row(
                  children: [
                    _LeaveStat(
                      label: 'Total Leaves',
                      value: '${balance.totalLeaves}',
                    ),
                    _LeaveStat(
                      label: 'Leaves Taken',
                      value: '${balance.totalUsed}',
                    ),
                    _LeaveStat(
                      label: 'Remaining',
                      value: '${balance.totalRemaining}',
                    ),
                    _LeaveStat(
                      label: 'Annual Left',
                      value: '${balance.remainingAnnual}',
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class _LeaveStat extends StatelessWidget {
  final String label;
  final String value;
  const _LeaveStat({required this.label, required this.value});

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
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
