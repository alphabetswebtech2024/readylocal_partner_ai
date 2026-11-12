import 'dart:developer';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/transaction_detail_entity.dart';
import '../../domain/repositories/transaction_details_repository.dart';
import '../datasources/transaction_details_remote_datasource.dart';

class TransactionDetailsRepositoryImpl implements TransactionDetailsRepository {
  final TransactionDetailsRemoteDataSource remoteDataSource;

  TransactionDetailsRepositoryImpl(this.remoteDataSource);

  @override
  Future<ApiResult<TransactionDetailEntity>> getTransactionDetails(String transactionId) async {
    try {
      final detail = await remoteDataSource.getTransactionDetails(transactionId);
      return ApiResult.success(detail);
    } catch (e) {
      log('Error fetching transaction details: $e');
      return ApiResult.failure(e is Exception ? e.toString() : 'Unexpected error occurred.');
    }
  }
}
