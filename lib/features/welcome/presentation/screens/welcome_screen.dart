import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gotask_partner/core/session/app_session.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../providers/welcome_provider.dart';
import '../widgets/welcome_action_buttons.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/design/language_switch.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final WelcomeProvider _welcomeProvider;

  @override
  void initState() {
    super.initState();
    _welcomeProvider = ServiceLocator.createWelcomeProvider();
  }

  @override
  void dispose() {
    _welcomeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Logo panel with the language choice, the first thing a partner sees.
          Expanded(
            child: Stack(
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        const Align(alignment: Alignment.centerRight, child: LanguageSwitch()),
                        const SizedBox(height: 4),
                        // Shrinks first on small phones, so nothing is pushed off screen.
                        Flexible(
                          flex: 6,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 340),
                            child: Image.asset(
                              'assets/images/partner_welcome.webp',
                              fit: BoxFit.contain,
                              cacheHeight: 1020,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // The splash already shows the logo; here the partner reads why to join.
                        Text(
                          l10n.welcomeHeadline,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 24, height: 1.25, fontWeight: FontWeight.w800, color: AppColors.ink),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.welcomeSubline,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14.5, height: 1.45, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 14),
                        _benefit(Icons.verified_outlined, l10n.welcomeBenefitJobs),
                        _benefit(Icons.account_balance_wallet_outlined, l10n.welcomeBenefitEarnings),
                        _benefit(Icons.schedule_rounded, l10n.welcomeBenefitTime),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Color(0x14344A84), blurRadius: 22, offset: Offset(0, -6))],
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  WelcomeActionButtons(
                    onRegister: () {
                      AppSession.registerIntent = true;
                      context.push(AppRoutes.login);
                    },
                    onLogin: () {
                      AppSession.registerIntent = false;
                      context.push(AppRoutes.login);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      children: [
                        TextSpan(text: context.l10n.welcomeReadOur),
                        TextSpan(
                          text: context.l10n.loginTerms,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.push(
                                AppRoutes.webView,
                                extra: {
                                  'title': context.l10n.webTermsTitle,
                                  'url': 'https://www.readylocal.in/terms-and-conditions',
                                },
                              );
                            },
                        ),
                        TextSpan(text: context.l10n.welcomeAnd),
                        TextSpan(
                          text: context.l10n.webPrivacyTitle,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.push(
                                AppRoutes.webView,
                                extra: {
                                  'title': context.l10n.webPrivacyTitle,
                                  'url': 'https://www.readylocal.in/privacy-policy',
                                },
                              );
                            },
                        ),
                        TextSpan(text: context.l10n.welcomeReadSuffix),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefit(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: AppColors.accentTint, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 20, color: AppColors.accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.text),
          ),
        ),
      ],
    ),
  );
}
