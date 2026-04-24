import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/document_model.dart';
import '../services/document_service.dart';
import '../services/storage_service.dart';

class DocumentState {
  final List<DocumentModel> documents;
  final bool isLoading;
  final bool isUploading;
  final String? error;

  DocumentState({
    this.documents = const [],
    this.isLoading = false,
    this.isUploading = false,
    this.error,
  });
}

class DocumentNotifier extends StateNotifier<DocumentState> {
  final DocumentService _documentService;
  final StorageService _storageService;

  DocumentNotifier(this._documentService, this._storageService)
      : super(DocumentState());

  Future<void> loadDocuments(String employeeId) async {
    state = DocumentState(isLoading: true);
    try {
      final docs = await _documentService.getEmployeeDocuments(employeeId);
      state = DocumentState(documents: docs);
    } catch (e) {
      state = DocumentState(error: e.toString());
    }
  }

  Future<bool> uploadDocument({
    required String employeeId,
    required String documentType,
    required String fileName,
    required dynamic file,
    required String uploadedBy,
  }) async {
    state = DocumentState(
      documents: state.documents,
      isUploading: true,
    );
    try {
      final fileId = await _storageService.uploadFile(file);
      final doc = await _documentService.uploadDocument(
        employeeId: employeeId,
        documentType: documentType,
        fileName: fileName,
        fileId: fileId,
        uploadedBy: uploadedBy,
      );
      state = DocumentState(documents: [doc, ...state.documents]);
      return true;
    } catch (e) {
      state = DocumentState(
        documents: state.documents,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> deleteDocument(String documentId, String? fileId) async {
    try {
      if (fileId != null) {
        await _storageService.deleteFile(fileId);
      }
      await _documentService.deleteDocument(documentId);
      state = DocumentState(
        documents: state.documents.where((d) => d.id != documentId).toList(),
      );
      return true;
    } catch (e) {
      state = DocumentState(
        documents: state.documents,
        error: e.toString(),
      );
      return false;
    }
  }
}

final documentServiceProvider = Provider((ref) => DocumentService());
final storageServiceProvider = Provider((ref) => StorageService());

final documentProvider =
    StateNotifierProvider<DocumentNotifier, DocumentState>((ref) {
  return DocumentNotifier(
    ref.read(documentServiceProvider),
    ref.read(storageServiceProvider),
  );
});
