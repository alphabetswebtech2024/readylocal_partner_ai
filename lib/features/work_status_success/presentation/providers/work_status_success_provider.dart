import 'package:flutter/foundation.dart';
import '../../domain/entities/work_status_success_entity.dart';
import '../../domain/usecases/get_work_status_success_details_usecase.dart';

class WorkStatusSuccessProvider extends ChangeNotifier {
  final GetWorkStatusSuccessDetailsUseCase getWorkStatusSuccessDetailsUseCase;

  WorkStatusSuccessProvider({
    required this.getWorkStatusSuccessDetailsUseCase,
  });

  WorkStatusSuccessEntity? _details;
  WorkStatusSuccessEntity? get details => _details;

  void init(String partnerName) {
    _details = WorkStatusSuccessEntity(partnerName: partnerName);
    notifyListeners();
  }
}
