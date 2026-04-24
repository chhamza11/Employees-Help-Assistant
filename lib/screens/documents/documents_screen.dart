import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:appwrite/appwrite.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/colors.dart';
import '../../core/styles.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/document_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  @override
  void initState() {
    super.initState();
    Future(() {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.read(documentProvider.notifier).loadDocuments(user.id);
      }
    });
  }

  Future<void> _uploadDocument() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    final docType = await _showTypeSelector();
    if (docType == null) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;

    if (file.path == null) return;

    final inputFile = InputFile.fromPath(
      path: file.path!,
      filename: file.name,
    );

    final success = await ref.read(documentProvider.notifier).uploadDocument(
          employeeId: user.id,
          documentType: docType.value,
          fileName: file.name,
          file: inputFile,
          uploadedBy: user.name,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Document uploaded' : 'Upload failed'),
        backgroundColor: success ? AppColors.primary : const Color(0xFFE74C3C),
      ),
    );
  }

  Future<DocumentType?> _showTypeSelector() async {
    return showModalBottomSheet<DocumentType>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Document Type', style: AppStyles.sectionTitle),
              const SizedBox(height: 12),
              ...DocumentType.values.map((type) => ListTile(
                    title: Text(type.label, style: const TextStyle(color: AppColors.white)),
                    leading: const Icon(Iconsax.document_text, color: AppColors.white70),
                    onTap: () => Navigator.pop(context, type),
                  )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final docState = ref.watch(documentProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Documents', style: AppStyles.appBarTitle),
      ),
      body: docState.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : docState.documents.isEmpty
              ? const EmptyState(
                  icon: Iconsax.folder_open,
                  message: 'No documents uploaded yet',
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    final user = ref.read(authProvider).user;
                    if (user != null) {
                      ref.read(documentProvider.notifier).loadDocuments(user.id);
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docState.documents.length,
                    itemBuilder: (context, index) {
                      final doc = docState.documents[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AppCard(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(30),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Iconsax.document_text, color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc.fileName,
                                      style: AppStyles.cardTitle.copyWith(fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(doc.docType.label, style: AppStyles.cardDescription),
                                  ],
                                ),
                              ),
                              StatusBadge(
                                label: doc.isVerified ? 'Verified' : 'Pending',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: docState.isUploading ? null : _uploadDocument,
        backgroundColor: AppColors.primary,
        child: docState.isUploading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Iconsax.document_upload, color: Colors.white),
      ),
    );
  }
}
