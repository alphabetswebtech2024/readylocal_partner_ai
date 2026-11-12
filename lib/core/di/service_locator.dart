import '../network/api_client.dart';
import '../network/api_service.dart';
import '../network/token_storage.dart';
import '../provider/UserProvider.dart';

// Splash
import '../../features/splash/data/datasources/splash_remote_datasource.dart';
import '../../features/splash/data/repositories/splash_repository_impl.dart';
import '../../features/splash/domain/repositories/splash_repository.dart';
import '../../features/splash/domain/usecases/check_partner_status_usecase.dart';
import '../../features/splash/presentation/providers/splash_provider.dart';

// Welcome
import '../../features/welcome/data/datasources/welcome_local_datasource.dart';
import '../../features/welcome/data/repositories/welcome_repository_impl.dart';
import '../../features/welcome/domain/repositories/welcome_repository.dart';
import '../../features/welcome/domain/usecases/get_welcome_content_usecase.dart';
import '../../features/welcome/presentation/providers/welcome_provider.dart';

// Login
import '../../features/login/data/datasources/login_remote_datasource.dart';
import '../../features/login/data/repositories/login_repository_impl.dart';
import '../../features/login/domain/repositories/login_repository.dart';
import '../../features/login/domain/usecases/send_login_otp_usecase.dart';
import '../../features/login/presentation/providers/login_provider.dart';

// Otp Verification
import '../../features/otp_verification/data/datasources/otp_verification_remote_datasource.dart';
import '../../features/otp_verification/data/repositories/otp_verification_repository_impl.dart';
import '../../features/otp_verification/domain/repositories/otp_verification_repository.dart';
import '../../features/otp_verification/domain/usecases/resend_otp_usecase.dart';
import '../../features/otp_verification/domain/usecases/verify_otp_usecase.dart';
import '../../features/otp_verification/presentation/providers/otp_verification_provider.dart';

// Verified
import '../../features/verified/data/datasources/verified_local_datasource.dart';
import '../../features/verified/data/repositories/verified_repository_impl.dart';
import '../../features/verified/domain/repositories/verified_repository.dart';
import '../../features/verified/domain/usecases/get_verified_destination_usecase.dart';
import '../../features/verified/presentation/providers/verified_provider.dart';

// Personal Information
import '../../features/personal_information/data/datasources/personal_information_remote_datasource.dart';
import '../../features/personal_information/data/repositories/personal_information_repository_impl.dart';
import '../../features/personal_information/domain/repositories/personal_information_repository.dart';
import '../../features/personal_information/domain/usecases/save_personal_info_usecase.dart';
import '../../features/personal_information/presentation/providers/personal_information_provider.dart';

// Places Autocomplete
import '../../features/places_autocomplete/data/datasources/places_remote_datasource.dart';
import '../../features/places_autocomplete/data/repositories/places_repository_impl.dart';
import '../../features/places_autocomplete/domain/repositories/places_repository.dart';
import '../../features/places_autocomplete/domain/usecases/get_place_details_usecase.dart';
import '../../features/places_autocomplete/domain/usecases/search_places_usecase.dart';
import '../../features/places_autocomplete/presentation/providers/places_autocomplete_provider.dart';

// Select Service
import '../../features/select_service/data/datasources/select_service_remote_datasource.dart';
import '../../features/select_service/data/repositories/select_service_repository_impl.dart';
import '../../features/select_service/domain/repositories/select_service_repository.dart';
import '../../features/select_service/domain/usecases/get_service_modules_usecase.dart';
import '../../features/select_service/presentation/providers/select_service_provider.dart';

// Select Categories
import '../../features/select_categories/data/datasources/select_categories_remote_datasource.dart';
import '../../features/select_categories/data/repositories/select_categories_repository_impl.dart';
import '../../features/select_categories/domain/repositories/select_categories_repository.dart';
import '../../features/select_categories/domain/usecases/get_categories_usecase.dart';
import '../../features/select_categories/presentation/providers/select_categories_provider.dart';

// Driver Setup
import '../../features/driver_setup/data/datasources/driver_setup_remote_datasource.dart';
import '../../features/driver_setup/data/repositories/driver_setup_repository_impl.dart';
import '../../features/driver_setup/domain/repositories/driver_setup_repository.dart';
import '../../features/driver_setup/domain/usecases/get_driver_setup_options_usecase.dart';
import '../../features/driver_setup/presentation/providers/driver_setup_provider.dart';

// Pandit Setup
import '../../features/pandit_setup/data/datasources/pandit_setup_remote_datasource.dart';
import '../../features/pandit_setup/data/repositories/pandit_setup_repository_impl.dart';
import '../../features/pandit_setup/domain/repositories/pandit_setup_repository.dart';
import '../../features/pandit_setup/domain/usecases/get_pandit_services_usecase.dart';
import '../../features/pandit_setup/presentation/providers/pandit_setup_provider.dart';

