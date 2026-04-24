import 'package:appwrite/appwrite.dart';
import 'appwrite_client.dart';
import '../config/app_config.dart';
import '../models/document_model.dart';

class DocumentService {
  final _client = AppwriteClient();

  Future<List<DocumentModel>> getEmployeeDocuments(String employeeId) async {
    final response = await _client.databases.listDocuments(
      databaseId: _client.databaseId,
      collectionId: Collections.documents,
      queries: [
        Query.equal('employeeId', employeeId),
        Query.orderDesc('createdAt'),
      ],
    );

    return response.documents
        .map((doc) => DocumentModel.fromMap(doc.data))
        .toList();
  }

  Future<DocumentModel> uploadDocument({
    required String employeeId,
    required String documentType,
    required String fileName,
    required String fileId,
    required String uploadedBy,
  }) async {
    final now = DateTime.now().toIso8601String();
    final doc = await _client.databases.createDocument(
      databaseId: _client.databaseId,
      collectionId: Collections.documents,
      documentId: ID.unique(),
      data: {
        'employeeId': employeeId,
        'documentType': documentType,
        'fileName': fileName,
        'fileId': fileId,
        'uploadedBy': uploadedBy,
        'uploadedAt': now,
        'isVerified': false,
        'createdAt': now,
        'updatedAt': now,
      },
    );
    return DocumentModel.fromMap(doc.data);
  }

  Future<void> deleteDocument(String documentId) async {
    await _client.databases.deleteDocument(
      databaseId: _client.databaseId,
      collectionId: Collections.documents,
      documentId: documentId,
    );
  }
}
