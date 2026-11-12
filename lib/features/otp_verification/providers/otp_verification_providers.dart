import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../../core/di/service_locator.dart';
import '../presentation/providers/otp_verification_provider.dart';

List<SingleChildWidget> otpVerificationProviders = [
  ChangeNotifierProvider<OtpVerificationProvider>(
    create: (_) => ServiceLocator.createOtpVerificationProvider(),
  ),
];
