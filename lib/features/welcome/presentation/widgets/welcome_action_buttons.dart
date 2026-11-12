import 'package:flutter/material.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

class WelcomeActionButtons extends StatelessWidget {
  final VoidCallback onRegister;
  final VoidCallback onLogin;

  const WelcomeActionButtons({super.key, required this.onRegister, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(onPressed: onRegister, child: Text(context.l10n.welcomeRegister)),
        const SizedBox(height: 12),
        SizedBox(
          height: 54,
          child: OutlinedButton(onPressed: onLogin, child: Text(context.l10n.welcomeLogin)),
        ),
      ],
    );
  }
}
