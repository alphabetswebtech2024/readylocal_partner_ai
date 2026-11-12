// lib/core/network/api_constants.dart

// final String mainUrl = "https://e56epjdseb.execute-api.ap-south-1.amazonaws.com/";

// final String mainUrl = "https://i8kmaw2nab.execute-api.ap-south-1.amazonaws.com/"; //DEV
// final String versionNo = "Dev/";

//https://njv1idkdb8.execute-api.ap-south-1.amazonaws.com/prod/
final String mainUrl = "https://njv1idkdb8.execute-api.ap-south-1.amazonaws.com/";
final String versionNo = "prod/";

final String baseUrl = mainUrl + versionNo;

final String getListOfAPIs = baseUrl;


final String partnerOtp = '${baseUrl}partnerOTP';
final String partnerValidateOtp = '${baseUrl}partnerValidateOTP';

final String getModules = '${baseUrl}getModules';

final String sendLocationData_pat = '${baseUrl}sendLocationData';

final String startLocation_pat = '${baseUrl}startLocation_pat';

final String reachedLocation_pat = '${baseUrl}reachedLocation_pat';

final String acceptedJob = '${baseUrl}acceptedJob';

final String rejectedJob = '${baseUrl}rejectedJob';

final String uploadToS3 = '${baseUrl}uploadToS3';

final String cancelledJob = '${baseUrl}cancelledJob';

final String completedJob = '${baseUrl}completedJob';

final String saveTransaction_pat = '${baseUrl}saveTransaction_pat';

final String getCategories = '${baseUrl}getCategories';

// final String getSubCategories = baseUrl + 'getSubCategories';
final String getSubCategories = '${baseUrl}getSubCategoriesNew';

// final String getServiceTypes = baseUrl + 'getServiceTypes';
final String getServiceTypes = '${baseUrl}getServiceTypesNew';

final String getServices = '${baseUrl}getServicesNew';

final String getRequestDetails = '${baseUrl}getRequestDetails_pat';

final String getVehicleTypesAPI = '${baseUrl}getVehicleTypes';

final String getSafetySkillsAPI = '${baseUrl}getSafetySkills';

final String getDriverServiceTypes = '${baseUrl}getDriverServiceTypes';

final String getDriverLicenseTypes = '${baseUrl}getDriverLicenseTypes';

final String withdrawRequest = '${baseUrl}withdrawRequest';
final String partnerOnOrOff = '${baseUrl}partnerOnOrOff';
final String getEarningDetails = '${baseUrl}getEarningDetails';
final String updateDeviceToken = '${baseUrl}updateDeviceToken';
final String getPartnerDetails = '${baseUrl}getPartnerDetails';
final String getPurohitServices = '${baseUrl}getPurohitServices';
final String getEarningsSummary = '${baseUrl}getEarningsSummary';
final String getTransactionDetails = '${baseUrl}getTransactionDetails';
final String addBankAccount = '${baseUrl}addBankAccount';
final String listBankAccounts = '${baseUrl}listBankAccounts';
final String getPersonalCareServices = '${baseUrl}getPersonalCareServices';
final String sendLocationData = '${baseUrl}sendLocationData';
final String getRegistrationFeesURL = '${baseUrl}getRegistrationFees';
final String getRegistrationFees = getRegistrationFeesURL;
final String saveTransaction = saveTransaction_pat;
final String addBankDetail = addBankAccount;
final String getDriverSetupOptions = getDriverServiceTypes;
final String getServiceType = getServiceTypes;


class ApiConstants {
  // Base already in ApiClient
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // User
  static const String getModules = '/getModules';
  static const String updateProfile = '/user/update';

  // Example
  static const String getItems = '/items';
  static const String createItem = '/items/create';

  static const String partnerOtp = '/partnerOTP';
  static const String partnerValidateOtp = '/partnerValidateOTP';

}