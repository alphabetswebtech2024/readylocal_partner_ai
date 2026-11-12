import 'package:flutter/material.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

class WorkStatusSuccessCardWidget extends StatelessWidget {
  final String partnerName;
  final String subtitle;

  const WorkStatusSuccessCardWidget({
    super.key,
    required this.partnerName,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 340),
            child: Image.asset(
              'assets/images/partner_welcome.webp',
              cacheHeight: 1020,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Icon(
                Icons.check_circle_rounded,
                size: 120,
                color: Colors.green.shade400,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          context.l10n.thankYouName(partnerName),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 15, color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
