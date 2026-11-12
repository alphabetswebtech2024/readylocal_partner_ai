import '../../../../core/network/api_constants.dart' as api;
import '../../../../core/network/api_rows.dart';
import '../../../../core/network/catalog_cache.dart';
import '../../../../core/network/api_service.dart';
import '../models/service_module_model.dart';

abstract class SelectServiceRemoteDataSource {
  Future<List<ServiceModuleModel>> getModules();
  Future<Map<String, double>> getRegistrationFees(String partnerId);
}

class SelectServiceRemoteDataSourceImpl implements SelectServiceRemoteDataSource {
  final ApiService _apiService;

  SelectServiceRemoteDataSourceImpl(this._apiService);

  @override
  Future<List<ServiceModuleModel>> getModules() async {
    return parseModules(await CatalogCache.get(_apiService, api.getModules));
  }

  @override
  Future<Map<String, double>> getRegistrationFees(String partnerId) async {
    // Plain GET with the login token, exactly as the 6 Nov app asks for it.
    final response = await _apiService.get(api.getRegistrationFees);
    return parseRegistrationFees(response.data);
  }
}

/// Active services from `modules`, in the server's display order.
List<ServiceModuleModel> parseModules(dynamic raw) {
  final body = openBody(raw);
  if (body['Status'] != 'SUCCESS') {
    throw Exception((body['Message'] ?? 'Server failure.').toString());
  }
  final rows = rowsOf(body, const ['modules'], activeOnly: false)
      .where((row) => row['isActive'] != false)
      // As in the 6 Nov app: Learning Services (code LS) is not offered to partners.
      .where((row) => (row['Code'] ?? '').toString() != 'LS')
      .toList()
    ..sort((a, b) => numberOf(a['Order']).compareTo(numberOf(b['Order'])));
  return rows.map(ServiceModuleModel.fromJson).toList();
}

/// Fee per service code from `RegistrationFees`, for example `{'HS': 0}`.
/// An amount of 0 means the fee is waived for that service. A reply that is not
/// SUCCESS is a failure (6 Nov app), never an empty list that would mean ₹500.
Map<String, double> parseRegistrationFees(dynamic raw) {
  final fees = <String, double>{};
  final body = openBody(raw);
  if (body['Status'] != 'SUCCESS') {
    throw Exception((body['Message'] ?? 'Failed to fetch fees.').toString());
  }
  for (final row in rowsOf(body, const ['RegistrationFees'], activeOnly: false)) {
    final code = row['refId']?.toString().trim().toUpperCase() ?? '';
    final amount = row['amount'];
    if (code.isNotEmpty && amount is num && amount.isFinite && amount >= 0) {
      fees[code] = amount.toDouble();
    }
  }
  return fees;
}
