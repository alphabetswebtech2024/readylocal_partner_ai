// Golden screenshots of every screen, written to test_screens/shots/<phase>/.
// See harness.dart for how the fake backend and fonts work.
import 'package:gotask_partner/core/services/alert_setup.dart';
import 'package:gotask_partner/features/alert_setup/presentation/screens/alert_setup_screen.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gotask_partner/features/activation_fee/presentation/screens/partner_activation_fee_screen.dart';
import 'package:gotask_partner/features/bank_details/presentation/screens/add_bank_details_screen.dart';
import 'package:gotask_partner/features/completed_job_overview/presentation/screens/completed_job_overview_screen.dart';
import 'package:gotask_partner/features/customer_details/data/models/customer_details_model.dart';
import 'package:gotask_partner/features/customer_details/presentation/screens/customer_details_screen.dart';
import 'package:gotask_partner/features/document_upload/presentation/screens/upload_images_screen.dart';
import 'package:gotask_partner/features/driver_setup/presentation/screens/driver_setup_screen.dart';
import 'package:gotask_partner/features/earnings/presentation/screens/earnings_screen.dart';
import 'package:gotask_partner/features/home/presentation/screens/home_screen.dart';
import 'package:gotask_partner/features/job_overview/data/models/job_overview_model.dart';
import 'package:gotask_partner/features/job_overview/presentation/screens/job_overview_screen.dart';
import 'package:gotask_partner/features/job_progress/presentation/screens/job_progress_screen.dart';
import 'package:gotask_partner/features/jobs_list/presentation/screens/jobs_list_screen.dart';
import 'package:gotask_partner/features/login/presentation/screens/login_screen.dart';
import 'package:gotask_partner/features/medical_setup/presentation/screens/medical_setup_screen.dart';
import 'package:gotask_partner/features/notifications/domain/entities/notification_popup_config.dart';
import 'package:gotask_partner/features/notifications/presentation/providers/notification_popup_controller.dart';
import 'package:gotask_partner/features/notifications/presentation/screens/notification_screen.dart';
import 'package:gotask_partner/features/notifications/presentation/widgets/notification_popup_widget.dart';
import 'package:gotask_partner/features/otp_verification/presentation/screens/otp_verify_screen.dart';
import 'package:gotask_partner/features/pandit_setup/presentation/screens/pandit_setup_screen.dart';
import 'package:gotask_partner/features/payment_failed/presentation/screens/failed_payment_screen.dart';
import 'package:gotask_partner/features/payment_success/presentation/screens/payment_success_screen.dart';
import 'package:gotask_partner/features/personal_information/presentation/screens/personal_information_screen.dart';
import 'package:gotask_partner/features/profile/presentation/screens/profile_screen.dart';
import 'package:gotask_partner/features/select_categories/presentation/screens/select_categories_screen.dart';
import 'package:gotask_partner/features/select_service/presentation/screens/select_service_screen.dart';
import 'package:gotask_partner/features/transaction_details/presentation/screens/transaction_details_screen.dart';
import 'package:gotask_partner/features/verified/presentation/screens/verified_screen.dart';
import 'package:gotask_partner/features/view_profile/presentation/screens/view_profile_screen.dart';
import 'package:gotask_partner/features/welcome/presentation/screens/welcome_screen.dart';
import 'package:gotask_partner/features/withdraw/presentation/screens/withdraw_screen.dart';
import 'package:gotask_partner/features/work_status_success/presentation/screens/work_status_success_screen.dart';

import 'package:gotask_partner/features/splash/presentation/widgets/splash_logo_widget.dart';

import 'harness.dart';

JobOverviewData _sampleJob() => JobOverviewData.fromApi(sampleRequestApi, const {}, nextStep: 'START_RIDE');

NotificationPopupController? _openPopup;

Widget _popup(PopupStep step) {
  final controller = _openPopup = NotificationPopupController()
    ..open(const PopupConfig(
      requestId: 'req-1',
      customerName: 'Sneha',
      fullAddress: 'Flat 402, Lake View Residency, Madhapur',
      formattedDate: '04 Nov 2026',
      timeSlot: '04:00 PM - 05:00 PM',
      status: 'Pending',
      mobile: '9000000001',
      paymentStatus: 'Pending',
      services: [
        {'Name': 'AC Service & Repair'},
      ],
      pricing: {'totalAmount': 650, 'finalAmount': 650},
      apiData: {'Distance': '2.4'},
    ));
  if (step != PopupStep.jobDetail) controller.goTo(step);
  return Scaffold(
    backgroundColor: const Color(0xFFE9EEF5),
    body: NotificationPopup(controller: controller, onAcceptConfirmed: () {}, onRejectReasonSubmitted: () {}),
  );
}

