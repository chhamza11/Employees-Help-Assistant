import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskState {
  final List<TaskModel> tasks;
  final bool isLoading;
  final String? error;

  TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
  });
}

class TaskNotifier extends StateNotifier<TaskState> {
  final TaskService _service;

  TaskNotifier(this._service) : super(TaskState());

  Future<void> loadTasks(String userId) async {
    state = TaskState(isLoading: true);
    try {
      final tasks = await _service.getTasksByAssignee(userId);
      state = TaskState(tasks: tasks);
    } catch (e) {
      state = TaskState(error: e.toString());
    }
  }

  Future<bool> updateTaskStatus(String taskId, String status) async {
    try {
      await _service.updateTaskStatus(taskId, status);
      state = TaskState(
        tasks: state.tasks.map((t) {
          if (t.id == taskId) {
            return TaskModel.fromMap({
              ...{
                '\$id': t.id,
                'title': t.title,
                'description': t.description,
                'assignedTo': t.assignedTo,
                'assignedBy': t.assignedBy,
                'teamId': t.teamId,
                'priority': t.priority,
                'status': status,
                'deadline': t.deadline,
                'estimatedHours': t.estimatedHours,
                'createdAt': t.createdAt,
                'updatedAt': DateTime.now().toIso8601String(),
              },
            });
          }
          return t;
        }).toList(),
      );
      return true;
    } catch (e) {
      state = TaskState(tasks: state.tasks, error: e.toString());
      return false;
    }
  }

  Future<bool> addComment({
    required String taskId,
    required String userId,
    required String userName,
    required String comment,
  }) async {
    try {
      await _service.addTaskComment(
        taskId: taskId,
        userId: userId,
        userName: userName,
        comment: comment,
      );
      return true;
    } catch (e) {
      state = TaskState(tasks: state.tasks, error: e.toString());
      return false;
    }
  }
}

final taskServiceProvider = Provider((ref) => TaskService());

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>((ref) {
  return TaskNotifier(ref.read(taskServiceProvider));
});
