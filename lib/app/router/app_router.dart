import 'package:gotask_partner/features/alert_setup/presentation/screens/alert_setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/session/app_session.dart';
import '../../core/provider/UserProvider.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/welcome/presentation/screens/welcome_screen.dart';
import '../../features/login/presentation/screens/login_screen.dart';
import '../../features/otp_verification/presentation/screens/otp_verify_screen.dart';
import '../../features/verified/presentation/screens/verified_screen.dart';
import '../../features/personal_information/presentation/screens/personal_information_screen.dart';
import '../../features/select_service/presentation/screens/select_service_screen.dart';
import '../../features/select_categories/presentation/screens/select_categories_screen.dart';
import '../../features/driver_setup/presentation/screens/driver_setup_screen.dart';
import '../../features/pandit_setup/presentation/screens/pandit_setup_screen.dart';
import '../../features/medical_setup/presentation/screens/medical_setup_screen.dart';
import '../../features/bank_details/presentation/screens/add_bank_details_screen.dart';
import '../../features/activation_fee/presentation/screens/partner_activation_fee_screen.dart';
import '../../features/payment_success/presentation/screens/payment_success_screen.dart';
import '../../features/payment_failed/presentation/screens/failed_payment_screen.dart';
import '../../features/document_upload/presentation/screens/upload_images_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/view_profile/presentation/screens/view_profile_screen.dart';
import '../../features/earnings/presentation/screens/earnings_screen.dart';
import '../../features/withdraw/presentation/screens/withdraw_screen.dart';
import '../../features/transaction_details/presentation/screens/transaction_details_screen.dart';
import '../../features/app_web_view/presentation/screens/app_web_view_screen.dart';
import '../../features/completed_job_overview/presentation/screens/completed_job_overview_screen.dart';
import '../../features/jobs_list/presentation/screens/jobs_list_screen.dart';
import '../../features/customer_details/data/models/customer_details_model.dart';
import '../../features/customer_details/presentation/screens/customer_details_screen.dart';
import '../../features/job_overview/data/models/job_overview_model.dart';
import '../../features/job_overview/presentation/screens/job_overview_screen.dart';
import '../../features/job_progress/presentation/screens/job_progress_screen.dart';
import '../../features/work_status_success/presentation/screens/work_status_success_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import 'route_names.dart';

/// Centralized GoRouter configuration for the application.
class AppRouter {
  AppRouter._();

