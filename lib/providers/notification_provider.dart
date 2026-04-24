import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;

  NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
  });
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _service;

  NotificationNotifier(this._service) : super(NotificationState());

  Future<void> loadNotifications(String userId) async {
    state = NotificationState(isLoading: true);
    try {
      final notifications = await _service.getUserNotifications(userId);
      final unread = notifications.where((n) => !n.isRead).length;
      state = NotificationState(
        notifications: notifications,
        unreadCount: unread,
      );
    } catch (e) {
      state = NotificationState(error: e.toString());
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _service.markAsRead(notificationId);
      state = NotificationState(
        notifications: state.notifications.map((n) {
          if (n.id == notificationId) {
            return NotificationModel(
              id: n.id,
              userId: n.userId,
              announcementId: n.announcementId,
              title: n.title,
              message: n.message,
              eventType: n.eventType,
              isRead: true,
              createdBy: n.createdBy,
              createdByName: n.createdByName,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList(),
        unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
      );
    } catch (_) {}
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _service.markAllAsRead(userId);
      state = NotificationState(
        notifications: state.notifications.map((n) {
          return NotificationModel(
            id: n.id,
            userId: n.userId,
            announcementId: n.announcementId,
            title: n.title,
            message: n.message,
            eventType: n.eventType,
            isRead: true,
            createdBy: n.createdBy,
            createdByName: n.createdByName,
            createdAt: n.createdAt,
          );
        }).toList(),
        unreadCount: 0,
      );
    } catch (_) {}
  }
}

final notificationServiceProvider = Provider((ref) => NotificationService());

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref.read(notificationServiceProvider));
});
