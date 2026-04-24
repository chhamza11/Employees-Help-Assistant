import 'package:appwrite/appwrite.dart';
import 'appwrite_client.dart';
import '../config/app_config.dart';
import '../models/task_model.dart';

class TaskService {
  final _client = AppwriteClient();

  Future<List<TaskModel>> getTasksByAssignee(String userId, {int limit = 50}) async {
    final response = await _client.databases.listDocuments(
      databaseId: _client.databaseId,
      collectionId: Collections.tasks,
      queries: [
        Query.equal('assignedTo', userId),
        Query.orderDesc('createdAt'),
        Query.limit(limit),
      ],
    );

    return response.documents
        .map((doc) => TaskModel.fromMap(doc.data))
        .toList();
  }

  Future<TaskModel> getTask(String taskId) async {
    final doc = await _client.databases.getDocument(
      databaseId: _client.databaseId,
      collectionId: Collections.tasks,
      documentId: taskId,
    );
    return TaskModel.fromMap(doc.data);
  }

  Future<void> updateTaskStatus(String taskId, String status) async {
    final data = <String, dynamic>{
      'status': status,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    if (status == 'completed') {
      data['completedAt'] = DateTime.now().toIso8601String();
    }
    await _client.databases.updateDocument(
      databaseId: _client.databaseId,
      collectionId: Collections.tasks,
      documentId: taskId,
      data: data,
    );
  }

  Future<List<TaskComment>> getTaskComments(String taskId) async {
    final doc = await _client.databases.getDocument(
      databaseId: _client.databaseId,
      collectionId: Collections.tasks,
      documentId: taskId,
    );
    final comments = doc.data['comments'] as List<dynamic>? ?? [];
    return comments
        .map((c) => TaskComment.fromMap(c is Map<String, dynamic> ? c : {}))
        .toList();
  }

  Future<void> addTaskComment({
    required String taskId,
    required String userId,
    required String userName,
    required String comment,
  }) async {
    final doc = await _client.databases.getDocument(
      databaseId: _client.databaseId,
      collectionId: Collections.tasks,
      documentId: taskId,
    );
    final existingComments = doc.data['comments'] as List<dynamic>? ?? [];
    existingComments.add({
      'userId': userId,
      'userName': userName,
      'comment': comment,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await _client.databases.updateDocument(
      databaseId: _client.databaseId,
      collectionId: Collections.tasks,
      documentId: taskId,
      data: {
        'comments': existingComments,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }
}
