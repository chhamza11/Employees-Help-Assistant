import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'appwrite_client.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';

class AuthService {
  final _client = AppwriteClient();

  Future<models.Session> login(String email, String password) async {
    final session = await _client.account.createEmailPasswordSession(
      email: email,
      password: password,
    );
    return session;
  }

  Future<UserModel> getCurrentUserProfile() async {
    final account = await _client.account.get();
    final response = await _client.databases.listDocuments(
      databaseId: _client.databaseId,
      collectionId: Collections.users,
      queries: [Query.equal('userId', account.$id)],
    );

    if (response.documents.isEmpty) {
      throw Exception('User profile not found');
    }

    final doc = response.documents.first;
    final data = doc.data;

    if (data['isActive'] == false) {
      throw Exception('Your account has been deactivated. Please contact HR.');
    }

    if (data['isRegistered'] != true) {
      throw Exception('Account not fully registered. Please complete registration.');
    }

    return UserModel.fromMap(data);
  }

  Future<void> register(String email, String password) async {
    // Check if employee was pre-created by HR
    models.Session? anonSession;
    try {
      anonSession = await _client.account.createAnonymousSession();
    } catch (_) {}

    Map<String, dynamic>? foundDoc;
    try {
      final response = await _client.databases.listDocuments(
        databaseId: _client.databaseId,
        collectionId: Collections.users,
        queries: [Query.equal('email', email)],
      );
      if (response.documents.isNotEmpty) {
        foundDoc = response.documents.first.data;
      }
    } finally {
      if (anonSession != null) {
        try {
          await _client.account.deleteSession(sessionId: 'current');
        } catch (_) {}
      }
    }

    if (foundDoc == null) {
      throw Exception('You have not been added to the system. Please contact HR.');
    }
    if (foundDoc['isRegistered'] == true) {
      throw Exception('An account with this email already exists. Please log in.');
    }

    // Create auth account
    await _client.account.create(
      userId: ID.unique(),
      email: email,
      password: password,
    );

    // Login with new credentials
    await _client.account.createEmailPasswordSession(
      email: email,
      password: password,
    );

    final currentAccount = await _client.account.get();

    // Update user document
    await _client.databases.updateDocument(
      databaseId: _client.databaseId,
      collectionId: Collections.users,
      documentId: foundDoc['\$id'],
      data: {
        'isRegistered': true,
        'userId': currentAccount.$id,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logout() async {
    await _client.account.deleteSession(sessionId: 'current');
  }

  Future<bool> checkSession() async {
    try {
      await _client.account.get();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> updatePassword(String newPassword, String oldPassword) async {
    await _client.account.updatePassword(
      password: newPassword,
      oldPassword: oldPassword,
    );
  }
}
