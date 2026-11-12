import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_result.dart';
import '../repositories/document_repository.dart';

class UploadDocumentUseCase {
  final DocumentRepository repository;

  UploadDocumentUseCase(this.repository);

  Future<ApiResult<String>> call(XFile file) {
    return repository.uploadDocument(file);
  }
}
