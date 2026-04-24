import 'package:appwrite/appwrite.dart';
import 'appwrite_client.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';

class UserService {
  final _client = AppwriteClient();

  Future<UserModel> getUserProfile(String userId) async {
    final response = await _client.databases.listDocuments(
      databaseId: _client.databaseId,
      collectionId: Collections.users,
      queries: [Query.equal('userId', userId)],
    );

    if (response.documents.isEmpty) {
      throw Exception('User profile not found');
    }

    return UserModel.fromMap(response.documents.first.data);
  }

  Future<UserModel> getUserById(String documentId) async {
    final doc = await _client.databases.getDocument(
      databaseId: _client.databaseId,
      collectionId: Collections.users,
      documentId: documentId,
    );
    return UserModel.fromMap(doc.data);
  }
}
