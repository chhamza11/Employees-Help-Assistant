import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attendance_model.dart';
import '../models/break_model.dart';
import '../services/attendance_service.dart';
import '../services/location_service.dart';

class AttendanceState {
  final AttendanceModel? todayAttendance;
  final List<AttendanceModel> history;
  final List<BreakModel> todayBreaks;
  final bool isLoading;
  final bool isClocking;
  final String? error;

  AttendanceState({
    this.todayAttendance,
    this.history = const [],
    this.todayBreaks = const [],
    this.isLoading = false,
    this.isClocking = false,
    this.error,
  });

  AttendanceState copyWith({
    AttendanceModel? todayAttendance,
    List<AttendanceModel>? history,
    List<BreakModel>? todayBreaks,
    bool? isLoading,
    bool? isClocking,
    String? error,
    bool clearError = false,
    bool clearAttendance = false,
  }) {
    return AttendanceState(
      todayAttendance: clearAttendance ? null : (todayAttendance ?? this.todayAttendance),
      history: history ?? this.history,
      todayBreaks: todayBreaks ?? this.todayBreaks,
      isLoading: isLoading ?? this.isLoading,
      isClocking: isClocking ?? this.isClocking,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AttendanceService _attendanceService;
  final LocationService _locationService;

  AttendanceNotifier(this._attendanceService, this._locationService)
      : super(AttendanceState());

  Future<void> loadTodayAttendance(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final attendance = await _attendanceService.getTodayAttendance(userId);
      final breaks = await _attendanceService.getTodayBreaks(userId);
      state = state.copyWith(
        todayAttendance: attendance,
        todayBreaks: breaks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadHistory(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final history = await _attendanceService.getAttendanceHistory(userId);
      state = state.copyWith(history: history, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadHistoryForMonth(String userId, int year, int month) async {
    state = state.copyWith(isLoading: true);
    try {
      final history = await _attendanceService.getAttendanceForMonth(userId, year, month);
      state = state.copyWith(history: history, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> clockIn(String userId) async {
    state = state.copyWith(isClocking: true, clearError: true);
    try {
      final position = await _locationService.getCurrentPosition();
      if (!_locationService.isWithinGeofence(position.latitude, position.longitude)) {
        state = state.copyWith(
          isClocking: false,
          error: 'You are not within the office geofence. Please move closer to clock in.',
        );
        return false;
      }
      final attendance = await _attendanceService.clockIn(
        userId,
        position.latitude,
        position.longitude,
      );
      state = state.copyWith(todayAttendance: attendance, isClocking: false);
      return true;
    } catch (e) {
      state = state.copyWith(isClocking: false, error: e.toString());
      return false;
    }
  }

  Future<bool> clockOut(String userId) async {
    if (state.todayAttendance == null) return false;
    state = state.copyWith(isClocking: true, clearError: true);
    try {
      final position = await _locationService.getCurrentPosition();
      if (!_locationService.isWithinGeofence(position.latitude, position.longitude)) {
        state = state.copyWith(
          isClocking: false,
          error: 'You are not within the office geofence. Please move closer to clock out.',
        );
        return false;
      }
      final attendance = await _attendanceService.clockOut(
        state.todayAttendance!.id,
        position.latitude,
        position.longitude,
      );
      state = state.copyWith(todayAttendance: attendance, isClocking: false);
      return true;
    } catch (e) {
      state = state.copyWith(isClocking: false, error: e.toString());
      return false;
    }
  }

  Future<void> startBreak(String userId, String breakType) async {
    if (state.todayAttendance == null) return;
    try {
      final brk = await _attendanceService.startBreak(
        state.todayAttendance!.id,
        userId,
        breakType,
      );
      state = state.copyWith(todayBreaks: [...state.todayBreaks, brk]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> endBreak(String breakId) async {
    try {
      final brk = await _attendanceService.endBreak(breakId);
      final updated = state.todayBreaks.map((b) => b.id == breakId ? brk : b).toList();
      state = state.copyWith(todayBreaks: updated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final attendanceServiceProvider = Provider((ref) => AttendanceService());
final locationServiceProvider = Provider((ref) => LocationService());

final attendanceProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  return AttendanceNotifier(
    ref.read(attendanceServiceProvider),
    ref.read(locationServiceProvider),
  );
});
