import 'package:appwrite/appwrite.dart';
import 'appwrite_client.dart';
import '../config/app_config.dart';
import '../models/leave_balance_model.dart';

class LeaveBalanceService {
  final _client = AppwriteClient();

  Future<LeaveBalanceModel?> getLeaveBalance(String userId) async {
    final response = await _client.databases.listDocuments(
      databaseId: _client.databaseId,
      collectionId: Collections.leaveBalances,
      queries: [Query.equal('userId', userId)],
    );

    if (response.documents.isEmpty) return null;
    return LeaveBalanceModel.fromMap(response.documents.first.data);
  }
}
