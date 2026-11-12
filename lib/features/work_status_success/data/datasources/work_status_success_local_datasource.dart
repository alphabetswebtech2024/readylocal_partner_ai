import '../models/work_status_success_model.dart';

abstract class WorkStatusSuccessLocalDataSource {
  WorkStatusSuccessModel getSuccessDetails(String partnerName);
}

class WorkStatusSuccessLocalDataSourceImpl implements WorkStatusSuccessLocalDataSource {
  @override
  WorkStatusSuccessModel getSuccessDetails(String partnerName) {
    return WorkStatusSuccessModel(
      partnerName: partnerName,
      title: 'Thank you $partnerName',
      subtitle: 'We have received your work Status',
    );
  }
}
