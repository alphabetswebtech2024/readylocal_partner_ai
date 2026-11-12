import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/models/User.dart';
import '../../domain/entities/document_urls_entity.dart';
import '../../domain/usecases/submit_documents_usecase.dart';
import '../../domain/usecases/upload_document_usecase.dart';

typedef DocumentUploadProvider = UploadImagesController;

class UploadImagesController extends ChangeNotifier {
  final UploadDocumentUseCase _uploadDocumentUseCase;
  final SubmitDocumentsUseCase _submitDocumentsUseCase;

  UploadImagesController({
    required UploadDocumentUseCase uploadDocumentUseCase,
    required SubmitDocumentsUseCase submitDocumentsUseCase,
  })  : _uploadDocumentUseCase = uploadDocumentUseCase,
        _submitDocumentsUseCase = submitDocumentsUseCase;

  int _uploadingCount = 0;
  bool _isSubmitting = false;
  String? _errorMessage;

  int get uploadingCount => _uploadingCount;
  bool get isSubmitting => _isSubmitting;
  bool get hasActiveUploads => _uploadingCount > 0;
  String? get errorMessage => _errorMessage;

  Future<String?> uploadFile(XFile file) async {
    _uploadingCount++;
    notifyListeners();

    try {
      final result = await _uploadDocumentUseCase(file);
      final uploadedUrl = result.when(
        success: (url) {
          _uploadingCount--;
          notifyListeners();
          return url;
        },
        failure: (message) {
          _errorMessage = message;
          _uploadingCount--;
          notifyListeners();
          return null;
        },
      );
      return uploadedUrl;
    } catch (e) {
      _errorMessage = e.toString();
      _uploadingCount--;
      notifyListeners();
      return null;
    }
  }

  /// Free registration, as in the 6 Nov app: the documents are saved first,
  /// then the ₹0 registration record.
  Future<FreeSubmitResult> submitWithoutPayment({
    required User user,
    required DocumentUrlsEntity documentUrls,
    required String moduleId,
    required String moduleName,
    required dynamic professionalProfileData,
    List? skills,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _submitDocumentsUseCase(
        user: user,
        documentUrls: documentUrls,
        moduleId: moduleId,
        moduleName: moduleName,
        professionalProfileData: professionalProfileData,
        skills: skills,
      );

      _isSubmitting = false;
      final outcome = result.when(
        success: (recordSaved) => recordSaved ? FreeSubmitResult.done : FreeSubmitResult.recordFailed,
        failure: (msg) {
          _errorMessage = msg;
          return FreeSubmitResult.documentsFailed;
        },
      );
      notifyListeners();
      return outcome;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return FreeSubmitResult.documentsFailed;
    }
  }
}

/// documentsFailed: nothing saved, stay on Documents. recordFailed: documents
/// saved but the ₹0 registration record failed (6 Nov app opens Payment Failed).
enum FreeSubmitResult { done, documentsFailed, recordFailed }
