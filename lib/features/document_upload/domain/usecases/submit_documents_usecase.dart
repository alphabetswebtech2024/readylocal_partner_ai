import '../../../../core/models/User.dart';
import '../../../../core/network/api_result.dart';
import '../entities/document_urls_entity.dart';
import '../repositories/document_repository.dart';

class SubmitDocumentsUseCase {
  final DocumentRepository repository;

  SubmitDocumentsUseCase(this.repository);

  Future<ApiResult<bool>> call({
    required User user,
    required DocumentUrlsEntity documentUrls,
    required String moduleId,
    required String moduleName,
    required dynamic professionalProfileData,
    List? skills,
  }) {
    return repository.submitDocumentsWithoutPayment(
      user: user,
      documentUrls: documentUrls,
      moduleId: moduleId,
      moduleName: moduleName,
      professionalProfileData: professionalProfileData,
      skills: skills,
    );
  }
}
