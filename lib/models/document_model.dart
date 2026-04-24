import '../core/constants.dart';

class DocumentModel {
  final String id;
  final String employeeId;
  final String documentType;
  final String fileName;
  final String fileId;
  final String uploadedBy;
  final String uploadedAt;
  final bool isVerified;
  final String? verifiedBy;
  final String? verifiedAt;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  DocumentModel({
    required this.id,
    required this.employeeId,
    required this.documentType,
    required this.fileName,
    required this.fileId,
    required this.uploadedBy,
    required this.uploadedAt,
    this.isVerified = false,
    this.verifiedBy,
    this.verifiedAt,
    this.notes,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['\$id'] ?? '',
      employeeId: map['employeeId'] ?? '',
      documentType: map['documentType'] ?? 'other',
      fileName: map['fileName'] ?? '',
      fileId: map['fileId'] ?? '',
      uploadedBy: map['uploadedBy'] ?? '',
      uploadedAt: map['uploadedAt'] ?? '',
      isVerified: map['isVerified'] ?? false,
      verifiedBy: map['verifiedBy'],
      verifiedAt: map['verifiedAt'],
      notes: map['notes'],
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
    );
  }

  DocumentType get docType => DocumentType.fromString(documentType);
}
