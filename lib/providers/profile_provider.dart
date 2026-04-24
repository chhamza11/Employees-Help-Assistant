import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_update_model.dart';
import '../services/profile_update_service.dart';

class ProfileState {
  final List<ProfileUpdateModel> updateRequests;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  ProfileState({
    this.updateRequests = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileUpdateService _service;

  ProfileNotifier(this._service) : super(ProfileState());

  Future<void> loadUpdateRequests(String userId) async {
    state = ProfileState(isLoading: true);
    try {
      final requests = await _service.getProfileUpdates(userId);
      state = ProfileState(updateRequests: requests);
    } catch (e) {
      state = ProfileState(error: e.toString());
    }
  }

  Future<bool> submitUpdate({
    required String userId,
    required String userName,
    required String field,
    required String oldValue,
    required String newValue,
  }) async {
    state = ProfileState(
      updateRequests: state.updateRequests,
      isSubmitting: true,
    );
    try {
      final update = await _service.requestProfileUpdate(
        userId: userId,
        userName: userName,
        field: field,
        oldValue: oldValue,
        newValue: newValue,
      );
      state = ProfileState(
        updateRequests: [update, ...state.updateRequests],
      );
      return true;
    } catch (e) {
      state = ProfileState(
        updateRequests: state.updateRequests,
        error: e.toString(),
      );
      return false;
    }
  }
}

final profileUpdateServiceProvider = Provider((ref) => ProfileUpdateService());

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref.read(profileUpdateServiceProvider));
});
