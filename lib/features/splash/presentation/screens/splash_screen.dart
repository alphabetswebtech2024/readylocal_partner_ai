import 'package:gotask_partner/features/splash/domain/entities/splash_partner_status_entity.dart';
import 'package:gotask_partner/features/document_upload/domain/entities/partner_category.dart';
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:country_codes/country_codes.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/models/User.dart';
import '../../../../core/provider/UserProvider.dart';
import '../../../../core/utils/AppConstants.dart';
import '../../../../main.dart';
import '../providers/splash_provider.dart';
import '../widgets/splash_logo_widget.dart';

final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
Map<String, dynamic> deviceData = <String, dynamic>{};
String deviceName = "";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late final SplashProvider _splashProvider;
  bool _hasRouted = false;

  @override
  void initState() {
    super.initState();
    _splashProvider = ServiceLocator.createSplashProvider();
    initPlatformState();
    checkLogin();
  }

  Future<void> initPlatformState() async {
    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        deviceName = deviceData['model'] ?? '';
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
        deviceName = deviceData['name'] ?? '';
      }
    } catch (_) {
      deviceData = <String, dynamic>{'Error:': 'Failed to get platform version.'};
    }
    if (!mounted) return;
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  void _finalizeRouting(VoidCallback navigationAction) {
    if (_hasRouted) return;
    _hasRouted = true;

    final pending = pendingNotificationData;
    if (pending != null) {
      log("Found pendingNotificationData on splash start: $pending");
      if (mounted) {
        context.go(AppRoutes.notifications, extra: {
          'autoOpenJobData': pending,
          'autoOpenApiData': null,
        });
      }
      return;
    }

    navigationAction();
  }

  /// The routing below must always finish: whatever goes wrong, the partner
  /// leaves the splash screen instead of being stuck on it.
  Future<void> checkLogin() async {
    try {
      await _checkLogin();
    } catch (e, s) {
      log('Splash routing failed: $e', stackTrace: s);
      _finalizeRouting(() {
        if (mounted) context.go(AppRoutes.intro);
      });
    }
  }

  /// Opens the last screen of an unfinished registration with the earlier steps
  /// underneath it, so Back returns to them as in the 6 Nov app.
  void _goWithHistory(List<(String, Object?)> steps) {
    if (!mounted) return;
    final router = GoRouter.of(context);
    router.go(steps.first.$1, extra: steps.first.$2);
    for (final step in steps.skip(1)) {
      router.push(step.$1, extra: step.$2);
    }
  }

  Future<void> _checkLogin() async {
    // Long enough for the logo animation; the old fixed wait was 3 seconds.
    // The partner's status is fetched during this wait rather than after it.
    final animationDone = Future<void>.delayed(SplashLogoWidget.duration + const Duration(milliseconds: 150));

    if (await UserProvider.hasUser()) {
      User? user1 = await UserProvider.getCurrentUser();

      if (user1 != null) {
        final preferences = await SharedPreferences.getInstance();
        user = user1;
        userID = user!.id.toString();
        userFirstName = user!.FirstName;
        userLastName = user!.LastName;
        userEmail = user!.email;
        userPhone = user!.phone;
        isGuestUser = "false";
        try {
          analytics.setUserId(id: user!.id.toString());
          analytics.setUserProperty(name: "email", value: user!.email);
          analytics.setUserProperty(name: "phone", value: user!.phone);
        } catch (e) {
          log('Analytics unavailable: $e');
        }

        bool isDriver = false;
        if (user!.skills.isNotEmpty) {
          final firstSkill = (user!.skills.first['moduleName'] ?? user!.skills.first['moduleId'] ?? '')
              .toString()
              .toUpperCase();
          if (firstSkill.contains('DRIVER')) isDriver = true;
        }
        bool hasSkills = user!.skills.isNotEmpty;
        double registrationFee = preferences.getDouble('registrationFee') ?? 500.0;
        final category = partnerCategoryForSkills(user!.skills);
        bool isMedical = category == PartnerCategory.medical;

        bool hasPaid = false;
        // A partner already known to be registered, paid and not held back opens
        // as soon as the logo finishes; the server's answer is saved for next time.
        // Anyone else waits for the server, up to 8 s, then uses the saved status.
        final savedTxn = preferences.getString('TransactionID') ?? '';
        final knownReady = user!.AadharPicBack.isNotEmpty &&
            (registrationFee == 0 || isMedical || (savedTxn.isNotEmpty && savedTxn != 'FREE_REGISTRATION'));
        final statusCheck = _splashProvider.verifyStatus(userID);
        final statusEntity = knownReady
            ? await Future.any<SplashPartnerStatusEntity?>([statusCheck, animationDone.then((_) => null)])
            : await statusCheck.timeout(const Duration(seconds: 8), onTimeout: () => null);
        await animationDone;
        if (!mounted) return;
        if (statusEntity != null) {
          if (statusEntity.hasPaid) {
            hasPaid = true;
            await preferences.setString('TransactionID', statusEntity.transactionId);
          } else {
            await preferences.remove('TransactionID');
            hasPaid = false;
          }
        } else {
          String? localTxn = preferences.getString('TransactionID');
          if (localTxn != null && localTxn.isNotEmpty && localTxn != 'FREE_REGISTRATION') {
            hasPaid = true;
          }
        }

        if (registrationFee == 0 || isMedical) {
          hasPaid = true;
        }

        if (user!.FirstName.isEmpty) {
          _finalizeRouting(() {
            if (mounted) context.go(AppRoutes.personalInfo);
          });
        } else if (user!.AadharPicBack.isNotEmpty && hasPaid) {
          _finalizeRouting(() {
            if (mounted) context.go(AppRoutes.home);
          });
        } else if (user!.AadharPicBack.isNotEmpty && !hasPaid) {
          _finalizeRouting(() => _goWithHistory([
                (AppRoutes.personalInfo, null),
                (AppRoutes.selectService, null),
                (AppRoutes.uploadDocs, category),
                (AppRoutes.activationFee, null),
              ]));
        } else if (hasSkills || isDriver) {
          _finalizeRouting(() => _goWithHistory([
                (AppRoutes.personalInfo, null),
                (AppRoutes.selectService, null),
                (AppRoutes.uploadDocs, category),
              ]));
        } else {
          _finalizeRouting(() => _goWithHistory([
                (AppRoutes.personalInfo, null),
                (AppRoutes.selectService, null),
              ]));
        }
      } else {
        await animationDone;
        _finalizeRouting(() {
          if (mounted) context.go(AppRoutes.intro);
        });
      }
    } else {
      await animationDone;
      _finalizeRouting(() {
        if (mounted) context.go(AppRoutes.intro);
      });
    }
  }

  @override
  void dispose() {
    _splashProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SplashLogoWidget(),
    );
  }
}
