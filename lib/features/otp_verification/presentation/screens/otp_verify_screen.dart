import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:gotask_partner/core/design/app_top_bar.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/session/app_session.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/common_loading_overlay.dart';
import '../providers/otp_verification_provider.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String phoneNumber; // e.g. "+91 9381409072"

  const OtpVerifyScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  // v9: unified controller — replaces TextEditingController + errorAnimationController
  final PinInputController _pinController = PinInputController();

  // ── Resend timer ──────────────────────────────────────────────────────────
  static const int _timerSeconds = 30;
  int _secondsRemaining = _timerSeconds;
  bool _canResend = false;
  Timer? _timer;

  late final OtpVerificationProvider _otpProvider;

  @override
  void initState() {
    super.initState();
    _otpProvider = ServiceLocator.createOtpVerificationProvider();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _canResend = false;
      _secondsRemaining = _timerSeconds;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _otpProvider.dispose();
    super.dispose();
  }

  String get _formattedTimer {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// ── VERIFY OTP ───────────────────────────────────────
  Future<void> _onVerify() async {
    final otp = _pinController.text;

    if (otp.length < 4) {
      _pinController.triggerError();
      _showError(context.l10n.otpEnterComplete);
      return;
    }

    _pinController.clearError();

    final success = await _otpProvider.verifyOtp(
      mobileNumber: widget.phoneNumber,
      otp: otp,
    );

    if (!mounted) return;

    if (success && _otpProvider.authEntity != null) {
      _pinController.clearError();

      // Navigate to PersonalInformation if profile is incomplete
      final bool needsProfile = !_otpProvider.authEntity!.isProfileComplete;

      // Tapped Register, but this number already has a partner account.
      if (AppSession.registerIntent && !needsProfile) {
        AppSession.registerIntent = false;
        await _showAlreadyRegistered();
        if (!mounted) return;
      }

      context.go(AppRoutes.verified, extra: needsProfile);
    } else {
      _pinController.triggerError();
      _showError(_otpProvider.errorMessage ?? context.l10n.otpInvalid);
    }
  }

  Future<void> _showAlreadyRegistered() {
    final l10n = context.l10n;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(color: AppColors.primaryTint, shape: BoxShape.circle),
          child: const Icon(Icons.how_to_reg_rounded, size: 32, color: AppColors.primary),
        ),
        title: Text(l10n.alreadyRegisteredTitle, textAlign: TextAlign.center),
        content: Text(
          l10n.alreadyRegisteredBody,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14.5, height: 1.45, color: AppColors.textSecondary),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.alreadyRegisteredContinue),
            ),
          ),
        ],
      ),
    );
  }

  /// ── RESEND OTP ───────────────────────────────────────
  Future<void> _onResend() async {
    if (!_canResend) return;

    _pinController.clear();
    _pinController.clearError();

    final success = await _otpProvider.resendOtp(widget.phoneNumber);

    if (!mounted) return;

    if (success) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.otpResent),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      _showError(_otpProvider.errorMessage ?? context.l10n.otpResendFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: _otpProvider,
      builder: (context, _) {
        return CommonLoadingOverlay(
          isLoading: _otpProvider.isLoading,
          child: Scaffold(
            backgroundColor: AppColors.background,
            resizeToAvoidBottomInset: true,
            body: SafeArea(
 top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── App Bar ────────────────────────────────────────────────
                  AppTopBar(title: context.l10n.otpVerify, showBack: false),

                  
                  // ── Body ───────────────────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 28,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Heading
                            Text(
                              context.l10n.otpHeading,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              context.l10n.otpSentTo,
                              style: const TextStyle(fontSize: 13, color: Colors.black54),
                            ),

                            const SizedBox(height: 10),

                            // Phone + Edit
                            Row(
                              children: [
                                Text(
                                  widget.phoneNumber,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    context.l10n.otpEdit,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.primary,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 28),

                            // ── OTP Input (pin_code_fields v9) ─────────────────
                            Center(
                              child: MaterialPinField(
                                length: 4,
                                pinController: _pinController,
                                keyboardType: TextInputType.number,
                                autoFocus: true,
                                onCompleted: (pin) {
                                  _pinController.clearError();
                                },
                                onChanged: (value) {
                                  if (_pinController.hasError) {
                                    _pinController.clearError();
                                  }
                                },
                                theme: MaterialPinTheme(
                                  shape: MaterialPinShape.outlined,
                                  cellSize: const Size(50, 50),
                                  spacing: 16,
                                  borderRadius: BorderRadius.circular(8),
                                  borderWidth: 1.5,
                                  focusedBorderWidth: 2.0,
                                  borderColor: Colors.black26,
                                  focusedBorderColor: colorScheme.primary,
                                  filledBorderColor: colorScheme.primary.withValues(alpha: 0.6),
                                  errorColor: Colors.red,
                                  fillColor: Colors.white,
                                  focusedFillColor: Colors.white,
                                  filledFillColor: Colors.white,
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  showCursor: true,
                                  cursorColor: colorScheme.primary,
                                  animateCursor: true,
                                  entryAnimation: MaterialPinAnimation.scale,
                                  animationDuration: const Duration(milliseconds: 150),
                                  enableErrorShake: true,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ── Resend + Timer ─────────────────────────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: _canResend ? _onResend : null,
                                  child: Text(
                                    context.l10n.otpResend,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _canResend
                                          ? colorScheme.primary
                                          : Colors.black38,
                                      decoration: _canResend
                                          ? TextDecoration.underline
                                          : TextDecoration.none,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (!_canResend)
                                  Text(
                                    _formattedTimer,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Verify Button ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _otpProvider.isLoading ? null : _onVerify,
                        child: Text(
                          context.l10n.otpVerify,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
