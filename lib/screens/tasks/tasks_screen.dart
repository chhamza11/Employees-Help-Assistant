import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/colors.dart';
import '../../core/styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    Future(() {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.read(taskProvider.notifier).loadTasks(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskProvider);
    final filteredTasks = _statusFilter == null
        ? taskState.tasks
        : taskState.tasks.where((t) => t.status == _statusFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('My Tasks', style: AppStyles.appBarTitle),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _FilterChip('All', _statusFilter == null, () => setState(() => _statusFilter = null)),
                const SizedBox(width: 8),
                _FilterChip('Pending', _statusFilter == 'pending', () => setState(() => _statusFilter = 'pending')),
                const SizedBox(width: 8),
                _FilterChip('In Progress', _statusFilter == 'in_progress', () => setState(() => _statusFilter = 'in_progress')),
                const SizedBox(width: 8),
                _FilterChip('Completed', _statusFilter == 'completed', () => setState(() => _statusFilter = 'completed')),
              ],
            ),
          ),
          Expanded(
            child: taskState.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : filteredTasks.isEmpty
                    ? const EmptyState(icon: Iconsax.task_square, message: 'No tasks found')
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: AppCard(
                              onTap: () => context.push('/tasks/${task.id}'),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          task.title,
                                          style: AppStyles.cardTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      StatusBadge(label: task.taskPriority.label),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      StatusBadge(label: task.taskStatus.label),
                                      const Spacer(),
                                      if (task.deadline != null)
                                        Text(
                                          'Due: ${_formatDate(task.deadline!)}',
                                          style: AppStyles.cardDescription.copyWith(fontSize: 12),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
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
