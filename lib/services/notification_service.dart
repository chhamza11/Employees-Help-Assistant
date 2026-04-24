import 'package:appwrite/appwrite.dart';
import 'appwrite_client.dart';
import '../config/app_config.dart';
import '../models/notification_model.dart';

class NotificationService {
  final _client = AppwriteClient();

  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    final response = await _client.databases.listDocuments(
      databaseId: _client.databaseId,
      collectionId: Collections.notifications,
      queries: [
        Query.equal('userId', userId),
        Query.orderDesc('createdAt'),
        Query.limit(50),
      ],
    );

    return response.documents
        .map((doc) => NotificationModel.fromMap(doc.data))
        .toList();
  }

  Future<void> markAsRead(String notificationId) async {
    await _client.databases.updateDocument(
      databaseId: _client.databaseId,
      collectionId: Collections.notifications,
      documentId: notificationId,
      data: {'isRead': true},
    );
  }

  Future<void> markAllAsRead(String userId) async {
    final unread = await _client.databases.listDocuments(
      databaseId: _client.databaseId,
      collectionId: Collections.notifications,
      queries: [
        Query.equal('userId', userId),
        Query.equal('isRead', false),
      ],
    );

    for (final doc in unread.documents) {
      await _client.databases.updateDocument(
        databaseId: _client.databaseId,
        collectionId: Collections.notifications,
        documentId: doc.$id,
        data: {'isRead': true},
      );
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    await _client.databases.deleteDocument(
      databaseId: _client.databaseId,
      collectionId: Collections.notifications,
      documentId: notificationId,
    );
  }

  Future<int> getUnreadCount(String userId) async {
    final response = await _client.databases.listDocuments(
      databaseId: _client.databaseId,
      collectionId: Collections.notifications,
      queries: [
        Query.equal('userId', userId),
        Query.equal('isRead', false),
        Query.limit(1),
      ],
    );
    return response.total;
  }
}
