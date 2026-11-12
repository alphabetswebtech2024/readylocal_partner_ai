import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('te'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ReadyLocal Partner'**
  String get appTitle;

  /// No description provided for @commonViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get commonViewAll;

  /// No description provided for @commonMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'More Details'**
  String get commonMoreDetails;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get commonPleaseWait;

  /// No description provided for @commonSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get commonSomethingWentWrong;

  /// No description provided for @commonNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get commonNoInternet;

  /// No description provided for @statusOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get statusOnline;

  /// No description provided for @statusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get statusOffline;

  /// No description provided for @statusOngoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get statusOngoing;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusInProgress;

  /// No description provided for @periodDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get periodDaily;

  /// No description provided for @periodWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get periodWeekly;

  /// No description provided for @periodMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get periodMonthly;

  /// No description provided for @homeWelcomeName.
  ///
  /// In en, this message translates to:
  /// **'Welcome {name}'**
  String homeWelcomeName(String name);

  /// No description provided for @homeWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get homeWelcomeBack;

  /// No description provided for @homeLocationFallback.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get homeLocationFallback;

  /// No description provided for @homeTotalRequest.
  ///
  /// In en, this message translates to:
  /// **'Total Request'**
  String get homeTotalRequest;

  /// No description provided for @homeEarnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get homeEarnings;

  /// No description provided for @homeJobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get homeJobs;

  /// No description provided for @homeTodaysEarning.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Earning'**
  String get homeTodaysEarning;

  /// No description provided for @homeWeeklyEarning.
  ///
  /// In en, this message translates to:
  /// **'Weekly Earning'**
  String get homeWeeklyEarning;

  /// No description provided for @homeMonthlyEarning.
  ///
  /// In en, this message translates to:
  /// **'Monthly Earning'**
  String get homeMonthlyEarning;

  /// No description provided for @homeJobsToday.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 job today} other{{count} jobs today}}'**
  String homeJobsToday(int count);

  /// No description provided for @homeJobsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 job this week} other{{count} jobs this week}}'**
  String homeJobsThisWeek(int count);

  /// No description provided for @homeJobsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 job this month} other{{count} jobs this month}}'**
  String homeJobsThisMonth(int count);

  /// No description provided for @homeNoOngoingJobs.
  ///
  /// In en, this message translates to:
  /// **'No ongoing jobs'**
  String get homeNoOngoingJobs;

  /// No description provided for @homeNoOngoingJobsHint.
  ///
  /// In en, this message translates to:
  /// **'Stay online to receive new job requests.'**
  String get homeNoOngoingJobsHint;

  /// No description provided for @homeNoCompletedJobs.
  ///
  /// In en, this message translates to:
  /// **'No completed jobs'**
  String get homeNoCompletedJobs;

  /// No description provided for @homeSessionErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Session Error'**
  String get homeSessionErrorTitle;

  /// No description provided for @homeSessionErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, please login.'**
  String get homeSessionErrorMessage;

  /// No description provided for @homeYouAreOnline.
  ///
  /// In en, this message translates to:
  /// **'You are online now.'**
  String get homeYouAreOnline;

  /// No description provided for @homeYouAreOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline now.'**
  String get homeYouAreOffline;

  /// No description provided for @homeJobDetailsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load job details.'**
  String get homeJobDetailsFailed;

  /// No description provided for @homeOpenProfile.
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get homeOpenProfile;

  /// No description provided for @homeOnlineToggleHint.
  ///
  /// In en, this message translates to:
  /// **'Go online or offline'**
  String get homeOnlineToggleHint;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get loginTitle;

  /// No description provided for @loginHeading.
  ///
  /// In en, this message translates to:
  /// **'Be a part of ReadyLocal Partner'**
  String get loginHeading;

  /// No description provided for @loginSubheading.
  ///
  /// In en, this message translates to:
  /// **'Make your first move to improve your business.'**
  String get loginSubheading;

  /// No description provided for @loginPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get loginPhoneLabel;

  /// No description provided for @loginPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get loginPhoneRequired;

  /// No description provided for @loginPhoneDigitsOnly.
  ///
  /// In en, this message translates to:
  /// **'Phone number must contain only digits'**
  String get loginPhoneDigitsOnly;

  /// No description provided for @loginPhoneInvalidIndia.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit Indian mobile number'**
  String get loginPhoneInvalidIndia;

  /// No description provided for @loginPhoneStartDigit.
  ///
  /// In en, this message translates to:
  /// **'Indian numbers must start with 6, 7, 8, or 9'**
  String get loginPhoneStartDigit;

  /// No description provided for @loginPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number (7–15 digits)'**
  String get loginPhoneInvalid;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get loginFailed;

  /// No description provided for @loginSelectCountryCode.
  ///
  /// In en, this message translates to:
  /// **'Select Country Code'**
  String get loginSelectCountryCode;

  /// No description provided for @loginCountryIndia.
  ///
  /// In en, this message translates to:
  /// **'India'**
  String get loginCountryIndia;

  /// No description provided for @loginAgreePrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our '**
  String get loginAgreePrefix;

  /// No description provided for @loginTerms.
  ///
  /// In en, this message translates to:
  /// **'T&C'**
  String get loginTerms;

  /// No description provided for @loginAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get loginAnd;

  /// No description provided for @loginPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get loginPrivacy;

  /// No description provided for @loginAgreeSuffix.
  ///
  /// In en, this message translates to:
  /// **''**
  String get loginAgreeSuffix;

  /// No description provided for @loginBecomePartner.
  ///
  /// In en, this message translates to:
  /// **'Become a Partner'**
  String get loginBecomePartner;

  /// No description provided for @webTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get webTermsTitle;

  /// No description provided for @webPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get webPrivacyTitle;

  /// No description provided for @webAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get webAboutTitle;

  /// No description provided for @earningsTitle.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earningsTitle;

  /// No description provided for @earningsOverview.
  ///
  /// In en, this message translates to:
  /// **'Earnings Overview'**
  String get earningsOverview;

  /// No description provided for @earningsAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get earningsAvailableBalance;

  /// No description provided for @earningsSendWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Send withdraw request'**
  String get earningsSendWithdraw;

  /// No description provided for @earningsBankTransaction.
  ///
  /// In en, this message translates to:
  /// **'Bank Transaction'**
  String get earningsBankTransaction;

  /// No description provided for @earningsNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions found.'**
  String get earningsNoTransactions;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @earningsBankTransactionItem.
  ///
  /// In en, this message translates to:
  /// **'Bank Transaction'**
  String get earningsBankTransactionItem;

  /// No description provided for @jobNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Notification'**
  String get jobNotificationTitle;

  /// No description provided for @jobServiceRequest.
  ///
  /// In en, this message translates to:
  /// **'Service Request'**
  String get jobServiceRequest;

  /// No description provided for @jobCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get jobCustomer;

  /// No description provided for @jobDistanceKm.
  ///
  /// In en, this message translates to:
  /// **'{distance} Km'**
  String jobDistanceKm(String distance);

  /// No description provided for @jobAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get jobAccept;

  /// No description provided for @jobReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get jobReject;

  /// No description provided for @jobDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get jobDetails;

  /// No description provided for @jobAcceptTitle.
  ///
  /// In en, this message translates to:
  /// **'Accept Job'**
  String get jobAcceptTitle;

  /// No description provided for @jobAcceptMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to accept this job?'**
  String get jobAcceptMessage;

  /// No description provided for @jobRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject Job'**
  String get jobRejectTitle;

  /// No description provided for @jobRejectMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject this job?'**
  String get jobRejectMessage;

  /// No description provided for @jobWait.
  ///
  /// In en, this message translates to:
  /// **'Wait...'**
  String get jobWait;

  /// No description provided for @jobRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason'**
  String get jobRejectionReason;

  /// No description provided for @jobRejectionHint.
  ///
  /// In en, this message translates to:
  /// **'Please tell us why you are rejecting this job...'**
  String get jobRejectionHint;

  /// No description provided for @jobSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get jobSubmitting;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @jobTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'Time left to respond'**
  String get jobTimeLeft;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @profileViewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get profileViewProfile;

  /// No description provided for @profileAbout.
  ///
  /// In en, this message translates to:
  /// **'About ReadyLocal Partner'**
  String get profileAbout;

  /// No description provided for @profileTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get profileTerms;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy and Policy'**
  String get profilePrivacy;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get profileLogoutConfirm;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccount;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get profileChooseLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageTelugu.
  ///
  /// In en, this message translates to:
  /// **'తెలుగు'**
  String get languageTelugu;

  /// No description provided for @jobsAllJobs.
  ///
  /// In en, this message translates to:
  /// **'All Jobs'**
  String get jobsAllJobs;

  /// No description provided for @otpEnterComplete.
  ///
  /// In en, this message translates to:
  /// **'Enter complete OTP'**
  String get otpEnterComplete;

  /// No description provided for @otpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP. Please try again.'**
  String get otpInvalid;

  /// No description provided for @otpResent.
  ///
  /// In en, this message translates to:
  /// **'OTP resent successfully'**
  String get otpResent;

  /// No description provided for @otpResendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend OTP'**
  String get otpResendFailed;

  /// No description provided for @otpVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerify;

  /// No description provided for @otpHeading.
  ///
  /// In en, this message translates to:
  /// **'To be a part of ReadyLocal Partner verify number'**
  String get otpHeading;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'We have sent you the verification code to'**
  String get otpSentTo;

  /// No description provided for @otpEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get otpEdit;

  /// No description provided for @otpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get otpResend;

  /// No description provided for @selectServiceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a service to continue.'**
  String get selectServiceRequired;

  /// No description provided for @selectServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Your Service'**
  String get selectServiceTitle;

  /// No description provided for @verifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verifiedTitle;

  /// No description provided for @welcomeReadOur.
  ///
  /// In en, this message translates to:
  /// **'Make Sure Read our '**
  String get welcomeReadOur;

  /// No description provided for @welcomeAnd.
  ///
  /// In en, this message translates to:
  /// **' And '**
  String get welcomeAnd;

  /// No description provided for @welcomeReadSuffix.
  ///
  /// In en, this message translates to:
  /// **''**
  String get welcomeReadSuffix;

  /// No description provided for @welcomeRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get welcomeRegister;

  /// No description provided for @welcomeLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get welcomeLogin;

  /// No description provided for @jobSummary.
  ///
  /// In en, this message translates to:
  /// **'Job Summary'**
  String get jobSummary;

  /// No description provided for @labelOrderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get labelOrderId;

  /// No description provided for @labelScheduledOn.
  ///
  /// In en, this message translates to:
  /// **'Scheduled on'**
  String get labelScheduledOn;

  /// No description provided for @labelDistanceTraveled.
  ///
  /// In en, this message translates to:
  /// **'Distance Traveled'**
  String get labelDistanceTraveled;

  /// No description provided for @customerDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer Details'**
  String get customerDetailsTitle;

  /// No description provided for @labelName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get labelName;

  /// No description provided for @labelPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get labelPhone;

  /// No description provided for @labelLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get labelLocation;

  /// No description provided for @labelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email ID'**
  String get labelEmail;

  /// No description provided for @paymentSummary.
  ///
  /// In en, this message translates to:
  /// **'Payment Summary'**
  String get paymentSummary;

  /// No description provided for @paymentServiceTotal.
  ///
  /// In en, this message translates to:
  /// **'Service Total'**
  String get paymentServiceTotal;

  /// No description provided for @paymentAmountCollected.
  ///
  /// In en, this message translates to:
  /// **'Amount Collected'**
  String get paymentAmountCollected;

  /// No description provided for @mapStartLocation.
  ///
  /// In en, this message translates to:
  /// **'Start Location'**
  String get mapStartLocation;

  /// No description provided for @mapDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get mapDestination;

  /// No description provided for @rideStartedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ride Started Successfully!'**
  String get rideStartedSuccess;

  /// No description provided for @reachedRecorded.
  ///
  /// In en, this message translates to:
  /// **'Reached Location Recorded!'**
  String get reachedRecorded;

  /// No description provided for @statusUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update status'**
  String get statusUpdateFailed;

  /// No description provided for @labelServiceBookedDate.
  ///
  /// In en, this message translates to:
  /// **'Service Booked Date'**
  String get labelServiceBookedDate;

  /// No description provided for @labelServiceBookedTime.
  ///
  /// In en, this message translates to:
  /// **'Service Booked Time'**
  String get labelServiceBookedTime;

  /// No description provided for @getDirection.
  ///
  /// In en, this message translates to:
  /// **'Get Direction'**
  String get getDirection;

  /// No description provided for @mapLabel.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get mapLabel;

  /// No description provided for @callLabel.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callLabel;

  /// No description provided for @startRide.
  ///
  /// In en, this message translates to:
  /// **'Start Ride'**
  String get startRide;

  /// No description provided for @reachedLocation.
  ///
  /// In en, this message translates to:
  /// **'Reached Location'**
  String get reachedLocation;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @jobExpired.
  ///
  /// In en, this message translates to:
  /// **'This job request has expired.'**
  String get jobExpired;

  /// No description provided for @warningTitle.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warningTitle;

  /// No description provided for @jobAcceptedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Job accepted successfully!'**
  String get jobAcceptedSuccess;

  /// No description provided for @jobAcceptFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to accept job'**
  String get jobAcceptFailed;

  /// No description provided for @jobRejectReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit the reason of rejecting the job'**
  String get jobRejectReasonTitle;

  /// No description provided for @jobRejectReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Write the reason behind the rejecting the job'**
  String get jobRejectReasonHint;

  /// No description provided for @enterReason.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason.'**
  String get enterReason;

  /// No description provided for @jobRejected.
  ///
  /// In en, this message translates to:
  /// **'Job rejected.'**
  String get jobRejected;

  /// No description provided for @jobRejectFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to reject job.'**
  String get jobRejectFailed;

  /// No description provided for @overviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overviewTitle;

  /// No description provided for @instantLabel.
  ///
  /// In en, this message translates to:
  /// **'Instant'**
  String get instantLabel;

  /// No description provided for @aboutService.
  ///
  /// In en, this message translates to:
  /// **'About Service'**
  String get aboutService;

  /// No description provided for @serviceBookedBy.
  ///
  /// In en, this message translates to:
  /// **'Service Booked by'**
  String get serviceBookedBy;

  /// No description provided for @uploadAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Please upload at least one image of the work.'**
  String get uploadAtLeastOne;

  /// No description provided for @waitForUploads.
  ///
  /// In en, this message translates to:
  /// **'Please wait for all images to finish uploading.'**
  String get waitForUploads;

  /// No description provided for @someUploadsFailed.
  ///
  /// In en, this message translates to:
  /// **'Some images failed to upload. Please remove or retry them.'**
  String get someUploadsFailed;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @selectAvailability.
  ///
  /// In en, this message translates to:
  /// **'Please select customer availability.'**
  String get selectAvailability;

  /// No description provided for @enterFeedback.
  ///
  /// In en, this message translates to:
  /// **'Please enter feedback/reason before submitting.'**
  String get enterFeedback;

  /// No description provided for @closeJob.
  ///
  /// In en, this message translates to:
  /// **'Close Job'**
  String get closeJob;

  /// No description provided for @closeJobConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close this job?'**
  String get closeJobConfirm;

  /// No description provided for @cancelJobFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel job. Please try again.'**
  String get cancelJobFailed;

  /// No description provided for @completeJobFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to complete job. Please try again.'**
  String get completeJobFailed;

  /// No description provided for @partnerFallback.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get partnerFallback;

  /// No description provided for @jobProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Progress'**
  String get jobProgressTitle;

  /// No description provided for @startJob.
  ///
  /// In en, this message translates to:
  /// **'Start Job'**
  String get startJob;

  /// No description provided for @fillDetailsBeforeWork.
  ///
  /// In en, this message translates to:
  /// **'Fill the details before starting your work'**
  String get fillDetailsBeforeWork;

  /// No description provided for @customerAvailable.
  ///
  /// In en, this message translates to:
  /// **'Customer is available?'**
  String get customerAvailable;

  /// No description provided for @selectHint.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectHint;

  /// No description provided for @selfieTitle.
  ///
  /// In en, this message translates to:
  /// **'Click Selfie with Product'**
  String get selfieTitle;

  /// No description provided for @selfieSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Selfie with the product once you reach to customers place.'**
  String get selfieSubtitle;

  /// No description provided for @beforeRepairTitle.
  ///
  /// In en, this message translates to:
  /// **'Click before repair product Image.'**
  String get beforeRepairTitle;

  /// No description provided for @beforeRepairSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload before repair product image.'**
  String get beforeRepairSubtitle;

  /// No description provided for @afterRepairTitle.
  ///
  /// In en, this message translates to:
  /// **'Click After repair product Image.'**
  String get afterRepairTitle;

  /// No description provided for @afterRepairSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload after repair product image.'**
  String get afterRepairSubtitle;

  /// No description provided for @feedbackReason.
  ///
  /// In en, this message translates to:
  /// **'Feedback / Reason'**
  String get feedbackReason;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Write the feedback of the product repair'**
  String get feedbackHint;

  /// No description provided for @closeReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Write the reason why the job is being closed'**
  String get closeReasonHint;

  /// No description provided for @workDone.
  ///
  /// In en, this message translates to:
  /// **'Work Done'**
  String get workDone;

  /// No description provided for @addMore.
  ///
  /// In en, this message translates to:
  /// **'Add More'**
  String get addMore;

  /// No description provided for @noAddressProvided.
  ///
  /// In en, this message translates to:
  /// **'No address provided'**
  String get noAddressProvided;

  /// No description provided for @enterReasonBeforeSubmit.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason before submitting.'**
  String get enterReasonBeforeSubmit;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @jobCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Cancelled'**
  String get jobCancelledTitle;

  /// No description provided for @jobCancelledMessage.
  ///
  /// In en, this message translates to:
  /// **'This job request was cancelled by the customer or has expired.'**
  String get jobCancelledMessage;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please try again.'**
  String get networkError;

  /// No description provided for @enterRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Please enter a rejection reason'**
  String get enterRejectionReason;

  /// No description provided for @loadingJobDetails.
  ///
  /// In en, this message translates to:
  /// **'Loading job details...'**
  String get loadingJobDetails;

  /// No description provided for @newNotification.
  ///
  /// In en, this message translates to:
  /// **'New Notification'**
  String get newNotification;

  /// No description provided for @earlierLabel.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlierLabel;

  /// No description provided for @workStatusReceived.
  ///
  /// In en, this message translates to:
  /// **'We have received your work Status'**
  String get workStatusReceived;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// No description provided for @thankYouName.
  ///
  /// In en, this message translates to:
  /// **'Thank you {name}'**
  String thankYouName(String name);

  /// No description provided for @feeUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile details.'**
  String get feeUpdateFailed;

  /// No description provided for @feeUnexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred: {error}'**
  String feeUnexpectedError(String error);

  /// No description provided for @feeTitle.
  ///
  /// In en, this message translates to:
  /// **'Partner Activation Fee'**
  String get feeTitle;

  /// No description provided for @feeDescription.
  ///
  /// In en, this message translates to:
  /// **'To be a part of this there will be the one time registration need to be paid'**
  String get feeDescription;

  /// No description provided for @feePayNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get feePayNow;

  /// No description provided for @bankAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Bank account added successfully'**
  String get bankAddedSuccess;

  /// No description provided for @bankAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add bank details'**
  String get bankAddFailed;

  /// No description provided for @bankAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Bank Details'**
  String get bankAddTitle;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankName;

  /// No description provided for @bankNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Bank Name'**
  String get bankNameHint;

  /// No description provided for @bankNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Bank name is required'**
  String get bankNameRequired;

  /// No description provided for @bankAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get bankAccountNumber;

  /// No description provided for @bankAccountNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Account Number'**
  String get bankAccountNumberHint;

  /// No description provided for @bankAccountNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Account number is required'**
  String get bankAccountNumberRequired;

  /// No description provided for @bankAccountNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid account number (9-18 digits)'**
  String get bankAccountNumberInvalid;

  /// No description provided for @bankHolderName.
  ///
  /// In en, this message translates to:
  /// **'Account Holder Name'**
  String get bankHolderName;

  /// No description provided for @bankHolderNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Account Holder Name'**
  String get bankHolderNameHint;

  /// No description provided for @bankHolderNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Account holder name is required'**
  String get bankHolderNameRequired;

  /// No description provided for @bankIfsc.
  ///
  /// In en, this message translates to:
  /// **'IFSC Code'**
  String get bankIfsc;

  /// No description provided for @bankIfscHint.
  ///
  /// In en, this message translates to:
  /// **'Enter IFSC Code'**
  String get bankIfscHint;

  /// No description provided for @bankIfscRequired.
  ///
  /// In en, this message translates to:
  /// **'IFSC code is required'**
  String get bankIfscRequired;

  /// No description provided for @bankIfscLabel.
  ///
  /// In en, this message translates to:
  /// **'IFSC Code'**
  String get bankIfscLabel;

  /// No description provided for @paymentRequestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Request Accepted'**
  String get paymentRequestAccepted;

  /// No description provided for @paymentReceived.
  ///
  /// In en, this message translates to:
  /// **'We have received your payment'**
  String get paymentReceived;

  /// No description provided for @paymentTeamWillContact.
  ///
  /// In en, this message translates to:
  /// **'\nOur team will get back to you with-in 24-48 Hrs'**
  String get paymentTeamWillContact;

  /// No description provided for @paymentExploreApp.
  ///
  /// In en, this message translates to:
  /// **'Explore App'**
  String get paymentExploreApp;

  /// No description provided for @genderSelect.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get genderSelect;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @optionalSuffix.
  ///
  /// In en, this message translates to:
  /// **' (Optional)'**
  String get optionalSuffix;

  /// No description provided for @personalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfoTitle;

  /// No description provided for @personalInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your personal Information'**
  String get personalInfoSubtitle;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Your First Name'**
  String get firstNameHint;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Last Name'**
  String get lastNameHint;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameRequired;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Your email ID'**
  String get emailHint;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get emailInvalid;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @genderHint.
  ///
  /// In en, this message translates to:
  /// **'Select Your Gender'**
  String get genderHint;

  /// No description provided for @genderRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select gender'**
  String get genderRequired;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @addressSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for Area/Street/Locality'**
  String get addressSearchHint;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get addressRequired;

  /// No description provided for @houseLabel.
  ///
  /// In en, this message translates to:
  /// **'Area/House/Flat No.'**
  String get houseLabel;

  /// No description provided for @houseHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your House/Flat/Apartment No.'**
  String get houseHint;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// No description provided for @cityHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Your City'**
  String get cityHint;

  /// No description provided for @cityRequired.
  ///
  /// In en, this message translates to:
  /// **'City is required'**
  String get cityRequired;

  /// No description provided for @stateLabel.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get stateLabel;

  /// No description provided for @stateHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Your State'**
  String get stateHint;

  /// No description provided for @stateRequired.
  ///
  /// In en, this message translates to:
  /// **'State is required'**
  String get stateRequired;

  /// No description provided for @pinLabel.
  ///
  /// In en, this message translates to:
  /// **'Pin code'**
  String get pinLabel;

  /// No description provided for @pinHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your Pin code'**
  String get pinHint;

  /// No description provided for @pinRequired.
  ///
  /// In en, this message translates to:
  /// **'Pin code is required'**
  String get pinRequired;

  /// No description provided for @pinInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 6-digit pin code'**
  String get pinInvalid;

  /// No description provided for @txnDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get txnDetailsTitle;

  /// No description provided for @txnId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get txnId;

  /// No description provided for @txnIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID copied!'**
  String get txnIdCopied;

  /// No description provided for @txnPaidThrough.
  ///
  /// In en, this message translates to:
  /// **'Paid Through'**
  String get txnPaidThrough;

  /// No description provided for @txnAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get txnAmount;

  /// No description provided for @txnTax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get txnTax;

  /// No description provided for @txnTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get txnTotalAmount;

  /// No description provided for @txnBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Bank Account'**
  String get txnBankAccount;

  /// No description provided for @txnLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load transaction details.'**
  String get txnLoadFailed;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @withdrawNoBankSelected.
  ///
  /// In en, this message translates to:
  /// **'No bank account selected.'**
  String get withdrawNoBankSelected;

  /// No description provided for @withdrawInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount.'**
  String get withdrawInvalidAmount;

  /// No description provided for @withdrawExceedsBalance.
  ///
  /// In en, this message translates to:
  /// **'Amount exceeds available balance.'**
  String get withdrawExceedsBalance;

  /// No description provided for @withdrawNoBank.
  ///
  /// In en, this message translates to:
  /// **'No bank account found.'**
  String get withdrawNoBank;

  /// No description provided for @withdrawSuccess.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal request successful!'**
  String get withdrawSuccess;

  /// No description provided for @withdrawTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdrawTitle;

  /// No description provided for @withdrawEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount to withdraw'**
  String get withdrawEnterAmount;

  /// No description provided for @withdrawAddAnotherBank.
  ///
  /// In en, this message translates to:
  /// **'Add Another Bank Details'**
  String get withdrawAddAnotherBank;

  /// No description provided for @withdrawSendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get withdrawSendRequest;

  /// No description provided for @setupSelectAtLeastOneCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one category.'**
  String get setupSelectAtLeastOneCategory;

  /// No description provided for @setupSelectAtLeastOneService.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one service.'**
  String get setupSelectAtLeastOneService;

  /// No description provided for @setupSelectExperience.
  ///
  /// In en, this message translates to:
  /// **'Please select years of experience.'**
  String get setupSelectExperience;

  /// No description provided for @setupSelectCategories.
  ///
  /// In en, this message translates to:
  /// **'Select Categories'**
  String get setupSelectCategories;

  /// No description provided for @setupSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get setupSelectCategory;

  /// No description provided for @setupNoCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories available'**
  String get setupNoCategories;

  /// No description provided for @setupDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get setupDone;

  /// No description provided for @setupSelectService.
  ///
  /// In en, this message translates to:
  /// **'Select Service'**
  String get setupSelectService;

  /// No description provided for @setupSelectServiceType.
  ///
  /// In en, this message translates to:
  /// **'Select Service Type'**
  String get setupSelectServiceType;

  /// No description provided for @setupSelectServices.
  ///
  /// In en, this message translates to:
  /// **'Select Services'**
  String get setupSelectServices;

  /// No description provided for @setupErrorFetching.
  ///
  /// In en, this message translates to:
  /// **'Error fetching data'**
  String get setupErrorFetching;

  /// No description provided for @setupNoItems.
  ///
  /// In en, this message translates to:
  /// **'No items available'**
  String get setupNoItems;

  /// No description provided for @setupNoData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get setupNoData;

  /// No description provided for @setupSelectYears.
  ///
  /// In en, this message translates to:
  /// **'Select Years'**
  String get setupSelectYears;

  /// No description provided for @setupCategoriesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} Categories Selected'**
  String setupCategoriesSelected(int count);

  /// No description provided for @setupServicesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} Services Selected'**
  String setupServicesSelected(int count);

  /// No description provided for @setupSubCategoriesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} Sub Categories Selected'**
  String setupSubCategoriesSelected(int count);

  /// No description provided for @setupAddCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Categories & Sub Categories'**
  String get setupAddCategoriesTitle;

  /// No description provided for @setupAddCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'As per the next step to be a ReadyLocal Partner Please Add Categories & Sub Categories.'**
  String get setupAddCategoriesSubtitle;

  /// No description provided for @setupAddCategoriesServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Categories & Select Services'**
  String get setupAddCategoriesServicesTitle;

  /// No description provided for @setupAddCategoriesServicesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'As per the next step to be a ReadyLocal Partner Please Add Categories & Services.'**
  String get setupAddCategoriesServicesSubtitle;

  /// No description provided for @setupCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get setupCategories;

  /// No description provided for @setupServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get setupServices;

  /// No description provided for @setupService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get setupService;

  /// No description provided for @setupServiceType.
  ///
  /// In en, this message translates to:
  /// **'Service Type'**
  String get setupServiceType;

  /// No description provided for @setupSubCategories.
  ///
  /// In en, this message translates to:
  /// **'Sub Categories'**
  String get setupSubCategories;

  /// No description provided for @setupSelectSubCategories.
  ///
  /// In en, this message translates to:
  /// **'Select Sub Categories'**
  String get setupSelectSubCategories;

  /// No description provided for @setupSelectedSubCategories.
  ///
  /// In en, this message translates to:
  /// **'Selected Sub Categories'**
  String get setupSelectedSubCategories;

  /// No description provided for @setupYearOfExperience.
  ///
  /// In en, this message translates to:
  /// **'Year of experience'**
  String get setupYearOfExperience;

  /// No description provided for @setupNoVariants.
  ///
  /// In en, this message translates to:
  /// **'No variants selected'**
  String get setupNoVariants;

  /// No description provided for @setupSelectCategoryError.
  ///
  /// In en, this message translates to:
  /// **'Please select a category.'**
  String get setupSelectCategoryError;

  /// No description provided for @setupSelectSubCategoryAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one sub category.'**
  String get setupSelectSubCategoryAtLeastOne;

  /// No description provided for @setupSelectSubCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a sub category.'**
  String get setupSelectSubCategory;

  /// No description provided for @setupSelectServiceError.
  ///
  /// In en, this message translates to:
  /// **'Please select a service.'**
  String get setupSelectServiceError;

  /// No description provided for @setupServiceDurationRates.
  ///
  /// In en, this message translates to:
  /// **'Service Duration & Rates'**
  String get setupServiceDurationRates;

  /// No description provided for @setupServiceRateRequired.
  ///
  /// In en, this message translates to:
  /// **'Service rate required.'**
  String get setupServiceRateRequired;

  /// No description provided for @setupEnterRateFor.
  ///
  /// In en, this message translates to:
  /// **'Enter Rate for {name}'**
  String setupEnterRateFor(String name);

  /// No description provided for @setupEnterHourRate.
  ///
  /// In en, this message translates to:
  /// **'Enter Per Hour Rate'**
  String get setupEnterHourRate;

  /// No description provided for @setupEnterDayRate.
  ///
  /// In en, this message translates to:
  /// **'Enter Per Day Rate'**
  String get setupEnterDayRate;

  /// No description provided for @setupEnter24Rate.
  ///
  /// In en, this message translates to:
  /// **'Enter 24 Hours Rate'**
  String get setupEnter24Rate;

  /// No description provided for @setupEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get setupEnterValidAmount;

  /// No description provided for @setupInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid Input'**
  String get setupInvalidInput;

  /// No description provided for @setupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get setupConfirm;

  /// No description provided for @driverFetchingLocation.
  ///
  /// In en, this message translates to:
  /// **'Fetching location...'**
  String get driverFetchingLocation;

  /// No description provided for @driverLocationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get driverLocationDenied;

  /// No description provided for @driverLocationDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permissions permanently denied'**
  String get driverLocationDeniedForever;

  /// No description provided for @driverLocationDetected.
  ///
  /// In en, this message translates to:
  /// **'Current Location Detected'**
  String get driverLocationDetected;

  /// No description provided for @driverLocationFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch location'**
  String get driverLocationFailed;

  /// No description provided for @driverSetRateFor.
  ///
  /// In en, this message translates to:
  /// **'Set Rate for {name}'**
  String driverSetRateFor(String name);

  /// No description provided for @driverEnterRate.
  ///
  /// In en, this message translates to:
  /// **'Enter rate ({unit}):'**
  String driverEnterRate(String unit);

  /// No description provided for @driverSaveRate.
  ///
  /// In en, this message translates to:
  /// **'Save Rate'**
  String get driverSaveRate;

  /// No description provided for @driverSelectServiceType.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one service type.'**
  String get driverSelectServiceType;

  /// No description provided for @driverSelectExperience.
  ///
  /// In en, this message translates to:
  /// **'Please select your experience.'**
  String get driverSelectExperience;

  /// No description provided for @driverSelectLicense.
  ///
  /// In en, this message translates to:
  /// **'Please select your license type.'**
  String get driverSelectLicense;

  /// No description provided for @driverSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one language.'**
  String get driverSelectLanguage;

  /// No description provided for @driverSelectVehicle.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one vehicle type.'**
  String get driverSelectVehicle;

  /// No description provided for @driverSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile'**
  String get driverSaveFailed;

  /// No description provided for @driverDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Details'**
  String get driverDetailsTitle;

  /// No description provided for @driverSelectServiceTypes.
  ///
  /// In en, this message translates to:
  /// **'Select Service Types'**
  String get driverSelectServiceTypes;

  /// No description provided for @driverExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get driverExperience;

  /// No description provided for @driverLicenseType.
  ///
  /// In en, this message translates to:
  /// **'License Type'**
  String get driverLicenseType;

  /// No description provided for @driverLanguages.
  ///
  /// In en, this message translates to:
  /// **'Language(s)'**
  String get driverLanguages;

  /// No description provided for @driverPreferredLocation.
  ///
  /// In en, this message translates to:
  /// **'Preferred Location for Work'**
  String get driverPreferredLocation;

  /// No description provided for @driverVehicleTypes.
  ///
  /// In en, this message translates to:
  /// **'Types of Vehicles'**
  String get driverVehicleTypes;

  /// No description provided for @driverSafetySkills.
  ///
  /// In en, this message translates to:
  /// **'Safety / Special Skills'**
  String get driverSafetySkills;

  /// No description provided for @driverSelectExperienceHint.
  ///
  /// In en, this message translates to:
  /// **'Select Experience'**
  String get driverSelectExperienceHint;

  /// No description provided for @driverSelectLicenseHint.
  ///
  /// In en, this message translates to:
  /// **'Select License Type'**
  String get driverSelectLicenseHint;

  /// No description provided for @driverSaveDetails.
  ///
  /// In en, this message translates to:
  /// **'Save Details'**
  String get driverSaveDetails;

  /// No description provided for @docProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Profile Picture'**
  String get docProfilePicture;

  /// No description provided for @docProfilePictureSub.
  ///
  /// In en, this message translates to:
  /// **'Upload a clear profile photo'**
  String get docProfilePictureSub;

  /// No description provided for @docAadhaarFront.
  ///
  /// In en, this message translates to:
  /// **'Upload Aadhaar Card Front'**
  String get docAadhaarFront;

  /// No description provided for @docAadhaarBack.
  ///
  /// In en, this message translates to:
  /// **'Upload Aadhaar Card Back'**
  String get docAadhaarBack;

  /// No description provided for @docPan.
  ///
  /// In en, this message translates to:
  /// **'Upload Pan Card'**
  String get docPan;

  /// No description provided for @docAddressProof.
  ///
  /// In en, this message translates to:
  /// **'Address Proof (Bill/Rental)'**
  String get docAddressProof;

  /// No description provided for @docAddressProofSub.
  ///
  /// In en, this message translates to:
  /// **'Upload Bill/Rental agreement'**
  String get docAddressProofSub;

  /// No description provided for @docToolPhotos.
  ///
  /// In en, this message translates to:
  /// **'Tool Photos'**
  String get docToolPhotos;

  /// No description provided for @docDrivingLicense.
  ///
  /// In en, this message translates to:
  /// **'Upload Driving License'**
  String get docDrivingLicense;

  /// No description provided for @docDrivingLicenseSub.
  ///
  /// In en, this message translates to:
  /// **'Required for Driver Verification'**
  String get docDrivingLicenseSub;

  /// No description provided for @docQualification.
  ///
  /// In en, this message translates to:
  /// **'Upload Qualification Certificate'**
  String get docQualification;

  /// No description provided for @docQualificationSub.
  ///
  /// In en, this message translates to:
  /// **'Required for Medical Verification'**
  String get docQualificationSub;

  /// No description provided for @docExperience.
  ///
  /// In en, this message translates to:
  /// **'Upload Experience Certificate'**
  String get docExperience;

  /// No description provided for @docExperienceSub.
  ///
  /// In en, this message translates to:
  /// **'Required for Verification'**
  String get docExperienceSub;

  /// No description provided for @docQualificationLabel.
  ///
  /// In en, this message translates to:
  /// **'Qualification'**
  String get docQualificationLabel;

  /// No description provided for @docAvailabilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get docAvailabilityLabel;

  /// No description provided for @docUploadFailedFor.
  ///
  /// In en, this message translates to:
  /// **'Upload failed for: {name}. Please try again.'**
  String docUploadFailedFor(String name);

  /// No description provided for @docCameraDisabled.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is disabled. Enable it in Settings to take a photo.'**
  String get docCameraDisabled;

  /// No description provided for @docCameraRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to capture photos.'**
  String get docCameraRequired;

  /// No description provided for @docCameraFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the camera. Please try again.'**
  String get docCameraFailed;

  /// No description provided for @docGalleryFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the photo gallery. Please try again.'**
  String get docGalleryFailed;

  /// No description provided for @docUploadsInProgress.
  ///
  /// In en, this message translates to:
  /// **'Please wait, uploads are still in progress...'**
  String get docUploadsInProgress;

  /// No description provided for @docPleaseUpload.
  ///
  /// In en, this message translates to:
  /// **'Please upload: {name}'**
  String docPleaseUpload(String name);

  /// No description provided for @docReuploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed for: {name}. Please re-upload.'**
  String docReuploadFailed(String name);

  /// No description provided for @docUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get docUploadImage;

  /// No description provided for @docChooseOption.
  ///
  /// In en, this message translates to:
  /// **'Choose an option to upload the image'**
  String get docChooseOption;

  /// No description provided for @docCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get docCamera;

  /// No description provided for @docTakePhotoNow.
  ///
  /// In en, this message translates to:
  /// **'Take a photo now'**
  String get docTakePhotoNow;

  /// No description provided for @docGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get docGallery;

  /// No description provided for @docChooseLibrary.
  ///
  /// In en, this message translates to:
  /// **'Choose from photo library'**
  String get docChooseLibrary;

  /// No description provided for @docDocumentation.
  ///
  /// In en, this message translates to:
  /// **'Documentation'**
  String get docDocumentation;

  /// No description provided for @docUploadDocuments.
  ///
  /// In en, this message translates to:
  /// **'Upload Documents'**
  String get docUploadDocuments;

  /// No description provided for @docUploadDocumentsSub.
  ///
  /// In en, this message translates to:
  /// **'As a part of process partners need to upload required Documents'**
  String get docUploadDocumentsSub;

  /// No description provided for @docOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get docOptional;

  /// No description provided for @docTapAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photo'**
  String get docTapAddPhoto;

  /// No description provided for @docTapUploadFile.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload file'**
  String get docTapUploadFile;

  /// No description provided for @docUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get docUploadFailed;

  /// No description provided for @docUploadFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Upload failed — tap to retry'**
  String get docUploadFailedRetry;

  /// No description provided for @docUploaded.
  ///
  /// In en, this message translates to:
  /// **'✓ Uploaded'**
  String get docUploaded;

  /// No description provided for @imgEmpty.
  ///
  /// In en, this message translates to:
  /// **'The selected image is empty. Please take it again.'**
  String get imgEmpty;

  /// No description provided for @imgTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This image is too large. Please use an image smaller than 10 MB.'**
  String get imgTooLarge;

  /// No description provided for @imgUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The selected image is no longer available. Please choose it again.'**
  String get imgUnavailable;

  /// No description provided for @imgServerFailed.
  ///
  /// In en, this message translates to:
  /// **'The server could not upload this image.'**
  String get imgServerFailed;

  /// No description provided for @imgInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'The server returned an invalid upload response.'**
  String get imgInvalidResponse;

  /// No description provided for @imgTimeout.
  ///
  /// In en, this message translates to:
  /// **'The upload timed out. Please check your connection and retry.'**
  String get imgTimeout;

  /// No description provided for @imgOffline.
  ///
  /// In en, this message translates to:
  /// **'No network connection. Please try again when you are online.'**
  String get imgOffline;

  /// No description provided for @imgUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to upload this image. Please try again.'**
  String get imgUploadFailed;

  /// No description provided for @snackError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get snackError;

  /// No description provided for @snackSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get snackSuccess;

  /// No description provided for @snackNotice.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get snackNotice;

  /// No description provided for @placesServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled.'**
  String get placesServicesDisabled;

  /// No description provided for @placesPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are denied.'**
  String get placesPermissionDenied;

  /// No description provided for @placesPermissionDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied.'**
  String get placesPermissionDeniedForever;

  /// No description provided for @placesCurrentFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to get current location.'**
  String get placesCurrentFailed;

  /// No description provided for @placesCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get placesCurrentLocation;

  /// No description provided for @placesAddAddress.
  ///
  /// In en, this message translates to:
  /// **'Add Address'**
  String get placesAddAddress;

  /// No description provided for @placesAddYourAddress.
  ///
  /// In en, this message translates to:
  /// **'Add Your Address'**
  String get placesAddYourAddress;

  /// No description provided for @placesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for your location'**
  String get placesSearchHint;

  /// No description provided for @netTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Please check your internet.'**
  String get netTimeout;

  /// No description provided for @netNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again.'**
  String get netNoInternet;

  /// No description provided for @netCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request was cancelled.'**
  String get netCancelled;

  /// No description provided for @netUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error occurred.'**
  String get netUnexpected;

  /// No description provided for @net400.
  ///
  /// In en, this message translates to:
  /// **'Bad request. Please check your input.'**
  String get net400;

  /// No description provided for @net401.
  ///
  /// In en, this message translates to:
  /// **'Unauthorised. Please log in again.'**
  String get net401;

  /// No description provided for @net403.
  ///
  /// In en, this message translates to:
  /// **'Access denied.'**
  String get net403;

  /// No description provided for @net404.
  ///
  /// In en, this message translates to:
  /// **'Resource not found.'**
  String get net404;

  /// No description provided for @net422.
  ///
  /// In en, this message translates to:
  /// **'Validation failed. Please check your input.'**
  String get net422;

  /// No description provided for @net429.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please slow down.'**
  String get net429;

  /// No description provided for @net500.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get net500;

  /// No description provided for @net503.
  ///
  /// In en, this message translates to:
  /// **'Service unavailable. Please try later.'**
  String get net503;

  /// No description provided for @netCode.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong (code {code}).'**
  String netCode(int code);

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Actions that need the internet won\'t work until you reconnect.'**
  String get offlineBanner;

  /// No description provided for @noNotificationsHint.
  ///
  /// In en, this message translates to:
  /// **'New job requests appear as alerts on your phone. Stay online to receive them.'**
  String get noNotificationsHint;

  /// No description provided for @pushNewJobTitle.
  ///
  /// In en, this message translates to:
  /// **'New job request'**
  String get pushNewJobTitle;

  /// No description provided for @pushNewJobBody.
  ///
  /// In en, this message translates to:
  /// **'Open ReadyLocal Partner to accept or reject.'**
  String get pushNewJobBody;

  /// No description provided for @welcomeBenefitJobs.
  ///
  /// In en, this message translates to:
  /// **'Get verified job requests near you'**
  String get welcomeBenefitJobs;

  /// No description provided for @welcomeBenefitEarnings.
  ///
  /// In en, this message translates to:
  /// **'Track your earnings in one place'**
  String get welcomeBenefitEarnings;

  /// No description provided for @welcomeBenefitTime.
  ///
  /// In en, this message translates to:
  /// **'Work at the times that suit you'**
  String get welcomeBenefitTime;

  /// No description provided for @alertsOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Job alerts are off'**
  String get alertsOffTitle;

  /// No description provided for @alertsOffBody.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications so you don’t miss new jobs.'**
  String get alertsOffBody;

  /// No description provided for @alertsTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get alertsTurnOn;

  /// No description provided for @alertsSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Job alert settings'**
  String get alertsSettingsTitle;

  /// No description provided for @alertsSettingsIntro.
  ///
  /// In en, this message translates to:
  /// **'To get job alerts even when the app is closed, set these on your phone:'**
  String get alertsSettingsIntro;

  /// No description provided for @alertsStepNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications for ReadyLocal Partner'**
  String get alertsStepNotifications;

  /// No description provided for @alertsStepBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery: choose “No restrictions” or “Don’t optimise”'**
  String get alertsStepBattery;

  /// No description provided for @alertsStepAutostart.
  ///
  /// In en, this message translates to:
  /// **'Xiaomi, Oppo, Vivo, Realme: turn on Autostart'**
  String get alertsStepAutostart;

  /// No description provided for @alertsStepForceStop.
  ///
  /// In en, this message translates to:
  /// **'Don’t use “Force stop” on the app'**
  String get alertsStepForceStop;

  /// No description provided for @alertsOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open phone settings'**
  String get alertsOpenSettings;

  /// No description provided for @paymentFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentFailedTitle;

  /// No description provided for @paymentFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Try after sometime.'**
  String get paymentFailedBody;

  /// No description provided for @rateLine.
  ///
  /// In en, this message translates to:
  /// **'Rate: ₹{price} {unit}'**
  String rateLine(String price, String unit);

  /// No description provided for @alreadyRegisteredTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re already registered'**
  String get alreadyRegisteredTitle;

  /// No description provided for @alreadyRegisteredBody.
  ///
  /// In en, this message translates to:
  /// **'This mobile number already has a ReadyLocal Partner account. You don’t need to register again. Please continue to log in.'**
  String get alreadyRegisteredBody;

  /// No description provided for @alreadyRegisteredContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue to Login'**
  String get alreadyRegisteredContinue;

  /// No description provided for @verifyPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Details submitted'**
  String get verifyPendingTitle;

  /// No description provided for @verifyPendingBody.
  ///
  /// In en, this message translates to:
  /// **'Your verification is in process. Our team will review your details and update you soon.'**
  String get verifyPendingBody;

  /// No description provided for @verifyCheckStatus.
  ///
  /// In en, this message translates to:
  /// **'Check status'**
  String get verifyCheckStatus;

  /// No description provided for @verifySuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification successful'**
  String get verifySuccessTitle;

  /// No description provided for @verifySuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Your details are verified. You can now access the app.'**
  String get verifySuccessBody;

  /// No description provided for @verifyContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get verifyContinue;

  /// No description provided for @verifyRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification not approved'**
  String get verifyRejectedTitle;

  /// No description provided for @verifyRejectedReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get verifyRejectedReason;

  /// No description provided for @verifyRejectedNoReason.
  ///
  /// In en, this message translates to:
  /// **'Please check your documents and submit them again.'**
  String get verifyRejectedNoReason;

  /// No description provided for @verifyUpdateDetails.
  ///
  /// In en, this message translates to:
  /// **'Update and submit again'**
  String get verifyUpdateDetails;

  /// No description provided for @verifyOffline.
  ///
  /// In en, this message translates to:
  /// **'Could not check your status. Please check your internet and try again.'**
  String get verifyOffline;

  /// No description provided for @paymentDetailsReceived.
  ///
  /// In en, this message translates to:
  /// **'We have received your details'**
  String get paymentDetailsReceived;

  /// No description provided for @alertSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Job alert setup'**
  String get alertSetupTitle;

  /// No description provided for @alertSetupIntro.
  ///
  /// In en, this message translates to:
  /// **'Do these steps once so new jobs ring on your phone even when the app is closed.'**
  String get alertSetupIntro;

  /// No description provided for @alertSetupProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String alertSetupProgress(int done, int total);

  /// No description provided for @alertSetupAllDone.
  ///
  /// In en, this message translates to:
  /// **'All set. You will get job alerts even when the app is closed.'**
  String get alertSetupAllDone;

  /// No description provided for @alertStepNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get alertStepNotificationsTitle;

  /// No description provided for @alertStepNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Turn on “Allow notifications” for ReadyLocal Partner.'**
  String get alertStepNotificationsBody;

  /// No description provided for @alertStepChannelTitle.
  ///
  /// In en, this message translates to:
  /// **'Job request sound'**
  String get alertStepChannelTitle;

  /// No description provided for @alertStepChannelBody.
  ///
  /// In en, this message translates to:
  /// **'Open “New job requests” and allow sound and pop-up.'**
  String get alertStepChannelBody;

  /// No description provided for @alertStepBatteryTitle.
  ///
  /// In en, this message translates to:
  /// **'Battery: No restrictions'**
  String get alertStepBatteryTitle;

  /// No description provided for @alertStepBatteryBody.
  ///
  /// In en, this message translates to:
  /// **'Tap Battery (or App battery usage) and choose “Unrestricted” / “No restrictions” / “Don’t optimise”.'**
  String get alertStepBatteryBody;

  /// No description provided for @alertStepAutostartTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on Autostart'**
  String get alertStepAutostartTitle;

  /// No description provided for @alertStepAutostartBody.
  ///
  /// In en, this message translates to:
  /// **'Find ReadyLocal Partner in the list and switch Autostart on.'**
  String get alertStepAutostartBody;

  /// No description provided for @alertStepPopupTitle.
  ///
  /// In en, this message translates to:
  /// **'Pop-up and lock screen'**
  String get alertStepPopupTitle;

  /// No description provided for @alertStepPopupBody.
  ///
  /// In en, this message translates to:
  /// **'Allow “Display pop-up windows while running in background” and “Show on Lock screen”.'**
  String get alertStepPopupBody;

  /// No description provided for @alertSetupOpen.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get alertSetupOpen;

  /// No description provided for @alertSetupIDidThis.
  ///
  /// In en, this message translates to:
  /// **'I did this'**
  String get alertSetupIDidThis;

  /// No description provided for @alertSetupDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get alertSetupDone;

  /// No description provided for @alertSetupLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get alertSetupLater;

  /// No description provided for @alertSetupTest.
  ///
  /// In en, this message translates to:
  /// **'Play a test alert'**
  String get alertSetupTest;

  /// No description provided for @alertSetupTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Test job alert'**
  String get alertSetupTestTitle;

  /// No description provided for @alertSetupTestBody.
  ///
  /// In en, this message translates to:
  /// **'If you can hear this, job alerts are working.'**
  String get alertSetupTestBody;

  /// No description provided for @alertsFix.
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get alertsFix;

  /// No description provided for @alertsSetupNeededTitle.
  ///
  /// In en, this message translates to:
  /// **'Job alerts may be missed'**
  String get alertsSetupNeededTitle;

  /// No description provided for @alertsSetupNeededBody.
  ///
  /// In en, this message translates to:
  /// **'Finish the job alert setup so jobs ring when the app is closed.'**
  String get alertsSetupNeededBody;

  /// No description provided for @jobTakenByOther.
  ///
  /// In en, this message translates to:
  /// **'This job was accepted by another partner.'**
  String get jobTakenByOther;

  /// No description provided for @welcomeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Earn more with your skills'**
  String get welcomeHeadline;

  /// No description provided for @welcomeSubline.
  ///
  /// In en, this message translates to:
  /// **'Join ReadyLocal Partner and get job requests from customers near you.'**
  String get welcomeSubline;

  /// No description provided for @loginTitleLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitleLogin;

  /// No description provided for @loginHeadingLogin.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginHeadingLogin;

  /// No description provided for @loginSubheadingLogin.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered mobile number. We will send you an OTP.'**
  String get loginSubheadingLogin;

  /// No description provided for @loginSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get loginSendOtp;

  /// No description provided for @loginSwitchToLogin.
  ///
  /// In en, this message translates to:
  /// **'Already a partner? Login'**
  String get loginSwitchToLogin;

  /// No description provided for @loginSwitchToRegister.
  ///
  /// In en, this message translates to:
  /// **'New to ReadyLocal? Register'**
  String get loginSwitchToRegister;

  /// No description provided for @selectServiceFeeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the registration fee. Please check your internet and try again.'**
  String get selectServiceFeeFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
