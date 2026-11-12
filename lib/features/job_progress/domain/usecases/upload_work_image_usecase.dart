import '../../../../core/network/api_result.dart';
import '../repositories/job_progress_repository.dart';

class UploadWorkImageUseCase {
  final JobProgressRepository repository;

  UploadWorkImageUseCase(this.repository);

  Future<ApiResult<String>> call({
    required String filename,
    required String base64Data,
  }) {
    return repository.uploadWorkImage(
      filename: filename,
      base64Data: base64Data,
    );
  }
}
