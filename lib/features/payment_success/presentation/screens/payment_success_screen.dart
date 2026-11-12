import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/provider/UserProvider.dart';
import '../../../../core/utils/AppConstants.dart';
import '../../../../core/widgets/common_loading_overlay.dart';
import '../providers/payment_success_provider.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  late final PaymentSuccessProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = ServiceLocator.createPaymentSuccessProvider();
    _readPaid();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  /// A waived fee has no payment to mention.
  bool _paid = false;

  Future<void> _readPaid() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('TransactionID') ?? '';
    if (mounted) setState(() => _paid = id.isNotEmpty && id != 'FREE_REGISTRATION');
  }

  Future<void> _onExploreApp() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.userOrNull;

    if (currentUser == null) {
      if (mounted) context.go(AppRoutes.splash);
      return;
    }

    await _provider.onExploreApp(
      partnerId: currentUser.id,
      deviceToken: deviceId,
      onComplete: () async {
        if (mounted) context.go(AppRoutes.home);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        return CommonLoadingOverlay(
          isLoading: _provider.isLoading,
          child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(''),
          backgroundColor: Colors.white,
          elevation: 0.0,
          toolbarHeight: 0.0,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Shrinks on small phones so the button always stays on screen.
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 340),
                  child: Image.asset(
                    'assets/images/partner_welcome.webp',
                    fit: BoxFit.contain,
                    cacheHeight: 1020,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  context.l10n.paymentRequestAccepted,
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Text(
                _paid ? context.l10n.paymentReceived : context.l10n.paymentDetailsReceived,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Text(
                context.l10n.paymentTeamWillContact,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _provider.isLoading ? null : _onExploreApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    context.l10n.verifyContinue,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
