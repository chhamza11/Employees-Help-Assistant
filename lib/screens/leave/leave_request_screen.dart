import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/colors.dart';
import '../../core/styles.dart';
import '../../core/constants.dart';
import '../../core/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leave_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../widgets/app_card.dart';

class LeaveRequestScreen extends ConsumerStatefulWidget {
  const LeaveRequestScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends ConsumerState<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  LeaveType _selectedType = LeaveType.casual;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  int get _days {
    return _endDate.difference(_startDate).inDays + 1;
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.card,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) _endDate = _startDate;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_days < 1) return;

    final user = ref.read(authProvider).user;
    if (user == null) return;

    final success = await ref.read(leaveProvider.notifier).submitLeaveRequest(
          userId: user.id,
          userName: user.name,
          leaveType: _selectedType.name,
          startDate: _startDate.toIso8601String().split('T')[0],
          endDate: _endDate.toIso8601String().split('T')[0],
          days: _days,
          reason: _reasonController.text.trim(),
        );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave request submitted')),
      );
      context.pop();
    } else {
      final error = ref.read(leaveProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final leaveState = ref.watch(leaveProvider);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Request Leave', style: AppStyles.appBarTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Leave Type', style: AppStyles.tileLabel),
              const SizedBox(height: 8),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<LeaveType>(
                    value: _selectedType,
                    isExpanded: true,
                    dropdownColor: AppColors.card,
                    style: const TextStyle(color: AppColors.white),
                    items: [LeaveType.casual, LeaveType.sick, LeaveType.annual, LeaveType.unpaid]
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.label),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedType = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start Date', style: AppStyles.tileLabel),
                        const SizedBox(height: 8),
                        AppCard(
                          onTap: () => _pickDate(true),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              const Icon(Iconsax.calendar_1,
                                  color: AppColors.white70, size: 18),
                              const SizedBox(width: 8),
                              Text(dateFormat.format(_startDate),
                                  style: AppStyles.tileValue),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('End Date', style: AppStyles.tileLabel),
                        const SizedBox(height: 8),
                        AppCard(
                          onTap: () => _pickDate(false),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              const Icon(Iconsax.calendar_1,
                                  color: AppColors.white70, size: 18),
                              const SizedBox(width: 8),
                              Text(dateFormat.format(_endDate),
                                  style: AppStyles.tileValue),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$_days day${_days != 1 ? 's' : ''} requested',
                style: AppStyles.cardDescription.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text('Reason', style: AppStyles.tileLabel),
              const SizedBox(height: 8),
              InputField(
                controller: _reasonController,
                hintText: 'Enter your reason for leave...',
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                validator: Validators.leaveReason,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: leaveState.isSubmitting ? 'Submitting...' : 'Submit Request',
                onPressed: leaveState.isSubmitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
