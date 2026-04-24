import 'package:appwrite/appwrite.dart';
import 'appwrite_client.dart';

class StorageService {
  final _client = AppwriteClient();

  Future<String> uploadFile(InputFile file) async {
    final result = await _client.storage.createFile(
      bucketId: _client.bucketId,
      fileId: ID.unique(),
      file: file,
    );
    return result.$id;
  }

  Future<void> deleteFile(String fileId) async {
    await _client.storage.deleteFile(
      bucketId: _client.bucketId,
      fileId: fileId,
    );
  }

  String getFileViewUrl(String fileId) {
    return '${AppwriteClient().client.endPoint}/storage/buckets/${_client.bucketId}/files/$fileId/view?project=${_client.client.config['project']}';
  }

  String getFilePreviewUrl(String fileId) {
    return '${AppwriteClient().client.endPoint}/storage/buckets/${_client.bucketId}/files/$fileId/preview?project=${_client.client.config['project']}';
  }
}
