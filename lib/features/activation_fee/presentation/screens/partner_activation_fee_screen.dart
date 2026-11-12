import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gotask_partner/core/design/app_top_bar.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/models/User.dart';
import '../../../../core/provider/UserProvider.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/common_loading_overlay.dart';
import '../../../../main.dart';
import '../providers/activation_fee_provider.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

class PartnerActivationFeeScreen extends StatefulWidget {
  const PartnerActivationFeeScreen({super.key});
  @override
  State<PartnerActivationFeeScreen> createState() => _PartnerActivationFeeScreenState();
}

class _PartnerActivationFeeScreenState extends State<PartnerActivationFeeScreen> {
  late final ActivationFeeProvider _activationController;
  Razorpay razorpay = Razorpay();
  Map<String, dynamic> options = {};

  String razorpay_payment_id = "";
  String enquiryID = "";

  double _registrationFee = 500.0;
  bool _isInitializing = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _activationController = ServiceLocator.createActivationFeeProvider();
    _initializePaymentData();

    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
  }

  @override
  void dispose() {
    razorpay.clear();
    _activationController.dispose();
    super.dispose();
  }

  Future<void> _initializePaymentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _registrationFee = prefs.getDouble('registrationFee') ?? 500.0;
      options = {
        'key': rzpKey,
        'amount': (_registrationFee * 100).roundToDouble(), // whole paise; the fee now comes from the server
        'name': 'ReadyLocal Partner',
        'description': '',
        'retry': {'enabled': true, 'max_count': 1},
        'send_sms_hash': true,
        'prefill': {'contact': userPhone, 'email': userEmail},
        'config': {
          'display': {
            'hide': [
              {'method': 'netbanking'},
              {'method': 'wallet'},
              {'method': 'emi'},
              {'method': 'paylater'},
            ],
            'blocks': {
              'upi_and_cards': {
                'name': 'Pay using UPI or Card',
                'instruments': [
                  {
                    'method': 'upi',
                    'flows': ['intent', 'collect'],
                  },
                  {'method': 'card'},
                ],
              },
            },
            'sequence': ['block.upi_and_cards'],
            'preferences': {'show_default_blocks': false},
          },
        },
      };
      _isInitializing = false;
    });
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    if (mounted) {
      context.push(AppRoutes.paymentFailed);
    }
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    razorpay_payment_id = response.paymentId ?? "";
    SaveDetails();
  }

  Future<void> SaveDetails() async {
    setState(() => _isLoading = true);
    final AuthService _authService = AuthService(ServiceLocator.apiService);
    final currentUser = await UserProvider.getCurrentUser();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? profProfileStr = prefs.getString('professionalProfile');

      dynamic professionalProfileData;
      List skillsToPass = currentUser!.skills;
      String extractedModuleId = "";
      String extractedModuleName = "";

      if (profProfileStr != null && profProfileStr.isNotEmpty) {
        var decodedData = jsonDecode(profProfileStr);
        professionalProfileData = decodedData is Map ? [decodedData] : decodedData;
        try {
          if (professionalProfileData != null && professionalProfileData.isNotEmpty) {
            var serviceTypesList = professionalProfileData[0]['profile']['serviceTypes'] as List;
            if (serviceTypesList.isNotEmpty) {
              extractedModuleId = serviceTypesList[0]['moduleId']?.toString() ?? "";
              extractedModuleName = serviceTypesList[0]['moduleName']?.toString() ?? "";
            }
          }
        } catch (e) {}
        skillsToPass = [];
      } else {
        List<Map<String, dynamic>> mappedServiceTypes = [];
        String professionName = "Service Provider";
        if (skillsToPass.isNotEmpty) {
          professionName = skillsToPass.first['moduleName'] ?? professionName;
          extractedModuleId = skillsToPass.first['moduleId']?.toString() ?? "";
          extractedModuleName = skillsToPass.first['moduleName']?.toString() ?? "";
          for (var skill in skillsToPass) {
            final moduleId = skill['moduleId']?.toString() ?? '';
            final moduleName = skill['moduleName']?.toString() ?? '';
            final categoryId = skill['categoryId']?.toString() ?? '';
            final categoryName = skill['categoryName']?.toString() ?? '';
            final subCategoryId = skill['subCategoryId']?.toString() ?? '';
            final subCategoryName = (skill['subcategoryName'] ?? skill['subCategoryName'])?.toString() ?? '';
            final List dynamicServiceTypes = skill['serviceTypes'] ?? [];
            for (var st in dynamicServiceTypes) {
              mappedServiceTypes.add({
                "serviceType": st['serviceTypeName']?.toString() ?? '',
                "serviceId": st['serviceTypeID']?.toString() ?? '',
                "serviceName": st['serviceTypeName']?.toString() ?? '',
                "moduleId": moduleId,
                "moduleName": moduleName,
                "categoryId": categoryId,
                "categoryName": categoryName,
                "subCategoryId": subCategoryId,
                "subCategoryName": subCategoryName,
                "bookingTypes": ["ONLINE"],
                "deliveryModes": ["OFFLINE"],
                "isAvailable": true,
              });
            }
          }
        }
        professionalProfileData = [
          {
            "profession": professionName,
            "profile": {
              "Services": [],
              "serviceTypes": mappedServiceTypes,
              "pricing": [],
              "vehicleTypes": [],
              "licenceTypes": [],
              "languages": [],
              "preferredLocations": [],
              "specialSkills": [],
            },
          },
        ];
      }

      List<dynamic>? safeProfileList;
      if (professionalProfileData != null) safeProfileList = List<dynamic>.from(professionalProfileData);

      final res = await _authService.updateProfile(
        partnerID: currentUser.id,
        firstName: currentUser.FirstName,
        lastName: currentUser.LastName,
        gender: currentUser.Gender,
        address: currentUser.Address,
        city: currentUser.City,
        state: currentUser.State,
        district: currentUser.District,
        pinCode: int.tryParse(currentUser.PinCode.trim()) ?? 0,
        avatar: currentUser.Avatar,
        experience: currentUser.Experience.toString(),
        upi: currentUser.UPI,
        paymentGateWay: currentUser.PaymentGateWay,
        refContactPerson: currentUser.RefContactPerson,
        refContactNumber: currentUser.RefContactNumber,
        skills: skillsToPass,
        professionalProfile: safeProfileList,
        aadharPicFront: currentUser.AadharPicFront,
        aadharPicBack: currentUser.AadharPicBack,
        panPics: currentUser.PanPics,
        toolPhoto: currentUser.ToolPhoto,
        addressProof: currentUser.AddressProof,
      );

      if (!mounted) return;

      if (res['Status'] == 'SUCCESS' && res['StatusCode'] == 200) {
        if (profProfileStr != null) await prefs.remove('professionalProfile');
        final updatedUser = User(
            id: currentUser.id,
            FirstName: currentUser.FirstName,
            LastName: currentUser.LastName,
            Gender: currentUser.Gender,
            email: currentUser.email,
            phone: currentUser.phone,
            isProfileUpdated: true,
            isActive: currentUser.isActive,
            Address: currentUser.Address,
            City: currentUser.City,
            State: currentUser.State,
            District: currentUser.District,
            PinCode: currentUser.PinCode,
            Avatar: currentUser.Avatar,
            UPI: currentUser.UPI,
            PaymentGateWay: currentUser.PaymentGateWay,
            Experience: currentUser.Experience,
            RefContactPerson: currentUser.RefContactPerson,
            RefContactNumber: currentUser.RefContactNumber,
            skills: skillsToPass,
            AadharPicFront: currentUser.AadharPicFront,
            AadharPicBack: currentUser.AadharPicBack,
            PanPics: currentUser.PanPics,
            ToolPhoto: currentUser.ToolPhoto,
            AddressProof: currentUser.AddressProof,
            QualificationCertificate: currentUser.QualificationCertificate // ✅ FIXED
        );
        if (!mounted) return;
        await Provider.of<UserProvider>(context, listen: false).setAsCurrentUser(updatedUser);
        saveTransactionCall("", extractedModuleId, extractedModuleName);
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          AppSnackBar.showError(context, context.l10n.feeUpdateFailed);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppSnackBar.showError(context, context.l10n.feeUnexpectedError('$e'));
      }
    }
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {}

  Future<void> saveTransactionCall(String requestId, String moduleId, String moduleName) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;

    final success = await _activationController.saveTransaction(
      partnerId: currentUser.id,
      transactionId: razorpay_payment_id,
      amount: _registrationFee,
      moduleId: moduleId,
      moduleName: moduleName,
    );

    final preferences = await SharedPreferences.getInstance();
    preferences.setString('TransactionID', razorpay_payment_id);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go(AppRoutes.paymentSuccess, extra: {"RequestDataID": requestId});
    } else {
      context.push(AppRoutes.paymentFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return CommonLoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppTopBar(title: context.l10n.feeTitle),
        body: _isInitializing
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.feeDescription,
                style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 24),
              _buildFeeCard(),
              const SizedBox(height: 28),
              const Spacer(),
              _buildPayNowButton(primary),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.primaryDeep, AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.l10n.feeTitle,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Text(
            '₹${_registrationFee % 1 == 0 ? _registrationFee.toInt() : _registrationFee.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildPayNowButton(Color primary) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          razorpay.open(options);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          context.l10n.feePayNow,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}