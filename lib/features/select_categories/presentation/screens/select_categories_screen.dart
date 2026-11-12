import 'package:gotask_partner/core/localization/server_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:gotask_partner/features/document_upload/presentation/screens/upload_images_screen.dart';
import 'package:provider/provider.dart';
import 'package:gotask_partner/core/design/app_top_bar.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/models/User.dart';
import '../../../../core/provider/UserProvider.dart';
import '../../data/models/category_model.dart';
import '../providers/select_categories_provider.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

class SelectCategoriesScreen extends StatefulWidget {
  final Map<String, dynamic>? args;
  const SelectCategoriesScreen({super.key, this.args});

  @override
  State<SelectCategoriesScreen> createState() => _SelectCategoriesScreenState();
}

class _SelectCategoriesScreenState extends State<SelectCategoriesScreen> {
  late final SelectCategoriesProvider _controller;

  late String moduleId;
  late String moduleCode;
  late String ModuleName;
  late bool hasCategory;

  bool showServiceDropdown = true;

  // Single Selection Variables (For Non-PC Modules)
  String? selectedCategoryId;
  String? selectedCategoryName;
  String? selectedSubCategoryId;
  String? selectedSubCategoryName;

  // Multiple Selection Variables (For Personal Care Module)
  List<Map<String, dynamic>> selectedSubCategories = [];

  List<Map<String, dynamic>> selectedServiceData = [];

  String? selectedYear;
  final List<String> yearsList = ["0-5", "6-10", "11-15", "16-20"];

  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = ServiceLocator.createSelectCategoriesProvider();

    final args = widget.args;
    if (args != null) {
      moduleId = args['moduleId'] ?? "6976633c40fa55336c965dfc";
      moduleCode = args['moduleCode'] ?? "HS";
      ModuleName = args['ModuleName'] ?? "";
      hasCategory = args['hasCategory'] ?? false;
    } else {
      moduleId = args?.toString() ?? "6976633c40fa55336c965dfc";
      moduleCode = "HS";
      ModuleName = '';
      hasCategory = false;
    }

    _prefillCategoryData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Helper to dynamically hide variants for specific subcategories
  bool get _shouldHideVariants {
    if (moduleCode.toUpperCase() == 'PC') return true; // Hide variants strictly for Personal Care
    if (selectedSubCategoryName == null) return false;
    final name = selectedSubCategoryName!.trim().toLowerCase();
    return name == 'cleaning' || name == 'electrician';
  }

  bool get shouldShowServiceSection {
    if (moduleCode.toUpperCase() == 'PUROHIT') return false;
    if (moduleCode.toUpperCase() == 'PC') return selectedSubCategories.isNotEmpty;
    if (selectedSubCategoryId == null) return true;
    return showServiceDropdown;
  }

  Future<void> _prefillCategoryData() async {
    final user = await UserProvider.getCurrentUser();
    if (user != null && user.skills.isNotEmpty) {
      if (moduleCode.toUpperCase() == 'PC') {
        var pcSkills = user.skills.where((s) => s['moduleId'] == moduleId).toList();
        if (pcSkills.isNotEmpty && mounted) {
          setState(() {
            selectedCategoryId = pcSkills.first['categoryId'];
            selectedCategoryName = pcSkills.first['categoryName'];

            for (var skill in pcSkills) {
              if (skill['subCategoryId'] != null) {
                selectedSubCategories.add({
                  '_id': skill['subCategoryId'],
                  'Name': skill['subcategoryName'] ?? skill['subCategoryName'] ?? 'Unknown'
                });
              }
              if (skill['serviceTypes'] != null) {
                for (var st in skill['serviceTypes']) {
                  selectedServiceData.add({
                    "serviceType": {
                      "_id": st['serviceTypeID'],
                      "Name": st['serviceTypeName'],
                      "SubCategoryID": skill['subCategoryId']
                    },
                    "variants": []
                  });
                }
              }
            }
            _setExperience(user.Experience);
          });
        }
      } else {
        final skill = user.skills.first;
        if (skill['moduleId'] == moduleId && mounted) {
          setState(() {
            selectedCategoryId = skill['categoryId'];
            selectedCategoryName = skill['categoryName'];
            selectedSubCategoryId = skill['subCategoryId'];
            selectedSubCategoryName = skill['subcategoryName'] ?? skill['subCategoryName'];

            _setExperience(user.Experience);

            if (skill['serviceTypes'] != null) {
              for (var st in skill['serviceTypes']) {
                selectedServiceData.add({
                  "serviceType": {"_id": st['serviceTypeID'], "Name": st['serviceTypeName']},
                  "variants": st['serviceVariant']?.map((v) => {"_id": v['serviceVariantId'], "Name": v['serviceVariantName']}).toList() ?? [],
                });
              }
            }
          });
        }
      }
    }
  }