// Medical Setup
import '../../features/medical_setup/data/datasources/medical_setup_remote_datasource.dart';
import '../../features/medical_setup/data/repositories/medical_setup_repository_impl.dart';
import '../../features/medical_setup/domain/repositories/medical_setup_repository.dart';
import '../../features/medical_setup/domain/usecases/get_medical_services_usecase.dart';
import '../../features/medical_setup/presentation/providers/medical_setup_provider.dart';

// Bank Details
import '../../features/bank_details/data/datasources/bank_details_remote_datasource.dart';
import '../../features/bank_details/data/repositories/bank_details_repository_impl.dart';
import '../../features/bank_details/domain/repositories/bank_details_repository.dart';
import '../../features/bank_details/domain/usecases/add_bank_account_usecase.dart';
import '../../features/bank_details/presentation/providers/bank_details_provider.dart';

// Activation Fee
import '../../features/activation_fee/data/datasources/activation_fee_remote_datasource.dart';
import '../../features/activation_fee/data/repositories/activation_fee_repository_impl.dart';
import '../../features/activation_fee/domain/repositories/activation_fee_repository.dart';
import '../../features/activation_fee/domain/usecases/save_activation_transaction_usecase.dart';
import '../../features/activation_fee/presentation/providers/activation_fee_provider.dart';

// Payment Success
import '../../features/payment_success/data/datasources/payment_success_remote_datasource.dart';
import '../../features/payment_success/data/repositories/payment_success_repository_impl.dart';
import '../../features/payment_success/domain/repositories/payment_success_repository.dart';
import '../../features/payment_success/domain/usecases/sync_post_payment_usecase.dart';
import '../../features/payment_success/presentation/providers/payment_success_provider.dart';

// Payment Failed
import '../../features/payment_failed/data/datasources/payment_failed_local_datasource.dart';
import '../../features/payment_failed/data/repositories/payment_failed_repository_impl.dart';
import '../../features/payment_failed/domain/repositories/payment_failed_repository.dart';
import '../../features/payment_failed/domain/usecases/get_payment_failure_details_usecase.dart';
import '../../features/payment_failed/presentation/providers/payment_failed_provider.dart';


// Home
import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_details_usecase.dart';
import '../../features/home/domain/usecases/toggle_online_status_usecase.dart';
import '../../features/home/domain/usecases/sync_location_usecase.dart';
import '../../features/home/domain/usecases/update_device_token_usecase.dart';
import '../../features/home/presentation/providers/home_provider.dart';

// Profile
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_partner_profile_usecase.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';

// View Profile
import '../../features/view_profile/data/datasources/view_profile_remote_datasource.dart';
import '../../features/view_profile/data/repositories/view_profile_repository_impl.dart';
import '../../features/view_profile/domain/repositories/view_profile_repository.dart';
import '../../features/view_profile/domain/usecases/get_view_profile_usecase.dart';
import '../../features/view_profile/presentation/providers/view_profile_provider.dart';

// Earnings
import '../../features/earnings/data/datasources/earnings_remote_datasource.dart';
import '../../features/earnings/data/repositories/earnings_repository_impl.dart';
import '../../features/earnings/domain/repositories/earnings_repository.dart';
import '../../features/earnings/domain/usecases/get_earnings_usecase.dart';
import '../../features/earnings/presentation/providers/earnings_provider.dart';

// Withdraw
import '../../features/withdraw/data/datasources/withdraw_remote_datasource.dart';
import '../../features/withdraw/data/repositories/withdraw_repository_impl.dart';
import '../../features/withdraw/domain/repositories/withdraw_repository.dart';
import '../../features/withdraw/domain/usecases/get_bank_accounts_usecase.dart';
import '../../features/withdraw/domain/usecases/request_withdrawal_usecase.dart';
import '../../features/withdraw/presentation/providers/withdraw_provider.dart';

// Transaction Details
import '../../features/transaction_details/data/datasources/transaction_details_remote_datasource.dart';
import '../../features/transaction_details/data/repositories/transaction_details_repository_impl.dart';
import '../../features/transaction_details/domain/repositories/transaction_details_repository.dart';
import '../../features/transaction_details/domain/usecases/get_transaction_details_usecase.dart';
import '../../features/transaction_details/presentation/providers/transaction_details_provider.dart';

// Jobs List
import '../../features/jobs_list/data/datasources/jobs_list_remote_datasource.dart';
import '../../features/jobs_list/data/repositories/jobs_list_repository_impl.dart';
import '../../features/jobs_list/domain/repositories/jobs_list_repository.dart';
import '../../features/jobs_list/domain/usecases/get_jobs_list_usecase.dart';
import '../../features/jobs_list/presentation/providers/jobs_list_provider.dart';

