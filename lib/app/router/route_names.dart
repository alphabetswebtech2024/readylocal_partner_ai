/// Centralized route paths and names for GoRouter.
class AppRoutes {
  AppRoutes._();

  // Root / Splash
  static const String splash = '/';
  static const String intro = '/intro';

  // Auth Flow
  static const String login = '/auth/login';
  static const String otpVerify = '/auth/otp-verify';
  static const String verified = '/auth/verified';
  static const String personalInfo = '/auth/personal-info';

  // Onboarding / Setup Flow
  static const String selectService = '/onboarding/select-service';
  static const String selectCategories = '/onboarding/select-categories';
  static const String driverSetup = '/onboarding/driver-setup';
  static const String panditSetup = '/onboarding/pandit-setup';
  static const String medicalSetup = '/onboarding/medical-setup';
  static const String addBankDetails = '/onboarding/add-bank-details';
  static const String uploadDocs = '/onboarding/upload-docs';
  static const String activationFee = '/onboarding/activation-fee';
  static const String paymentSuccess = '/onboarding/payment-success';
  static const String paymentFailed = '/onboarding/payment-failed';

  // Home & Dashboard
  static const String home = '/home';
  static const String profile = '/profile';
  static const String viewProfile = '/view-profile';
  static const String earnings = '/earnings';
  static const String withdraw = '/withdraw';
  static const String jobsList = '/jobs-list';
  static const String transactionDetails = '/transaction-details';
  static const String webView = '/webview';

  // Job Operations
  static const String jobOverview = '/jobs/overview';
  static const String customerDetails = '/jobs/customer-details';
  static const String jobProgress = '/jobs/progress';
  static const String workStatusSuccess = '/jobs/work-status-success';
  static const String completedJobOverview = '/jobs/completed-overview';

  // Notifications
  static const String notifications = '/notifications';
  static const String alertSetup = '/alert-setup';
}
