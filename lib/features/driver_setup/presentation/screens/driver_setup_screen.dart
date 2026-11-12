import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gotask_partner/core/design/app_top_bar.dart';
import 'package:gotask_partner/core/localization/server_labels.dart';
import 'package:gotask_partner/core/services/quick_location.dart';
import 'package:gotask_partner/core/utils/first_or.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/provider/UserProvider.dart';
import '../../../../core/utils/snackbar_helper.dart';
import 'package:gotask_partner/features/document_upload/presentation/screens/upload_images_screen.dart';
import '../../domain/entities/driver_setup_entity.dart';
import '../providers/driver_setup_provider.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

typedef DriverServiceType = DriverServiceTypeEntity;
typedef DriverLicenseType = DriverLicenseTypeEntity;
typedef VehicleType = VehicleTypeEntity;
typedef SafetySkill = SafetySkillEntity;

class DriverSetupScreen extends StatefulWidget {
  final Map<String, dynamic>? args;
  const DriverSetupScreen({super.key, this.args});
  @override
  State<DriverSetupScreen> createState() => _DriverSetupScreenState();
}

class _DriverSetupScreenState extends State<DriverSetupScreen> {
  late final DriverSetupProvider _controller;

  final List<String> _experienceLevels = ['0 - 5 yrs', '6 - 10 yrs', '10 - 20 yrs', '20+ yrs'];
  final List<String> _languages = ['English', 'Hindi'];

  final Map<String, double> _selectedServiceTypes = {};
  String? _selectedExperience;
  String? _selectedLicenseId;
  final Set<String> _selectedLanguages = {};
  String _currentLocation = L10n.current.driverFetchingLocation;
  final Set<String> _selectedVehicleIds = {};
  final Set<String> _selectedSkillIds = {};

  @override
  void initState() {
    super.initState();
    _controller = ServiceLocator.createDriverSetupProvider();
    _loadAllData().then((_) => _prefillDriverData());
    _fetchLocation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await _controller.fetchOptions();
  }