// App Web View
import '../../features/app_web_view/data/datasources/app_web_view_local_datasource.dart';
import '../../features/app_web_view/data/repositories/app_web_view_repository_impl.dart';
import '../../features/app_web_view/domain/repositories/app_web_view_repository.dart';
import '../../features/app_web_view/domain/usecases/get_web_view_config_usecase.dart';
import '../../features/app_web_view/presentation/providers/app_web_view_provider.dart';

// Completed Job Overview
import '../../features/completed_job_overview/data/datasources/completed_job_local_datasource.dart';
import '../../features/completed_job_overview/data/repositories/completed_job_repository_impl.dart';
import '../../features/completed_job_overview/domain/repositories/completed_job_repository.dart';
import '../../features/completed_job_overview/domain/usecases/get_completed_job_details_usecase.dart';
import '../../features/completed_job_overview/presentation/providers/completed_job_provider.dart';

// Job Overview
import '../../features/job_overview/data/datasources/job_overview_remote_datasource.dart';
import '../../features/job_overview/data/repositories/job_overview_repository_impl.dart';
import '../../features/job_overview/domain/repositories/job_overview_repository.dart';
import '../../features/job_overview/domain/usecases/accept_job_usecase.dart';
import '../../features/job_overview/domain/usecases/reject_job_usecase.dart';
import '../../features/job_overview/presentation/providers/job_overview_provider.dart';

// Customer Details
import '../../features/customer_details/data/datasources/customer_details_remote_datasource.dart';
import '../../features/customer_details/data/repositories/customer_details_repository_impl.dart';
import '../../features/customer_details/domain/repositories/customer_details_repository.dart';
import '../../features/customer_details/domain/usecases/start_ride_usecase.dart';
import '../../features/customer_details/domain/usecases/reach_location_usecase.dart';
import '../../features/customer_details/domain/usecases/sync_live_location_usecase.dart';
import '../../features/customer_details/presentation/providers/customer_details_provider.dart';

// Job Progress
import '../../features/job_progress/data/datasources/job_progress_remote_datasource.dart';
import '../../features/job_progress/data/repositories/job_progress_repository_impl.dart';
import '../../features/job_progress/domain/repositories/job_progress_repository.dart';
import '../../features/job_progress/domain/usecases/upload_work_image_usecase.dart';
import '../../features/job_progress/domain/usecases/cancel_job_usecase.dart';
import '../../features/job_progress/domain/usecases/complete_job_usecase.dart';
import '../../features/job_progress/presentation/providers/job_progress_provider.dart';

// Work Status Success
import '../../features/work_status_success/data/datasources/work_status_success_local_datasource.dart';
import '../../features/work_status_success/data/repositories/work_status_success_repository_impl.dart';
import '../../features/work_status_success/domain/repositories/work_status_success_repository.dart';
import '../../features/work_status_success/domain/usecases/get_work_status_success_details_usecase.dart';
import '../../features/work_status_success/presentation/providers/work_status_success_provider.dart';

import '../../features/document_upload/data/datasources/document_remote_datasource.dart';
import '../../features/document_upload/data/repositories/document_repository_impl.dart';
import '../../features/document_upload/domain/repositories/document_repository.dart';
import '../../features/document_upload/domain/usecases/upload_document_usecase.dart';
import '../../features/document_upload/domain/usecases/submit_documents_usecase.dart';
import '../../features/document_upload/presentation/providers/document_upload_provider.dart';

// Notifications
import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/get_job_request_details_usecase.dart';
import '../../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';

/// Centralized Service Locator for Dependency Injection.
/// Follows Clean Architecture without any third-party DI package.
class ServiceLocator {
  ServiceLocator._();

  static late final ApiClient apiClient;
  static late final ApiService apiService;
  static late final UserProvider userProvider;

  // Phase 1: Screen-as-a-Feature dependencies
  static late final CheckPartnerStatusUseCase checkPartnerStatusUseCase;
  static late final GetWelcomeContentUseCase getWelcomeContentUseCase;
  static late final SendLoginOtpUseCase sendLoginOtpUseCase;
  static late final VerifyOtpUseCase verifyOtpUseCase;
  static late final ResendOtpUseCase resendOtpUseCase;
  static late final GetVerifiedDestinationUseCase getVerifiedDestinationUseCase;
  static late final SavePersonalInfoUseCase savePersonalInfoUseCase;
  static late final SearchPlacesUseCase searchPlacesUseCase;
  static late final GetPlaceDetailsUseCase getPlaceDetailsUseCase;

  // Select Service
  static late final GetServiceModulesUseCase getServiceModulesUseCase;
  static late final GetServiceRegistrationFeesUseCase getServiceRegistrationFeesUseCase;

