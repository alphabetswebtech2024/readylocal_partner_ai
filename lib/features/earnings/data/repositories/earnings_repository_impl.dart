import 'dart:developer';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/earnings_details_entity.dart';
import '../../domain/repositories/earnings_repository.dart';
import '../datasources/earnings_remote_datasource.dart';
import '../models/earnings_summary_model.dart';
import '../models/transaction_model.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  final EarningsRemoteDataSource remoteDataSource;

  EarningsRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<EarningsDetailsEntity>> getEarningsDetails(String partnerId) async {
    try {
      final rawData = await remoteDataSource.getEarningsSummary(partnerId);

      final summary = EarningsSummaryModel.fromJson(rawData);
      final rawTxns = rawData['transactions'] as List<dynamic>? ?? [];

      final transactions = rawTxns
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResult.success(
        EarningsDetailsEntity(
          summary: summary,
          transactions: transactions,
        ),
      );
    } catch (e) {
      log('Error fetching earnings details: $e');
      return ApiResult.failure(e is Exception ? e.toString() : 'Unexpected error occurred.');
    }
  }
}
