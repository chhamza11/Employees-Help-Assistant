import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/working_hours_model.dart';
import '../services/working_hours_service.dart';

class WorkingHoursState {
  final List<WorkingHoursModel> weeklyHours;
  final List<WorkingHoursModel> history;
  final bool isLoading;
  final String? error;

  WorkingHoursState({
    this.weeklyHours = const [],
    this.history = const [],
    this.isLoading = false,
    this.error,
  });

  double get totalWeeklyRegular =>
      weeklyHours.fold(0, (sum, h) => sum + h.regularHours);

  double get totalWeeklyOvertime =>
      weeklyHours.fold(0, (sum, h) => sum + h.overtimeHours);

  double get totalWeeklyHours => totalWeeklyRegular + totalWeeklyOvertime;
}

class WorkingHoursNotifier extends StateNotifier<WorkingHoursState> {
  final WorkingHoursService _service;

  WorkingHoursNotifier(this._service) : super(WorkingHoursState());

  Future<void> loadWeeklyHours(String userId) async {
    state = WorkingHoursState(isLoading: true);
    try {
      final weekly = await _service.getWeeklyHours(userId);
      state = WorkingHoursState(weeklyHours: weekly);
    } catch (e) {
      state = WorkingHoursState(error: e.toString());
    }
  }

  Future<void> loadHistory(String userId) async {
    state = WorkingHoursState(
      weeklyHours: state.weeklyHours,
      isLoading: true,
    );
    try {
      final history = await _service.getHoursHistory(userId);
      state = WorkingHoursState(
        weeklyHours: state.weeklyHours,
        history: history,
      );
    } catch (e) {
      state = WorkingHoursState(
        weeklyHours: state.weeklyHours,
        error: e.toString(),
      );
    }
  }
}

final workingHoursServiceProvider = Provider((ref) => WorkingHoursService());

final workingHoursProvider =
    StateNotifierProvider<WorkingHoursNotifier, WorkingHoursState>((ref) {
  return WorkingHoursNotifier(ref.read(workingHoursServiceProvider));
});
