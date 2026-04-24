import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/colors.dart';
import '../../core/styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../services/task_service.dart';
import '../../models/task_model.dart';
import '../../widgets/app_card.dart';
import '../../widgets/info_tile.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/input_field.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;
  const TaskDetailScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  TaskModel? _task;
  bool _isLoading = true;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadTask() async {
    try {
      final task = await TaskService().getTask(widget.taskId);
      if (mounted) setState(() { _task = task; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String status) async {
    final success = await ref
        .read(taskProvider.notifier)
        .updateTaskStatus(widget.taskId, status);
    if (success) {
      await _loadTask();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated')),
        );
      }
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(authProvider).user;
    if (user == null) return;

    final success = await ref.read(taskProvider.notifier).addComment(
          taskId: widget.taskId,
          userId: user.id,
          userName: user.name,
          comment: text,
        );

    if (success) {
      _commentController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment added')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Task Details', style: AppStyles.appBarTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _task == null
              ? const Center(child: Text('Task not found', style: TextStyle(color: AppColors.white70)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_task!.title, style: AppStyles.sectionTitle),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                StatusBadge(label: _task!.taskStatus.label),
                                const SizedBox(width: 8),
                                StatusBadge(label: _task!.taskPriority.label),
                              ],
                            ),
                            if (_task!.description != null) ...[
                              const Divider(color: AppColors.divider, height: 24),
                              Text(_task!.description!, style: AppStyles.tileValue),
                            ],
                            const Divider(color: AppColors.divider, height: 24),
                            if (_task!.deadline != null)
                              InfoTile(
                                label: 'Deadline',
                                value: _formatDate(_task!.deadline!),
                                icon: Iconsax.calendar_1,
                              ),
                            if (_task!.estimatedHours != null)
                              InfoTile(
                                label: 'Estimated Hours',
                                value: '${_task!.estimatedHours}h',
                                icon: Iconsax.clock,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_task!.status != 'completed') ...[
                        Text('Update Status', style: AppStyles.sectionTitle),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (_task!.status == 'pending')
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _updateStatus('in_progress'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Start', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            if (_task!.status == 'pending') const SizedBox(width: 8),
                            if (_task!.status != 'completed')
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _updateStatus('completed'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text('Complete', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),
                      Text('Add Comment', style: AppStyles.sectionTitle),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: InputField(
                              controller: _commentController,
                              hintText: 'Write a comment...',
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _addComment,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Iconsax.send_1, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
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
