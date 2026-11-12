import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../domain/entities/payment_failure_entity.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

class PaymentFailedContentWidget extends StatelessWidget {
  final PaymentFailureEntity failureEntity;

  const PaymentFailedContentWidget({
    super.key,
    required this.failureEntity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          "assets/images/failedPayment.svg",
          height: 200,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 16.0),
        Text(
          context.l10n.paymentFailedTitle,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16.0),
        Text(
          context.l10n.paymentFailedBody,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 18.0,
          ),
        ),
      ],
    );
  }
}
