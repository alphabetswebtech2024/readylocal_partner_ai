import '../../domain/entities/activation_fee_entity.dart';

class ActivationFeeModel extends ActivationFeeEntity {
  const ActivationFeeModel({
    required super.amount,
    required super.transactionId,
    required super.moduleId,
    required super.moduleName,
  });

  Map<String, dynamic> toJson(String partnerId) => {
    'partnerId': partnerId,
    'transactionId': transactionId,
    'amount': amount,
    'moduleId': moduleId,
    'moduleName': moduleName,
  };
}
