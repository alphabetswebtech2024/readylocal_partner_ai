import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../providers/payment_failed_provider.dart';
import '../widgets/payment_failed_content_widget.dart';

class FailedPaymentScreen extends StatefulWidget {
  const FailedPaymentScreen({super.key});

  @override
  State<FailedPaymentScreen> createState() => _FailedPaymentScreenState();
}

class _FailedPaymentScreenState extends State<FailedPaymentScreen> {
  late final PaymentFailedProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = ServiceLocator.createPaymentFailedProvider();
    _provider.addListener(_onProviderUpdate);
  }

  void _onProviderUpdate() {
    if (_provider.shouldDismiss && mounted && context.canPop()) {
      context.pop();
    }
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderUpdate);
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        return Scaffold(
          body: Center(
            child: PaymentFailedContentWidget(
              failureEntity: _provider.failureEntity,
            ),
          ),
        );
      },
    );
  }
}
