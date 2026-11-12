import 'package:image_picker/image_picker.dart';
import '../../../../core/models/User.dart';
import '../../../../core/network/api_result.dart';
import '../entities/document_urls_entity.dart';

abstract class DocumentRepository {
  Future<ApiResult<String>> uploadDocument(XFile file);
  Future<ApiResult<bool>> submitDocumentsWithoutPayment({
    required User user,
    required DocumentUrlsEntity documentUrls,
    required String moduleId,
    required String moduleName,
    required dynamic professionalProfileData,
    List? skills,
  });
}
