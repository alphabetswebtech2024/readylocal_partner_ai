import 'package:provider/single_child_widget.dart';

import '../../features/activation_fee/providers/activation_fee_providers.dart';
import '../../features/app_web_view/providers/app_web_view_providers.dart';
import '../../features/bank_details/providers/bank_details_providers.dart';
import '../../features/completed_job_overview/providers/completed_job_overview_providers.dart';
import '../../features/customer_details/providers/customer_details_providers.dart';
import '../../features/document_upload/providers/document_upload_providers.dart';
import '../../features/driver_setup/providers/driver_setup_providers.dart';
import '../../features/earnings/providers/earnings_providers.dart';
import '../../features/home/providers/home_providers.dart';
import '../../features/job_overview/providers/job_overview_providers.dart';
import '../../features/job_progress/providers/job_progress_providers.dart';
import '../../features/jobs_list/providers/jobs_list_providers.dart';
import '../../features/login/providers/login_providers.dart';
import '../../features/medical_setup/providers/medical_setup_providers.dart';
import '../../features/notifications/providers/notifications_providers.dart';
import '../../features/otp_verification/providers/otp_verification_providers.dart';
import '../../features/pandit_setup/providers/pandit_setup_providers.dart';
import '../../features/payment_failed/providers/payment_failed_providers.dart';
import '../../features/payment_success/providers/payment_success_providers.dart';
import '../../features/personal_information/providers/personal_information_providers.dart';
import '../../features/places_autocomplete/providers/places_autocomplete_providers.dart';
import '../../features/profile/providers/profile_providers.dart';
import '../../features/select_categories/providers/select_categories_providers.dart';
import '../../features/select_service/providers/select_service_providers.dart';
import '../../features/splash/providers/splash_providers.dart';
import '../../features/transaction_details/providers/transaction_details_providers.dart';
import '../../features/verified/providers/verified_providers.dart';
import '../../features/view_profile/providers/view_profile_providers.dart';
import '../../features/welcome/providers/welcome_providers.dart';
import '../../features/withdraw/providers/withdraw_providers.dart';
import '../../features/work_status_success/providers/work_status_success_providers.dart';

List<SingleChildWidget> get appProviders => [
  ...activationFeeProviders,
  ...appWebViewProviders,
  ...bankDetailsProviders,
  ...completedJobOverviewProviders,
  ...customerDetailsProviders,
  ...documentUploadProviders,
  ...driverSetupProviders,
  ...earningsProviders,
  ...homeProviders,
  ...jobOverviewProviders,
  ...jobProgressProviders,
  ...jobsListProviders,
  ...loginProviders,
  ...medicalSetupProviders,
  ...notificationsProviders,
  ...otpVerificationProviders,
  ...panditSetupProviders,
  ...paymentFailedProviders,
  ...paymentSuccessProviders,
  ...personalInformationProviders,
  ...placesAutocompleteProviders,
  ...profileProviders,
  ...selectCategoriesProviders,
  ...selectServiceProviders,
  ...splashProviders,
  ...transactionDetailsProviders,
  ...verifiedProviders,
  ...viewProfileProviders,
  ...welcomeProviders,
  ...withdrawProviders,
  ...workStatusSuccessProviders,
];
