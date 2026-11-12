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
import '../../data/models/pandit_setup_model.dart';
import '../providers/pandit_setup_provider.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

class PanditSetupScreen extends StatefulWidget {
  final Map<String, dynamic>? args;
  const PanditSetupScreen({super.key, this.args});

  @override
  State<PanditSetupScreen> createState() => _PanditSetupScreenState();
}

class _PanditSetupScreenState extends State<PanditSetupScreen> {
  late final PanditSetupProvider _controller;
  late String moduleId;
  late String moduleCode;
  late String ModuleName;

  List<Map<String, dynamic>> selectedCategories = [];
  List<Map<String, dynamic>> selectedServices = [];

  String? selectedYear;
  final List<String> yearsList = ["0-5", "6-10", "11-15", "16-20", "20+"];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = ServiceLocator.createPanditSetupProvider();

    final args = widget.args;
    if (args != null) {
      moduleId = args['moduleId'] ?? "6a40b51b2facc993ac45f537";
      moduleCode = args['moduleCode'] ?? "PUROHIT";
      ModuleName = args['ModuleName'] ?? "Pandit / Purohit";
    } else {
      moduleId = "6a40b51b2facc993ac45f537";
      moduleCode = "PUROHIT";
      ModuleName = "Pandit / Purohit";
    }

    _prefillPanditData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _prefillPanditData() async {
    final prefs = await SharedPreferences.getInstance();
    final profileStr = prefs.getString('professionalProfile');

    if (profileStr != null && profileStr.isNotEmpty) {
      try {
        UserProvider.getCurrentUser().then((user) {
          if (user != null && user.Experience > 0) {
            if (user.Experience <= 5) {
              selectedYear = "0-5";
            } else if (user.Experience <= 10) selectedYear = "6-10";
            else if (user.Experience <= 15) selectedYear = "11-15";
            else if (user.Experience <= 20) selectedYear = "16-20";
            else selectedYear = "20+";

            if (mounted) setState(() {});
          }
        });
      } catch (e) { log("Error prefilling pandit data: $e"); }
    }
  }

  Future<void> _onNext(List skillsPayload) async {
    final currentUser = await UserProvider.getCurrentUser();
    if (currentUser == null) return;
    setState(() => _isLoading = true);

    int expInt = 0;
    if (selectedYear == "0-5") {
      expInt = 5;
    } else if (selectedYear == "6-10") expInt = 10;
    else if (selectedYear == "11-15") expInt = 15;
    else if (selectedYear == "16-20") expInt = 20;
    else if (selectedYear == "20+") expInt = 25;

    final updatedUser = User(
        id: currentUser.id, FirstName: currentUser.FirstName, LastName: currentUser.LastName,
        Gender: currentUser.Gender, email: currentUser.email, phone: currentUser.phone,
        isProfileUpdated: true, isActive: currentUser.isActive, Address: currentUser.Address,
        City: currentUser.City, State: currentUser.State, District: currentUser.District,
        PinCode: currentUser.PinCode, Avatar: currentUser.Avatar, UPI: currentUser.UPI,
        PaymentGateWay: currentUser.PaymentGateWay, Experience: expInt,
        RefContactPerson: currentUser.RefContactPerson, RefContactNumber: currentUser.RefContactNumber,
        skills: skillsPayload, AadharPicFront: currentUser.AadharPicFront, AadharPicBack: currentUser.AadharPicBack,
        PanPics: currentUser.PanPics, ToolPhoto: currentUser.ToolPhoto, AddressProof: currentUser.AddressProof,
        QualificationCertificate: currentUser.QualificationCertificate // ✅ FIXED
    );

    if (!mounted) return;
    await Provider.of<UserProvider>(context, listen: false).setAsCurrentUser(updatedUser);
    if (!mounted) return;
    setState(() => _isLoading = false);

    context.push(AppRoutes.uploadDocs, extra: PartnerCategory.purohit);
  }

  Future<List<dynamic>> fetchCategories() async {
    final list = await _controller.fetchCategories(moduleId);
    return list.map((c) {
      if (c is PanditCategoryModel) return c.toJson();
      return {'_id': c.id, 'id': c.id, 'name': c.name, 'categoryName': c.name};
    }).toList();
  }

