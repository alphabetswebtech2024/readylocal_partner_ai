import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:gotask_partner/features/document_upload/presentation/screens/upload_images_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gotask_partner/core/design/app_top_bar.dart';
import 'package:gotask_partner/core/localization/server_labels.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/models/User.dart';
import '../../../../core/provider/UserProvider.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../data/models/medical_setup_model.dart';
import '../providers/medical_setup_provider.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

class MedicalSetupScreen extends StatefulWidget {
  final Map<String, dynamic>? args;
  const MedicalSetupScreen({super.key, this.args});

  @override
  State<MedicalSetupScreen> createState() => _MedicalSetupScreenState();
}

class _MedicalSetupScreenState extends State<MedicalSetupScreen> {
  late final MedicalSetupProvider _controller;
  late String moduleId;
  late String moduleCode;
  late String ModuleName;

  List<Map<String, dynamic>> selectedCategories = [];
  List<Map<String, dynamic>> selectedServices = [];
  String? selectedYear;
  final List<String> yearsList = ["0-5", "6-10", "11-15", "16-20", "20+"];

  final List<dynamic> allServiceTypes = [
    {"_id": "ST_HOURLY", "Name": "Hourly"},
    {"_id": "ST_DAYS", "Name": "Days"},
    {"_id": "ST_24_HOURS", "Name": "24 hours"},
  ];

  final Map<String, double> selectedServiceTypesPricing = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = ServiceLocator.createMedicalSetupProvider();

    final args = widget.args;
    if (args != null) {
      moduleId = args['moduleId'] ?? "";
      moduleCode = args['moduleCode'] ?? "";
      ModuleName = args['ModuleName'] ?? "Medical Service";
    } else {
      moduleId = "";
      moduleCode = "";
      ModuleName = "Medical Service";
    }

    for (var st in allServiceTypes) {
      selectedServiceTypesPricing[st['_id']] = 0.0;
    }

    _prefillMedicalData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _prefillMedicalData() async {
    bool isSameModule = false;
    final prefs = await SharedPreferences.getInstance();
    final profileStr = prefs.getString('professionalProfile');

    // 1. Check SharedPreferences for Drafted Rates & Module Match
    if (profileStr != null && profileStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(profileStr);
        final profileData = decoded is List ? decoded.first['profile'] : decoded['profile'];

        // Verify if the drafted data belongs to the current module
        if (profileData['serviceTypes'] != null && (profileData['serviceTypes'] as List).isNotEmpty) {
          final savedModuleId = profileData['serviceTypes'][0]['moduleId'];
          if (savedModuleId == moduleId) {
            isSameModule = true;
          }
        }

        if (!isSameModule) {
          // The draft belongs to a different module (e.g. Physiotherapy vs Nursing). Clear it out.
          await prefs.remove('professionalProfile');
        }
      } catch (e) {
        log("Error prefilling medical data: $e");
      }
    }

    // As in the 6 Nov app: every duration stays selected at price 0; the server sets prices.
    for (var st in allServiceTypes) {
      selectedServiceTypesPricing[st['_id']] = 0.0;
    }

    // 2. Prefill Experience ONLY if the module matches
    final user = await UserProvider.getCurrentUser();
    if (user != null) {
      // Check if the user already has this specific module saved in their backend skills
      bool hasBackendSkill = user.skills.any((skill) => skill['moduleId'] == moduleId);

      // Only prefill if the active draft matches OR if they already have this skill approved
      if (isSameModule || hasBackendSkill) {
        if (user.Experience > 0 && mounted) {
          setState(() {
            if (user.Experience <= 5) {
              selectedYear = "0-5";
            } else if (user.Experience <= 10)
              selectedYear = "6-10";
            else if (user.Experience <= 15)
              selectedYear = "11-15";
            else if (user.Experience <= 20)
              selectedYear = "16-20";
            else
              selectedYear = "20+";
          });
        }
      } else {
        // Ensure the dropdown is completely cleared out when switching to a new blank module
        if (mounted) {
          setState(() => selectedYear = null);
        }
      }
    }
  }

