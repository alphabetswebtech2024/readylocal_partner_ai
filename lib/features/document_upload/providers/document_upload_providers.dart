import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/document_upload_provider.dart';

List<SingleChildWidget> documentUploadProviders = [
  ChangeNotifierProvider<DocumentUploadProvider>(
    create: (_) => ServiceLocator.createDocumentUploadProvider(),
  ),
];
