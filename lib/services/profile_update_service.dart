import 'package:appwrite/appwrite.dart';
import 'appwrite_client.dart';
import '../config/app_config.dart';
import '../models/profile_update_model.dart';

class ProfileUpdateService {
  final _client = AppwriteClient();

  Future<ProfileUpdateModel> requestProfileUpdate({
    required String userId,
    required String userName,
    required String field,
    required String oldValue,
    required String newValue,
  }) async {
    final doc = await _client.databases.createDocument(
      databaseId: _client.databaseId,
      collectionId: Collections.profileUpdates,
      documentId: ID.unique(),
      data: {
        'userId': userId,
        'userName': userName,
        'field': field,
        'oldValue': oldValue,
        'newValue': newValue,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
    return ProfileUpdateModel.fromMap(doc.data);
  }

  Future<List<ProfileUpdateModel>> getProfileUpdates(String userId) async {
    final response = await _client.databases.listDocuments(
      databaseId: _client.databaseId,
      collectionId: Collections.profileUpdates,
      queries: [
        Query.equal('userId', userId),
        Query.orderDesc('createdAt'),
      ],
    );

    return response.documents
        .map((doc) => ProfileUpdateModel.fromMap(doc.data))
        .toList();
  }
}
