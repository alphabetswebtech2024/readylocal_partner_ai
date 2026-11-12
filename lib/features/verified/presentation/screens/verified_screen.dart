import 'package:gotask_partner/core/services/push_notification_service.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gotask_partner/core/provider/UserProvider.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/design/app_tokens.dart';

import '../../../../app/router/route_names.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

class VerifiedScreen extends StatefulWidget {
  /// true  → go to PersonalInformationScreen after 5 s
  /// false → go to HomeScreen after 5 s
  final bool navigateToProfile;

  const VerifiedScreen({super.key, this.navigateToProfile = true});

  @override
  State<VerifiedScreen> createState() => _VerifiedScreenState();
}

class _VerifiedScreenState extends State<VerifiedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();

    PushNotificationService.ensureTokenOnServer();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();

    _redirectTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (widget.navigateToProfile) {
        context.go(AppRoutes.personalInfo);
      } else {
        _goHome();
      }
    });
  }

  Future<void> _goHome() async {
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _animController.dispose();
    _redirectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  width: 124,
                  height: 124,
                  decoration: const BoxDecoration(
                    gradient: AppColors.brandGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.brand,
                  ),
                  child: const Icon(Icons.check_rounded, size: 68, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _fadeAnim,
              child: Text(
                context.l10n.verifiedTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