  // Select Categories
  static late final GetCategoriesUseCase getCategoriesUseCase;
  static late final GetSubcategoriesUseCase getSubcategoriesUseCase;
  static late final GetServiceTypesUseCase getServiceTypesUseCase;
  static late final GetServicesUseCase getServicesUseCase;
  static late final GetPersonalCareServicesUseCase getPersonalCareServicesUseCase;

  // Driver Setup
  static late final GetDriverSetupOptionsUseCase driverSetupOptionsUseCase;

  // Pandit Setup
  static late final GetPanditCategoriesUseCase getPanditCategoriesUseCase;
  static late final GetPanditServicesUseCase getPanditServicesUseCase;

  // Medical Setup
  static late final GetMedicalCategoriesUseCase getMedicalCategoriesUseCase;
  static late final GetMedicalServicesUseCase getMedicalServicesUseCase;

  // Bank Details
  static late final AddBankAccountUseCase addBankDetailsUseCase;

  // Activation Fee
  static late final SaveActivationTransactionUseCase saveActivationTransactionUseCase;

  // Payment Success
  static late final SyncPostPaymentUseCase syncPostPaymentUseCase;

  // Payment Failed
  static late final GetPaymentFailureDetailsUseCase getPaymentFailureDetailsUseCase;


  // Home & Dashboard dependencies
  static late final HomeRepository homeRepository;
  static late final GetHomeDetailsUseCase getHomeDetailsUseCase;
  static late final ToggleOnlineStatusUseCase toggleOnlineStatusUseCase;
  static late final SyncLocationUseCase syncLocationUseCase;
  static late final UpdateDeviceTokenUseCase updateDeviceTokenUseCase;
  static late final GetPartnerProfileUseCase getPartnerProfileUseCase;
  static late final GetViewProfileUseCase getViewProfileUseCase;
  static late final GetEarningsUseCase getEarningsUseCase;
  static late final GetBankAccountsUseCase getBankAccountsUseCase;
  static late final RequestWithdrawalUseCase requestWithdrawalUseCase;
  static late final GetTransactionDetailsUseCase getTransactionDetailsUseCase;
  static late final GetJobsListUseCase getJobsListUseCase;
  static late final GetWebViewConfigUseCase getWebViewConfigUseCase;
  static late final GetCompletedJobDetailsUseCase getCompletedJobDetailsUseCase;

  // Job Overview dependencies
  static late final JobOverviewRepository jobOverviewRepository;
  static late final AcceptJobUseCase acceptJobUseCase;
  static late final RejectJobUseCase rejectJobUseCase;

  // Customer Details dependencies
  static late final CustomerDetailsRepository customerDetailsRepository;
  static late final StartRideUseCase startRideUseCase;
  static late final ReachLocationUseCase reachLocationUseCase;
  static late final SyncLiveLocationUseCase syncLiveLocationUseCase;

  // Job Progress dependencies
  static late final JobProgressRepository jobProgressRepository;
  static late final UploadWorkImageUseCase uploadWorkImageUseCase;
  static late final CancelJobUseCase cancelJobUseCase;
  static late final CompleteJobUseCase completeJobUseCase;

  // Work Status Success dependencies
  static late final WorkStatusSuccessRepository workStatusSuccessRepository;
  static late final GetWorkStatusSuccessDetailsUseCase getWorkStatusSuccessDetailsUseCase;


  // Upload Documents / KYC dependencies
  static late final DocumentRepository documentRepository;
  static late final UploadDocumentUseCase uploadDocumentUseCase;
  static late final SubmitDocumentsUseCase submitDocumentsUseCase;

  // Notifications dependencies
  static late final NotificationRepository notificationRepository;
  static late final GetNotificationsUseCase getNotificationsUseCase;
  static late final GetJobRequestDetailsUseCase getJobRequestDetailsUseCase;

  static bool _initialized = false;