  Future<List<dynamic>> fetchPurohitServices() async {
    if (selectedCategories.isEmpty) return [];
    final categoryIds = selectedCategories.map((c) => c['_id'].toString()).toList();
    final list = await _controller.fetchPurohitServices(
      moduleId: moduleId,
      categoryIds: categoryIds,
    );
    return list.map((s) {
      if (s is PanditServiceModel) return s.toJson();
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

  Future<void> _prepareAndShowJson() async {
    if (selectedCategories.isEmpty) { _showError(context.l10n.setupSelectAtLeastOneCategory); return; }
    if (selectedServices.isEmpty) { _showError(context.l10n.setupSelectAtLeastOneService); return; }
    if (selectedYear == null) { _showError(context.l10n.setupSelectExperience); return; }

    List<Map<String, dynamic>> professionalProfileList = [];

    for (var cat in selectedCategories) {
      var servicesForCat = selectedServices.where((s) => s['categoryId'] == cat['_id']).toList();

      if (servicesForCat.isNotEmpty) {
        List<Map<String, dynamic>> profileServices = servicesForCat.map((s) { return {"type": s['service']['_id']}; }).toList();
        List<Map<String, dynamic>> profileServiceTypes = servicesForCat.map((serviceData) {
          final serviceItem = serviceData['service'];
          final List variants = serviceData['variants'] ?? [];
          List<String> deliveryModes = variants.map<String>((v) => v['Name'].toString().toUpperCase()).toList();

          return {
            "serviceType": "", "serviceId": serviceItem['_id']?.toString() ?? "", "serviceName": serviceItem['Name']?.toString() ?? "", "moduleId": moduleId, "moduleName": ModuleName, "categoryId": cat['_id']?.toString() ?? "", "categoryName": cat['Name']?.toString() ?? "", "subCategoryId": "", "subCategoryName": "", "bookingTypes": ["ONLINE"], "deliveryModes": deliveryModes, "isAvailable": true
          };
        }).toList();

        professionalProfileList.add({
          "profession": cat['Name'],
          "profile": { "Services": profileServices, "serviceTypes": profileServiceTypes, "pricing": [], "vehicleTypes": [], "licenceTypes": [], "languages": [], "preferredLocations": [], "specialSkills": [] }
        });
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('professionalProfile', jsonEncode(professionalProfileList));

    await _onNext([]);
  }

  void _showError(String message) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red)); }

  void _showCategorySelectionSheet() {
    List<Map<String, dynamic>> tempSelections = List.from(selectedCategories);
    final Future<List<dynamic>> categoriesFuture = fetchCategories();

    showModalBottomSheet(
      context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(20), height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                Row(children: [Text(context.l10n.setupSelectCategories, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const Spacer(), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded))]),
                const SizedBox(height: 10),
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: categoriesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text(context.l10n.setupNoCategories));

                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final item = snapshot.data![index];
                          bool isChecked = tempSelections.any((e) => e['_id'] == item['_id']);

                          return CheckboxListTile(
                            title: Text(context.serverLabel(item['Name'].toString())), value: isChecked, controlAffinity: ListTileControlAffinity.leading, activeColor: AppColors.primary, visualDensity: VisualDensity.compact,
                            onChanged: (val) {
                              setSheetState(() {
                                if (val == true) { tempSelections.add(item); }
                                else { tempSelections.removeWhere((e) => e['_id'] == item['_id']); }
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () { setState(() { if (selectedCategories.length != tempSelections.length || !selectedCategories.every((c) => tempSelections.any((t) => t['_id'] == c['_id']))) { selectedServices.clear(); } selectedCategories = tempSelections; }); Navigator.pop(context); }, child: Text(context.l10n.setupDone, style: const TextStyle(color: Colors.white, fontSize: 16))))
              ],
            ),
          );
        });
      },
    );
  }

  void _showServiceSelectionSheet() {
    List<Map<String, dynamic>> tempSelections = List.from(selectedServices);
    final Future<List<dynamic>> servicesFuture = fetchPurohitServices();
    final List<Map<String, String>> purohitVariants = [ {"_id": "ONLINE", "Name": "Online"}, {"_id": "OFFLINE", "Name": "Offline"} ];

    showModalBottomSheet(
      context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(20), height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                Row(children: [Text(context.l10n.setupSelectService, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const Spacer(), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded))]),
                const SizedBox(height: 10),
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: servicesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (snapshot.hasError) return Center(child: Text(context.l10n.setupErrorFetching));
                      if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text(context.l10n.setupNoItems));

                      Map<String, List<dynamic>> groupedServices = {};
                      for (var cat in selectedCategories) { groupedServices[cat['_id']] = []; }
                      for (var service in snapshot.data!) {
                        String catId = service['CategoryID'] ?? service['categoryId'] ?? "";
                        if (groupedServices.containsKey(catId)) { groupedServices[catId]!.add(service); }
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
                              Padding(padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 4.0), child: Text(context.serverLabel((categoryName).toString()), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87))),
                              ...servicesForThisCat.map((serviceItem) {
                                bool isServiceChecked = tempSelections.any((e) => e['service']['_id'] == serviceItem['_id']);
                                Map<String, dynamic>? currentSelection = isServiceChecked ? tempSelections.firstWhere((e) => e['service']['_id'] == serviceItem['_id']) : null;

                                return Column(
                                  children: [
                                    CheckboxListTile(
                                      title: Text(context.serverLabel((serviceItem['Name'] ?? 'Unknown').toString()), style: TextStyle(fontSize: 14, color: Colors.grey.shade800)), value: isServiceChecked, controlAffinity: ListTileControlAffinity.leading, activeColor: AppColors.primary, visualDensity: VisualDensity.compact, contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      onChanged: (val) {
                                        setSheetState(() {
                                          if (val == true) {
                                            tempSelections.add({ "service": serviceItem, "categoryId": categoryId, "categoryName": categoryName, "variants": List.from(purohitVariants) });
                                          } else {
                                            tempSelections.removeWhere((e) => e['service']['_id'] == serviceItem['_id']);
                                          }
                                        });
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 36.0),
                                      child: Column(
                                        children: purohitVariants.map((variant) {
                                          bool isVariantChecked = currentSelection != null && (currentSelection!['variants'] as List).any((v) => v['_id'] == variant['_id']);
                                          return CheckboxListTile(
                                            title: Text(context.serverLabel((variant['Name']).toString()), style: TextStyle(fontSize: 14, color: Colors.grey.shade700)), value: isVariantChecked, controlAffinity: ListTileControlAffinity.leading, activeColor: AppColors.primary, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero,
                                            onChanged: (val) {
                                              setSheetState(() {
                                                if (val == true) {
                                                  if (!isServiceChecked) { currentSelection = { "service": serviceItem, "categoryId": categoryId, "categoryName": categoryName, "variants": [variant] }; tempSelections.add(currentSelection!); isServiceChecked = true; }
                                                  else { currentSelection!['variants'].add(variant); }
                                                } else { currentSelection?['variants'].removeWhere((v) => v['_id'] == variant['_id']); }
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              if (index < selectedCategories.length - 1) const Divider(color: Colors.transparent, height: 10),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () { setState(() => selectedServices = tempSelections); Navigator.pop(context); }, child: Text(context.l10n.setupDone, style: const TextStyle(color: Colors.white, fontSize: 16))))
              ],
            ),
          );
        });
      },
    );
  }

  void _showYearSheet() {
    showModalBottomSheet(
      context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20), height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [Text(context.l10n.setupSelectYears, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const Spacer(), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded))]),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true, itemCount: yearsList.length,
                  itemBuilder: (context, index) { return ListTile(title: Text(yearsList[index]), onTap: () { setState(() => selectedYear = yearsList[index]); Navigator.pop(context); }); },
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
    String categoryHint = selectedCategories.isEmpty ? context.l10n.setupSelectCategories : (selectedCategories.length == 1 ? selectedCategories.first['Name'] : context.l10n.setupCategoriesSelected(selectedCategories.length));
    String servicesHint = selectedServices.isEmpty ? context.l10n.setupSelectServices : (selectedServices.length == 1 ? selectedServices.first['service']['Name'] : context.l10n.setupServicesSelected(selectedServices.length));

    return Scaffold(
      backgroundColor: AppColors.background, appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.setupAddCategoriesTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)), const SizedBox(height: 6), Text(context.l10n.setupAddCategoriesSubtitle, style: const TextStyle(color: Colors.grey, fontSize: 14)), const SizedBox(height: 30),

            _buildLabel(context.l10n.setupCategories), _buildDropdownTrigger(hint: categoryHint, onTap: _showCategorySelectionSheet), const SizedBox(height: 16),
            if (selectedCategories.isNotEmpty) _buildSelectedCategoriesBox(), const SizedBox(height: 20),

            _buildLabel(context.l10n.setupServices), _buildDropdownTrigger(hint: servicesHint, enabled: selectedCategories.isNotEmpty, onTap: _showServiceSelectionSheet), const SizedBox(height: 20),

            _buildLabel(context.l10n.setupYearOfExperience), _buildDropdownTrigger(hint: selectedYear ?? context.l10n.setupSelectYears, onTap: _showYearSheet), const SizedBox(height: 40),

            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _prepareAndShowJson,
                style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                child: _isLoading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : Text(context.l10n.commonNext, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) { return Padding(padding: const EdgeInsets.only(bottom: 8.0, left: 2.0), child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))); }
  Widget _buildDropdownTrigger({required String hint, required VoidCallback onTap, bool enabled = true}) {
    return InkWell(
      onTap: enabled ? onTap : null, borderRadius: BorderRadius.circular(8),
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15), decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border, width: 1.2), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(hint, style: TextStyle(color: enabled ? Colors.black87 : Colors.grey, fontSize: 14)), const Icon(Icons.keyboard_arrow_down, color: Colors.black87, size: 22)])),
    );
  }
  Widget _buildSelectedCategoriesBox() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.background, border: Border.all(color: AppColors.textDisabled, width: 1), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.setupCategories, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 15)), const SizedBox(height: 8),
          ...selectedCategories.map((c) => Padding(padding: const EdgeInsets.only(bottom: 6.0), child: Row(children: [Container(decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.check, size: 14, color: Colors.white)), const SizedBox(width: 10), Expanded(child: Text(context.serverLabel(c['Name'].toString()), style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary, fontSize: 13)))]))),
        ],
      ),
    );
  }
}