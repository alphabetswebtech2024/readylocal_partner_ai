// Free registration (fee 0 or medical), as in the 6 Nov app: documents are
// saved first with the skills list the app chose, then the ₹0 record.
import 'package:flutter_test/flutter_test.dart';
import 'package:gotask_partner/core/models/User.dart';
import 'package:gotask_partner/features/document_upload/data/datasources/document_remote_datasource.dart';
import 'package:gotask_partner/features/document_upload/data/repositories/document_repository_impl.dart';
import 'package:gotask_partner/features/document_upload/domain/entities/document_urls_entity.dart';
import 'package:gotask_partner/features/document_upload/domain/usecases/submit_documents_usecase.dart';
import 'package:gotask_partner/features/document_upload/domain/usecases/upload_document_usecase.dart';
import 'package:gotask_partner/features/document_upload/presentation/providers/document_upload_provider.dart';
import 'package:image_picker/image_picker.dart';

class _Source implements DocumentRemoteDataSource {
  _Source(this.behaviour);
  final String behaviour; // ok | record-fails | documents-fail
  List? sentSkills;

  @override
  Future<String> uploadDocument(XFile file) async => 'url';

  @override
  Future<bool> submitDocumentsWithoutPayment({
    required User user,
    required DocumentUrlsEntity documentUrls,
    required String moduleId,
    required String moduleName,
    required dynamic professionalProfileData,
    List? skills,
  }) async {
    sentSkills = skills;
    if (behaviour == 'documents-fail') throw Exception('Failed to update profile details');
    return behaviour == 'ok';
  }
}

User _user() => User(
      id: 'p1', FirstName: 'Ravi', LastName: 'K', Gender: 'Male', email: '', phone: '9876543210',
      isProfileUpdated: true, isActive: true, Address: 'A', City: 'Hyd', State: 'TS', District: '',
      PinCode: '500081', Avatar: '', UPI: '', PaymentGateWay: '', Experience: 0, RefContactPerson: '',
      RefContactNumber: '', skills: [{'moduleId': 'old', 'moduleName': 'Old service'}],
      AadharPicFront: '', AadharPicBack: '', PanPics: '', ToolPhoto: '', AddressProof: '',
      QualificationCertificate: '',
    );

Future<(FreeSubmitResult, _Source)> _run(String behaviour) async {
  final source = _Source(behaviour);
  final repo = DocumentRepositoryImpl(source);
  final controller = UploadImagesController(
    uploadDocumentUseCase: UploadDocumentUseCase(repo),
    submitDocumentsUseCase: SubmitDocumentsUseCase(repo),
  );
  final outcome = await controller.submitWithoutPayment(
    user: _user(),
    documentUrls: DocumentUrlsEntity(),
    moduleId: 'new',
    moduleName: 'Nursing',
    professionalProfileData: const [],
    skills: const [],
  );
  return (outcome, source);
}

void main() {
  test('documents and the ₹0 record saved: done', () async {
    final (outcome, source) = await _run('ok');
    expect(outcome, FreeSubmitResult.done);
    expect(source.sentSkills, isEmpty, reason: 'a new service chosen on this pass sends an empty skills list');
  });

  test('documents saved but the ₹0 record failed: Payment Failed screen (6 Nov app)', () async {
    final (outcome, _) = await _run('record-fails');
    expect(outcome, FreeSubmitResult.recordFailed);
  });

  test('documents not saved: stay on Documents with an error', () async {
    final (outcome, _) = await _run('documents-fail');
    expect(outcome, FreeSubmitResult.documentsFailed);
  });
}