  static GoRouter createRouter(UserProvider userProvider, {List<NavigatorObserver>? observers}) {
    return GoRouter(
      navigatorKey: AppSession.navigatorKey,
      initialLocation: AppRoutes.splash,
      refreshListenable: userProvider,
      observers: observers,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.intro,
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.otpVerify,
          builder: (context, state) {
            final phone = state.extra as String? ?? '';
            return OtpVerifyScreen(phoneNumber: phone);
          },
        ),
        GoRoute(
          path: AppRoutes.verified,
          builder: (context, state) {
            final navigateToProfile = state.extra as bool? ?? false;
            return VerifiedScreen(navigateToProfile: navigateToProfile);
          },
        ),
        GoRoute(
          path: AppRoutes.personalInfo,
          builder: (context, state) => const PersonalInformationScreen(),
        ),
        GoRoute(
          path: AppRoutes.selectService,
          builder: (context, state) => const SelectServiceScreen(),
        ),
        GoRoute(
          path: AppRoutes.selectCategories,
          // Passes the chosen module; without it every service was treated as Home Services.
          builder: (context, state) => SelectCategoriesScreen(args: state.extra as Map<String, dynamic>?),
        ),
        GoRoute(
          path: AppRoutes.driverSetup,
          // Passes the chosen module; without it Driver saved a blank module ID.
          builder: (context, state) => DriverSetupScreen(args: state.extra as Map<String, dynamic>?),
        ),
        GoRoute(
          path: AppRoutes.panditSetup,
          builder: (context, state) => PanditSetupScreen(args: state.extra as Map<String, dynamic>?),
        ),
        GoRoute(
          path: AppRoutes.medicalSetup,
          // Passes the chosen module; without it Medical asked for categories with an empty ID.
          builder: (context, state) => MedicalSetupScreen(args: state.extra as Map<String, dynamic>?),
        ),
        GoRoute(
          path: AppRoutes.addBankDetails,
          builder: (context, state) => const AddBankDetailsScreen(),
        ),
        GoRoute(
          path: AppRoutes.uploadDocs,
          builder: (context, state) {
            final category = state.extra as PartnerCategory? ?? PartnerCategory.homeServices;
            return UploadImagesScreen(category: category);
          },
        ),
        GoRoute(
          path: AppRoutes.activationFee,
          builder: (context, state) => const PartnerActivationFeeScreen(),
        ),
        GoRoute(
          path: AppRoutes.paymentSuccess,
          builder: (context, state) => const PaymentSuccessScreen(),
        ),
        GoRoute(
          path: AppRoutes.paymentFailed,
          builder: (context, state) => const FailedPaymentScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            return HomeScreen(args: args);
          },
        ),
        GoRoute(
          path: AppRoutes.alertSetup,
          builder: (context, state) => const AlertSetupScreen(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.viewProfile,
          builder: (context, state) => const ViewProfileScreen(),
        ),
        GoRoute(
          path: AppRoutes.webView,
          builder: (context, state) {
            final params = state.extra as Map<String, dynamic>? ?? {};
            return AppWebViewScreen(
              title: params['title']?.toString() ?? '',
              url: params['url']?.toString() ?? '',
            );
          },
        ),
        GoRoute(
          path: AppRoutes.earnings,
          builder: (context, state) => const EarningsScreen(),
        ),
        GoRoute(
          path: AppRoutes.withdraw,
          builder: (context, state) {
            final balance = (state.extra as num?)?.toDouble() ?? 0.0;
            return WithdrawScreen(availableBalance: balance);
          },
        ),
        GoRoute(
          path: AppRoutes.transactionDetails,
          builder: (context, state) {
            final extraMap = (state.extra is Map<String, dynamic>) ? state.extra as Map<String, dynamic> : null;
            final txnId = (state.extra is String)
                ? state.extra as String
                : extraMap?['transactionId']?.toString() ?? '';
            final txn = extraMap?['transaction'] as TransactionDetail?;
            return TransactionDetailsScreen(transactionId: txnId, transaction: txn);
          },
        ),
        GoRoute(
          path: AppRoutes.jobsList,
          builder: (context, state) => const JobsListScreen(),
        ),
        GoRoute(
          path: AppRoutes.completedJobOverview,
          // Without job data (e.g. app restored by the OS) go home instead of crashing.
          redirect: (context, state) => state.extra is JobOverviewData ? null : AppRoutes.home,
          builder: (context, state) {
            final job = state.extra as JobOverviewData;
            return CompletedJobOverviewScreen(job: job);
          },
        ),
        GoRoute(
          path: AppRoutes.customerDetails,
          redirect: (context, state) => state.extra is CustomerDetails ? null : AppRoutes.home,
          builder: (context, state) {
            final details = state.extra as CustomerDetails;
            return CustomerDetailsScreen(details: details);
          },
        ),
        GoRoute(
          path: AppRoutes.jobOverview,
          redirect: (context, state) => state.extra is JobOverviewData ? null : AppRoutes.home,
          builder: (context, state) {
            final job = state.extra as JobOverviewData;
            return JobOverviewScreen(job: job);
          },
        ),
        GoRoute(
          path: AppRoutes.jobProgress,
          builder: (context, state) {
            final params = state.extra as Map<String, dynamic>? ?? {};
            return JobProgressScreen(
              jobId: params['jobId']?.toString() ?? '',
              jobTitle: params['jobTitle']?.toString() ?? '',
              jobAmount: (params['jobAmount'] as num?)?.toDouble() ?? 0.0,
              jobDateTime: params['jobDateTime']?.toString() ?? '',
              isInstant: params['isInstant'] as bool? ?? false,
              etaLabel: params['etaLabel']?.toString() ?? '',
              aboutPoints: (params['aboutPoints'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
            );
          },
        ),
        GoRoute(
          path: AppRoutes.workStatusSuccess,
          builder: (context, state) {
            final partnerName = state.extra as String? ?? 'Partner';
            return WorkStatusSuccessScreen(partnerName: partnerName);
          },
        ),
        GoRoute(
          path: AppRoutes.notifications,
          builder: (context, state) => const NotificationScreen(),
        ),
      ],
    );
  }
}
