import '../../../../core/network/api_constants.dart' as api;
import '../../../../core/network/api_service.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<Map<String, dynamic>?> getJobRequestDetails(
    String requestId, [
    String serviceId = '',
  ]);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiService _apiService;

  NotificationRemoteDataSourceImpl(this._apiService);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    // There is no notifications-history endpoint yet. Job alerts arrive as
    // push notifications and open the job popup directly. The hard-coded
    // sample entries that used to be returned here were removed so partners
    // never see (or accept) fake jobs. Fetch from the API once it exists.
    return const [];
  }

  @override
  Future<Map<String, dynamic>?> getJobRequestDetails(
    String requestId, [
    String serviceId = '',
  ]) async {
    final Map<String, dynamic> requestBody = {'RequestID': requestId};
    if (serviceId.isNotEmpty) {
      requestBody['ServiceID'] = serviceId;
    }

    final response = await _apiService.post(
      api.getRequestDetails,
      data: requestBody,
    );

    final body = response.data;
    if (body is Map<String, dynamic>) {
      if (body['Status'] == 'SUCCESS' && body['Data'] != null) {
        return Map<String, dynamic>.from(body['Data']);
      }
    }
    return null;
  }
}