  Future<void> _prefillDriverData() async {
    final prefs = await SharedPreferences.getInstance();
    final profileStr = prefs.getString('professionalProfile');

    if (profileStr != null && profileStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(profileStr);
        final profileData = decoded is List ? decoded.first['profile'] : decoded['profile'];
        final user = await UserProvider.getCurrentUser();

        if (mounted) {
          setState(() {
            if (user != null && user.Experience > 0) {
              if (user.Experience > 20) {
                _selectedExperience = '20+ yrs';
              } else if (user.Experience > 10) {
                _selectedExperience = '10 - 20 yrs';
              } else if (user.Experience > 5) {
                _selectedExperience = '6 - 10 yrs';
              } else {
                _selectedExperience = '0 - 5 yrs';
              }
            }

            if (profileData['languages'] != null) {
              for (var lang in profileData['languages']) {
                _selectedLanguages.add(lang['language']);
              }
            }
            if (profileData['pricing'] != null && profileData['serviceTypes'] != null) {
              for (var st in profileData['serviceTypes']) {
                final matchingPricing = (profileData['pricing'] as List).firstWhere(
                  (p) => p['serviceType'] == st['serviceName'],
                  orElse: () => null,
                );
                if (matchingPricing != null) {
                  _selectedServiceTypes[st['serviceId']] = (matchingPricing['price'] as num).toDouble();
                }
              }
            }
            if (profileData['vehicleTypes'] != null) {
              for (var vt in profileData['vehicleTypes']) {
                final match = firstOr(_controller.vehicleTypes, (v) => v.type == vt['vehicleType'], const VehicleTypeEntity(id: '', type: ''));
                if (match.id.isNotEmpty) _selectedVehicleIds.add(match.id);
              }
            }
            if (profileData['specialSkills'] != null) {
              for (var sk in profileData['specialSkills']) {
                final match = firstOr(_controller.safetySkills, (s) => s.skill == sk['skill'], const SafetySkillEntity(id: '', skill: ''));
                if (match.id.isNotEmpty) _selectedSkillIds.add(match.id);
              }
            }
          });
        }
      } catch (e) {
        log("Error prefilling driver data: $e");
      }
    }
  }

  Future<void> _fetchLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _currentLocation = context.l10n.driverLocationDenied);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _currentLocation = context.l10n.driverLocationDeniedForever);
        return;
      }

      final position = await QuickLocation.get();
      if (position == null) throw StateError('No location available');
      List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks[0];
        setState(() {
          _currentLocation =
              "${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}"
                  .replaceAll(RegExp(r'^,\s*|,\s*$'), '');
          if (_currentLocation.isEmpty) _currentLocation = context.l10n.driverLocationDetected;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _currentLocation = context.l10n.driverLocationFailed);
    }
  }

  String _getUnitForService(String serviceId) {
    final service = firstOr(_controller.serviceTypes, (s) => s.id == serviceId, const DriverServiceTypeEntity(id: '', type: ''));
    final name = service.type.toLowerCase();
    if (name.contains('hourly')) return 'Per hour';
    if (name.contains('day')) return 'Per day';
    if (name.contains('outstation')) return 'Per trip / day';
    return 'Per service';
  }

  Future<double?> _askForPrice(DriverServiceTypeEntity service) async {
    final controller = TextEditingController(
      text: _selectedServiceTypes[service.id]?.toStringAsFixed(0) ?? '',
    );
    final unit = _getUnitForService(service.id);

    return showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(context.l10n.driverSetRateFor(context.serverLabel(service.type)), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.driverEnterRate(context.serverLabel(unit)), style: const TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofocus: true,
              decoration: InputDecoration(
                prefixText: '₹ ',
                hintText: '500',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text(context.l10n.commonCancel, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                final val = double.tryParse(text);
                if (val != null && val > 0) {
                  Navigator.pop(ctx, val);
                  return;
                }
              }
              AppSnackBar.showError(context, context.l10n.setupEnterValidAmount);
            },
            child: Text(context.l10n.driverSaveRate, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _onSave() async {
    if (_selectedServiceTypes.isEmpty) {
      AppSnackBar.showError(context, context.l10n.driverSelectServiceType);
      return;
    }
    if (_selectedExperience == null) {
      AppSnackBar.showError(context, context.l10n.driverSelectExperience);
      return;
    }
    if (_selectedLicenseId == null) {
      AppSnackBar.showError(context, context.l10n.driverSelectLicense);
      return;
    }
    if (_selectedLanguages.isEmpty) {
      AppSnackBar.showError(context, context.l10n.driverSelectLanguage);
      return;
    }
    if (_selectedVehicleIds.isEmpty) {
      AppSnackBar.showError(context, context.l10n.driverSelectVehicle);
      return;
    }

    String getServiceName(String id) => firstOr(_controller.serviceTypes, (e) => e.id == id, const DriverServiceTypeEntity(id: '', type: 'Unknown'))
        .type;
    String getLicenseName(String id) => firstOr(_controller.licenseTypes, (e) => e.id == id, const DriverLicenseTypeEntity(id: '', type: 'Unknown', description: ''))
        .type;
    String getVehicleName(String id) => firstOr(_controller.vehicleTypes, (e) => e.id == id, const VehicleTypeEntity(id: '', type: 'Unknown'))
        .type;
    String getSkillName(String id) => firstOr(_controller.safetySkills, (e) => e.id == id, const SafetySkillEntity(id: '', skill: 'Unknown'))
        .skill;

    final args = widget.args ?? {};
    final String professionName = args['ModuleName'] ?? 'Personal Driver';
    final String moduleId = args['ModuleId'] ?? args['moduleId'] ?? '';
    final String categoryId = args['CategoryId'] ?? '';
    final String categoryName = args['CategoryName'] ?? '';
    final String subCategoryId = args['SubCategoryId'] ?? '';
    final String subCategoryName = args['SubCategoryName'] ?? '';

    final payload = {
      "professionalProfile": {
        "profession": professionName,
        "profile": {
          "Services": [],
          "serviceTypes": _selectedServiceTypes.keys.map((id) {
            String serviceName = getServiceName(id);
            return {
              "serviceType": serviceName,
              "serviceId": id,
              "serviceName": serviceName,
              "moduleId": moduleId,
              "moduleName": professionName,
              "categoryId": categoryId,
              "categoryName": categoryName,
              "subCategoryId": subCategoryId,
              "subCategoryName": subCategoryName,
              "bookingTypes": ["ONLINE"],
              "deliveryModes": ["OFFLINE"],
              "isAvailable": true,
            };
          }).toList(),
          "pricing": _selectedServiceTypes.entries
              .map(
                (entry) => {
                  "serviceType": getServiceName(entry.key),
                  "price": entry.value,
                  "unit": _getUnitForService(entry.key),
                },
              )
              .toList(),
          "vehicleTypes": _selectedVehicleIds.map((id) => {"vehicleType": getVehicleName(id)}).toList(),
          "licenceTypes": [
            {"licenceType": getLicenseName(_selectedLicenseId!)},
          ],
          "languages": _selectedLanguages.map((lang) => {"language": lang}).toList(),
          "preferredLocations": [
            {"location": _currentLocation},
          ],
          "specialSkills": _selectedSkillIds.map((id) => {"skill": getSkillName(id)}).toList(),
        },
      },
    };

    final saved = await _controller.saveDriverProfile(payload);
    if (!mounted) return;

    if (saved) {
      context.push(AppRoutes.uploadDocs, extra: PartnerCategory.drivers);
    } else {
      AppSnackBar.showError(context, _controller.errorMessage ?? context.l10n.driverSaveFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppTopBar(title: context.l10n.driverDetailsTitle),
          body: _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(context.l10n.driverSelectServiceTypes),
                            _buildServiceTypesSection(),
                            const SizedBox(height: 24),
                            _buildSectionTitle(context.l10n.driverExperience),
                            _buildExperienceDropdown(),
                            const SizedBox(height: 24),
                            _buildSectionTitle(context.l10n.driverLicenseType),
                            _buildLicenseDropdown(),
                            const SizedBox(height: 24),
                            _buildSectionTitle(context.l10n.driverLanguages),
                            _buildLanguagesSection(),
                            const SizedBox(height: 24),
                            _buildSectionTitle(context.l10n.driverPreferredLocation),
                            _buildLocationTile(),
                            const SizedBox(height: 24),
                            _buildSectionTitle(context.l10n.driverVehicleTypes),
                            _buildVehicleTypesSection(),
                            const SizedBox(height: 24),
                            _buildSectionTitle(context.l10n.driverSafetySkills),
                            _buildSafetySkillsSection(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomBar(),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87),
      ),
    );
  }

  Widget _buildServiceTypesSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: _controller.serviceTypes.map((service) {
          final isSelected = _selectedServiceTypes.containsKey(service.id);
          final price = _selectedServiceTypes[service.id];

          return CheckboxListTile(
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(context.serverLabel(service.type), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            subtitle: isSelected
                ? Text(
                    context.l10n.rateLine(price?.toStringAsFixed(0) ?? '', context.serverLabel(_getUnitForService(service.id))),
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                  )
                : null,
            secondary: isSelected
                ? IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    color: Theme.of(context).primaryColor,
                    onPressed: () async {
                      final newPrice = await _askForPrice(service);
                      if (newPrice != null && mounted) {
                        setState(() => _selectedServiceTypes[service.id] = newPrice);
                      }
                    },
                  )
                : null,
            value: isSelected,
            activeColor: Theme.of(context).primaryColor,
            onChanged: (bool? checked) async {
              if (checked == true) {
                final price = await _askForPrice(service);
                if (price != null && mounted) {
                  setState(() => _selectedServiceTypes[service.id] = price);
                }
              } else {
                setState(() => _selectedServiceTypes.remove(service.id));
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExperienceDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      value: _selectedExperience,
      hint: Text(context.l10n.driverSelectExperienceHint),
      items: _experienceLevels.map((exp) => DropdownMenuItem(value: exp, child: Text(context.serverLabel(exp)))).toList(),
      onChanged: (val) => setState(() => _selectedExperience = val),
    );
  }

  Widget _buildLicenseDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      value: _selectedLicenseId,
      hint: Text(context.l10n.driverSelectLicenseHint),
      items: _controller.licenseTypes.map((lic) => DropdownMenuItem(value: lic.id, child: Text(context.serverLabel(lic.type)))).toList(),
      onChanged: (val) => setState(() => _selectedLicenseId = val),
    );
  }

  Widget _buildLanguagesSection() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _languages.map((lang) {
        final isSelected = _selectedLanguages.contains(lang);
        return FilterChip(
          label: Text(context.serverLabel(lang)),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          backgroundColor: Colors.white,
          selectedColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: isSelected ? Theme.of(context).primaryColor : AppColors.border),
          ),
          selected: isSelected,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _selectedLanguages.add(lang);
              } else {
                _selectedLanguages.remove(lang);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildLocationTile() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Theme.of(context).primaryColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _currentLocation,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20, color: Colors.grey),
            onPressed: () {
              setState(() => _currentLocation = context.l10n.driverFetchingLocation);
              _fetchLocation();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleTypesSection() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _controller.vehicleTypes.map((vehicle) {
        final isSelected = _selectedVehicleIds.contains(vehicle.id);
        return FilterChip(
          label: Text(context.serverLabel(vehicle.type)),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          backgroundColor: Colors.white,
          selectedColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: isSelected ? Theme.of(context).primaryColor : AppColors.border),
          ),
          selected: isSelected,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _selectedVehicleIds.add(vehicle.id);
              } else {
                _selectedVehicleIds.remove(vehicle.id);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSafetySkillsSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: _controller.safetySkills.map((skill) {
          final isSelected = _selectedSkillIds.contains(skill.id);
          return CheckboxListTile(
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(context.serverLabel(skill.skill), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
            value: isSelected,
            activeColor: Theme.of(context).primaryColor,
            onChanged: (bool? checked) {
              setState(() {
                if (checked == true) {
                  _selectedSkillIds.add(skill.id);
                } else {
                  _selectedSkillIds.remove(skill.id);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomBar() {
    final canSave =
        _selectedServiceTypes.isNotEmpty &&
        _selectedExperience != null &&
        _selectedLicenseId != null &&
        _selectedLanguages.isNotEmpty &&
        _selectedVehicleIds.isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 26),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            color: canSave ? Theme.of(context).primaryColor : AppColors.border,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _onSave,
              child: Center(
                child: Text(
                  context.l10n.driverSaveDetails,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