final Map<String, Widget Function()> screens = {
  '00_splash': () => const Scaffold(body: SplashLogoWidget()),
  '01_welcome': () => const WelcomeScreen(),
  '02_login': () => const LoginScreen(),
  '03_otp': () => const OtpVerifyScreen(phoneNumber: '9876543210'),
  '04_verified': () => const VerifiedScreen(navigateToProfile: false),
  '05_personal_info': () => const PersonalInformationScreen(),
  '06_select_service': () => const SelectServiceScreen(),
  '07_select_categories': () => const SelectCategoriesScreen(),
  '08_driver_setup': () => const DriverSetupScreen(),
  '09_pandit_setup': () => const PanditSetupScreen(),
  '10_medical_setup': () => const MedicalSetupScreen(),
  '11_upload_docs': () => const UploadImagesScreen(category: PartnerCategory.homeServices),
  '12_bank_details': () => const AddBankDetailsScreen(),
  '13_activation_fee': () => const PartnerActivationFeeScreen(),
  '14_payment_success': () => const PaymentSuccessScreen(),
  '15_payment_failed': () => const FailedPaymentScreen(),
  '16_home': () => const HomeScreen(),
  '17_jobs_list': () => const JobsListScreen(),
  '18_job_overview': () => JobOverviewScreen(job: _sampleJob()),
  '19_customer_details': () =>
      CustomerDetailsScreen(details: CustomerDetails.fromJobOverview(_sampleJob(), sampleRequestApi, nextStep: 'START_RIDE')),
  '20_job_progress': () => const JobProgressScreen(
        jobId: 'req-1',
        jobTitle: 'AC Service & Repair',
        jobAmount: 650,
        jobDateTime: '04 Nov 2026 | 04:00 PM',
        isInstant: false,
        etaLabel: '',
        aboutPoints: ['Gas top-up if needed', 'Filter cleaning'],
      ),
  '21_work_success': () => const WorkStatusSuccessScreen(partnerName: 'Ravi Kumar'),
  '22_completed_overview': () => CompletedJobOverviewScreen(job: _sampleJob()),
  '23_earnings': () => const EarningsScreen(),
  '24_transaction_details': () => const TransactionDetailsScreen(transactionId: 't1'),
  '25_withdraw': () => const WithdrawScreen(availableBalance: 4200),
  '26_profile': () => const ProfileScreen(),
  '27_view_profile': () => const ViewProfileScreen(),
  '28_notifications': () => const NotificationScreen(),
  '29_job_popup': () => _popup(PopupStep.jobDetail),
  '30_job_popup_accept': () => _popup(PopupStep.confirmAccept),
  '31_job_popup_reason': () => _popup(PopupStep.rejectReason),
  '32_alert_setup': () => const AlertSetupScreen(),
};

const int _width = int.fromEnvironment('WIDTH', defaultValue: 390);
const int _height = int.fromEnvironment('HEIGHT', defaultValue: 844);

/// Telugu run: writes any text still in English, screen by screen, to a report.
void _recordLatinText(WidgetTester tester, String screen) {
  if (shotsLocale != 'te') return;
  final found = <String>{};
  for (final rich in tester.widgetList<RichText>(find.byType(RichText))) {
    final text = rich.text.toPlainText();
    if (RegExp(r'[A-Za-z]{3,}').hasMatch(text)) found.add(text.replaceAll('\n', ' '));
  }
  File('test_screens/shots/english_in_telugu.txt')
      .writeAsStringSync('$screen: ${found.join(' | ')}\n', mode: FileMode.append);
}

void main() {
  setUpAll(bootHarness);
  // A Xiaomi phone with notifications on, battery saver still limiting the app.
  AlertSetup.debugStatus = () async => const AlertSetupStatus(
        notifications: true,
        jobChannel: true,
        batteryUnrestricted: false,
        backgroundRestricted: false,
        hasAutostart: true,
        isXiaomi: true,
        confirmed: {AlertStep.autostart},
      );

  for (final entry in screens.entries) {
    testWidgets(entry.key, (tester) async {
      tester.view.physicalSize = const Size(_width * 3.0, _height * 3.0);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(await shell(entry.value()));
      // Let async loads finish without waiting on endless animations.
      for (var i = 0; i < 12; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pump(const Duration(milliseconds: 100));
      }
      _recordLatinText(tester, entry.key);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('shots/$shotsPhase/${shotsLocale}${_width == 390 ? '' : '_small'}_${entry.key}.png'),
      );
      // Unmount so timers and listeners are disposed inside the test.
      await tester.pumpWidget(const SizedBox.shrink());
      _openPopup?.close();
      _openPopup = null;
      await tester.pump(const Duration(seconds: 5));
    });
  }
}
