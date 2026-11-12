import 'package:gotask_partner/core/session/app_session.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/design/app_colors.dart';
import '../../../../core/design/language_switch.dart';
import '../../../../core/design/app_tokens.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/widgets/common_loading_overlay.dart';
import '../providers/login_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  String _selectedCountryCode = '+91';

  // Common country codes — extend as needed
  final List<Map<String, String>> _countryCodes = [
    {'code': '+91', 'flag': '🇮🇳', 'name': 'India'},
  ];

  late final LoginProvider _loginProvider;

  @override
  void initState() {
    super.initState();
    _loginProvider = ServiceLocator.createLoginProvider();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _loginProvider.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.loginPhoneRequired;
    }
    final digitsOnly = value.trim().replaceAll(RegExp(r'\s+'), '');
    if (!RegExp(r'^\d+$').hasMatch(digitsOnly)) {
      return context.l10n.loginPhoneDigitsOnly;
    }
    // India: 10 digits; others: 7–15 digits (E.164 range)
    if (_selectedCountryCode == '+91') {
      if (digitsOnly.length != 10) {
        return context.l10n.loginPhoneInvalidIndia;
      }
      if (!RegExp(r'^[6-9]').hasMatch(digitsOnly)) {
        return context.l10n.loginPhoneStartDigit;
      }
    } else {
      if (digitsOnly.length < 7 || digitsOnly.length > 15) {
        return context.l10n.loginPhoneInvalid;
      }
    }
    return null;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.accent,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _onBecomePartner() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = '$_selectedCountryCode${_phoneController.text.trim()}';

    final success = await _loginProvider.sendOtp(phone);

    if (!mounted) return;

    if (success) {
      context.push(AppRoutes.otpVerify, extra: phone);
    } else {
      _showError(_loginProvider.errorMessage ?? context.l10n.loginFailed);
    }
  }

  void _showCountryCodePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                context.l10n.loginSelectCountryCode,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            ..._countryCodes.map((country) {
              final isSelected = country['code'] == _selectedCountryCode;
              return ListTile(
                leading: Text(
                  country['flag']!,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(country['code'] == '+91' ? context.l10n.loginCountryIndia : country['name']!),
                trailing: Text(
                  country['code']!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selected: isSelected,
                selectedTileColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.08),
                onTap: () {
                  setState(() => _selectedCountryCode = country['code']!);
                  Navigator.pop(context);
                  _formKey.currentState?.validate();
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    // Same screen and the same OTP steps for both buttons, as in the 6 Nov app;
    // only the words follow the button the partner tapped on Welcome.
    final registering = AppSession.registerIntent;
    final linkStyle = TextStyle(
      color: colorScheme.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: colorScheme.primary,
    );

    return ListenableBuilder(
      listenable: _loginProvider,
      builder: (context, _) {
        return CommonLoadingOverlay(
          isLoading: _loginProvider.isLoading,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: Scaffold(
              backgroundColor: AppColors.background,
              body: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Brand header ───────────────────────────────────────
                      Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          MediaQuery.paddingOf(context).top + AppSpacing.xl,
                          AppSpacing.xl,
                          72,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (Navigator.of(context).canPop()) ...[
                                  Material(
                                    color: Colors.white.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(AppRadii.input),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(AppRadii.input),
                                      onTap: () => Navigator.of(context).maybePop(),
                                      child: const SizedBox(
                                        width: 44,
                                        height: 44,
                                        child: Icon(Icons.arrow_back_rounded, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                ],
                                Text(
                                  registering ? l10n.loginTitle : l10n.loginTitleLogin,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                const LanguageSwitch(onDark: true)
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Text(
                              registering ? l10n.loginHeading : l10n.loginHeadingLogin,
                              style: const TextStyle(
                                fontSize: 26,
                                height: 1.25,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              registering ? l10n.loginSubheading : l10n.loginSubheadingLogin,
                              style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.onPrimaryMuted),
                            ),
                          ],
                        ),
                      ),

                      // ── Form card ──────────────────────────────────────────
                      Transform.translate(
                        offset: const Offset(0, -40),
                        child: Container(
                          margin: AppSpacing.page,
                          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                          decoration: AppDecorations.card(shadow: true),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.loginPhoneLabel,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                validator: _validatePhone,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.6,
                                  color: AppColors.ink,
                                ),
                                decoration: InputDecoration(
                                  hintText: l10n.loginPhoneLabel,
                                  prefixIcon: InkWell(
                                    onTap: _showCountryCodePicker,
                                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppRadii.input)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _selectedCountryCode,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.ink,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          const Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            size: 18,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 8),
                                          Container(width: 1, height: 22, color: AppColors.border),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              ElevatedButton(
                                onPressed: _loginProvider.isLoading ? null : _onBecomePartner,
                                child: Text(registering ? l10n.loginBecomePartner : l10n.loginSendOtp),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text.rich(
                                TextSpan(
                                  style: const TextStyle(fontSize: 13, height: 1.6, color: AppColors.textMuted),
                                  children: [
                                    TextSpan(text: l10n.loginAgreePrefix),
                                    TextSpan(
                                      text: l10n.loginTerms,
                                      style: linkStyle,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          context.push(
                                            AppRoutes.webView,
                                            extra: {
                                              'title': l10n.webTermsTitle,
                                              'url': 'https://www.readylocal.in/terms-and-conditions',
                                            },
                                          );
                                        },
                                    ),
                                    TextSpan(text: l10n.loginAnd),
                                    TextSpan(
                                      text: l10n.loginPrivacy,
                                      style: linkStyle,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          context.push(
                                            AppRoutes.webView,
                                            extra: {
                                              'title': l10n.webPrivacyTitle,
                                              'url': 'https://www.readylocal.in/privacy-policy',
                                            },
                                          );
                                        },
                                    ),
                                    TextSpan(text: l10n.loginAgreeSuffix),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: () => setState(() => AppSession.registerIntent = !registering),
                          child: Text(
                            registering ? l10n.loginSwitchToLogin : l10n.loginSwitchToRegister,
                            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
