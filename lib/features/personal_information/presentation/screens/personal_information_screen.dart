import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:gotask_partner/core/design/app_top_bar.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/models/User.dart';
import '../../../../core/provider/UserProvider.dart';
import '../../../../core/session/app_session.dart';
import '../../../../core/widgets/common_loading_overlay.dart';
import '../../../places_autocomplete/domain/entities/place_prediction_entity.dart';
import '../../../places_autocomplete/presentation/screens/places_autocomplete_screen.dart';
import '../providers/personal_information_provider.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/server_labels.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _genderController = TextEditingController();
  final _addressController = TextEditingController();
  final _houseNoController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  late final PersonalInformationProvider _personalInfoProvider;

  @override
  void initState() {
    super.initState();
    _personalInfoProvider = ServiceLocator.createPersonalInformationProvider();

    // Prefill data
    _prefillData();
  }

  Future<void> _prefillData() async {
    final currentUser = await UserProvider.getCurrentUser();
    if (currentUser != null && mounted) {
      setState(() {
        _firstNameController.text = currentUser.FirstName;
        _lastNameController.text = currentUser.LastName;
        _emailController.text = currentUser.email;
        _genderController.text = currentUser.Gender;
        _cityController.text = currentUser.City;
        _stateController.text = currentUser.State;
        _pincodeController.text = currentUser.PinCode;

        if (currentUser.Address.contains(', ')) {
          final parts = currentUser.Address.split(', ');
          _houseNoController.text = parts.first;
          _addressController.text = parts.sublist(1).join(', ');
        } else {
          _addressController.text = currentUser.Address;
        }
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    _houseNoController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _personalInfoProvider.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    if (!_formKey.currentState!.validate()) return;
    final currentUser = await UserProvider.getCurrentUser();
    final String combinedAddress =
        "${_houseNoController.text.trim()}, ${_addressController.text.trim()}";

    final updatedUser = User(
      id: currentUser?.id ?? '',
      FirstName: _firstNameController.text.trim(),
      LastName: _lastNameController.text.trim(),
      Gender: _genderController.text.trim(),
      email: _emailController.text.trim(),
      phone: currentUser?.phone ?? '',
      isProfileUpdated: true,
      isActive: currentUser?.isActive ?? false,
      Address: combinedAddress,
      City: _cityController.text.trim(),
      State: _stateController.text.trim(),
      District: currentUser?.District ?? '',
      PinCode: _pincodeController.text.trim(),
      Avatar: currentUser?.Avatar ?? '',
      UPI: currentUser?.UPI ?? '',
      PaymentGateWay: currentUser?.PaymentGateWay ?? '',
      Experience: currentUser?.Experience ?? 0,
      RefContactPerson: currentUser?.RefContactPerson ?? '',
      RefContactNumber: currentUser?.RefContactNumber ?? '',
      skills: currentUser?.skills ?? const [],
      AadharPicFront: currentUser?.AadharPicFront ?? '',
      AadharPicBack: currentUser?.AadharPicBack ?? '',
      PanPics: currentUser?.PanPics ?? '',
      ToolPhoto: currentUser?.ToolPhoto ?? '',
      AddressProof: currentUser?.AddressProof ?? '',
      QualificationCertificate: currentUser?.QualificationCertificate ?? '',
    );

    // As in the 6 Nov app: saved on the phone only. The server receives these
    // details with the documents (updateProfile_pat), together with everything else,
    // so a partial update here can never blank fields already on the server.
    if (mounted) {
      await Provider.of<UserProvider>(context, listen: false)
          .setAsCurrentUser(updatedUser);
      // Keep the session on the details just saved; later steps read its ID.
      AppSession.setUser(updatedUser);
    }

    if (!mounted) return;

    context.push(AppRoutes.selectService);
  }

  void _showGenderPicker(BuildContext context) {
    // Otherwise the keyboard reopens over the form when the picker closes.
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.genderSelect,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ListTile(
                title: Text(context.l10n.genderMale, style: const TextStyle(fontSize: 18)),
                onTap: () {
                  setState(() => _genderController.text = 'Male');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(context.l10n.genderFemale, style: const TextStyle(fontSize: 18)),
                onTap: () {
                  setState(() => _genderController.text = 'Female');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      // Closing the picker returns focus to the last text field; drop it again
      // once that has happened so the keyboard doesn't reopen over the form.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) FocusManager.instance.primaryFocus?.unfocus();
      });
    });
  }

  // Field style comes from the app theme.
  InputDecoration _inputDecoration(String hint) => InputDecoration(hintText: hint);

  Widget _fieldLabel(String label, {bool optional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          children: optional
              ? [
                  TextSpan(
                    text: context.l10n.optionalSuffix,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.black45,
                    ),
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: _personalInfoProvider,
      builder: (context, _) {
        return CommonLoadingOverlay(
          isLoading: _personalInfoProvider.isLoading,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
 top: false,
              child: Column(
                children: [
                  AppTopBar(title: context.l10n.personalInfoTitle, showBack: false),
                  
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.personalInfoSubtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 24),

                          _fieldLabel(context.l10n.firstName),
                          TextFormField(
                            controller: _firstNameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDecoration(context.l10n.firstNameHint),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? context.l10n.firstNameRequired
                                : null,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          const SizedBox(height: 18),

                          _fieldLabel(context.l10n.lastName),
                          TextFormField(
                            controller: _lastNameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDecoration(context.l10n.lastNameHint),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? context.l10n.lastNameRequired
                                : null,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          const SizedBox(height: 18),

                          _fieldLabel(context.l10n.emailLabel, optional: true),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(context.l10n.emailHint),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return null;
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(v.trim())) {
                                return context.l10n.emailInvalid;
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          const SizedBox(height: 18),

                          _fieldLabel(context.l10n.genderLabel),
                          TextFormField(
                            // Shows the translated word; _genderController keeps the value sent to the server.
                            key: ValueKey('gender-${_genderController.text}-${context.l10n.localeName}'),
                            initialValue: context.serverLabel(_genderController.text),
                            readOnly: true,
                            // A picker, not a text box: taking focus here made the keyboard
                            // reopen on the previous field when the picker closed.
                            canRequestFocus: false,
                            onTap: () => _showGenderPicker(context),
                            decoration: _inputDecoration(context.l10n.genderHint),
                            validator: (v) => (v == null || v.isEmpty)
                                ? context.l10n.genderRequired
                                : null,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          const SizedBox(height: 18),

                          _fieldLabel(context.l10n.addressLabel),
                          TextFormField(
                            controller: _addressController,
                            decoration: _inputDecoration(
                              context.l10n.addressSearchHint,
                            ),
                            readOnly: true,
                            onTap: () async {
                              final result = await Navigator.of(context)
                                  .push<PlaceDetailEntity>(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const PlacesAutocompleteScreen(),
                                ),
                              );
                              if (result != null) {
                                List<String> addressParts = [
                                  result.address,
                                  result.city,
                                  result.district,
                                  result.state,
                                  result.pinCode,
                                ];
                                _addressController.text = addressParts
                                    .where((part) => part.isNotEmpty)
                                    .join(', ');
                                _cityController.text = result.city;
                                _stateController.text = result.state;
                                _pincodeController.text = result.pinCode;
                              }
                            },
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? context.l10n.addressRequired
                                : null,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          const SizedBox(height: 18),

                          _fieldLabel(context.l10n.houseLabel),
                          TextFormField(
                            controller: _houseNoController,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDecoration(
                              context.l10n.houseHint,
                            ),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          const SizedBox(height: 18),

                          _fieldLabel(context.l10n.cityLabel),
                          TextFormField(
                            controller: _cityController,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDecoration(context.l10n.cityHint),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? context.l10n.cityRequired
                                : null,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          const SizedBox(height: 18),

                          _fieldLabel(context.l10n.stateLabel),
                          TextFormField(
                            controller: _stateController,
                            textCapitalization: TextCapitalization.words,
                            decoration: _inputDecoration(context.l10n.stateHint),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? context.l10n.stateRequired
                                : null,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          const SizedBox(height: 18),

                          _fieldLabel(context.l10n.pinLabel),
                          TextFormField(
                            controller: _pincodeController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: _inputDecoration(context.l10n.pinHint)
                                .copyWith(counterText: ''),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return context.l10n.pinRequired;
                              }
                              if (!RegExp(r'^\d{6}$').hasMatch(v.trim())) {
                                return context.l10n.pinInvalid;
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                          ),
                          const SizedBox(height: 28),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _personalInfoProvider.isLoading
                                  ? null
                                  : _onNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                disabledBackgroundColor:
                                    colorScheme.primary.withValues(alpha: 0.6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                context.l10n.commonNext,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