  /// Initializes all core infrastructure singletons.
  /// Must be called before `runApp()`.
  static Future<void> init() async {
    if (_initialized) return;

    // 1. Initialize persistent storage / tokens
    await TokenStorage.init();
    userProvider = UserProvider();

    // 2. Initialize networking clients
    apiClient = ApiClient();
    apiService = ApiService(apiClient);

    // Phase 1 Initializations
    final splashRemoteDataSource = SplashRemoteDataSourceImpl(apiService);
    final splashRepository = SplashRepositoryImpl(splashRemoteDataSource);
    checkPartnerStatusUseCase = CheckPartnerStatusUseCase(splashRepository);

    final welcomeLocalDataSource = WelcomeLocalDataSourceImpl();
    final welcomeRepository = WelcomeRepositoryImpl(welcomeLocalDataSource);
    getWelcomeContentUseCase = GetWelcomeContentUseCase(welcomeRepository);

    final loginRemoteDataSource = LoginRemoteDataSourceImpl(apiService);
    final loginRepository = LoginRepositoryImpl(loginRemoteDataSource);
    sendLoginOtpUseCase = SendLoginOtpUseCase(loginRepository);

    final otpVerificationRemoteDataSource = OtpVerificationRemoteDataSourceImpl(apiService);
    final otpVerificationRepository = OtpVerificationRepositoryImpl(otpVerificationRemoteDataSource);
    verifyOtpUseCase = VerifyOtpUseCase(otpVerificationRepository);
    resendOtpUseCase = ResendOtpUseCase(otpVerificationRepository);

    final verifiedLocalDataSource = VerifiedLocalDataSourceImpl();
    final verifiedRepository = VerifiedRepositoryImpl(verifiedLocalDataSource);
    getVerifiedDestinationUseCase = GetVerifiedDestinationUseCase(verifiedRepository);

    final personalInformationRemoteDataSource = PersonalInformationRemoteDataSourceImpl(apiService);
    final personalInformationRepository = PersonalInformationRepositoryImpl(personalInformationRemoteDataSource);
    savePersonalInfoUseCase = SavePersonalInfoUseCase(personalInformationRepository);

    final placesRemoteDataSource = PlacesRemoteDataSourceImpl();
    final placesRepository = PlacesRepositoryImpl(placesRemoteDataSource);
    searchPlacesUseCase = SearchPlacesUseCase(placesRepository);
    getPlaceDetailsUseCase = GetPlaceDetailsUseCase(placesRepository);

    final selectServiceRemoteDataSource = SelectServiceRemoteDataSourceImpl(apiService);
    final selectServiceRepository = SelectServiceRepositoryImpl(selectServiceRemoteDataSource);
    getServiceModulesUseCase = GetServiceModulesUseCase(selectServiceRepository);
    getServiceRegistrationFeesUseCase = GetServiceRegistrationFeesUseCase(selectServiceRepository);

    final selectCategoriesRemoteDataSource = SelectCategoriesRemoteDataSourceImpl(apiService);
    final selectCategoriesRepository = SelectCategoriesRepositoryImpl(selectCategoriesRemoteDataSource);
    getCategoriesUseCase = GetCategoriesUseCase(selectCategoriesRepository);
    getSubcategoriesUseCase = GetSubcategoriesUseCase(selectCategoriesRepository);
    getServiceTypesUseCase = GetServiceTypesUseCase(selectCategoriesRepository);
    getServicesUseCase = GetServicesUseCase(selectCategoriesRepository);
    getPersonalCareServicesUseCase = GetPersonalCareServicesUseCase(selectCategoriesRepository);

    final driverSetupRemoteDataSource = DriverSetupRemoteDataSourceImpl(apiService);
    final driverSetupRepository = DriverSetupRepositoryImpl(driverSetupRemoteDataSource);
    driverSetupOptionsUseCase = GetDriverSetupOptionsUseCase(driverSetupRepository);

    final panditSetupRemoteDataSource = PanditSetupRemoteDataSourceImpl(apiService);
    final panditSetupRepository = PanditSetupRepositoryImpl(panditSetupRemoteDataSource);
    getPanditCategoriesUseCase = GetPanditCategoriesUseCase(panditSetupRepository);
    getPanditServicesUseCase = GetPanditServicesUseCase(panditSetupRepository);

    final medicalSetupRemoteDataSource = MedicalSetupRemoteDataSourceImpl(apiService);
    final medicalSetupRepository = MedicalSetupRepositoryImpl(medicalSetupRemoteDataSource);
    getMedicalCategoriesUseCase = GetMedicalCategoriesUseCase(medicalSetupRepository);
    getMedicalServicesUseCase = GetMedicalServicesUseCase(medicalSetupRepository);

    final bankDetailsRemoteDataSource = BankDetailsRemoteDataSourceImpl(apiService);
    final bankDetailsRepository = BankDetailsRepositoryImpl(bankDetailsRemoteDataSource);
    addBankDetailsUseCase = AddBankAccountUseCase(bankDetailsRepository);

    final activationFeeRemoteDataSource = ActivationFeeRemoteDataSourceImpl(apiService);
    final activationFeeRepository = ActivationFeeRepositoryImpl(activationFeeRemoteDataSource);
    saveActivationTransactionUseCase = SaveActivationTransactionUseCase(activationFeeRepository);

    final paymentSuccessRemoteDataSource = PaymentSuccessRemoteDataSourceImpl(apiService);
    final paymentSuccessRepository = PaymentSuccessRepositoryImpl(paymentSuccessRemoteDataSource);
    syncPostPaymentUseCase = SyncPostPaymentUseCase(paymentSuccessRepository);

    final paymentFailedLocalDataSource = PaymentFailedLocalDataSourceImpl();
    final paymentFailedRepository = PaymentFailedRepositoryImpl(localDataSource: paymentFailedLocalDataSource);
    getPaymentFailureDetailsUseCase = GetPaymentFailureDetailsUseCase(repository: paymentFailedRepository);

    // 3. Initialize Auth feature

    // 4. Initialize Home & Dashboard features
    final homeRemoteDataSource = HomeRemoteDataSourceImpl(apiService);
    homeRepository = HomeRepositoryImpl(homeRemoteDataSource);
    getHomeDetailsUseCase = GetHomeDetailsUseCase(homeRepository);
    toggleOnlineStatusUseCase = ToggleOnlineStatusUseCase(homeRepository);
    syncLocationUseCase = SyncLocationUseCase(homeRepository);
    updateDeviceTokenUseCase = UpdateDeviceTokenUseCase(homeRepository);

    final profileRemoteDataSource = ProfileRemoteDataSourceImpl(apiService);
    final profileRepository = ProfileRepositoryImpl(profileRemoteDataSource);
    getPartnerProfileUseCase = GetPartnerProfileUseCase(profileRepository);

    final viewProfileRemoteDataSource = ViewProfileRemoteDataSourceImpl(apiService);
    final viewProfileRepository = ViewProfileRepositoryImpl(viewProfileRemoteDataSource);
    getViewProfileUseCase = GetViewProfileUseCase(viewProfileRepository);

    final earningsRemoteDataSource = EarningsRemoteDataSourceImpl(apiService);
    final earningsRepository = EarningsRepositoryImpl(earningsRemoteDataSource);
    getEarningsUseCase = GetEarningsUseCase(earningsRepository);

    final withdrawRemoteDataSource = WithdrawRemoteDataSourceImpl(apiService);
    final withdrawRepository = WithdrawRepositoryImpl(withdrawRemoteDataSource);
    getBankAccountsUseCase = GetBankAccountsUseCase(withdrawRepository);
    requestWithdrawalUseCase = RequestWithdrawalUseCase(withdrawRepository);

    final transactionDetailsRemoteDataSource = TransactionDetailsRemoteDataSourceImpl(apiService);
    final transactionDetailsRepository = TransactionDetailsRepositoryImpl(transactionDetailsRemoteDataSource);
    getTransactionDetailsUseCase = GetTransactionDetailsUseCase(transactionDetailsRepository);

    final jobsListRemoteDataSource = JobsListRemoteDataSourceImpl(apiService);
    final jobsListRepository = JobsListRepositoryImpl(jobsListRemoteDataSource);
    getJobsListUseCase = GetJobsListUseCase(jobsListRepository);

    final appWebViewLocalDataSource = AppWebViewLocalDataSourceImpl();
    final appWebViewRepository = AppWebViewRepositoryImpl(appWebViewLocalDataSource);
    getWebViewConfigUseCase = GetWebViewConfigUseCase(appWebViewRepository);

    final completedJobLocalDataSource = CompletedJobLocalDataSourceImpl();
    final completedJobRepository = CompletedJobRepositoryImpl(completedJobLocalDataSource);
    getCompletedJobDetailsUseCase = GetCompletedJobDetailsUseCase(completedJobRepository);

    // 5. Initialize Job Overview
    final jobOverviewRemoteDataSource = JobOverviewRemoteDataSourceImpl(apiService);
    jobOverviewRepository = JobOverviewRepositoryImpl(jobOverviewRemoteDataSource);
    acceptJobUseCase = AcceptJobUseCase(jobOverviewRepository);
    rejectJobUseCase = RejectJobUseCase(jobOverviewRepository);

    // Initialize Customer Details
    final customerDetailsRemoteDataSource = CustomerDetailsRemoteDataSourceImpl(apiService);
    customerDetailsRepository = CustomerDetailsRepositoryImpl(customerDetailsRemoteDataSource);
    startRideUseCase = StartRideUseCase(customerDetailsRepository);
    reachLocationUseCase = ReachLocationUseCase(customerDetailsRepository);
    syncLiveLocationUseCase = SyncLiveLocationUseCase(customerDetailsRepository);

    // Initialize Job Progress
    final jobProgressRemoteDataSource = JobProgressRemoteDataSourceImpl(apiService);
    jobProgressRepository = JobProgressRepositoryImpl(jobProgressRemoteDataSource);
    uploadWorkImageUseCase = UploadWorkImageUseCase(jobProgressRepository);
    cancelJobUseCase = CancelJobUseCase(jobProgressRepository);
    completeJobUseCase = CompleteJobUseCase(jobProgressRepository);

    // Initialize Work Status Success
    final workStatusSuccessLocalDataSource = WorkStatusSuccessLocalDataSourceImpl();
    workStatusSuccessRepository = WorkStatusSuccessRepositoryImpl(workStatusSuccessLocalDataSource);
    getWorkStatusSuccessDetailsUseCase = GetWorkStatusSuccessDetailsUseCase(workStatusSuccessRepository);


    // 7. Initialize Document Upload feature
    final documentRemoteDataSource = DocumentRemoteDataSourceImpl(apiService);
    documentRepository = DocumentRepositoryImpl(documentRemoteDataSource);
    uploadDocumentUseCase = UploadDocumentUseCase(documentRepository);
    submitDocumentsUseCase = SubmitDocumentsUseCase(documentRepository);

    // 8. Initialize Notifications feature
    final notificationRemoteDataSource = NotificationRemoteDataSourceImpl(apiService);
    notificationRepository = NotificationRepositoryImpl(notificationRemoteDataSource);
    getNotificationsUseCase = GetNotificationsUseCase(notificationRepository);
    getJobRequestDetailsUseCase = GetJobRequestDetailsUseCase(notificationRepository);

    _initialized = true;
  }


