import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/colors.dart';
import '../../core/styles.dart';
import '../../providers/leave_provider.dart';
import '../../services/leave_service.dart';
import '../../models/leave_model.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../widgets/app_card.dart';
import '../../widgets/info_tile.dart';
import '../../widgets/status_badge.dart';

class LeaveDetailScreen extends ConsumerStatefulWidget {
  final String leaveId;
  const LeaveDetailScreen({Key? key, required this.leaveId}) : super(key: key);

  @override
  ConsumerState<LeaveDetailScreen> createState() => _LeaveDetailScreenState();
}

class _LeaveDetailScreenState extends ConsumerState<LeaveDetailScreen> {
  LeaveModel? _leave;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeave();
  }

  Future<void> _loadLeave() async {
    try {
      final leave = await LeaveService().getLeave(widget.leaveId);
      if (mounted) setState(() { _leave = leave; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Leave Details', style: AppStyles.appBarTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _leave == null
              ? const Center(child: Text('Leave request not found', style: TextStyle(color: AppColors.white70)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_leave!.leaveTypeEnum.label, style: AppStyles.sectionTitle),
                                StatusBadge(label: _leave!.leaveStatus.label),
                              ],
                            ),
                            const Divider(color: AppColors.divider, height: 24),
                            InfoTile(
                              label: 'Start Date',
                              value: _formatDate(_leave!.startDate),
                              icon: Iconsax.calendar_1,
                            ),
                            InfoTile(
                              label: 'End Date',
                              value: _formatDate(_leave!.endDate),
                              icon: Iconsax.calendar_1,
                            ),
                            InfoTile(
                              label: 'Duration',
                              value: '${_leave!.days} day${_leave!.days > 1 ? 's' : ''}',
                              icon: Iconsax.clock,
                            ),
                            InfoTile(
                              label: 'Reason',
                              value: _leave!.reason,
                              icon: Iconsax.note_1,
                            ),
                            if (_leave!.rejectionReason != null)
                              InfoTile(
                                label: 'Rejection Reason',
                                value: _leave!.rejectionReason!,
                                icon: Iconsax.close_circle,
                              ),
                            if (_leave!.approvedBy != null)
                              InfoTile(
                                label: 'Approved By',
                                value: _leave!.approvedBy!,
                                icon: Iconsax.tick_circle,
                              ),
                          ],
                        ),
                      ),
                      if (_leave!.status == 'pending') ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final success = await ref
                                  .read(leaveProvider.notifier)
                                  .cancelLeave(_leave!.id);
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Leave request cancelled')),
                                );
                                context.pop();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE74C3C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Cancel Request',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  String _formatDate(String date) {
    try {
      return DateFormat('EEEE, MMMM d, y').format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }
}
