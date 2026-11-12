import 'package:image_picker/image_picker.dart';
import '../../../../core/models/User.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/document_urls_entity.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/document_remote_datasource.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource _remoteDataSource;

  DocumentRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<String>> uploadDocument(XFile file) async {
    try {
      final url = await _remoteDataSource.uploadDocument(file);
      return ApiResult.success(url);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  @override
  Future<ApiResult<bool>> submitDocumentsWithoutPayment({
    required User user,
    required DocumentUrlsEntity documentUrls,
    required String moduleId,
    required String moduleName,
    required dynamic professionalProfileData,
    List? skills,
  }) async {
    try {
      final success = await _remoteDataSource.submitDocumentsWithoutPayment(
        user: user,
        documentUrls: documentUrls,
        moduleId: moduleId,
        moduleName: moduleName,
        professionalProfileData: professionalProfileData,
        skills: skills,
      );
      // Documents saved; false = only the free-registration record failed.
      return ApiResult.success(success);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