/*
  Future<void> _prefillMedicalData() async {
    final prefs = await SharedPreferences.getInstance();
    final profileStr = prefs.getString('professionalProfile');

    if (profileStr != null && profileStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(profileStr);
        final profileData = decoded is List ? decoded.first['profile'] : decoded['profile'];

        if (mounted) {
          setState(() {
            if (profileData['pricing'] != null) {
              for (var price in profileData['pricing']) {
                final match = allServiceTypes.firstWhere(
                  (st) => st['Name'] == price['serviceType'],
                  orElse: () => null,
                );
                if (match != null) selectedServiceTypesPricing[match['_id']] = (price['price'] as num).toDouble();
              }
            }

            UserProvider.getCurrentUser().then((user) {
              if (user != null && user.Experience > 0) {
                if (user.Experience <= 5)
                  selectedYear = "0-5";
                else if (user.Experience <= 10)
                  selectedYear = "6-10";
                else if (user.Experience <= 15)
                  selectedYear = "11-15";
                else if (user.Experience <= 20)
                  selectedYear = "16-20";
                else
                  selectedYear = "20+";

                if (mounted) setState(() {});
              }
            });
          });
        }
      } catch (e) {
        log("Error prefilling medical data: $e");
      }
    }
  }
*/

  Future<void> _onNext(List skillsPayload) async {
    final currentUser = await UserProvider.getCurrentUser();
    if (currentUser == null) return;
    setState(() => _isLoading = true);

    int expInt = 0;
    if (selectedYear == "0-5") {
      expInt = 5;
    } else if (selectedYear == "6-10")
      expInt = 10;
    else if (selectedYear == "11-15")
      expInt = 15;
    else if (selectedYear == "16-20")
      expInt = 20;
    else if (selectedYear == "20+")
      expInt = 25;

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
      Experience: expInt,
      RefContactPerson: currentUser.RefContactPerson,
      RefContactNumber: currentUser.RefContactNumber,
      skills: skillsPayload,
      AadharPicFront: currentUser.AadharPicFront,
      AadharPicBack: currentUser.AadharPicBack,
      PanPics: currentUser.PanPics,
      ToolPhoto: currentUser.ToolPhoto,
      AddressProof: currentUser.AddressProof,
      QualificationCertificate: currentUser.QualificationCertificate, // ✅ FIXED
    );

    if (!mounted) return;
    await Provider.of<UserProvider>(context, listen: false).setAsCurrentUser(updatedUser);
    if (!mounted) return;
    setState(() => _isLoading = false);

    context.push(AppRoutes.uploadDocs, extra: PartnerCategory.medical);
  }

  Future<List<dynamic>> fetchCategories() async {
    final list = await _controller.fetchCategories(moduleId);
    return list.map((c) {
      if (c is MedicalCategoryModel) return c.toJson();
      return {'_id': c.id, 'id': c.id, 'name': c.name, 'categoryName': c.name};
    }).toList();
  }

  Future<List<dynamic>> fetchMedicalServices() async {
    if (selectedCategories.isEmpty) return [];
    final categoryIds = selectedCategories.map((c) => c['_id']).join(',');
    final list = await _controller.fetchServices(
      moduleId: moduleId,
      categoryId: categoryIds,
    );
    return list.map((s) {
      if (s is MedicalServiceModel) return s.toJson();
      return {
        '_id': s.id,
        'id': s.id,
        'name': s.name,
        'serviceName': s.name,
        'categoryId': s.categoryId,
        'price': s.price,
      };
    }).toList();
  }

  String _getUnitForService(String typeName) {
    final nameStr = typeName.toLowerCase();
    if (nameStr.contains('hourly')) return 'per hour';
    if (nameStr.contains('days')) return 'per day';
    if (nameStr.contains('24 hours')) return 'per 24 hours';
    return 'fixed';
  }

  Future<void> _prepareAndShowJson() async {
    if (selectedCategories.isEmpty) {
      _showError(context.l10n.setupSelectAtLeastOneCategory);
      return;
    }
    if (selectedServices.isEmpty) {
      _showError(context.l10n.setupSelectAtLeastOneService);
      return;
    }
    if (selectedYear == null) {
      _showError(context.l10n.setupSelectExperience);
      return;
    }

    // Safety fallback ensuring all service types are assigned (6 Nov app).
    for (var st in allServiceTypes) {
      selectedServiceTypesPricing.putIfAbsent(st['_id'], () => 0.0);
    }

    List<Map<String, dynamic>> professionalProfileList = [];
    List<Map<String, dynamic>> profilePricing = selectedServiceTypesPricing.entries.map((entry) {
      final stData = allServiceTypes.firstWhere((e) => e['_id'] == entry.key);
      final stName = stData['Name'];
      return {"serviceType": stName, "price": 0.0, "unit": _getUnitForService(stName)};
    }).toList();

    for (var cat in selectedCategories) {
      var servicesForCat = selectedServices.where((s) => s['categoryId'] == cat['_id']).toList();
      if (servicesForCat.isNotEmpty) {
        List<Map<String, dynamic>> profileServices = servicesForCat.map((s) {
          return {"type": s['service']['_id']};
        }).toList();
        List<Map<String, dynamic>> profileServiceTypes = selectedServiceTypesPricing.keys.map((stId) {
          final stData = allServiceTypes.firstWhere((e) => e['_id'] == stId);
          final stName = stData['Name'];
          return {
            "serviceType": stName,
            "serviceId": stId,
            "serviceName": stName,
            "moduleId": moduleId,
            "moduleName": ModuleName,
            "categoryId": cat['_id']?.toString() ?? "",
            "categoryName": cat['Name']?.toString() ?? "",
            "subCategoryId": "",
            "subCategoryName": "",
            "bookingTypes": ["ONLINE"],
            "deliveryModes": ["OFFLINE"],
            "isAvailable": true,
          };
        }).toList();

        professionalProfileList.add({
          "profession": cat['Name'],
          "profile": {
            "Services": profileServices,
            "serviceTypes": profileServiceTypes,
            "pricing": profilePricing,
            "vehicleTypes": [],
            "licenceTypes": [],
            "languages": [],
            "preferredLocations": [],
            "specialSkills": [],
          },
        });
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('professionalProfile', jsonEncode(professionalProfileList));
    await _onNext([]);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _showCategorySelectionSheet() {
    List<Map<String, dynamic>> tempSelections = List.from(selectedCategories);
    final Future<List<dynamic>> categoriesFuture = fetchCategories();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(context.l10n.setupSelectCategories, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: categoriesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text(context.l10n.setupNoCategories));
                        }
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final item = snapshot.data![index];
                            bool isChecked = tempSelections.any((e) => e['_id'] == item['_id']);
                            return CheckboxListTile(
                              title: Text(context.serverLabel(item['Name'].toString())),
                              value: isChecked,
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: Theme.of(context).primaryColor,
                              visualDensity: VisualDensity.compact,
                              onChanged: (val) {
                                setSheetState(() {
                                  if (val == true) {
                                    tempSelections.add(item);
                                  } else {
                                    tempSelections.removeWhere((e) => e['_id'] == item['_id']);
                                  }
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        setState(() {
                          if (selectedCategories.length != tempSelections.length ||
                              !selectedCategories.every((c) => tempSelections.any((t) => t['_id'] == c['_id']))) {
                            selectedServices.clear();
                          }
                          selectedCategories = tempSelections;
                        });
                        Navigator.pop(context);
                      },
                      child: Text(context.l10n.setupDone, style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showServiceSelectionSheet() {
    List<Map<String, dynamic>> tempSelections = List.from(selectedServices);
    final Future<List<dynamic>> servicesFuture = fetchMedicalServices();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(context.l10n.setupSelectService, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: servicesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) return Center(child: Text(context.l10n.setupErrorFetching));
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text(context.l10n.setupNoItems));
                        }

                        Map<String, List<dynamic>> groupedServices = {};
                        for (var cat in selectedCategories) {
                          groupedServices[cat['_id']] = [];
                        }
                        for (var service in snapshot.data!) {
                          String catId = service['CategoryID'] ?? service['categoryId'] ?? "";
                          if (groupedServices.containsKey(catId)) {
                            groupedServices[catId]!.add(service);
                          }
                        }

                        return ListView.builder(
                          itemCount: selectedCategories.length,
                          itemBuilder: (context, index) {
                            final category = selectedCategories[index];
                            final categoryId = category['_id'];
                            final categoryName = category['Name'];
                            final servicesForThisCat = groupedServices[categoryId] ?? [];

                            if (servicesForThisCat.isEmpty) return const SizedBox.shrink();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ✅ MASTER CHECKBOX FOR CATEGORY
                                CheckboxListTile(
                                  title: Text(
                                    categoryName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  value:
                                      servicesForThisCat.isNotEmpty &&
                                      servicesForThisCat.every(
                                        (serviceItem) =>
                                            tempSelections.any((e) => e['service']['_id'] == serviceItem['_id']),
                                      ),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  activeColor: Theme.of(context).primaryColor,
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: (val) {
                                    setSheetState(() {
                                      if (val == true) {
                                        for (var serviceItem in servicesForThisCat) {
                                          if (!tempSelections.any((e) => e['service']['_id'] == serviceItem['_id'])) {
                                            tempSelections.add({
                                              "service": serviceItem,
                                              "categoryId": categoryId,
                                              "categoryName": categoryName,
                                            });
                                          }
                                        }
                                      } else {
                                        for (var serviceItem in servicesForThisCat) {
                                          tempSelections.removeWhere((e) => e['service']['_id'] == serviceItem['_id']);
                                        }
                                      }
                                    });
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Column(
                                    children: servicesForThisCat.map((serviceItem) {
                                      bool isServiceChecked = tempSelections.any(
                                        (e) => e['service']['_id'] == serviceItem['_id'],
                                      );
                                      return CheckboxListTile(
                                        title: Text(
                                          context.serverLabel((serviceItem['Name'] ?? 'Unknown').toString()),
                                          style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                                        ),
                                        value: isServiceChecked,
                                        controlAffinity: ListTileControlAffinity.leading,
                                        activeColor: Theme.of(context).primaryColor,
                                        visualDensity: VisualDensity.compact,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        onChanged: (val) {
                                          setSheetState(() {
                                            if (val == true) {
                                              tempSelections.add({
                                                "service": serviceItem,
                                                "categoryId": categoryId,
                                                "categoryName": categoryName,
                                              });
                                            } else {
                                              tempSelections.removeWhere(
                                                (e) => e['service']['_id'] == serviceItem['_id'],
                                              );
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                                if (index < selectedCategories.length - 1)
                                  const Divider(color: Colors.transparent, height: 10),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        setState(() => selectedServices = tempSelections);
                        Navigator.pop(context);
                      },
                      child: Text(context.l10n.setupDone, style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showYearSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(context.l10n.setupSelectYears, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: yearsList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(yearsList[index]),
                      onTap: () {
                        setState(() => selectedYear = yearsList[index]);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppTopBar(title: context.serverLabel(ModuleName));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    String categoryHint = selectedCategories.isEmpty
        ? context.l10n.setupSelectCategories
        : (selectedCategories.length == 1
              ? selectedCategories.first['Name']
              : context.l10n.setupCategoriesSelected(selectedCategories.length));
    String servicesHint = selectedServices.isEmpty
        ? context.l10n.setupSelectServices
        : (selectedServices.length == 1
              ? selectedServices.first['service']['Name']
              : context.l10n.setupServicesSelected(selectedServices.length));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.setupAddCategoriesServicesTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              context.l10n.setupAddCategoriesServicesSubtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),

            _buildLabel(context.l10n.setupCategories),
            _buildDropdownTrigger(hint: categoryHint, onTap: _showCategorySelectionSheet),
            const SizedBox(height: 16),

            if (selectedCategories.isNotEmpty) _buildSelectedCategoriesBox(),
            const SizedBox(height: 20),

            _buildLabel(context.l10n.setupServices),
            _buildDropdownTrigger(
              hint: servicesHint,
              enabled: selectedCategories.isNotEmpty,
              onTap: _showServiceSelectionSheet,
            ),
            const SizedBox(height: 20),

            _buildLabel(context.l10n.setupYearOfExperience),
            _buildDropdownTrigger(hint: selectedYear ?? context.l10n.setupSelectYears, onTap: _showYearSheet),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _prepareAndShowJson,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(context.l10n.commonNext, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 2.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
    );
  }

  Widget _buildDropdownTrigger({required String hint, required VoidCallback onTap, bool enabled = true}) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 1.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(hint, style: TextStyle(color: enabled ? Colors.black87 : Colors.grey, fontSize: 14)),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black87, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedCategoriesBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.textDisabled, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.setupCategories,
            style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 15),
          ),
          const SizedBox(height: 8),
          ...selectedCategories
              .map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.check, size: 14, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          context.serverLabel(c['Name'].toString()),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              ,
        ],
      ),
    );
  }
}