  /// Factory method to create a [HomeProvider] / [HomeController] instance.
  static HomeProvider createHomeProvider() => HomeProvider(
        getHomeDetailsUseCase: getHomeDetailsUseCase,
        toggleOnlineStatusUseCase: toggleOnlineStatusUseCase,
        syncLocationUseCase: syncLocationUseCase,
        updateDeviceTokenUseCase: updateDeviceTokenUseCase,
      );
  static HomeController createHomeController() => createHomeProvider();

  /// Factory method to create a [EarningsProvider] / [EarningsController] instance.
  static EarningsProvider createEarningsProvider() => EarningsProvider(
        getEarningsUseCase: getEarningsUseCase,
      );
  static EarningsController createEarningsController() => createEarningsProvider();

  /// Factory method to create a [WithdrawProvider] / [WithdrawController] instance.
  static WithdrawProvider createWithdrawProvider() => WithdrawProvider(
        getBankAccountsUseCase: getBankAccountsUseCase,
        requestWithdrawalUseCase: requestWithdrawalUseCase,
      );
  static WithdrawController createWithdrawController() => createWithdrawProvider();

  /// Factory method to create a [TransactionDetailsProvider] / [TransactionDetailsController] instance.
  static TransactionDetailsProvider createTransactionDetailsProvider() =>
      TransactionDetailsProvider(
        getTransactionDetailsUseCase: getTransactionDetailsUseCase,
      );
  static TransactionDetailsController createTransactionDetailsController() =>
      createTransactionDetailsProvider();

