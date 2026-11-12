// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ReadyLocal Partner';

  @override
  String get commonViewAll => 'View All';

  @override
  String get commonMoreDetails => 'More Details';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonNext => 'Next';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get commonSave => 'Save';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonOk => 'OK';

  @override
  String get commonPleaseWait => 'Please wait...';

  @override
  String get commonSomethingWentWrong =>
      'Something went wrong. Please try again.';

  @override
  String get commonNoInternet =>
      'No internet connection. Please check your network.';

  @override
  String get statusOnline => 'Online';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusOngoing => 'Ongoing';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get periodDaily => 'Daily';

  @override
  String get periodWeekly => 'Weekly';

  @override
  String get periodMonthly => 'Monthly';

  @override
  String homeWelcomeName(String name) {
    return 'Welcome $name';
  }

  @override
  String get homeWelcomeBack => 'Welcome back';

  @override
  String get homeLocationFallback => 'Location';

  @override
  String get homeTotalRequest => 'Total Request';

  @override
  String get homeEarnings => 'Earnings';

  @override
  String get homeJobs => 'Jobs';

  @override
  String get homeTodaysEarning => 'Today\'s Earning';

  @override
  String get homeWeeklyEarning => 'Weekly Earning';

  @override
  String get homeMonthlyEarning => 'Monthly Earning';

  @override
  String homeJobsToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jobs today',
      one: '1 job today',
    );
    return '$_temp0';
  }

  @override
  String homeJobsThisWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jobs this week',
      one: '1 job this week',
    );
    return '$_temp0';
  }

  @override
  String homeJobsThisMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jobs this month',
      one: '1 job this month',
    );
    return '$_temp0';
  }

  @override
  String get homeNoOngoingJobs => 'No ongoing jobs';

  @override
  String get homeNoOngoingJobsHint =>
      'Stay online to receive new job requests.';

  @override
  String get homeNoCompletedJobs => 'No completed jobs';

  @override
  String get homeSessionErrorTitle => 'Session Error';

  @override
  String get homeSessionErrorMessage => 'Something went wrong, please login.';

  @override
  String get homeYouAreOnline => 'You are online now.';

  @override
  String get homeYouAreOffline => 'You are offline now.';

  @override
  String get homeJobDetailsFailed => 'Failed to load job details.';

  @override
  String get homeOpenProfile => 'Open profile';

  @override
  String get homeOnlineToggleHint => 'Go online or offline';

  @override
  String get loginTitle => 'Register';

  @override
  String get loginHeading => 'Be a part of ReadyLocal Partner';

  @override
  String get loginSubheading =>
      'Make your first move to improve your business.';

  @override
  String get loginPhoneLabel => 'Phone Number';

  @override
  String get loginPhoneRequired => 'Phone number is required';

  @override
  String get loginPhoneDigitsOnly => 'Phone number must contain only digits';

  @override
  String get loginPhoneInvalidIndia =>
      'Enter a valid 10-digit Indian mobile number';

  @override
  String get loginPhoneStartDigit =>
      'Indian numbers must start with 6, 7, 8, or 9';

  @override
  String get loginPhoneInvalid => 'Enter a valid phone number (7–15 digits)';

  @override
  String get loginFailed => 'Failed';

  @override
  String get loginSelectCountryCode => 'Select Country Code';

  @override
  String get loginCountryIndia => 'India';

  @override
  String get loginAgreePrefix => 'By continuing you agree to our ';

  @override
  String get loginTerms => 'T&C';

  @override
  String get loginAnd => ' and ';

  @override
  String get loginPrivacy => 'Privacy policy';

  @override
  String get loginAgreeSuffix => '';

  @override
  String get loginBecomePartner => 'Become a Partner';

  @override
  String get webTermsTitle => 'Terms & Conditions';

  @override
  String get webPrivacyTitle => 'Privacy Policy';

  @override
  String get webAboutTitle => 'About Us';

  @override
  String get earningsTitle => 'Earnings';

  @override
  String get earningsOverview => 'Earnings Overview';

  @override
  String get earningsAvailableBalance => 'Available Balance';

  @override
  String get earningsSendWithdraw => 'Send withdraw request';

  @override
  String get earningsBankTransaction => 'Bank Transaction';

  @override
  String get earningsNoTransactions => 'No transactions found.';

  @override
  String get commonBack => 'Back';

  @override
  String get earningsBankTransactionItem => 'Bank Transaction';

  @override
  String get jobNotificationTitle => 'Job Notification';

  @override
  String get jobServiceRequest => 'Service Request';

  @override
  String get jobCustomer => 'Customer';

  @override
  String jobDistanceKm(String distance) {
    return '$distance Km';
  }

  @override
  String get jobAccept => 'Accept';

  @override
  String get jobReject => 'Reject';

  @override
  String get jobDetails => 'Details';

  @override
  String get jobAcceptTitle => 'Accept Job';

  @override
  String get jobAcceptMessage => 'Are you sure you want to accept this job?';

  @override
  String get jobRejectTitle => 'Reject Job';

  @override
  String get jobRejectMessage => 'Are you sure you want to reject this job?';

  @override
  String get jobWait => 'Wait...';

  @override
  String get jobRejectionReason => 'Rejection Reason';

  @override
  String get jobRejectionHint =>
      'Please tell us why you are rejecting this job...';

  @override
  String get jobSubmitting => 'Submitting...';

  @override
  String get commonClose => 'Close';

  @override
  String get jobTimeLeft => 'Time left to respond';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileViewProfile => 'View Profile';

  @override
  String get profileAbout => 'About ReadyLocal Partner';

  @override
  String get profileTerms => 'Terms & Conditions';

  @override
  String get profilePrivacy => 'Privacy and Policy';

  @override
  String get profileLogout => 'Logout';

  @override
  String get profileLogoutConfirm => 'Are you sure you want to logout?';

  @override
  String get profileDeleteAccount => 'Delete Account';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileChooseLanguage => 'Choose language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTelugu => 'తెలుగు';

  @override
  String get jobsAllJobs => 'All Jobs';

  @override
  String get otpEnterComplete => 'Enter complete OTP';

  @override
  String get otpInvalid => 'Invalid OTP. Please try again.';

  @override
  String get otpResent => 'OTP resent successfully';

  @override
  String get otpResendFailed => 'Failed to resend OTP';

  @override
  String get otpVerify => 'Verify';

  @override
  String get otpHeading => 'To be a part of ReadyLocal Partner verify number';

  @override
  String get otpSentTo => 'We have sent you the verification code to';

  @override
  String get otpEdit => 'Edit';

  @override
  String get otpResend => 'Resend OTP';

  @override
  String get selectServiceRequired => 'Please select a service to continue.';

  @override
  String get selectServiceTitle => 'Select Your Service';

  @override
  String get verifiedTitle => 'Verified';

  @override
  String get welcomeReadOur => 'Make Sure Read our ';

  @override
  String get welcomeAnd => ' And ';

  @override
  String get welcomeReadSuffix => '';

  @override
  String get welcomeRegister => 'Register';

  @override
  String get welcomeLogin => 'Login';

  @override
  String get jobSummary => 'Job Summary';

  @override
  String get labelOrderId => 'Order ID';

  @override
  String get labelScheduledOn => 'Scheduled on';

  @override
  String get labelDistanceTraveled => 'Distance Traveled';

  @override
  String get customerDetailsTitle => 'Customer Details';

  @override
  String get labelName => 'Name';

  @override
  String get labelPhone => 'Phone';

  @override
  String get labelLocation => 'Location';

  @override
  String get labelEmail => 'Email ID';

  @override
  String get paymentSummary => 'Payment Summary';

  @override
  String get paymentServiceTotal => 'Service Total';

  @override
  String get paymentAmountCollected => 'Amount Collected';

  @override
  String get mapStartLocation => 'Start Location';

  @override
  String get mapDestination => 'Destination';

  @override
  String get rideStartedSuccess => 'Ride Started Successfully!';

  @override
  String get reachedRecorded => 'Reached Location Recorded!';

  @override
  String get statusUpdateFailed => 'Failed to update status';

  @override
  String get labelServiceBookedDate => 'Service Booked Date';

  @override
  String get labelServiceBookedTime => 'Service Booked Time';

  @override
  String get getDirection => 'Get Direction';

  @override
  String get mapLabel => 'Map';

  @override
  String get callLabel => 'Call';

  @override
  String get startRide => 'Start Ride';

  @override
  String get reachedLocation => 'Reached Location';

  @override
  String get processing => 'Processing...';

  @override
  String get jobExpired => 'This job request has expired.';

  @override
  String get warningTitle => 'Warning';

  @override
  String get jobAcceptedSuccess => 'Job accepted successfully!';

  @override
  String get jobAcceptFailed => 'Failed to accept job';

  @override
  String get jobRejectReasonTitle => 'Submit the reason of rejecting the job';

  @override
  String get jobRejectReasonHint =>
      'Write the reason behind the rejecting the job';

  @override
  String get enterReason => 'Please enter a reason.';

  @override
  String get jobRejected => 'Job rejected.';

  @override
  String get jobRejectFailed => 'Failed to reject job.';

  @override
  String get overviewTitle => 'Overview';

  @override
  String get instantLabel => 'Instant';

  @override
  String get aboutService => 'About Service';

  @override
  String get serviceBookedBy => 'Service Booked by';

  @override
  String get uploadAtLeastOne =>
      'Please upload at least one image of the work.';

  @override
  String get waitForUploads =>
      'Please wait for all images to finish uploading.';

  @override
  String get someUploadsFailed =>
      'Some images failed to upload. Please remove or retry them.';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get selectAvailability => 'Please select customer availability.';

  @override
  String get enterFeedback => 'Please enter feedback/reason before submitting.';

  @override
  String get closeJob => 'Close Job';

  @override
  String get closeJobConfirm => 'Are you sure you want to close this job?';

  @override
  String get cancelJobFailed => 'Failed to cancel job. Please try again.';

  @override
  String get completeJobFailed => 'Failed to complete job. Please try again.';

  @override
  String get partnerFallback => 'Partner';

  @override
  String get jobProgressTitle => 'Job Progress';

  @override
  String get startJob => 'Start Job';

  @override
  String get fillDetailsBeforeWork =>
      'Fill the details before starting your work';

  @override
  String get customerAvailable => 'Customer is available?';

  @override
  String get selectHint => 'Select';

  @override
  String get selfieTitle => 'Click Selfie with Product';

  @override
  String get selfieSubtitle =>
      'Upload Selfie with the product once you reach to customers place.';

  @override
  String get beforeRepairTitle => 'Click before repair product Image.';

  @override
  String get beforeRepairSubtitle => 'Upload before repair product image.';

  @override
  String get afterRepairTitle => 'Click After repair product Image.';

  @override
  String get afterRepairSubtitle => 'Upload after repair product image.';

  @override
  String get feedbackReason => 'Feedback / Reason';

  @override
  String get feedbackHint => 'Write the feedback of the product repair';

  @override
  String get closeReasonHint => 'Write the reason why the job is being closed';

  @override
  String get workDone => 'Work Done';

  @override
  String get addMore => 'Add More';

  @override
  String get noAddressProvided => 'No address provided';

  @override
  String get enterReasonBeforeSubmit =>
      'Please enter a reason before submitting.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get jobCancelledTitle => 'Job Cancelled';

  @override
  String get jobCancelledMessage =>
      'This job request was cancelled by the customer or has expired.';

  @override
  String get networkError => 'Network error. Please try again.';

  @override
  String get enterRejectionReason => 'Please enter a rejection reason';

  @override
  String get loadingJobDetails => 'Loading job details...';

  @override
  String get newNotification => 'New Notification';

  @override
  String get earlierLabel => 'Earlier';

  @override
  String get workStatusReceived => 'We have received your work Status';

  @override
  String get backToHome => 'Back to home';

  @override
  String thankYouName(String name) {
    return 'Thank you $name';
  }

  @override
  String get feeUpdateFailed => 'Failed to update profile details.';

  @override
  String feeUnexpectedError(String error) {
    return 'An unexpected error occurred: $error';
  }

  @override
  String get feeTitle => 'Partner Activation Fee';

  @override
  String get feeDescription =>
      'To be a part of this there will be the one time registration need to be paid';

  @override
  String get feePayNow => 'Pay Now';

  @override
  String get bankAddedSuccess => 'Bank account added successfully';

  @override
  String get bankAddFailed => 'Failed to add bank details';

  @override
  String get bankAddTitle => 'Add Bank Details';

  @override
  String get bankName => 'Bank Name';

  @override
  String get bankNameHint => 'Enter Bank Name';

  @override
  String get bankNameRequired => 'Bank name is required';

  @override
  String get bankAccountNumber => 'Account Number';

  @override
  String get bankAccountNumberHint => 'Enter Account Number';

  @override
  String get bankAccountNumberRequired => 'Account number is required';

  @override
  String get bankAccountNumberInvalid =>
      'Enter a valid account number (9-18 digits)';

  @override
  String get bankHolderName => 'Account Holder Name';

  @override
  String get bankHolderNameHint => 'Enter Account Holder Name';

  @override
  String get bankHolderNameRequired => 'Account holder name is required';

  @override
  String get bankIfsc => 'IFSC Code';

  @override
  String get bankIfscHint => 'Enter IFSC Code';

  @override
  String get bankIfscRequired => 'IFSC code is required';

  @override
  String get bankIfscLabel => 'IFSC Code';

  @override
  String get paymentRequestAccepted => 'Request Accepted';

  @override
  String get paymentReceived => 'We have received your payment';

  @override
  String get paymentTeamWillContact =>
      '\nOur team will get back to you with-in 24-48 Hrs';

  @override
  String get paymentExploreApp => 'Explore App';

  @override
  String get genderSelect => 'Select Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get optionalSuffix => ' (Optional)';

  @override
  String get personalInfoTitle => 'Personal Information';

  @override
  String get personalInfoSubtitle => 'Add your personal Information';

  @override
  String get firstName => 'First Name';

  @override
  String get firstNameHint => 'Enter Your First Name';

  @override
  String get firstNameRequired => 'First name is required';

  @override
  String get lastName => 'Last Name';

  @override
  String get lastNameHint => 'Enter Your Last Name';

  @override
  String get lastNameRequired => 'Last name is required';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'Enter Your email ID';

  @override
  String get emailInvalid => 'Enter a valid email address';

  @override
  String get genderLabel => 'Gender';

  @override
  String get genderHint => 'Select Your Gender';

  @override
  String get genderRequired => 'Please select gender';

  @override
  String get addressLabel => 'Address';

  @override
  String get addressSearchHint => 'Search for Area/Street/Locality';

  @override
  String get addressRequired => 'Address is required';

  @override
  String get houseLabel => 'Area/House/Flat No.';

  @override
  String get houseHint => 'Enter your House/Flat/Apartment No.';

  @override
  String get cityLabel => 'City';

  @override
  String get cityHint => 'Enter Your City';

  @override
  String get cityRequired => 'City is required';

  @override
  String get stateLabel => 'State';

  @override
  String get stateHint => 'Enter Your State';

  @override
  String get stateRequired => 'State is required';

  @override
  String get pinLabel => 'Pin code';

  @override
  String get pinHint => 'Enter your Pin code';

  @override
  String get pinRequired => 'Pin code is required';

  @override
  String get pinInvalid => 'Enter a valid 6-digit pin code';

  @override
  String get txnDetailsTitle => 'Transaction Details';

  @override
  String get txnId => 'Transaction ID';

  @override
  String get txnIdCopied => 'Transaction ID copied!';

  @override
  String get txnPaidThrough => 'Paid Through';

  @override
  String get txnAmount => 'Amount';

  @override
  String get txnTax => 'Tax';

  @override
  String get txnTotalAmount => 'Total Amount';

  @override
  String get txnBankAccount => 'Bank Account';

  @override
  String get txnLoadFailed => 'Failed to load transaction details.';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get withdrawNoBankSelected => 'No bank account selected.';

  @override
  String get withdrawInvalidAmount => 'Please enter a valid amount.';

  @override
  String get withdrawExceedsBalance => 'Amount exceeds available balance.';

  @override
  String get withdrawNoBank => 'No bank account found.';

  @override
  String get withdrawSuccess => 'Withdrawal request successful!';

  @override
  String get withdrawTitle => 'Withdraw';

  @override
  String get withdrawEnterAmount => 'Enter Amount to withdraw';

  @override
  String get withdrawAddAnotherBank => 'Add Another Bank Details';

  @override
  String get withdrawSendRequest => 'Send Request';

  @override
  String get setupSelectAtLeastOneCategory =>
      'Please select at least one category.';

  @override
  String get setupSelectAtLeastOneService =>
      'Please select at least one service.';

  @override
  String get setupSelectExperience => 'Please select years of experience.';

  @override
  String get setupSelectCategories => 'Select Categories';

  @override
  String get setupSelectCategory => 'Select Category';

  @override
  String get setupNoCategories => 'No categories available';

  @override
  String get setupDone => 'Done';

  @override
  String get setupSelectService => 'Select Service';

  @override
  String get setupSelectServiceType => 'Select Service Type';

  @override
  String get setupSelectServices => 'Select Services';

  @override
  String get setupErrorFetching => 'Error fetching data';

  @override
  String get setupNoItems => 'No items available';

  @override
  String get setupNoData => 'No data available';

  @override
  String get setupSelectYears => 'Select Years';

  @override
  String setupCategoriesSelected(int count) {
    return '$count Categories Selected';
  }

  @override
  String setupServicesSelected(int count) {
    return '$count Services Selected';
  }

  @override
  String setupSubCategoriesSelected(int count) {
    return '$count Sub Categories Selected';
  }

  @override
  String get setupAddCategoriesTitle => 'Add Categories & Sub Categories';

  @override
  String get setupAddCategoriesSubtitle =>
      'As per the next step to be a ReadyLocal Partner Please Add Categories & Sub Categories.';

  @override
  String get setupAddCategoriesServicesTitle =>
      'Add Categories & Select Services';

  @override
  String get setupAddCategoriesServicesSubtitle =>
      'As per the next step to be a ReadyLocal Partner Please Add Categories & Services.';

  @override
  String get setupCategories => 'Categories';

  @override
  String get setupServices => 'Services';

  @override
  String get setupService => 'Service';

  @override
  String get setupServiceType => 'Service Type';

  @override
  String get setupSubCategories => 'Sub Categories';

  @override
  String get setupSelectSubCategories => 'Select Sub Categories';

  @override
  String get setupSelectedSubCategories => 'Selected Sub Categories';

  @override
  String get setupYearOfExperience => 'Year of experience';

  @override
  String get setupNoVariants => 'No variants selected';

  @override
  String get setupSelectCategoryError => 'Please select a category.';

  @override
  String get setupSelectSubCategoryAtLeastOne =>
      'Please select at least one sub category.';

  @override
  String get setupSelectSubCategory => 'Please select a sub category.';

  @override
  String get setupSelectServiceError => 'Please select a service.';

  @override
  String get setupServiceDurationRates => 'Service Duration & Rates';

  @override
  String get setupServiceRateRequired => 'Service rate required.';

  @override
  String setupEnterRateFor(String name) {
    return 'Enter Rate for $name';
  }

  @override
  String get setupEnterHourRate => 'Enter Per Hour Rate';

  @override
  String get setupEnterDayRate => 'Enter Per Day Rate';

  @override
  String get setupEnter24Rate => 'Enter 24 Hours Rate';

  @override
  String get setupEnterValidAmount => 'Please enter a valid amount';

  @override
  String get setupInvalidInput => 'Invalid Input';

  @override
  String get setupConfirm => 'Confirm';

  @override
  String get driverFetchingLocation => 'Fetching location...';

  @override
  String get driverLocationDenied => 'Location permission denied';

  @override
  String get driverLocationDeniedForever =>
      'Location permissions permanently denied';

  @override
  String get driverLocationDetected => 'Current Location Detected';

  @override
  String get driverLocationFailed => 'Unable to fetch location';

  @override
  String driverSetRateFor(String name) {
    return 'Set Rate for $name';
  }

  @override
  String driverEnterRate(String unit) {
    return 'Enter rate ($unit):';
  }

  @override
  String get driverSaveRate => 'Save Rate';

  @override
  String get driverSelectServiceType =>
      'Please select at least one service type.';

  @override
  String get driverSelectExperience => 'Please select your experience.';

  @override
  String get driverSelectLicense => 'Please select your license type.';

  @override
  String get driverSelectLanguage => 'Please select at least one language.';

  @override
  String get driverSelectVehicle => 'Please select at least one vehicle type.';

  @override
  String get driverSaveFailed => 'Failed to save profile';

  @override
  String get driverDetailsTitle => 'Driver Details';

  @override
  String get driverSelectServiceTypes => 'Select Service Types';

  @override
  String get driverExperience => 'Experience';

  @override
  String get driverLicenseType => 'License Type';

  @override
  String get driverLanguages => 'Language(s)';

  @override
  String get driverPreferredLocation => 'Preferred Location for Work';

  @override
  String get driverVehicleTypes => 'Types of Vehicles';

  @override
  String get driverSafetySkills => 'Safety / Special Skills';

  @override
  String get driverSelectExperienceHint => 'Select Experience';

  @override
  String get driverSelectLicenseHint => 'Select License Type';

  @override
  String get driverSaveDetails => 'Save Details';

  @override
  String get docProfilePicture => 'Profile Picture';

  @override
  String get docProfilePictureSub => 'Upload a clear profile photo';

  @override
  String get docAadhaarFront => 'Upload Aadhaar Card Front';

  @override
  String get docAadhaarBack => 'Upload Aadhaar Card Back';

  @override
  String get docPan => 'Upload Pan Card';

  @override
  String get docAddressProof => 'Address Proof (Bill/Rental)';

  @override
  String get docAddressProofSub => 'Upload Bill/Rental agreement';

  @override
  String get docToolPhotos => 'Tool Photos';

  @override
  String get docDrivingLicense => 'Upload Driving License';

  @override
  String get docDrivingLicenseSub => 'Required for Driver Verification';

  @override
  String get docQualification => 'Upload Qualification Certificate';

  @override
  String get docQualificationSub => 'Required for Medical Verification';

  @override
  String get docExperience => 'Upload Experience Certificate';

  @override
  String get docExperienceSub => 'Required for Verification';

  @override
  String get docQualificationLabel => 'Qualification';

  @override
  String get docAvailabilityLabel => 'Availability';

  @override
  String docUploadFailedFor(String name) {
    return 'Upload failed for: $name. Please try again.';
  }

  @override
  String get docCameraDisabled =>
      'Camera permission is disabled. Enable it in Settings to take a photo.';

  @override
  String get docCameraRequired =>
      'Camera permission is required to capture photos.';

  @override
  String get docCameraFailed => 'Could not open the camera. Please try again.';

  @override
  String get docGalleryFailed =>
      'Could not open the photo gallery. Please try again.';

  @override
  String get docUploadsInProgress =>
      'Please wait, uploads are still in progress...';

  @override
  String docPleaseUpload(String name) {
    return 'Please upload: $name';
  }

  @override
  String docReuploadFailed(String name) {
    return 'Upload failed for: $name. Please re-upload.';
  }

  @override
  String get docUploadImage => 'Upload Image';

  @override
  String get docChooseOption => 'Choose an option to upload the image';

  @override
  String get docCamera => 'Camera';

  @override
  String get docTakePhotoNow => 'Take a photo now';

  @override
  String get docGallery => 'Gallery';

  @override
  String get docChooseLibrary => 'Choose from photo library';

  @override
  String get docDocumentation => 'Documentation';

  @override
  String get docUploadDocuments => 'Upload Documents';

  @override
  String get docUploadDocumentsSub =>
      'As a part of process partners need to upload required Documents';

  @override
  String get docOptional => 'Optional';

  @override
  String get docTapAddPhoto => 'Tap to add photo';

  @override
  String get docTapUploadFile => 'Tap to upload file';

  @override
  String get docUploadFailed => 'Upload failed';

  @override
  String get docUploadFailedRetry => 'Upload failed — tap to retry';

  @override
  String get docUploaded => '✓ Uploaded';

  @override
  String get imgEmpty => 'The selected image is empty. Please take it again.';

  @override
  String get imgTooLarge =>
      'This image is too large. Please use an image smaller than 10 MB.';

  @override
  String get imgUnavailable =>
      'The selected image is no longer available. Please choose it again.';

  @override
  String get imgServerFailed => 'The server could not upload this image.';

  @override
  String get imgInvalidResponse =>
      'The server returned an invalid upload response.';

  @override
  String get imgTimeout =>
      'The upload timed out. Please check your connection and retry.';

  @override
  String get imgOffline =>
      'No network connection. Please try again when you are online.';

  @override
  String get imgUploadFailed =>
      'Unable to upload this image. Please try again.';

  @override
  String get snackError => 'Error';

  @override
  String get snackSuccess => 'Success';

  @override
  String get snackNotice => 'Notice';

  @override
  String get placesServicesDisabled => 'Location services are disabled.';

  @override
  String get placesPermissionDenied => 'Location permissions are denied.';

  @override
  String get placesPermissionDeniedForever =>
      'Location permissions are permanently denied.';

  @override
  String get placesCurrentFailed => 'Failed to get current location.';

  @override
  String get placesCurrentLocation => 'Current Location';

  @override
  String get placesAddAddress => 'Add Address';

  @override
  String get placesAddYourAddress => 'Add Your Address';

  @override
  String get placesSearchHint => 'Search for your location';

  @override
  String get netTimeout => 'Connection timed out. Please check your internet.';

  @override
  String get netNoInternet => 'No internet connection. Please try again.';

  @override
  String get netCancelled => 'Request was cancelled.';

  @override
  String get netUnexpected => 'Unexpected error occurred.';

  @override
  String get net400 => 'Bad request. Please check your input.';

  @override
  String get net401 => 'Unauthorised. Please log in again.';

  @override
  String get net403 => 'Access denied.';

  @override
  String get net404 => 'Resource not found.';

  @override
  String get net422 => 'Validation failed. Please check your input.';

  @override
  String get net429 => 'Too many requests. Please slow down.';

  @override
  String get net500 => 'Server error. Please try again later.';

  @override
  String get net503 => 'Service unavailable. Please try later.';

  @override
  String netCode(int code) {
    return 'Something went wrong (code $code).';
  }

  @override
  String get offlineBanner =>
      'You\'re offline. Actions that need the internet won\'t work until you reconnect.';

  @override
  String get noNotificationsHint =>
      'New job requests appear as alerts on your phone. Stay online to receive them.';

  @override
  String get pushNewJobTitle => 'New job request';

  @override
  String get pushNewJobBody => 'Open ReadyLocal Partner to accept or reject.';

  @override
  String get welcomeBenefitJobs => 'Get verified job requests near you';

  @override
  String get welcomeBenefitEarnings => 'Track your earnings in one place';

  @override
  String get welcomeBenefitTime => 'Work at the times that suit you';

  @override
  String get alertsOffTitle => 'Job alerts are off';

  @override
  String get alertsOffBody =>
      'Turn on notifications so you don’t miss new jobs.';

  @override
  String get alertsTurnOn => 'Turn on';

  @override
  String get alertsSettingsTitle => 'Job alert settings';

  @override
  String get alertsSettingsIntro =>
      'To get job alerts even when the app is closed, set these on your phone:';

  @override
  String get alertsStepNotifications =>
      'Allow notifications for ReadyLocal Partner';

  @override
  String get alertsStepBattery =>
      'Battery: choose “No restrictions” or “Don’t optimise”';

  @override
  String get alertsStepAutostart =>
      'Xiaomi, Oppo, Vivo, Realme: turn on Autostart';

  @override
  String get alertsStepForceStop => 'Don’t use “Force stop” on the app';

  @override
  String get alertsOpenSettings => 'Open phone settings';

  @override
  String get paymentFailedTitle => 'Payment Failed';

  @override
  String get paymentFailedBody => 'Try after sometime.';

  @override
  String rateLine(String price, String unit) {
    return 'Rate: ₹$price $unit';
  }

  @override
  String get alreadyRegisteredTitle => 'You’re already registered';

  @override
  String get alreadyRegisteredBody =>
      'This mobile number already has a ReadyLocal Partner account. You don’t need to register again. Please continue to log in.';

  @override
  String get alreadyRegisteredContinue => 'Continue to Login';

  @override
  String get verifyPendingTitle => 'Details submitted';

  @override
  String get verifyPendingBody =>
      'Your verification is in process. Our team will review your details and update you soon.';

  @override
  String get verifyCheckStatus => 'Check status';

  @override
  String get verifySuccessTitle => 'Verification successful';

  @override
  String get verifySuccessBody =>
      'Your details are verified. You can now access the app.';

  @override
  String get verifyContinue => 'Continue';

  @override
  String get verifyRejectedTitle => 'Verification not approved';

  @override
  String get verifyRejectedReason => 'Reason';

  @override
  String get verifyRejectedNoReason =>
      'Please check your documents and submit them again.';

  @override
  String get verifyUpdateDetails => 'Update and submit again';

  @override
  String get verifyOffline =>
      'Could not check your status. Please check your internet and try again.';

  @override
  String get paymentDetailsReceived => 'We have received your details';

  @override
  String get alertSetupTitle => 'Job alert setup';

  @override
  String get alertSetupIntro =>
      'Do these steps once so new jobs ring on your phone even when the app is closed.';

  @override
  String alertSetupProgress(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get alertSetupAllDone =>
      'All set. You will get job alerts even when the app is closed.';

  @override
  String get alertStepNotificationsTitle => 'Allow notifications';

  @override
  String get alertStepNotificationsBody =>
      'Turn on “Allow notifications” for ReadyLocal Partner.';

  @override
  String get alertStepChannelTitle => 'Job request sound';

  @override
  String get alertStepChannelBody =>
      'Open “New job requests” and allow sound and pop-up.';

  @override
  String get alertStepBatteryTitle => 'Battery: No restrictions';

  @override
  String get alertStepBatteryBody =>
      'Tap Battery (or App battery usage) and choose “Unrestricted” / “No restrictions” / “Don’t optimise”.';

  @override
  String get alertStepAutostartTitle => 'Turn on Autostart';

  @override
  String get alertStepAutostartBody =>
      'Find ReadyLocal Partner in the list and switch Autostart on.';

  @override
  String get alertStepPopupTitle => 'Pop-up and lock screen';

  @override
  String get alertStepPopupBody =>
      'Allow “Display pop-up windows while running in background” and “Show on Lock screen”.';

  @override
  String get alertSetupOpen => 'Open settings';

  @override
  String get alertSetupIDidThis => 'I did this';

  @override
  String get alertSetupDone => 'Done';

  @override
  String get alertSetupLater => 'Later';

  @override
  String get alertSetupTest => 'Play a test alert';

  @override
  String get alertSetupTestTitle => 'Test job alert';

  @override
  String get alertSetupTestBody =>
      'If you can hear this, job alerts are working.';

  @override
  String get alertsFix => 'Fix';

  @override
  String get alertsSetupNeededTitle => 'Job alerts may be missed';

  @override
  String get alertsSetupNeededBody =>
      'Finish the job alert setup so jobs ring when the app is closed.';

  @override
  String get jobTakenByOther => 'This job was accepted by another partner.';

  @override
  String get welcomeHeadline => 'Earn more with your skills';

  @override
  String get welcomeSubline =>
      'Join ReadyLocal Partner and get job requests from customers near you.';

  @override
  String get loginTitleLogin => 'Login';

  @override
  String get loginHeadingLogin => 'Welcome back';

  @override
  String get loginSubheadingLogin =>
      'Enter your registered mobile number. We will send you an OTP.';

  @override
  String get loginSendOtp => 'Send OTP';

  @override
  String get loginSwitchToLogin => 'Already a partner? Login';

  @override
  String get loginSwitchToRegister => 'New to ReadyLocal? Register';

  @override
  String get selectServiceFeeFailed =>
      'Could not load the registration fee. Please check your internet and try again.';
}