  void _setExperience(int exp) {
    if (exp > 0) {
      if (exp <= 5) {
        selectedYear = "0-5";
      } else if (exp <= 10) selectedYear = "6-10";
      else if (exp <= 15) selectedYear = "11-15";
      else selectedYear = "16-20";
    }
  }

  Future<void> _onNext(Map<String, dynamic> skillsPayload) async {
    final currentUser = await UserProvider.getCurrentUser();
    if (currentUser == null) return;
    setState(() => _isLoading = true);

    int expInt = 0;
    if (selectedYear == "0-5") {
      expInt = 5;
    } else if (selectedYear == "6-10") expInt = 10;
    else if (selectedYear == "11-15") expInt = 15;
    else if (selectedYear == "16-20") expInt = 20;

    final updatedUser = User(
        id: currentUser.id, FirstName: currentUser.FirstName, LastName: currentUser.LastName,
        Gender: currentUser.Gender, email: currentUser.email, phone: currentUser.phone,
        isProfileUpdated: true, isActive: currentUser.isActive, Address: currentUser.Address,
        City: currentUser.City, State: currentUser.State, District: currentUser.District,
        PinCode: currentUser.PinCode, Avatar: currentUser.Avatar, UPI: currentUser.UPI,
        PaymentGateWay: currentUser.PaymentGateWay, Experience: expInt,
        RefContactPerson: currentUser.RefContactPerson, RefContactNumber: currentUser.RefContactNumber,
        skills: skillsPayload['skills'], AadharPicFront: currentUser.AadharPicFront,
        AadharPicBack: currentUser.AadharPicBack, PanPics: currentUser.PanPics,
        ToolPhoto: currentUser.ToolPhoto, AddressProof: currentUser.AddressProof,
        QualificationCertificate: currentUser.QualificationCertificate
    );

    if (!mounted) return;
    await Provider.of<UserProvider>(context, listen: false).setAsCurrentUser(updatedUser);

    if (!mounted) return;
    setState(() => _isLoading = false);

    context.push(AppRoutes.uploadDocs, extra: PartnerCategory.homeServices);
  }

  Future<List<dynamic>> fetchCategories() async {
    final list = await _controller.fetchCategories(moduleId);
    return list.map((c) {
      if (c is CategoryItemModel) return c.toJson();
      return {'_id': c.id, 'id': c.id, 'name': c.name, 'categoryName': c.name};
    }).toList();
  }

  Future<List<dynamic>> fetchSubCategories() async {
    final list = await _controller.fetchSubCategories(
      moduleId: moduleId,
      categoryId: (hasCategory && selectedCategoryId != null) ? selectedCategoryId : null,
      moduleName: ModuleName,
    );
    return list.map((c) {
      if (c is SubcategoryItemModel) return c.toJson();
      return {'_id': c.id, 'id': c.id, 'name': c.name, 'subCategoryName': c.name, 'categoryId': c.categoryId};
    }).toList();
  }

