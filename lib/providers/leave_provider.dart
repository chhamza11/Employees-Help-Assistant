import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leave_model.dart';
import '../models/leave_balance_model.dart';
import '../services/leave_service.dart';
import '../services/leave_balance_service.dart';

class LeaveState {
  final List<LeaveModel> leaves;
  final LeaveBalanceModel? balance;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  LeaveState({
    this.leaves = const [],
    this.balance,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  LeaveState copyWith({
    List<LeaveModel>? leaves,
    LeaveBalanceModel? balance,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return LeaveState(
      leaves: leaves ?? this.leaves,
      balance: balance ?? this.balance,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class LeaveNotifier extends StateNotifier<LeaveState> {
  final LeaveService _leaveService;
  final LeaveBalanceService _balanceService;

  LeaveNotifier(this._leaveService, this._balanceService) : super(LeaveState());

  Future<void> loadLeaves(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final leaves = await _leaveService.getUserLeaves(userId);
      final balance = await _balanceService.getLeaveBalance(userId);
      state = state.copyWith(
        leaves: leaves,
        balance: balance,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadBalance(String userId) async {
    try {
      final balance = await _balanceService.getLeaveBalance(userId);
      state = state.copyWith(balance: balance);
    } catch (_) {}
  }

  Future<bool> submitLeaveRequest({
    required String userId,
    required String userName,
    required String leaveType,
    required String startDate,
    required String endDate,
    required int days,
    required String reason,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final leave = await _leaveService.createLeaveRequest(
        userId: userId,
        userName: userName,
        leaveType: leaveType,
        startDate: startDate,
        endDate: endDate,
        days: days,
        reason: reason,
      );
      state = state.copyWith(
        leaves: [leave, ...state.leaves],
        isSubmitting: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }

  Future<bool> cancelLeave(String leaveId) async {
    try {
      await _leaveService.cancelLeaveRequest(leaveId);
      final updated = state.leaves.map((l) {
        if (l.id == leaveId) {
          return LeaveModel.fromMap({
            ...l.toMap(),
            '\$id': l.id,
            'status': 'cancelled',
          });
        }
        return l;
      }).toList();
      state = state.copyWith(leaves: updated);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final leaveServiceProvider = Provider((ref) => LeaveService());
final leaveBalanceServiceProvider = Provider((ref) => LeaveBalanceService());

final leaveProvider = StateNotifierProvider<LeaveNotifier, LeaveState>((ref) {
  return LeaveNotifier(
    ref.read(leaveServiceProvider),
    ref.read(leaveBalanceServiceProvider),
  );
});
