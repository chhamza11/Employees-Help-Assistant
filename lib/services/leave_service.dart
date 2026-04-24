import 'package:appwrite/appwrite.dart';
import 'appwrite_client.dart';
import '../config/app_config.dart';
import '../models/leave_model.dart';

class LeaveService {
  final _client = AppwriteClient();

  Future<LeaveModel> createLeaveRequest({
    required String userId,
    required String userName,
    required String leaveType,
    required String startDate,
    required String endDate,
    required int days,
    required String reason,
  }) async {
    final doc = await _client.databases.createDocument(
      databaseId: _client.databaseId,
      collectionId: Collections.leaves,
      documentId: ID.unique(),
      data: {
        'userId': userId,
        'userName': userName,
        'leaveType': leaveType,
        'startDate': startDate,
        'endDate': endDate,
        'days': days,
        'reason': reason,
        'status': 'pending',
        'isPaid': true,
        'isOverride': false,
        'monthlyUsageAtRequest': 0,
        'yearlyUsageAtRequest': 0,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
    return LeaveModel.fromMap(doc.data);
  }

  Future<List<LeaveModel>> getUserLeaves(String userId, {String? status}) async {
    final queries = <String>[
      Query.equal('userId', userId),
      Query.orderDesc('createdAt'),
      Query.limit(50),
    ];

    if (status != null) {
      queries.add(Query.equal('status', status));
    }

    final response = await _client.databases.listDocuments(
      databaseId: _client.databaseId,
      collectionId: Collections.leaves,
      queries: queries,
    );

    return response.documents
        .map((doc) => LeaveModel.fromMap(doc.data))
        .toList();
  }

  Future<LeaveModel> getLeave(String leaveId) async {
    final doc = await _client.databases.getDocument(
      databaseId: _client.databaseId,
      collectionId: Collections.leaves,
      documentId: leaveId,
    );
    return LeaveModel.fromMap(doc.data);
  }

  Future<void> cancelLeaveRequest(String leaveId) async {
    await _client.databases.updateDocument(
      databaseId: _client.databaseId,
      collectionId: Collections.leaves,
      documentId: leaveId,
      data: {
        'status': 'cancelled',
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }
}