  Future<List<dynamic>> fetchServiceTypes() async {
    if (selectedSubCategoryId == null) return [];
    final list = await _controller.fetchServiceTypes(
      moduleId: moduleId,
      subCategoryId: selectedSubCategoryId!,
      categoryId: (hasCategory && selectedCategoryId != null) ? selectedCategoryId : null,
    );
    return list.map((c) {
      if (c is ServiceTypeItemModel) return c.toJson();
      return {'_id': c.id, 'id': c.id, 'name': c.name, 'serviceTypeName': c.name, 'defaultPrice': c.defaultPrice};
    }).toList();
  }

  Future<List<dynamic>> fetchServices() async {
    if (moduleCode.toUpperCase() == 'PC') {
      if (selectedSubCategories.isEmpty) return [];
      final list = await _controller.fetchPersonalCareServices(
        moduleId: moduleId,
        subCategoryIds: selectedSubCategories.map((c) => c['_id'].toString()).toList(),
      );
      return list.map((c) {
        if (c is ServiceItemModel) return c.toJson();
        if (c is Map) return c;
        return {'_id': (c as dynamic).id, 'id': (c as dynamic).id, 'name': (c as dynamic).name};
      }).toList();
    } else {
      final list = await _controller.fetchServices(
        moduleId: moduleId,
        categoryId: (hasCategory && selectedCategoryId != null) ? selectedCategoryId : null,
        subCategoryId: selectedSubCategoryId,
        moduleName: ModuleName,
      );
      return list.map((c) {
        if (c is ServiceItemModel) return c.toJson();
        return {'_id': c.id, 'id': c.id, 'name': c.name, 'serviceName': c.name, 'price': c.price};
      }).toList();
    }
  }