  /// Factory method to create a [ProfileProvider] / [ProfileController] instance.
  static ProfileProvider createProfileProvider() => ProfileProvider(
        getPartnerProfileUseCase: getPartnerProfileUseCase,
      );
  static ProfileController createProfileController() => createProfileProvider();

  /// Factory method to create a [ViewProfileProvider] instance.
  static ViewProfileProvider createViewProfileProvider() => ViewProfileProvider(
        getViewProfileUseCase: getViewProfileUseCase,
      );

  /// Factory method to create a [JobsListProvider] instance.
  static JobsListProvider createJobsListProvider() => JobsListProvider(
        getJobsListUseCase: getJobsListUseCase,
      );

  /// Factory method to create a [AppWebViewProvider] instance.
  static AppWebViewProvider createAppWebViewProvider() => AppWebViewProvider(
        getWebViewConfigUseCase: getWebViewConfigUseCase,
      );

  /// Factory method to create a [CompletedJobProvider] instance.
  static CompletedJobProvider createCompletedJobProvider() => CompletedJobProvider(
        getCompletedJobDetailsUseCase: getCompletedJobDetailsUseCase,
      );

  /// Factory method to create a [JobOverviewProvider] / [JobOverviewController] instance.
  static JobOverviewProvider createJobOverviewProvider() =>
      JobOverviewProvider(
        acceptJobUseCase: acceptJobUseCase,
        rejectJobUseCase: rejectJobUseCase,
      );
  static JobOverviewController createJobOverviewController() =>
      createJobOverviewProvider();

  /// Factory method to create a [CustomerDetailsProvider] / [CustomerDetailsController] instance.
  static CustomerDetailsProvider createCustomerDetailsProvider() =>
      CustomerDetailsProvider(
        startRideUseCase: startRideUseCase,
        reachLocationUseCase: reachLocationUseCase,
        syncLiveLocationUseCase: syncLiveLocationUseCase,
      );
  static CustomerDetailsController createCustomerDetailsController() =>
      createCustomerDetailsProvider();

