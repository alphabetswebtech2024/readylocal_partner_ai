// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => 'రెడీలోకల్ పార్ట్‌నర్';

  @override
  String get commonViewAll => 'అన్నీ చూడండి';

  @override
  String get commonMoreDetails => 'మరిన్ని వివరాలు';

  @override
  String get commonCancel => 'రద్దు చేయండి';

  @override
  String get commonYes => 'అవును';

  @override
  String get commonNo => 'కాదు';

  @override
  String get commonNext => 'తదుపరి';

  @override
  String get commonSubmit => 'సమర్పించండి';

  @override
  String get commonSave => 'సేవ్ చేయండి';

  @override
  String get commonContinue => 'కొనసాగించండి';

  @override
  String get commonRetry => 'మళ్లీ ప్రయత్నించండి';

  @override
  String get commonOk => 'సరే';

  @override
  String get commonPleaseWait => 'దయచేసి వేచి ఉండండి...';

  @override
  String get commonSomethingWentWrong =>
      'ఏదో పొరపాటు జరిగింది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get commonNoInternet =>
      'ఇంటర్నెట్ కనెక్షన్ లేదు. దయచేసి మీ నెట్‌వర్క్‌ను తనిఖీ చేయండి.';

  @override
  String get statusOnline => 'ఆన్‌లైన్';

  @override
  String get statusOffline => 'ఆఫ్‌లైన్';

  @override
  String get statusOngoing => 'కొనసాగుతున్నవి';

  @override
  String get statusCompleted => 'పూర్తయినవి';

  @override
  String get statusPending => 'పెండింగ్';

  @override
  String get statusInProgress => 'పురోగతిలో ఉంది';

  @override
  String get periodDaily => 'రోజువారీ';

  @override
  String get periodWeekly => 'వారానికి';

  @override
  String get periodMonthly => 'నెలవారీ';

  @override
  String homeWelcomeName(String name) {
    return 'స్వాగతం $name';
  }

  @override
  String get homeWelcomeBack => 'తిరిగి స్వాగతం';

  @override
  String get homeLocationFallback => 'స్థానం';

  @override
  String get homeTotalRequest => 'మొత్తం అభ్యర్థనలు';

  @override
  String get homeEarnings => 'సంపాదన';

  @override
  String get homeJobs => 'పనులు';

  @override
  String get homeTodaysEarning => 'ఈరోజు సంపాదన';

  @override
  String get homeWeeklyEarning => 'ఈ వారం సంపాదన';

  @override
  String get homeMonthlyEarning => 'ఈ నెల సంపాదన';

  @override
  String homeJobsToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ఈరోజు $count పనులు',
    );
    return '$_temp0';
  }

  @override
  String homeJobsThisWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ఈ వారం $count పనులు',
    );
    return '$_temp0';
  }

  @override
  String homeJobsThisMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ఈ నెల $count పనులు',
    );
    return '$_temp0';
  }

  @override
  String get homeNoOngoingJobs => 'కొనసాగుతున్న పనులు లేవు';

  @override
  String get homeNoOngoingJobsHint =>
      'కొత్త పని అభ్యర్థనలు పొందడానికి ఆన్‌లైన్‌లో ఉండండి.';

  @override
  String get homeNoCompletedJobs => 'పూర్తయిన పనులు లేవు';

  @override
  String get homeSessionErrorTitle => 'సెషన్ లోపం';

  @override
  String get homeSessionErrorMessage =>
      'ఏదో పొరపాటు జరిగింది, దయచేసి లాగిన్ అవ్వండి.';

  @override
  String get homeYouAreOnline => 'మీరు ఇప్పుడు ఆన్‌లైన్‌లో ఉన్నారు.';

  @override
  String get homeYouAreOffline => 'మీరు ఇప్పుడు ఆఫ్‌లైన్‌లో ఉన్నారు.';

  @override
  String get homeJobDetailsFailed => 'పని వివరాలు లోడ్ కాలేదు.';

  @override
  String get homeOpenProfile => 'ప్రొఫైల్ తెరవండి';

  @override
  String get homeOnlineToggleHint => 'ఆన్‌లైన్ లేదా ఆఫ్‌లైన్‌కు మారండి';

  @override
  String get loginTitle => 'నమోదు';

  @override
  String get loginHeading => 'రెడీలోకల్ పార్ట్‌నర్‌లో భాగం అవ్వండి';

  @override
  String get loginSubheading =>
      'మీ వ్యాపారాన్ని మెరుగుపరచుకోవడానికి మొదటి అడుగు వేయండి.';

  @override
  String get loginPhoneLabel => 'ఫోన్ నంబర్';

  @override
  String get loginPhoneRequired => 'ఫోన్ నంబర్ అవసరం';

  @override
  String get loginPhoneDigitsOnly => 'ఫోన్ నంబర్‌లో అంకెలు మాత్రమే ఉండాలి';

  @override
  String get loginPhoneInvalidIndia =>
      'సరైన 10 అంకెల భారతీయ మొబైల్ నంబర్ నమోదు చేయండి';

  @override
  String get loginPhoneStartDigit =>
      'భారతీయ నంబర్లు 6, 7, 8 లేదా 9తో ప్రారంభం కావాలి';

  @override
  String get loginPhoneInvalid => 'సరైన ఫోన్ నంబర్ నమోదు చేయండి (7–15 అంకెలు)';

  @override
  String get loginFailed => 'విఫలమైంది';

  @override
  String get loginSelectCountryCode => 'దేశ కోడ్ ఎంచుకోండి';

  @override
  String get loginCountryIndia => 'భారతదేశం';

  @override
  String get loginAgreePrefix => 'కొనసాగడం ద్వారా మీరు మా ';

  @override
  String get loginTerms => 'నిబంధనలు';

  @override
  String get loginAnd => ' మరియు ';

  @override
  String get loginPrivacy => 'గోప్యతా విధానం';

  @override
  String get loginAgreeSuffix => 'కు అంగీకరిస్తున్నారు';

  @override
  String get loginBecomePartner => 'పార్ట్‌నర్ అవ్వండి';

  @override
  String get webTermsTitle => 'నిబంధనలు & షరతులు';

  @override
  String get webPrivacyTitle => 'గోప్యతా విధానం';

  @override
  String get webAboutTitle => 'మా గురించి';

  @override
  String get earningsTitle => 'సంపాదన';

  @override
  String get earningsOverview => 'సంపాదన సారాంశం';

  @override
  String get earningsAvailableBalance => 'అందుబాటులో ఉన్న బ్యాలెన్స్';

  @override
  String get earningsSendWithdraw => 'విత్‌డ్రా అభ్యర్థన పంపండి';

  @override
  String get earningsBankTransaction => 'బ్యాంక్ లావాదేవీలు';

  @override
  String get earningsNoTransactions => 'లావాదేవీలు ఏవీ లేవు.';

  @override
  String get commonBack => 'వెనుకకు';

  @override
  String get earningsBankTransactionItem => 'బ్యాంక్ లావాదేవీ';

  @override
  String get jobNotificationTitle => 'పని నోటిఫికేషన్';

  @override
  String get jobServiceRequest => 'సేవ అభ్యర్థన';

  @override
  String get jobCustomer => 'కస్టమర్';

  @override
  String jobDistanceKm(String distance) {
    return '$distance కి.మీ';
  }

  @override
  String get jobAccept => 'అంగీకరించు';

  @override
  String get jobReject => 'తిరస్కరించు';

  @override
  String get jobDetails => 'వివరాలు';

  @override
  String get jobAcceptTitle => 'పనిని అంగీకరించండి';

  @override
  String get jobAcceptMessage => 'మీరు ఈ పనిని అంగీకరించాలనుకుంటున్నారా?';

  @override
  String get jobRejectTitle => 'పనిని తిరస్కరించండి';

  @override
  String get jobRejectMessage => 'మీరు ఈ పనిని తిరస్కరించాలనుకుంటున్నారా?';

  @override
  String get jobWait => 'వేచి ఉండండి...';

  @override
  String get jobRejectionReason => 'తిరస్కరణ కారణం';

  @override
  String get jobRejectionHint =>
      'మీరు ఈ పనిని ఎందుకు తిరస్కరిస్తున్నారో చెప్పండి...';

  @override
  String get jobSubmitting => 'సమర్పిస్తోంది...';

  @override
  String get commonClose => 'మూసివేయండి';

  @override
  String get jobTimeLeft => 'స్పందించడానికి మిగిలిన సమయం';

  @override
  String get profileTitle => 'నా ప్రొఫైల్';

  @override
  String get profileViewProfile => 'ప్రొఫైల్ చూడండి';

  @override
  String get profileAbout => 'రెడీలోకల్ పార్ట్‌నర్ గురించి';

  @override
  String get profileTerms => 'నిబంధనలు & షరతులు';

  @override
  String get profilePrivacy => 'గోప్యతా విధానం';

  @override
  String get profileLogout => 'లాగ్ అవుట్';

  @override
  String get profileLogoutConfirm => 'మీరు లాగ్ అవుట్ అవ్వాలనుకుంటున్నారా?';

  @override
  String get profileDeleteAccount => 'ఖాతాను తొలగించండి';

  @override
  String get profileLanguage => 'భాష';

  @override
  String get profileChooseLanguage => 'భాషను ఎంచుకోండి';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTelugu => 'తెలుగు';

  @override
  String get jobsAllJobs => 'అన్ని పనులు';

  @override
  String get otpEnterComplete => 'పూర్తి OTP నమోదు చేయండి';

  @override
  String get otpInvalid => 'OTP తప్పు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get otpResent => 'OTP మళ్లీ పంపబడింది';

  @override
  String get otpResendFailed => 'OTP మళ్లీ పంపడం విఫలమైంది';

  @override
  String get otpVerify => 'ధృవీకరించండి';

  @override
  String get otpHeading =>
      'రెడీలోకల్ పార్ట్‌నర్‌లో చేరడానికి మీ నంబర్‌ను ధృవీకరించండి';

  @override
  String get otpSentTo => 'ధృవీకరణ కోడ్‌ను ఈ నంబర్‌కు పంపాము';

  @override
  String get otpEdit => 'మార్చండి';

  @override
  String get otpResend => 'OTP మళ్లీ పంపండి';

  @override
  String get selectServiceRequired => 'కొనసాగడానికి దయచేసి ఒక సేవను ఎంచుకోండి.';

  @override
  String get selectServiceTitle => 'మీ సేవను ఎంచుకోండి';

  @override
  String get verifiedTitle => 'ధృవీకరించబడింది';

  @override
  String get welcomeReadOur => 'దయచేసి మా ';

  @override
  String get welcomeAnd => ' మరియు ';

  @override
  String get welcomeReadSuffix => ' చదవండి';

  @override
  String get welcomeRegister => 'నమోదు';

  @override
  String get welcomeLogin => 'లాగిన్';

  @override
  String get jobSummary => 'పని సారాంశం';

  @override
  String get labelOrderId => 'ఆర్డర్ ID';

  @override
  String get labelScheduledOn => 'షెడ్యూల్ తేదీ';

  @override
  String get labelDistanceTraveled => 'ప్రయాణించిన దూరం';

  @override
  String get customerDetailsTitle => 'కస్టమర్ వివరాలు';

  @override
  String get labelName => 'పేరు';

  @override
  String get labelPhone => 'ఫోన్';

  @override
  String get labelLocation => 'స్థానం';

  @override
  String get labelEmail => 'ఈమెయిల్ ID';

  @override
  String get paymentSummary => 'చెల్లింపు సారాంశం';

  @override
  String get paymentServiceTotal => 'సేవ మొత్తం';

  @override
  String get paymentAmountCollected => 'వసూలు చేసిన మొత్తం';

  @override
  String get mapStartLocation => 'ప్రారంభ స్థానం';

  @override
  String get mapDestination => 'గమ్యస్థానం';

  @override
  String get rideStartedSuccess => 'ప్రయాణం విజయవంతంగా ప్రారంభమైంది!';

  @override
  String get reachedRecorded => 'చేరుకున్నట్లు నమోదైంది!';

  @override
  String get statusUpdateFailed => 'స్థితిని అప్‌డేట్ చేయడం విఫలమైంది';

  @override
  String get labelServiceBookedDate => 'సేవ బుక్ చేసిన తేదీ';

  @override
  String get labelServiceBookedTime => 'సేవ బుక్ చేసిన సమయం';

  @override
  String get getDirection => 'దారి చూపించు';

  @override
  String get mapLabel => 'మ్యాప్';

  @override
  String get callLabel => 'కాల్';

  @override
  String get startRide => 'ప్రయాణం ప్రారంభించండి';

  @override
  String get reachedLocation => 'స్థానానికి చేరుకున్నాను';

  @override
  String get processing => 'ప్రాసెస్ చేస్తోంది...';

  @override
  String get jobExpired => 'ఈ పని అభ్యర్థన గడువు ముగిసింది.';

  @override
  String get warningTitle => 'హెచ్చరిక';

  @override
  String get jobAcceptedSuccess => 'పని విజయవంతంగా అంగీకరించబడింది!';

  @override
  String get jobAcceptFailed => 'పనిని అంగీకరించడం విఫలమైంది';

  @override
  String get jobRejectReasonTitle =>
      'పనిని తిరస్కరించడానికి కారణాన్ని సమర్పించండి';

  @override
  String get jobRejectReasonHint => 'పనిని తిరస్కరించడానికి కారణం రాయండి';

  @override
  String get enterReason => 'దయచేసి కారణం నమోదు చేయండి.';

  @override
  String get jobRejected => 'పని తిరస్కరించబడింది.';

  @override
  String get jobRejectFailed => 'పనిని తిరస్కరించడం విఫలమైంది.';

  @override
  String get overviewTitle => 'పని వివరాలు';

  @override
  String get instantLabel => 'తక్షణం';

  @override
  String get aboutService => 'సేవ గురించి';

  @override
  String get serviceBookedBy => 'సేవ బుక్ చేసినవారు';

  @override
  String get uploadAtLeastOne =>
      'దయచేసి పని యొక్క కనీసం ఒక చిత్రాన్ని అప్‌లోడ్ చేయండి.';

  @override
  String get waitForUploads =>
      'దయచేసి అన్ని చిత్రాలు అప్‌లోడ్ అయ్యే వరకు వేచి ఉండండి.';

  @override
  String get someUploadsFailed =>
      'కొన్ని చిత్రాలు అప్‌లోడ్ కాలేదు. దయచేసి వాటిని తొలగించండి లేదా మళ్లీ ప్రయత్నించండి.';

  @override
  String get takePhoto => 'ఫోటో తీయండి';

  @override
  String get chooseFromGallery => 'గ్యాలరీ నుండి ఎంచుకోండి';

  @override
  String get selectAvailability => 'దయచేసి కస్టమర్ అందుబాటును ఎంచుకోండి.';

  @override
  String get enterFeedback =>
      'సమర్పించే ముందు దయచేసి అభిప్రాయం/కారణం నమోదు చేయండి.';

  @override
  String get closeJob => 'పనిని ముగించండి';

  @override
  String get closeJobConfirm => 'మీరు ఈ పనిని ముగించాలనుకుంటున్నారా?';

  @override
  String get cancelJobFailed =>
      'పనిని రద్దు చేయడం విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get completeJobFailed =>
      'పనిని పూర్తి చేయడం విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get partnerFallback => 'పార్ట్‌నర్';

  @override
  String get jobProgressTitle => 'పని పురోగతి';

  @override
  String get startJob => 'పని ప్రారంభించండి';

  @override
  String get fillDetailsBeforeWork => 'పని ప్రారంభించే ముందు వివరాలు నింపండి';

  @override
  String get customerAvailable => 'కస్టమర్ అందుబాటులో ఉన్నారా?';

  @override
  String get selectHint => 'ఎంచుకోండి';

  @override
  String get selfieTitle => 'ఉత్పత్తితో సెల్ఫీ తీయండి';

  @override
  String get selfieSubtitle =>
      'కస్టమర్ వద్దకు చేరుకున్న తర్వాత ఉత్పత్తితో సెల్ఫీ అప్‌లోడ్ చేయండి.';

  @override
  String get beforeRepairTitle => 'రిపేర్‌కు ముందు ఉత్పత్తి ఫోటో తీయండి.';

  @override
  String get beforeRepairSubtitle =>
      'రిపేర్‌కు ముందు ఉత్పత్తి చిత్రాన్ని అప్‌లోడ్ చేయండి.';

  @override
  String get afterRepairTitle => 'రిపేర్ తర్వాత ఉత్పత్తి ఫోటో తీయండి.';

  @override
  String get afterRepairSubtitle =>
      'రిపేర్ తర్వాత ఉత్పత్తి చిత్రాన్ని అప్‌లోడ్ చేయండి.';

  @override
  String get feedbackReason => 'అభిప్రాయం / కారణం';

  @override
  String get feedbackHint => 'ఉత్పత్తి రిపేర్ గురించి మీ అభిప్రాయం రాయండి';

  @override
  String get closeReasonHint => 'పనిని ఎందుకు ముగిస్తున్నారో కారణం రాయండి';

  @override
  String get workDone => 'పని పూర్తయింది';

  @override
  String get addMore => 'మరిన్ని జోడించండి';

  @override
  String get noAddressProvided => 'చిరునామా ఇవ్వలేదు';

  @override
  String get enterReasonBeforeSubmit =>
      'సమర్పించే ముందు దయచేసి కారణం నమోదు చేయండి.';

  @override
  String get notificationsTitle => 'నోటిఫికేషన్లు';

  @override
  String get noNotifications => 'ఇంకా నోటిఫికేషన్లు లేవు';

  @override
  String get jobCancelledTitle => 'పని రద్దయింది';

  @override
  String get jobCancelledMessage =>
      'ఈ పని అభ్యర్థనను కస్టమర్ రద్దు చేశారు లేదా గడువు ముగిసింది.';

  @override
  String get networkError => 'నెట్‌వర్క్ లోపం. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get enterRejectionReason => 'దయచేసి తిరస్కరణ కారణం నమోదు చేయండి';

  @override
  String get loadingJobDetails => 'పని వివరాలు లోడ్ అవుతున్నాయి...';

  @override
  String get newNotification => 'కొత్త నోటిఫికేషన్';

  @override
  String get earlierLabel => 'ఇంతకుముందు';

  @override
  String get workStatusReceived => 'మీ పని స్థితి మాకు అందింది';

  @override
  String get backToHome => 'హోమ్‌కు వెళ్ళండి';

  @override
  String thankYouName(String name) {
    return 'ధన్యవాదాలు $name';
  }

  @override
  String get feeUpdateFailed => 'ప్రొఫైల్ వివరాలు అప్‌డేట్ చేయడం విఫలమైంది.';

  @override
  String feeUnexpectedError(String error) {
    return 'అనుకోని లోపం జరిగింది: $error';
  }

  @override
  String get feeTitle => 'పార్ట్‌నర్ యాక్టివేషన్ ఫీజు';

  @override
  String get feeDescription =>
      'ఇందులో చేరడానికి ఒక్కసారి నమోదు ఫీజు చెల్లించాలి';

  @override
  String get feePayNow => 'ఇప్పుడే చెల్లించండి';

  @override
  String get bankAddedSuccess => 'బ్యాంక్ ఖాతా విజయవంతంగా జోడించబడింది';

  @override
  String get bankAddFailed => 'బ్యాంక్ వివరాలు జోడించడం విఫలమైంది';

  @override
  String get bankAddTitle => 'బ్యాంక్ వివరాలు జోడించండి';

  @override
  String get bankName => 'బ్యాంక్ పేరు';

  @override
  String get bankNameHint => 'బ్యాంక్ పేరు నమోదు చేయండి';

  @override
  String get bankNameRequired => 'బ్యాంక్ పేరు అవసరం';

  @override
  String get bankAccountNumber => 'ఖాతా నంబర్';

  @override
  String get bankAccountNumberHint => 'ఖాతా నంబర్ నమోదు చేయండి';

  @override
  String get bankAccountNumberRequired => 'ఖాతా నంబర్ అవసరం';

  @override
  String get bankAccountNumberInvalid =>
      'సరైన ఖాతా నంబర్ నమోదు చేయండి (9-18 అంకెలు)';

  @override
  String get bankHolderName => 'ఖాతాదారుని పేరు';

  @override
  String get bankHolderNameHint => 'ఖాతాదారుని పేరు నమోదు చేయండి';

  @override
  String get bankHolderNameRequired => 'ఖాతాదారుని పేరు అవసరం';

  @override
  String get bankIfsc => 'IFSC కోడ్';

  @override
  String get bankIfscHint => 'IFSC కోడ్ నమోదు చేయండి';

  @override
  String get bankIfscRequired => 'IFSC కోడ్ అవసరం';

  @override
  String get bankIfscLabel => 'IFSC కోడ్';

  @override
  String get paymentRequestAccepted => 'అభ్యర్థన అంగీకరించబడింది';

  @override
  String get paymentReceived => 'మీ చెల్లింపు మాకు అందింది';

  @override
  String get paymentTeamWillContact =>
      '\nమా బృందం 24-48 గంటల్లో మిమ్మల్ని సంప్రదిస్తుంది';

  @override
  String get paymentExploreApp => 'యాప్‌ను చూడండి';

  @override
  String get genderSelect => 'లింగాన్ని ఎంచుకోండి';

  @override
  String get genderMale => 'పురుషుడు';

  @override
  String get genderFemale => 'స్త్రీ';

  @override
  String get optionalSuffix => ' (తప్పనిసరి కాదు)';

  @override
  String get personalInfoTitle => 'వ్యక్తిగత సమాచారం';

  @override
  String get personalInfoSubtitle => 'మీ వ్యక్తిగత సమాచారాన్ని జోడించండి';

  @override
  String get firstName => 'మొదటి పేరు';

  @override
  String get firstNameHint => 'మీ మొదటి పేరు నమోదు చేయండి';

  @override
  String get firstNameRequired => 'మొదటి పేరు అవసరం';

  @override
  String get lastName => 'ఇంటి పేరు';

  @override
  String get lastNameHint => 'మీ ఇంటి పేరు నమోదు చేయండి';

  @override
  String get lastNameRequired => 'ఇంటి పేరు అవసరం';

  @override
  String get emailLabel => 'ఈమెయిల్';

  @override
  String get emailHint => 'మీ ఈమెయిల్ ID నమోదు చేయండి';

  @override
  String get emailInvalid => 'సరైన ఈమెయిల్ చిరునామా నమోదు చేయండి';

  @override
  String get genderLabel => 'లింగం';

  @override
  String get genderHint => 'మీ లింగాన్ని ఎంచుకోండి';

  @override
  String get genderRequired => 'దయచేసి లింగాన్ని ఎంచుకోండి';

  @override
  String get addressLabel => 'చిరునామా';

  @override
  String get addressSearchHint => 'ప్రాంతం/వీధి/లొకాలిటీ కోసం వెతకండి';

  @override
  String get addressRequired => 'చిరునామా అవసరం';

  @override
  String get houseLabel => 'ప్రాంతం/ఇల్లు/ఫ్లాట్ నం.';

  @override
  String get houseHint => 'మీ ఇల్లు/ఫ్లాట్/అపార్ట్‌మెంట్ నం. నమోదు చేయండి';

  @override
  String get cityLabel => 'నగరం';

  @override
  String get cityHint => 'మీ నగరం నమోదు చేయండి';

  @override
  String get cityRequired => 'నగరం అవసరం';

  @override
  String get stateLabel => 'రాష్ట్రం';

  @override
  String get stateHint => 'మీ రాష్ట్రం నమోదు చేయండి';

  @override
  String get stateRequired => 'రాష్ట్రం అవసరం';

  @override
  String get pinLabel => 'పిన్ కోడ్';

  @override
  String get pinHint => 'మీ పిన్ కోడ్ నమోదు చేయండి';

  @override
  String get pinRequired => 'పిన్ కోడ్ అవసరం';

  @override
  String get pinInvalid => 'సరైన 6 అంకెల పిన్ కోడ్ నమోదు చేయండి';

  @override
  String get txnDetailsTitle => 'లావాదేవీ వివరాలు';

  @override
  String get txnId => 'లావాదేవీ ID';

  @override
  String get txnIdCopied => 'లావాదేవీ ID కాపీ చేయబడింది!';

  @override
  String get txnPaidThrough => 'చెల్లించిన విధానం';

  @override
  String get txnAmount => 'మొత్తం';

  @override
  String get txnTax => 'పన్ను';

  @override
  String get txnTotalAmount => 'మొత్తం చెల్లింపు';

  @override
  String get txnBankAccount => 'బ్యాంక్ ఖాతా';

  @override
  String get txnLoadFailed => 'లావాదేవీ వివరాలు లోడ్ కాలేదు.';

  @override
  String get fullNameLabel => 'పూర్తి పేరు';

  @override
  String get withdrawNoBankSelected => 'బ్యాంక్ ఖాతా ఎంచుకోలేదు.';

  @override
  String get withdrawInvalidAmount => 'దయచేసి సరైన మొత్తం నమోదు చేయండి.';

  @override
  String get withdrawExceedsBalance =>
      'మొత్తం అందుబాటులో ఉన్న బ్యాలెన్స్‌ను మించింది.';

  @override
  String get withdrawNoBank => 'బ్యాంక్ ఖాతా కనుగొనబడలేదు.';

  @override
  String get withdrawSuccess => 'విత్‌డ్రా అభ్యర్థన విజయవంతమైంది!';

  @override
  String get withdrawTitle => 'విత్‌డ్రా';

  @override
  String get withdrawEnterAmount => 'విత్‌డ్రా చేయాల్సిన మొత్తం నమోదు చేయండి';

  @override
  String get withdrawAddAnotherBank => 'మరో బ్యాంక్ వివరాలు జోడించండి';

  @override
  String get withdrawSendRequest => 'అభ్యర్థన పంపండి';

  @override
  String get setupSelectAtLeastOneCategory =>
      'దయచేసి కనీసం ఒక వర్గాన్ని ఎంచుకోండి.';

  @override
  String get setupSelectAtLeastOneService => 'దయచేసి కనీసం ఒక సేవను ఎంచుకోండి.';

  @override
  String get setupSelectExperience => 'దయచేసి అనుభవ సంవత్సరాలను ఎంచుకోండి.';

  @override
  String get setupSelectCategories => 'వర్గాలను ఎంచుకోండి';

  @override
  String get setupSelectCategory => 'వర్గాన్ని ఎంచుకోండి';

  @override
  String get setupNoCategories => 'వర్గాలు అందుబాటులో లేవు';

  @override
  String get setupDone => 'పూర్తయింది';

  @override
  String get setupSelectService => 'సేవను ఎంచుకోండి';

  @override
  String get setupSelectServiceType => 'సేవ రకాన్ని ఎంచుకోండి';

  @override
  String get setupSelectServices => 'సేవలను ఎంచుకోండి';

  @override
  String get setupErrorFetching => 'డేటా పొందడంలో లోపం';

  @override
  String get setupNoItems => 'అంశాలు అందుబాటులో లేవు';

  @override
  String get setupNoData => 'డేటా అందుబాటులో లేదు';

  @override
  String get setupSelectYears => 'సంవత్సరాలను ఎంచుకోండి';

  @override
  String setupCategoriesSelected(int count) {
    return '$count వర్గాలు ఎంచుకున్నారు';
  }

  @override
  String setupServicesSelected(int count) {
    return '$count సేవలు ఎంచుకున్నారు';
  }

  @override
  String setupSubCategoriesSelected(int count) {
    return '$count ఉప వర్గాలు ఎంచుకున్నారు';
  }

  @override
  String get setupAddCategoriesTitle => 'వర్గాలు & ఉప వర్గాలు జోడించండి';

  @override
  String get setupAddCategoriesSubtitle =>
      'రెడీలోకల్ పార్ట్‌నర్ అవ్వడానికి తదుపరి దశగా దయచేసి వర్గాలు & ఉప వర్గాలు జోడించండి.';

  @override
  String get setupAddCategoriesServicesTitle =>
      'వర్గాలు జోడించి సేవలను ఎంచుకోండి';

  @override
  String get setupAddCategoriesServicesSubtitle =>
      'రెడీలోకల్ పార్ట్‌నర్ అవ్వడానికి తదుపరి దశగా దయచేసి వర్గాలు & సేవలు జోడించండి.';

  @override
  String get setupCategories => 'వర్గాలు';

  @override
  String get setupServices => 'సేవలు';

  @override
  String get setupService => 'సేవ';

  @override
  String get setupServiceType => 'సేవ రకం';

  @override
  String get setupSubCategories => 'ఉప వర్గాలు';

  @override
  String get setupSelectSubCategories => 'ఉప వర్గాలను ఎంచుకోండి';

  @override
  String get setupSelectedSubCategories => 'ఎంచుకున్న ఉప వర్గాలు';

  @override
  String get setupYearOfExperience => 'అనుభవ సంవత్సరాలు';

  @override
  String get setupNoVariants => 'వేరియంట్లు ఎంచుకోలేదు';

  @override
  String get setupSelectCategoryError => 'దయచేసి ఒక వర్గాన్ని ఎంచుకోండి.';

  @override
  String get setupSelectSubCategoryAtLeastOne =>
      'దయచేసి కనీసం ఒక ఉప వర్గాన్ని ఎంచుకోండి.';

  @override
  String get setupSelectSubCategory => 'దయచేసి ఒక ఉప వర్గాన్ని ఎంచుకోండి.';

  @override
  String get setupSelectServiceError => 'దయచేసి ఒక సేవను ఎంచుకోండి.';

  @override
  String get setupServiceDurationRates => 'సేవ వ్యవధి & ధరలు';

  @override
  String get setupServiceRateRequired => 'సేవ ధర అవసరం.';

  @override
  String setupEnterRateFor(String name) {
    return '$name కోసం ధర నమోదు చేయండి';
  }

  @override
  String get setupEnterHourRate => 'గంటకు ధర నమోదు చేయండి';

  @override
  String get setupEnterDayRate => 'రోజుకు ధర నమోదు చేయండి';

  @override
  String get setupEnter24Rate => '24 గంటల ధర నమోదు చేయండి';

  @override
  String get setupEnterValidAmount => 'దయచేసి సరైన మొత్తం నమోదు చేయండి';

  @override
  String get setupInvalidInput => 'చెల్లని ఇన్‌పుట్';

  @override
  String get setupConfirm => 'నిర్ధారించండి';

  @override
  String get driverFetchingLocation => 'స్థానాన్ని పొందుతోంది...';

  @override
  String get driverLocationDenied => 'స్థాన అనుమతి నిరాకరించబడింది';

  @override
  String get driverLocationDeniedForever =>
      'స్థాన అనుమతులు శాశ్వతంగా నిరాకరించబడ్డాయి';

  @override
  String get driverLocationDetected => 'ప్రస్తుత స్థానం గుర్తించబడింది';

  @override
  String get driverLocationFailed => 'స్థానాన్ని పొందడం సాధ్యం కాలేదు';

  @override
  String driverSetRateFor(String name) {
    return '$name కోసం ధర నిర్ణయించండి';
  }

  @override
  String driverEnterRate(String unit) {
    return 'ధర నమోదు చేయండి ($unit):';
  }

  @override
  String get driverSaveRate => 'ధర సేవ్ చేయండి';

  @override
  String get driverSelectServiceType =>
      'దయచేసి కనీసం ఒక సేవ రకాన్ని ఎంచుకోండి.';

  @override
  String get driverSelectExperience => 'దయచేసి మీ అనుభవాన్ని ఎంచుకోండి.';

  @override
  String get driverSelectLicense => 'దయచేసి మీ లైసెన్స్ రకాన్ని ఎంచుకోండి.';

  @override
  String get driverSelectLanguage => 'దయచేసి కనీసం ఒక భాషను ఎంచుకోండి.';

  @override
  String get driverSelectVehicle => 'దయచేసి కనీసం ఒక వాహన రకాన్ని ఎంచుకోండి.';

  @override
  String get driverSaveFailed => 'ప్రొఫైల్ సేవ్ చేయడం విఫలమైంది';

  @override
  String get driverDetailsTitle => 'డ్రైవర్ వివరాలు';

  @override
  String get driverSelectServiceTypes => 'సేవ రకాలను ఎంచుకోండి';

  @override
  String get driverExperience => 'అనుభవం';

  @override
  String get driverLicenseType => 'లైసెన్స్ రకం';

  @override
  String get driverLanguages => 'భాష(లు)';

  @override
  String get driverPreferredLocation => 'పని కోసం ఇష్టపడే స్థానం';

  @override
  String get driverVehicleTypes => 'వాహనాల రకాలు';

  @override
  String get driverSafetySkills => 'భద్రత / ప్రత్యేక నైపుణ్యాలు';

  @override
  String get driverSelectExperienceHint => 'అనుభవాన్ని ఎంచుకోండి';

  @override
  String get driverSelectLicenseHint => 'లైసెన్స్ రకాన్ని ఎంచుకోండి';

  @override
  String get driverSaveDetails => 'వివరాలు సేవ్ చేయండి';

  @override
  String get docProfilePicture => 'ప్రొఫైల్ ఫోటో';

  @override
  String get docProfilePictureSub =>
      'స్పష్టమైన ప్రొఫైల్ ఫోటోను అప్‌లోడ్ చేయండి';

  @override
  String get docAadhaarFront => 'ఆధార్ కార్డ్ ముందు భాగం అప్‌లోడ్ చేయండి';

  @override
  String get docAadhaarBack => 'ఆధార్ కార్డ్ వెనుక భాగం అప్‌లోడ్ చేయండి';

  @override
  String get docPan => 'పాన్ కార్డ్ అప్‌లోడ్ చేయండి';

  @override
  String get docAddressProof => 'చిరునామా రుజువు (బిల్లు/అద్దె)';

  @override
  String get docAddressProofSub => 'బిల్లు/అద్దె ఒప్పందాన్ని అప్‌లోడ్ చేయండి';

  @override
  String get docToolPhotos => 'పరికరాల ఫోటోలు';

  @override
  String get docDrivingLicense => 'డ్రైవింగ్ లైసెన్స్ అప్‌లోడ్ చేయండి';

  @override
  String get docDrivingLicenseSub => 'డ్రైవర్ ధృవీకరణకు అవసరం';

  @override
  String get docQualification => 'అర్హత సర్టిఫికేట్ అప్‌లోడ్ చేయండి';

  @override
  String get docQualificationSub => 'వైద్య ధృవీకరణకు అవసరం';

  @override
  String get docExperience => 'అనుభవ సర్టిఫికేట్ అప్‌లోడ్ చేయండి';

  @override
  String get docExperienceSub => 'ధృవీకరణకు అవసరం';

  @override
  String get docQualificationLabel => 'అర్హత';

  @override
  String get docAvailabilityLabel => 'అందుబాటు';

  @override
  String docUploadFailedFor(String name) {
    return '$name అప్‌లోడ్ విఫలమైంది. దయచేసి మళ్లీ ప్రయత్నించండి.';
  }

  @override
  String get docCameraDisabled =>
      'కెమెరా అనుమతి నిలిపివేయబడింది. ఫోటో తీయడానికి సెట్టింగ్స్‌లో అనుమతించండి.';

  @override
  String get docCameraRequired => 'ఫోటోలు తీయడానికి కెమెరా అనుమతి అవసరం.';

  @override
  String get docCameraFailed =>
      'కెమెరా తెరవడం సాధ్యం కాలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get docGalleryFailed =>
      'ఫోటో గ్యాలరీ తెరవడం సాధ్యం కాలేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get docUploadsInProgress =>
      'దయచేసి వేచి ఉండండి, అప్‌లోడ్‌లు ఇంకా జరుగుతున్నాయి...';

  @override
  String docPleaseUpload(String name) {
    return 'దయచేసి అప్‌లోడ్ చేయండి: $name';
  }

  @override
  String docReuploadFailed(String name) {
    return '$name అప్‌లోడ్ విఫలమైంది. దయచేసి మళ్లీ అప్‌లోడ్ చేయండి.';
  }

  @override
  String get docUploadImage => 'చిత్రాన్ని అప్‌లోడ్ చేయండి';

  @override
  String get docChooseOption =>
      'చిత్రాన్ని అప్‌లోడ్ చేయడానికి ఒక ఎంపికను ఎంచుకోండి';

  @override
  String get docCamera => 'కెమెరా';

  @override
  String get docTakePhotoNow => 'ఇప్పుడే ఫోటో తీయండి';

  @override
  String get docGallery => 'గ్యాలరీ';

  @override
  String get docChooseLibrary => 'ఫోటో లైబ్రరీ నుండి ఎంచుకోండి';

  @override
  String get docDocumentation => 'డాక్యుమెంటేషన్';

  @override
  String get docUploadDocuments => 'పత్రాలను అప్‌లోడ్ చేయండి';

  @override
  String get docUploadDocumentsSub =>
      'ప్రక్రియలో భాగంగా పార్ట్‌నర్లు అవసరమైన పత్రాలను అప్‌లోడ్ చేయాలి';

  @override
  String get docOptional => 'తప్పనిసరి కాదు';

  @override
  String get docTapAddPhoto => 'ఫోటో జోడించడానికి నొక్కండి';

  @override
  String get docTapUploadFile => 'ఫైల్ అప్‌లోడ్ చేయడానికి నొక్కండి';

  @override
  String get docUploadFailed => 'అప్‌లోడ్ విఫలమైంది';

  @override
  String get docUploadFailedRetry =>
      'అప్‌లోడ్ విఫలమైంది — మళ్లీ ప్రయత్నించడానికి నొక్కండి';

  @override
  String get docUploaded => '✓ అప్‌లోడ్ అయింది';

  @override
  String get imgEmpty => 'ఎంచుకున్న చిత్రం ఖాళీగా ఉంది. దయచేసి మళ్లీ తీయండి.';

  @override
  String get imgTooLarge =>
      'ఈ చిత్రం చాలా పెద్దది. దయచేసి 10 MB కంటే చిన్న చిత్రాన్ని ఉపయోగించండి.';

  @override
  String get imgUnavailable =>
      'ఎంచుకున్న చిత్రం ఇప్పుడు అందుబాటులో లేదు. దయచేసి మళ్లీ ఎంచుకోండి.';

  @override
  String get imgServerFailed => 'సర్వర్ ఈ చిత్రాన్ని అప్‌లోడ్ చేయలేకపోయింది.';

  @override
  String get imgInvalidResponse =>
      'సర్వర్ నుండి చెల్లని అప్‌లోడ్ ప్రతిస్పందన వచ్చింది.';

  @override
  String get imgTimeout =>
      'అప్‌లోడ్ సమయం ముగిసింది. దయచేసి మీ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get imgOffline =>
      'నెట్‌వర్క్ కనెక్షన్ లేదు. ఆన్‌లైన్‌లో ఉన్నప్పుడు మళ్లీ ప్రయత్నించండి.';

  @override
  String get imgUploadFailed =>
      'ఈ చిత్రాన్ని అప్‌లోడ్ చేయలేకపోయాము. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get snackError => 'లోపం';

  @override
  String get snackSuccess => 'విజయం';

  @override
  String get snackNotice => 'గమనిక';

  @override
  String get placesServicesDisabled => 'స్థాన సేవలు నిలిపివేయబడ్డాయి.';

  @override
  String get placesPermissionDenied => 'స్థాన అనుమతులు నిరాకరించబడ్డాయి.';

  @override
  String get placesPermissionDeniedForever =>
      'స్థాన అనుమతులు శాశ్వతంగా నిరాకరించబడ్డాయి.';

  @override
  String get placesCurrentFailed => 'ప్రస్తుత స్థానాన్ని పొందడం విఫలమైంది.';

  @override
  String get placesCurrentLocation => 'ప్రస్తుత స్థానం';

  @override
  String get placesAddAddress => 'చిరునామా జోడించండి';

  @override
  String get placesAddYourAddress => 'మీ చిరునామా జోడించండి';

  @override
  String get placesSearchHint => 'మీ స్థానం కోసం వెతకండి';

  @override
  String get netTimeout =>
      'కనెక్షన్ సమయం ముగిసింది. దయచేసి మీ ఇంటర్నెట్‌ను తనిఖీ చేయండి.';

  @override
  String get netNoInternet =>
      'ఇంటర్నెట్ కనెక్షన్ లేదు. దయచేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get netCancelled => 'అభ్యర్థన రద్దు చేయబడింది.';

  @override
  String get netUnexpected => 'అనుకోని లోపం జరిగింది.';

  @override
  String get net400 => 'తప్పు అభ్యర్థన. దయచేసి మీ వివరాలను తనిఖీ చేయండి.';

  @override
  String get net401 => 'అనుమతి లేదు. దయచేసి మళ్లీ లాగిన్ అవ్వండి.';

  @override
  String get net403 => 'ప్రవేశం నిరాకరించబడింది.';

  @override
  String get net404 => 'సమాచారం కనుగొనబడలేదు.';

  @override
  String get net422 => 'ధృవీకరణ విఫలమైంది. దయచేసి మీ వివరాలను తనిఖీ చేయండి.';

  @override
  String get net429 => 'చాలా ఎక్కువ అభ్యర్థనలు. దయచేసి కొంచెం ఆగండి.';

  @override
  String get net500 => 'సర్వర్ లోపం. దయచేసి తర్వాత మళ్లీ ప్రయత్నించండి.';

  @override
  String get net503 => 'సేవ అందుబాటులో లేదు. దయచేసి తర్వాత ప్రయత్నించండి.';

  @override
  String netCode(int code) {
    return 'ఏదో పొరపాటు జరిగింది (కోడ్ $code).';
  }

  @override
  String get offlineBanner =>
      'మీరు ఆఫ్‌లైన్‌లో ఉన్నారు. మళ్లీ కనెక్ట్ అయ్యే వరకు ఇంటర్నెట్ అవసరమైన పనులు జరగవు.';

  @override
  String get noNotificationsHint =>
      'కొత్త పని అభ్యర్థనలు మీ ఫోన్‌లో అలర్ట్‌లుగా వస్తాయి. వాటిని పొందడానికి ఆన్‌లైన్‌లో ఉండండి.';

  @override
  String get pushNewJobTitle => 'కొత్త పని అభ్యర్థన';

  @override
  String get pushNewJobBody =>
      'అంగీకరించడానికి లేదా తిరస్కరించడానికి రెడీలోకల్ పార్ట్‌నర్ తెరవండి.';

  @override
  String get welcomeBenefitJobs => 'మీ దగ్గర్లోని ధృవీకరించిన పనులు పొందండి';

  @override
  String get welcomeBenefitEarnings => 'మీ సంపాదనను ఒకే చోట చూసుకోండి';

  @override
  String get welcomeBenefitTime => 'మీకు వీలైన సమయంలో పని చేయండి';

  @override
  String get alertsOffTitle => 'పని అలర్ట్‌లు ఆఫ్‌లో ఉన్నాయి';

  @override
  String get alertsOffBody =>
      'కొత్త పనులు మిస్ కాకుండా నోటిఫికేషన్లు ఆన్ చేయండి.';

  @override
  String get alertsTurnOn => 'ఆన్ చేయండి';

  @override
  String get alertsSettingsTitle => 'పని అలర్ట్ సెట్టింగ్‌లు';

  @override
  String get alertsSettingsIntro =>
      'యాప్ మూసి ఉన్నా పని అలర్ట్‌లు రావాలంటే మీ ఫోన్‌లో ఇవి సెట్ చేయండి:';

  @override
  String get alertsStepNotifications =>
      'ReadyLocal Partner కు నోటిఫికేషన్లు అనుమతించండి';

  @override
  String get alertsStepBattery =>
      'బ్యాటరీ: “No restrictions” లేదా “Don’t optimise” ఎంచుకోండి';

  @override
  String get alertsStepAutostart =>
      'Xiaomi, Oppo, Vivo, Realme: Autostart ఆన్ చేయండి';

  @override
  String get alertsStepForceStop => 'యాప్‌పై “Force stop” వాడకండి';

  @override
  String get alertsOpenSettings => 'ఫోన్ సెట్టింగ్‌లు తెరవండి';

  @override
  String get paymentFailedTitle => 'చెల్లింపు విఫలమైంది';

  @override
  String get paymentFailedBody => 'కాసేపటి తర్వాత మళ్లీ ప్రయత్నించండి.';

  @override
  String rateLine(String price, String unit) {
    return 'ధర: ₹$price $unit';
  }

  @override
  String get alreadyRegisteredTitle => 'మీరు ఇప్పటికే నమోదు చేసుకున్నారు';

  @override
  String get alreadyRegisteredBody =>
      'ఈ మొబైల్ నంబర్‌తో ఇప్పటికే ReadyLocal Partner ఖాతా ఉంది. మళ్లీ నమోదు చేసుకోవాల్సిన అవసరం లేదు. దయచేసి లాగిన్‌తో కొనసాగండి.';

  @override
  String get alreadyRegisteredContinue => 'లాగిన్‌తో కొనసాగండి';

  @override
  String get verifyPendingTitle => 'మీ వివరాలు సమర్పించబడ్డాయి';

  @override
  String get verifyPendingBody =>
      'మీ ధృవీకరణ జరుగుతోంది. మా బృందం మీ వివరాలను పరిశీలించి త్వరలో తెలియజేస్తుంది.';

  @override
  String get verifyCheckStatus => 'స్థితి చూడండి';

  @override
  String get verifySuccessTitle => 'ధృవీకరణ విజయవంతమైంది';

  @override
  String get verifySuccessBody =>
      'మీ వివరాలు ధృవీకరించబడ్డాయి. ఇప్పుడు మీరు యాప్ ఉపయోగించవచ్చు.';

  @override
  String get verifyContinue => 'కొనసాగండి';

  @override
  String get verifyRejectedTitle => 'ధృవీకరణ ఆమోదించబడలేదు';

  @override
  String get verifyRejectedReason => 'కారణం';

  @override
  String get verifyRejectedNoReason =>
      'దయచేసి మీ పత్రాలు చూసి మళ్లీ సమర్పించండి.';

  @override
  String get verifyUpdateDetails => 'సరిచేసి మళ్లీ సమర్పించండి';

  @override
  String get verifyOffline =>
      'మీ స్థితి చూడలేకపోయాం. ఇంటర్నెట్ చూసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get paymentDetailsReceived => 'మీ వివరాలు మాకు అందాయి';

  @override
  String get alertSetupTitle => 'పని అలర్ట్ సెటప్';

  @override
  String get alertSetupIntro =>
      'యాప్ మూసి ఉన్నా కొత్త పనులు మీ ఫోన్‌లో మోగేలా ఈ దశలు ఒక్కసారి చేయండి.';

  @override
  String alertSetupProgress(int done, int total) {
    return '$totalలో $done పూర్తయ్యాయి';
  }

  @override
  String get alertSetupAllDone =>
      'అంతా సిద్ధం. యాప్ మూసి ఉన్నా పని అలర్ట్‌లు వస్తాయి.';

  @override
  String get alertStepNotificationsTitle => 'నోటిఫికేషన్లు అనుమతించండి';

  @override
  String get alertStepNotificationsBody =>
      'ReadyLocal Partner కోసం “Allow notifications” ఆన్ చేయండి.';

  @override
  String get alertStepChannelTitle => 'కొత్త పని శబ్దం';

  @override
  String get alertStepChannelBody =>
      '“New job requests” తెరిచి శబ్దం మరియు పాప్-అప్ అనుమతించండి.';

  @override
  String get alertStepBatteryTitle => 'బ్యాటరీ: పరిమితులు లేవు';

  @override
  String get alertStepBatteryBody =>
      'Battery (లేదా App battery usage) నొక్కి “Unrestricted” / “No restrictions” / “Don’t optimise” ఎంచుకోండి.';

  @override
  String get alertStepAutostartTitle => 'Autostart ఆన్ చేయండి';

  @override
  String get alertStepAutostartBody =>
      'జాబితాలో ReadyLocal Partner కనుగొని Autostart ఆన్ చేయండి.';

  @override
  String get alertStepPopupTitle => 'పాప్-అప్ మరియు లాక్ స్క్రీన్';

  @override
  String get alertStepPopupBody =>
      '“Display pop-up windows while running in background” మరియు “Show on Lock screen” అనుమతించండి.';

  @override
  String get alertSetupOpen => 'సెట్టింగ్‌లు తెరవండి';

  @override
  String get alertSetupIDidThis => 'నేను చేశాను';

  @override
  String get alertSetupDone => 'పూర్తయింది';

  @override
  String get alertSetupLater => 'తర్వాత';

  @override
  String get alertSetupTest => 'టెస్ట్ అలర్ట్ ప్లే చేయండి';

  @override
  String get alertSetupTestTitle => 'టెస్ట్ పని అలర్ట్';

  @override
  String get alertSetupTestBody =>
      'ఇది వినిపిస్తే, పని అలర్ట్‌లు పని చేస్తున్నాయి.';

  @override
  String get alertsFix => 'సరిచేయండి';

  @override
  String get alertsSetupNeededTitle => 'పని అలర్ట్‌లు మిస్ కావచ్చు';

  @override
  String get alertsSetupNeededBody =>
      'యాప్ మూసి ఉన్నా పనులు మోగేలా అలర్ట్ సెటప్ పూర్తి చేయండి.';

  @override
  String get jobTakenByOther => 'ఈ పనిని మరో భాగస్వామి అంగీకరించారు.';

  @override
  String get welcomeHeadline => 'మీ నైపుణ్యాలతో మరింత సంపాదించండి';

  @override
  String get welcomeSubline =>
      'ReadyLocal Partner లో చేరి మీ దగ్గరలోని కస్టమర్ల నుండి పని అభ్యర్థనలు పొందండి.';

  @override
  String get loginTitleLogin => 'లాగిన్';

  @override
  String get loginHeadingLogin => 'మళ్లీ స్వాగతం';

  @override
  String get loginSubheadingLogin =>
      'మీ నమోదైన మొబైల్ నంబర్ ఇవ్వండి. మేము OTP పంపుతాము.';

  @override
  String get loginSendOtp => 'OTP పంపండి';

  @override
  String get loginSwitchToLogin => 'ఇప్పటికే పార్ట్‌నర్‌నా? లాగిన్';

  @override
  String get loginSwitchToRegister => 'ReadyLocal కు కొత్తా? నమోదు చేయండి';

  @override
  String get selectServiceFeeFailed =>
      'నమోదు రుసుము లోడ్ కాలేదు. ఇంటర్నెట్ చూసి మళ్లీ ప్రయత్నించండి.';
}