  Future<void> _prepareAndShowJson() async {
    final isPersonalCare = (moduleCode.toUpperCase() == 'PC');

    if (hasCategory && selectedCategoryId == null) { _showError(context.l10n.setupSelectCategoryError); return; }
    if (isPersonalCare && selectedSubCategories.isEmpty) { _showError(context.l10n.setupSelectSubCategoryAtLeastOne); return; }
    if (!isPersonalCare && selectedSubCategoryId == null) { _showError(context.l10n.setupSelectSubCategory); return; }
    if (shouldShowServiceSection && selectedServiceData.isEmpty) { _showError(context.l10n.setupSelectServiceError); return; }
    if (selectedYear == null) { _showError(context.l10n.setupSelectExperience); return; }

    List<Map<String, dynamic>> skillsList = [];

    if (isPersonalCare) {
      for (var subCat in selectedSubCategories) {
        var servicesForThisSubCat = selectedServiceData.where((s) {
          return s['serviceType']['SubCategoryID'] == subCat['_id'];
        }).toList();

        skillsList.add({
          "moduleId": moduleId, "moduleName": moduleCode,
          "categoryId": hasCategory ? selectedCategoryId : null,
          "categoryName": hasCategory ? selectedCategoryName : null,
          "subCategoryId": subCat['_id'],
          "subcategoryName": subCat['Name'],
          "serviceTypes": servicesForThisSubCat.map((serviceData) {
            final serviceType = serviceData['serviceType'];
            return {
              "serviceTypeID": serviceType['_id'],
              "serviceTypeName": serviceType['Name'] ?? serviceType['Code'] ?? 'Unknown',
              "serviceVariant": [],
            };
          }).toList(),
        });
      }
    } else {
      skillsList.add({
        "moduleId": moduleId, "moduleName": moduleCode,
        "categoryId": hasCategory ? selectedCategoryId : null,
        "categoryName": hasCategory ? selectedCategoryName : null,
        "subCategoryId": selectedSubCategoryId,
        "subcategoryName": selectedSubCategoryName,
        "serviceTypes": shouldShowServiceSection
            ? selectedServiceData.map((serviceData) {
          final serviceType = serviceData['serviceType'];
          final List variants = serviceData['variants'] ?? [];
          return {
            "serviceTypeID": serviceType['_id'],
            "serviceTypeName": serviceType['Name'] ?? serviceType['Code'] ?? 'Unknown',
            "serviceVariant": variants.map((v) => {
              "serviceVariantId": v['_id'],
              "serviceVariantName": v['Name'] ?? v['Code'] ?? 'Unknown'
            }).toList(),
          };
        }).toList() : [],
      });
    }

    Map<String, dynamic> skillsPayload = {"skills": skillsList};
    await _onNext(skillsPayload);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  // --- Sub Categories Bottom Sheets ---

  void _showSingleSelectionSheet({required String title, required Future<List<dynamic>> future, bool isCategory = false}) {
    showModalBottomSheet(
      context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.all(20), height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text(context.l10n.setupNoData));
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final item = snapshot.data![index];
                          return RadioListTile<String>(
                            title: Text(context.serverLabel(item['Name'].toString())), value: item['_id'], groupValue: isCategory ? selectedCategoryId : selectedSubCategoryId, activeColor: Theme.of(context).colorScheme.primary,
                            onChanged: (val) {
                              setState(() {
                                if (isCategory) {
                                  selectedCategoryId = item['_id']; selectedCategoryName = item['Name'];
                                  selectedSubCategoryId = null; selectedSubCategoryName = null;
                                  selectedSubCategories.clear();
                                  selectedServiceData.clear(); showServiceDropdown = true;
                                } else {
                                  selectedSubCategoryId = item['_id']; selectedSubCategoryName = item['Name'];
                                  selectedServiceData.clear();
                                  showServiceDropdown = item['has_service_types'] ?? true;
                                }
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMultiSubCategorySheet() {
    List<Map<String, dynamic>> tempSelections = List.from(selectedSubCategories);
    final Future<List<dynamic>> categoriesFuture = fetchSubCategories();

    showModalBottomSheet(
      context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(20), height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                Row(
                    children: [
                      Text(context.l10n.setupSelectSubCategories, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded))
                    ]
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: categoriesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text(context.l10n.setupNoItems));
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final item = snapshot.data![index];
                          bool isChecked = tempSelections.any((e) => e['_id'] == item['_id']);
                          return CheckboxListTile(
                            title: Text(context.serverLabel(item['Name'].toString())), value: isChecked, controlAffinity: ListTileControlAffinity.leading, activeColor: Theme.of(context).primaryColor, visualDensity: VisualDensity.compact,
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
                SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        onPressed: () {
                          setState(() {
                            // Remove services belonging to unchecked sub categories
                            selectedServiceData.removeWhere((service) {
                              String subCatId = service['serviceType']['SubCategoryID'] ?? "";
                              return !tempSelections.any((sub) => sub['_id'] == subCatId);
                            });
                            selectedSubCategories = tempSelections;
                          });
                          Navigator.pop(context);
                        },
                        child: Text(context.l10n.setupDone, style: const TextStyle(color: Colors.white, fontSize: 16))
                    )
                )
              ],
            ),
          );
        });
      },
    );
  }

  // --- Services Bottom Sheet ---

  void _showServiceSelectionSheet() {
    final isPersonalCare = (moduleCode.toUpperCase() == 'PC');
    final String sheetTitle = isPersonalCare ? context.l10n.setupSelectService : context.l10n.setupSelectServiceType;

    final Future<List<dynamic>> dataFuture = isPersonalCare ? fetchServices() : fetchServiceTypes();

    List<Map<String, dynamic>> tempSelections = selectedServiceData.map((e) {
      return { "serviceType": e["serviceType"], "variants": List<dynamic>.from(e["variants"] ?? []) };
    }).toList();

    showModalBottomSheet(
      context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(20), height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(sheetTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded))
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: dataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (snapshot.hasError) return Center(child: Text(context.l10n.setupErrorFetching));
                      if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text(context.l10n.setupNoItems));

                      if (isPersonalCare) {
                        // Logic for grouping Personal Care Checkboxes
                        Map<String, List<dynamic>> groupedServices = {};
                        for (var sub in selectedSubCategories) { groupedServices[sub['_id']] = []; }
                        for (var service in snapshot.data!) {
                          String subId = service['SubCategoryID'] ?? "";
                          if (groupedServices.containsKey(subId)) { groupedServices[subId]!.add(service); }
                        }

                        return ListView.builder(
                            itemCount: selectedSubCategories.length,
                            itemBuilder: (context, index) {
                              final subCat = selectedSubCategories[index];
                              final servicesForSub = groupedServices[subCat['_id']] ?? [];

                              if (servicesForSub.isEmpty) return const SizedBox.shrink();

                              bool isAllSelected = servicesForSub.isNotEmpty && servicesForSub.every((s) => tempSelections.any((ts) => ts['serviceType']['_id'] == s['_id']));

                              return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CheckboxListTile(
                                        title: Text(context.serverLabel((subCat['Name'] ?? '').toString()), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                                        value: isAllSelected,
                                        controlAffinity: ListTileControlAffinity.leading,
                                        activeColor: Theme.of(context).colorScheme.primary,
                                        contentPadding: EdgeInsets.zero,
                                        onChanged: (val) {
                                          setSheetState(() {
                                            if (val == true) {
                                              for (var s in servicesForSub) {
                                                if (!tempSelections.any((ts) => ts['serviceType']['_id'] == s['_id'])) {
                                                  tempSelections.add({"serviceType": s, "variants": []});
                                                }
                                              }
                                            } else {
                                              for (var s in servicesForSub) {
                                                tempSelections.removeWhere((ts) => ts['serviceType']['_id'] == s['_id']);
                                              }
                                            }
                                          });
                                        }
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(left: 16.0),
                                        child: Column(
                                          children: servicesForSub.map((sItem) {
                                            bool isChecked = tempSelections.any((ts) => ts['serviceType']['_id'] == sItem['_id']);
                                            return CheckboxListTile(
                                                title: Text(context.serverLabel((sItem['Name'] ?? 'Unknown').toString()), style: TextStyle(fontSize: 14, color: Colors.grey.shade800)),
                                                value: isChecked,
                                                controlAffinity: ListTileControlAffinity.leading,
                                                activeColor: Theme.of(context).colorScheme.primary,
                                                visualDensity: VisualDensity.compact,
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                onChanged: (val) {
                                                  setSheetState(() {
                                                    if (val == true) {
                                                      tempSelections.add({"serviceType": sItem, "variants": []});
                                                    } else {
                                                      tempSelections.removeWhere((ts) => ts['serviceType']['_id'] == sItem['_id']);
                                                    }
                                                  });
                                                }
                                            );
                                          }).toList(),
                                        )
                                    ),
                                    if (index < selectedSubCategories.length - 1)
                                      const Divider(color: Colors.transparent, height: 10),
                                  ]
                              );
                            }
                        );
                      } else {
                        // Logic for Standard Radio Checkboxes with Variants (Other Modules)
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final serviceItem = snapshot.data![index];
                            List variants = serviceItem['variants'] ?? [];
                            if (_shouldHideVariants) { variants = []; }

                            bool isServiceChecked = tempSelections.any((e) => e['serviceType']['_id'] == serviceItem['_id']);
                            Map<String, dynamic>? currentSelection = isServiceChecked ? tempSelections.firstWhere((e) => e['serviceType']['_id'] == serviceItem['_id']) : null;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CheckboxListTile(
                                  title: Text(context.serverLabel((serviceItem['Name'] ?? 'Unknown').toString()), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  value: isServiceChecked, controlAffinity: ListTileControlAffinity.leading, activeColor: Theme.of(context).colorScheme.primary, visualDensity: VisualDensity.compact,
                                  onChanged: (val) {
                                    setSheetState(() {
                                      if (val == true) {
                                        tempSelections.add({ "serviceType": serviceItem, "variants": List.from(variants) });
                                      } else {
                                        tempSelections.removeWhere((e) => e['serviceType']['_id'] == serviceItem['_id']);
                                      }
                                    });
                                  },
                                ),
                                if (variants.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30.0),
                                    child: Column(
                                      children: variants.map((variant) {
                                        bool isVariantChecked = currentSelection != null && currentSelection?['variants'].any((v) => v['_id'] == variant['_id']);
                                        return CheckboxListTile(
                                          title: Text(context.serverLabel((variant['Name']).toString())), value: isVariantChecked, controlAffinity: ListTileControlAffinity.leading, activeColor: Theme.of(context).colorScheme.primary, visualDensity: VisualDensity.compact,
                                          onChanged: (val) {
                                            setSheetState(() {
                                              if (val == true) {
                                                if (!isServiceChecked) {
                                                  currentSelection = { "serviceType": serviceItem, "variants": [variant] };
                                                  tempSelections.add(currentSelection!);
                                                  isServiceChecked = true;
                                                } else {
                                                  currentSelection!['variants'].add(variant);
                                                }
                                              } else {
                                                currentSelection?['variants'].removeWhere((v) => v['_id'] == variant['_id']);
                                              }
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                const SizedBox(height: 10),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: () { setState(() => selectedServiceData = tempSelections); Navigator.pop(context); },
                    child: Text(context.l10n.setupDone, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                )
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
                  shrinkWrap: true, itemCount: yearsList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(yearsList[index]),
                      onTap: () { setState(() => selectedYear = yearsList[index]); Navigator.pop(context); },
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
    return AppTopBar(title: context.l10n.setupSelectCategory);
  }

  // --- Dynamic Render Logic for Horizonatal Cards ---
  List<Widget> _buildServiceCardsList(Color primaryColor) {
    final isPersonalCare = (moduleCode.toUpperCase() == 'PC');

    if (isPersonalCare) {
      List<Widget> cards = [];
      for (var subCat in selectedSubCategories) {
        // Find all selected services that belong to this SubCategory
        var servicesForThisSubCat = selectedServiceData.where((s) {
          return s['serviceType']['SubCategoryID'] == subCat['_id'];
        }).toList();

        if (servicesForThisSubCat.isNotEmpty) {
          cards.add(
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.55,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: AppColors.border,
                    border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SubCategory Name acts as the Title
                    Text(
                        context.serverLabel((subCat['Name'] ?? 'Unknown').toString()),
                        style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 16)
                    ),
                    const SizedBox(height: 10),

                    // Selected Services mapped as Check Items
                    ...servicesForThisSubCat.map((s) => _buildCheckItem(
                        context.serverLabel((s['serviceType']['Name'] ?? s['serviceType']['Code'] ?? 'Unknown').toString()),
                        primaryColor
                    )),
                  ],
                ),
              ),
            ),
          );
        }
      }
      return cards;
    } else {
      // Standard logic for HomeCare & other modules using variants
      return selectedServiceData.map((data) => Padding(
          padding: const EdgeInsets.only(right: 10),
          child: _buildServiceInfoCard(data, primaryColor)
      )).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).colorScheme.primary;
    final colorScheme = Theme.of(context).colorScheme;
    final isPersonalCare = (moduleCode.toUpperCase() == 'PC');

    String subCategoryHint;
    if (isPersonalCare) {
      subCategoryHint = selectedSubCategories.isEmpty
          ? context.l10n.setupSelectSubCategories
          : (selectedSubCategories.length == 1 ? selectedSubCategories.first['Name'] : context.l10n.setupSubCategoriesSelected(selectedSubCategories.length));
    } else {
      subCategoryHint = selectedSubCategoryName ?? context.l10n.setupSelectSubCategories;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.setupAddCategoriesTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(context.l10n.setupAddCategoriesSubtitle, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),

            if (hasCategory) ...[
              _buildLabel(context.l10n.setupCategories),
              _buildDropdownTrigger(
                hint: selectedCategoryName ?? context.l10n.setupSelectCategories,
                onTap: () => _showSingleSelectionSheet(title: context.l10n.setupSelectCategories, future: fetchCategories(), isCategory: true),
              ),
              const SizedBox(height: 20),
            ],

            _buildLabel(context.l10n.setupSubCategories),
            _buildDropdownTrigger(
              hint: subCategoryHint,
              enabled: hasCategory ? selectedCategoryId != null : true,
              onTap: () {
                if (isPersonalCare) {
                  _showMultiSubCategorySheet();
                } else {
                  _showSingleSelectionSheet(title: context.l10n.setupSelectSubCategories, future: fetchSubCategories(), isCategory: false);
                }
              },
            ),
            const SizedBox(height: 16),

            if (isPersonalCare && selectedSubCategories.isNotEmpty) ...[
              _buildSelectedSubCategoriesBox(),
              const SizedBox(height: 16),
            ],

            if (shouldShowServiceSection) ...[
              _buildLabel(isPersonalCare ? context.l10n.setupService : context.l10n.setupServiceType),
              _buildDropdownTrigger(
                  hint: isPersonalCare ? context.l10n.setupSelectService : context.l10n.setupSelectServiceType,
                  enabled: isPersonalCare ? selectedSubCategories.isNotEmpty : selectedSubCategoryId != null,
                  onTap: _showServiceSelectionSheet
              ),

              if (selectedServiceData.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 0.0),
                  child: Scrollbar(
                    controller: _scrollController, thumbVisibility: true, trackVisibility: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8.0),
                      child: SingleChildScrollView(
                        controller: _scrollController, scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start, // Prevents cards from vertically stretching strangely
                          children: _buildServiceCardsList(primaryColor), // Replaced single mapping with dynamic logic
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],

            _buildLabel(context.l10n.setupYearOfExperience),
            _buildDropdownTrigger(hint: selectedYear ?? context.l10n.setupSelectYears, onTap: _showYearSheet),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _prepareAndShowJson,
                style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary, disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.6), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: _isLoading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : Text(context.l10n.commonNext, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));
  }

  Widget _buildDropdownTrigger({required String hint, required VoidCallback onTap, bool enabled = true}) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border, width: 1.2), borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(hint, style: TextStyle(color: enabled ? Colors.black87 : Colors.grey)), const Icon(Icons.keyboard_arrow_down, color: Colors.black54)],
        ),
      ),
    );
  }

  Widget _buildSelectedSubCategoriesBox() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.background, border: Border.all(color: AppColors.textDisabled, width: 1), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.setupSelectedSubCategories, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor, fontSize: 15)),
          const SizedBox(height: 8),
          ...selectedSubCategories.map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                  children: [
                    Container(decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.check, size: 14, color: Colors.white)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(context.serverLabel(c['Name'].toString()), style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor, fontSize: 13)))
                  ]
              )
          )),
        ],
      ),
    );
  }

  Widget _buildServiceInfoCard(Map<String, dynamic> data, Color themeColor) {
    String typeName = data['serviceType']['Name'] ?? 'Unknown';
    List variants = data['variants'] ?? [];

    return Container(
      width: MediaQuery.of(context).size.width * 0.50, padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.border, border: Border.all(color: themeColor.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.serverLabel(typeName), style: TextStyle(fontWeight: FontWeight.bold, color: themeColor, fontSize: 16)),

          if (!_shouldHideVariants) ...[
            const SizedBox(height: 10),
            if (variants.isEmpty) Text(context.l10n.setupNoVariants, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            ...variants.map((v) => _buildCheckItem(v['Name'], themeColor)),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Helps if text spans multiple lines
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Icon(Icons.check_box, size: 16, color: themeColor),
          ),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: themeColor, fontSize: 14))),
        ],
      ),
    );
  }
}