  /// Factory method to create a [JobProgressProvider] / [JobProgressController] instance.
  static JobProgressProvider createJobProgressProvider() =>
      JobProgressProvider(
        uploadWorkImageUseCase: uploadWorkImageUseCase,
        cancelJobUseCase: cancelJobUseCase,
        completeJobUseCase: completeJobUseCase,
      );
  static JobProgressController createJobProgressController() =>
      createJobProgressProvider();

  /// Factory method to create a [WorkStatusSuccessProvider] instance.
  static WorkStatusSuccessProvider createWorkStatusSuccessProvider() =>
      WorkStatusSuccessProvider(
        getWorkStatusSuccessDetailsUseCase: getWorkStatusSuccessDetailsUseCase,
      );

  /// Factory method to create an [UploadImagesController] instance.
  static UploadImagesController createUploadImagesController() =>
      UploadImagesController(
        uploadDocumentUseCase: uploadDocumentUseCase,
        submitDocumentsUseCase: submitDocumentsUseCase,
      );

  /// Factory method to create a [NotificationsProvider] / [NotificationsController] instance.
  static NotificationsProvider createNotificationsProvider() =>
      NotificationsProvider(
        getNotificationsUseCase: getNotificationsUseCase,
      );
  static NotificationsController createNotificationsController() =>
      createNotificationsProvider();

  // Phase 1 Factory Methods
  static SplashProvider createSplashProvider() =>
      SplashProvider(checkPartnerStatusUseCase: checkPartnerStatusUseCase);

  static WelcomeProvider createWelcomeProvider() =>
      WelcomeProvider(getWelcomeContentUseCase: getWelcomeContentUseCase);

  static LoginProvider createLoginProvider() =>
      LoginProvider(sendLoginOtpUseCase: sendLoginOtpUseCase);

  static OtpVerificationProvider createOtpVerificationProvider() =>
      OtpVerificationProvider(
        verifyOtpUseCase: verifyOtpUseCase,
        resendOtpUseCase: resendOtpUseCase,
        userProvider: userProvider,
      );

  static VerifiedProvider createVerifiedProvider() =>
      VerifiedProvider(getVerifiedDestinationUseCase: getVerifiedDestinationUseCase);

  static PersonalInformationProvider createPersonalInformationProvider() =>
      PersonalInformationProvider(
        savePersonalInfoUseCase: savePersonalInfoUseCase,
        userProvider: userProvider,
      );

  static PlacesAutocompleteProvider createPlacesAutocompleteProvider() =>
      PlacesAutocompleteProvider(
        searchPlacesUseCase: searchPlacesUseCase,
        getPlaceDetailsUseCase: getPlaceDetailsUseCase,
      );

  static SelectServiceProvider createSelectServiceProvider() =>
      SelectServiceProvider(
        getModulesUseCase: getServiceModulesUseCase,
        getRegistrationFeesUseCase: getServiceRegistrationFeesUseCase,
      );

  static SelectCategoriesProvider createSelectCategoriesProvider() =>
      SelectCategoriesProvider(
        getCategoriesUseCase: getCategoriesUseCase,
        getSubcategoriesUseCase: getSubcategoriesUseCase,
        getServiceTypesUseCase: getServiceTypesUseCase,
        getServicesUseCase: getServicesUseCase,
        getPersonalCareServicesUseCase: getPersonalCareServicesUseCase,
      );

  static DriverSetupProvider createDriverSetupProvider() =>
      DriverSetupProvider(
        getDriverSetupOptionsUseCase: driverSetupOptionsUseCase,
      );

  static PanditSetupProvider createPanditSetupProvider() =>
      PanditSetupProvider(
        getCategoriesUseCase: getPanditCategoriesUseCase,
        getServicesUseCase: getPanditServicesUseCase,
      );

  static MedicalSetupProvider createMedicalSetupProvider() =>
      MedicalSetupProvider(
        getCategoriesUseCase: getMedicalCategoriesUseCase,
        getServicesUseCase: getMedicalServicesUseCase,
      );

  static BankDetailsProvider createBankDetailsProvider() =>
      BankDetailsProvider(
        addBankAccountUseCase: addBankDetailsUseCase,
      );

  static ActivationFeeProvider createActivationFeeProvider() =>
      ActivationFeeProvider(
        saveTransactionUseCase: saveActivationTransactionUseCase,
      );

  static PaymentSuccessProvider createPaymentSuccessProvider() =>
      PaymentSuccessProvider(
        syncPostPaymentUseCase: syncPostPaymentUseCase,
      );

  static PaymentFailedProvider createPaymentFailedProvider() =>
      PaymentFailedProvider(
        getPaymentFailureDetailsUseCase: getPaymentFailureDetailsUseCase,
      );

  static UploadImagesController createDocumentUploadProvider() =>
      createUploadImagesController();
}
