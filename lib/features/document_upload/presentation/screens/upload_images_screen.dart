import 'package:gotask_partner/core/session/app_session.dart';
import 'dart:developer' show log;
import 'dart:convert';
import 'dart:io';
import 'package:gotask_partner/core/design/app_top_bar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/models/User.dart';
import '../../../../core/provider/UserProvider.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/widgets/common_loading_overlay.dart';
import '../../data/models/document_urls_model.dart';
import '../providers/document_upload_provider.dart';

import '../../domain/entities/partner_category.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';
export '../../domain/entities/document_urls_entity.dart';
export '../../domain/entities/partner_category.dart';
export '../../data/models/document_urls_model.dart';

typedef DocumentUrls = DocumentUrlsModel;

class SvgGenImage {
  final String path;
  const SvgGenImage(this.path);

  SvgPicture svg({double? width, double? height, Color? color, BoxFit fit = BoxFit.contain}) {
    return SvgPicture.asset(
      path,
      width: width,
      height: height,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      fit: fit,
    );
  }
}

final SvgGenImage icUploadImages = const SvgGenImage('assets/icons/ic_upload_images.svg');
final SvgGenImage icCamera = const SvgGenImage('assets/icons/ic_camera.svg');
final SvgGenImage icFile = const SvgGenImage('assets/icons/ic_file.svg');
final SvgGenImage icGallery = const SvgGenImage('assets/icons/ic_gallery.svg');

class _DocField {
  final String id;
  final String label;
  final String? subtitle;
  final bool isOptional;
  final bool isPhoto;
  final bool allowMultiple;

  const _DocField({
    required this.id,
    required this.label,
    this.subtitle,
    this.isOptional = false,
    this.isPhoto = false,
    this.allowMultiple = false,
  });
}

class _DropdownField {
  final String id;
  final String label;
  final List<String> options;
  String selected;

  _DropdownField({
    required this.id,
    required this.label,
    required this.options,
    required this.selected,
  });
}

List<_DocField> _fieldsFor(PartnerCategory cat) {
  const profilePicField = _DocField(
    id: 'profile_pic',
    label: 'Profile Picture',
    subtitle: 'Upload a clear profile photo',
    isPhoto: true,
    allowMultiple: false,
  );

  switch (cat) {
    case PartnerCategory.homeServices:
    case PartnerCategory.personalCare:
    case PartnerCategory.learningServices:
    case PartnerCategory.events:
      return const [
        profilePicField,
        _DocField(id: 'aadhar_front', label: 'Upload Aadhaar Card Front'),
        _DocField(id: 'aadhar_back', label: 'Upload Aadhaar Card Back'),
        _DocField(id: 'pan', label: 'Upload Pan Card'),
        _DocField(id: 'address', label: 'Address Proof (Bill/Rental)', subtitle: 'Upload Bill/Rental agreement'),
        _DocField(id: 'tool_photos', label: 'Tool Photos', isPhoto: true, allowMultiple: false),
      ];
    case PartnerCategory.drivers:
      return const [
        profilePicField,
        _DocField(id: 'aadhar_front', label: 'Upload Aadhaar Card Front'),
        _DocField(id: 'aadhar_back', label: 'Upload Aadhaar Card Back'),
        _DocField(id: 'pan', label: 'Upload Pan Card'),
        _DocField(id: 'driving_license', label: 'Upload Driving License', subtitle: 'Required for Driver Verification'),
        _DocField(id: 'address', label: 'Address Proof (Bill/Rental)', subtitle: 'Upload Bill/Rental agreement'),
        _DocField(id: 'tool_photos', label: 'Tool Photos', isPhoto: true, allowMultiple: false),
      ];
    case PartnerCategory.medical:
      return const [
        profilePicField,
        _DocField(id: 'aadhar_front', label: 'Upload Aadhaar Card Front'),
        _DocField(id: 'aadhar_back', label: 'Upload Aadhaar Card Back'),
        _DocField(id: 'pan', label: 'Upload Pan Card'),
        _DocField(id: 'qualification_cert', label: 'Upload Qualification Certificate', subtitle: 'Required for Medical Verification'),
        _DocField(id: 'experience_cert', label: 'Upload Experience Certificate', subtitle: 'Required for Verification'),
        _DocField(id: 'address', label: 'Address Proof (Bill/Rental)', subtitle: 'Upload Bill/Rental agreement'),
      ];
    case PartnerCategory.purohit:
      return const [
        profilePicField,
        _DocField(id: 'aadhar_front', label: 'Upload Aadhaar Card Front'),
        _DocField(id: 'aadhar_back', label: 'Upload Aadhaar Card Back'),
        _DocField(id: 'pan', label: 'Upload Pan Card'),
        _DocField(id: 'address', label: 'Address Proof (Bill/Rental)', subtitle: 'Upload Bill/Rental agreement'),
      ];
  }
}

List<_DropdownField> _dropdownsFor(PartnerCategory cat) {
  if (cat == PartnerCategory.learningServices) {
    return [
      _DropdownField(
          id: 'qualification',
          label: 'Qualification',
          options: ['B.Ed', 'M.Ed', 'B.Sc', 'M.Sc', 'B.A', 'M.A', 'Other'],
          selected: 'B.Ed'),
      _DropdownField(
          id: 'availability',
          label: 'Availability',
          options: ['Mon - Fri', 'Mon - Sat', 'Weekends', 'Flexible'],
          selected: 'Mon - Fri'),
    ];
  }
  return [];
}

class _PickedFile {
  final String path;
  final String name;
  final bool isImage;
  String? s3Url;
  bool isUploading;

  _PickedFile({
    required this.path,
    required this.name,
    required this.isImage,
    this.s3Url,
    this.isUploading = false,
  });

  factory _PickedFile.fromXFile(XFile file) {
    final ext = file.name.split('.').last.toLowerCase();
    return _PickedFile(
      path: file.path,
      name: file.name,
      isImage: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext),
    );
  }
}

/// Display text for the fixed document field labels; the field ids and the
/// values sent to the server are unchanged.
String _docText(String s) {
  final l = L10n.current;
  final map = <String, String>{
    'Profile Picture': l.docProfilePicture,
    'Upload a clear profile photo': l.docProfilePictureSub,
    'Upload Aadhaar Card Front': l.docAadhaarFront,
    'Upload Aadhaar Card Back': l.docAadhaarBack,
    'Upload Pan Card': l.docPan,
    'Address Proof (Bill/Rental)': l.docAddressProof,
    'Upload Bill/Rental agreement': l.docAddressProofSub,
    'Tool Photos': l.docToolPhotos,
    'Upload Driving License': l.docDrivingLicense,
    'Required for Driver Verification': l.docDrivingLicenseSub,
    'Upload Qualification Certificate': l.docQualification,
    'Required for Medical Verification': l.docQualificationSub,
    'Upload Experience Certificate': l.docExperience,
    'Required for Verification': l.docExperienceSub,
    'Qualification': l.docQualificationLabel,
    'Availability': l.docAvailabilityLabel,
  };
  return map[s] ?? s;
}

class UploadImagesScreen extends StatefulWidget {
  final PartnerCategory category;
  final VoidCallback? onNext;
  final void Function(DocumentUrls urls)? onNextWithUrls;

  const UploadImagesScreen({
    super.key,
    this.category = PartnerCategory.homeServices,
    this.onNext,
    this.onNextWithUrls,
  });

  @override
  State<UploadImagesScreen> createState() => _UploadImagesScreenState();
}

class _UploadImagesScreenState extends State<UploadImagesScreen> {
  final Map<String, List<_PickedFile>> _uploads = {};
  late PartnerCategory _currentCategory;
  late List<_DocField> _fields;
  late List<_DropdownField> _dropdowns;
  final ImagePicker _imagePicker = ImagePicker();
  final Set<_PickedFile> _uploadingFiles = {};
  final DocumentUrls _documentUrls = DocumentUrls();

  bool _isLoading = false;
  bool _isPickingImage = false;
  late final UploadImagesController _controller;

  double _registrationFee = 500.0;

  @override
  void initState() {
    super.initState();
    _controller = ServiceLocator.createUploadImagesController();
    _currentCategory = widget.category;
    _fields = _fieldsFor(_currentCategory);
    _dropdowns = _dropdownsFor(_currentCategory);

    _resolveCategoryAndPrefill();
    _fetchRegistrationFee();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchRegistrationFee() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _registrationFee = prefs.getDouble('registrationFee') ?? 500.0;
      });
    }
  }

  Future<void> _resolveCategoryAndPrefill() async {
    final user = await UserProvider.getCurrentUser();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? profProfileStr = prefs.getString('professionalProfile');

    String moduleName = "";

    if (profProfileStr != null && profProfileStr.isNotEmpty) {
      try {
        var decodedData = jsonDecode(profProfileStr);
        var professionalProfileData = decodedData is Map ? [decodedData] : decodedData;
        if (professionalProfileData != null && professionalProfileData.isNotEmpty) {
          var serviceTypesList = professionalProfileData[0]['profile']['serviceTypes'] as List;
          if (serviceTypesList.isNotEmpty) {
            moduleName = serviceTypesList[0]['moduleName']?.toString() ?? "";
          }
        }
      } catch (e) {
        log('upload_images: $e');
      }
    }

    if (moduleName.isEmpty && user != null && user.skills.isNotEmpty) {
      moduleName = user.skills.first['moduleName']?.toString() ?? "";
    }

    if (mounted) {
      setState(() {
        if (moduleName.isNotEmpty) {
          String upper = moduleName.toUpperCase();
          if (upper.contains("PHYSIOTHERAPY") || upper.contains("NURSING") || upper.contains("CAREGIVER") || upper.contains("MEDICAL")) {
            _currentCategory = PartnerCategory.medical;
          } else if (upper.contains("DRIVER")) {
            _currentCategory = PartnerCategory.drivers;
          } else if (upper.contains("LEARNING")) {
            _currentCategory = PartnerCategory.learningServices;
          } else if (upper.contains("PUROHIT") || upper.contains("PANDIT")) {
            _currentCategory = PartnerCategory.purohit;
          } else if (upper.contains("PERSONAL CARE")) {
            _currentCategory = PartnerCategory.personalCare;
          } else {
            _currentCategory = PartnerCategory.homeServices;
          }

          _fields = _fieldsFor(_currentCategory);
          _dropdowns = _dropdownsFor(_currentCategory);
        }

        if (user != null) {
          if (user.Avatar.isNotEmpty) {
            _documentUrls.profilePic = user.Avatar;
            _uploads['profile_pic'] = [
              _PickedFile(path: user.Avatar, name: 'Profile.png', isImage: true, s3Url: user.Avatar)
            ];
          }
          if (user.AadharPicFront.isNotEmpty) {
            _documentUrls.aadharPicFront = user.AadharPicFront;
            _uploads['aadhar_front'] = [
              _PickedFile(path: user.AadharPicFront, name: 'Aadhar_F.png', isImage: true, s3Url: user.AadharPicFront)
            ];
          }
          if (user.AadharPicBack.isNotEmpty) {
            _documentUrls.aadharPicBack = user.AadharPicBack;
            _uploads['aadhar_back'] = [
              _PickedFile(path: user.AadharPicBack, name: 'Aadhar_B.png', isImage: true, s3Url: user.AadharPicBack)
            ];
          }
          if (user.PanPics.isNotEmpty) {
            _documentUrls.panPics = user.PanPics;
            _uploads['pan'] = [
              _PickedFile(path: user.PanPics, name: 'Pan.png', isImage: true, s3Url: user.PanPics)
            ];
          }
          if (user.QualificationCertificate.isNotEmpty) {
            _documentUrls.qualificationCert = user.QualificationCertificate;
            _uploads['qualification_cert'] = [
              _PickedFile(path: user.QualificationCertificate, name: 'Qualification.png', isImage: true, s3Url: user.QualificationCertificate)
            ];
          }
          if (user.ToolPhoto.isNotEmpty) {
            _documentUrls.toolPhoto = user.ToolPhoto;
            _uploads['tool_photos'] = [
              _PickedFile(path: user.ToolPhoto, name: 'Tools.png', isImage: true, s3Url: user.ToolPhoto)
            ];
          }
          if (user.AddressProof.isNotEmpty) {
            _documentUrls.addressProof = user.AddressProof;
            _uploads['address'] = [
              _PickedFile(path: user.AddressProof, name: 'Address.png', isImage: true, s3Url: user.AddressProof)
            ];
          }
        }
      });
    }
  }

  Future<void> _uploadToS3AndStore(String fieldId, _PickedFile file) async {
    if (!mounted) return;
    setState(() {
      file.isUploading = true;
      _uploadingFiles.add(file);
    });

    final url = await _controller.uploadFile(XFile(file.path, name: file.name));

    if (!mounted) return;

    setState(() {
      file.s3Url = url ?? '';
      file.isUploading = false;
      _uploadingFiles.remove(file);
    });

    if (!(_uploads[fieldId]?.contains(file) ?? false)) return;

    if (url != null && url.isNotEmpty) {
      _storeUrl(fieldId, url, file);
    } else {
      _showError(_controller.errorMessage ?? context.l10n.docUploadFailedFor(file.name));
    }
  }

  void _storeUrl(String fieldId, String url, _PickedFile file) {
    switch (fieldId) {
      case 'profile_pic':
        _documentUrls.profilePic = url;
        break;
      case 'aadhar_front':
        _documentUrls.aadharPicFront = url;
        break;
      case 'aadhar_back':
        _documentUrls.aadharPicBack = url;
        break;
      case 'pan':
        _documentUrls.panPics = url;
        break;
      case 'tool_photos':
        _documentUrls.toolPhoto = url;
        break;
      case 'address':
        _documentUrls.addressProof = url;
        break;
      case 'qualification_cert':
        _documentUrls.qualificationCert = url;
        break;
      case 'experience_cert':
        _documentUrls.experienceCert = url;
        break;
      case 'selfie':
        _documentUrls.selfie = url;
        break;
      case 'driving_license':
        _documentUrls.drivingLicense = url;
        break;
      case 'rc':
        _documentUrls.rc = url;
        break;
      case 'police_cert':
        _documentUrls.policeCert = url;
        break;
      case 'certificate':
        _documentUrls.certificate = url;
        break;
      case 'salon_cert':
        _documentUrls.salonCert = url;
        break;
      case 'work_photos':
        if (!_documentUrls.workPhotos.contains(url)) _documentUrls.workPhotos.add(url);
        break;
      case 'work_media':
        if (!_documentUrls.workMedia.contains(url)) _documentUrls.workMedia.add(url);
        break;
    }
  }

  Future<void> _pickFromCamera(String fieldId, {bool allowMultiple = false}) async {
    if (_isPickingImage) return;
    _isPickingImage = true;
    try {
      var status = await Permission.camera.status;
      if (!status.isGranted) status = await Permission.camera.request();
      if (!status.isGranted) {
        _showError(status.isPermanentlyDenied
            ? L10n.current.docCameraDisabled
            : L10n.current.docCameraRequired);
        return;
      }

      // Evict unused memory caches before giving control to native camera
      PaintingBinding.instance.imageCache.clear();

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 60,
      );

      if (image != null && mounted) {
        final picked = _PickedFile.fromXFile(image);
        setState(() => _addFile(fieldId, picked, allowMultiple));
        await _uploadToS3AndStore(fieldId, picked);
      }
    } catch (_) {
      _showError(L10n.current.docCameraFailed);
    } finally {
      _isPickingImage = false;
    }
  }

  Future<void> _pickFromGallery(String fieldId, {bool allowMultiple = false}) async {
    if (_isPickingImage) return;
    _isPickingImage = true;
    try {
      PaintingBinding.instance.imageCache.clear();

      if (allowMultiple) {
        final List<XFile> images = await _imagePicker.pickMultiImage(
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 60,
        );
        if (images.isNotEmpty && mounted) {
          final pickedList = images.map((img) => _PickedFile.fromXFile(img)).toList();
          setState(() {
            for (final p in pickedList) {
              _addFile(fieldId, p, true);
            }
          });

          for (final p in pickedList) {
            await _uploadToS3AndStore(fieldId, p);
          }
        }
      } else {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 60,
        );
        if (image != null && mounted) {
          final picked = _PickedFile.fromXFile(image);
          setState(() => _addFile(fieldId, picked, false));
          await _uploadToS3AndStore(fieldId, picked);
        }
      }
    } catch (_) {
      _showError(L10n.current.docGalleryFailed);
    } finally {
      _isPickingImage = false;
    }
  }

  void _addFile(String fieldId, _PickedFile file, bool allowMultiple) {
    if (!allowMultiple) {
      _uploads[fieldId] = [file];
    } else {
      _uploads.putIfAbsent(fieldId, () => []).add(file);
    }
  }

  void _removeFile(String fieldId, int index) {
    final fileToRemove = _uploads[fieldId]?[index];

    if (fileToRemove != null && fileToRemove.isImage && !fileToRemove.path.startsWith('http')) {
      final file = File(fileToRemove.path);
      if (file.existsSync()) {
        PaintingBinding.instance.imageCache.evict(FileImage(file));
        try {
          file.deleteSync();
        } catch (e) {
          log('upload_images: $e');
        }
      }
    }

    setState(() {
      _uploads[fieldId]?.removeAt(index);
      if (_uploads[fieldId]?.isEmpty ?? false) _uploads.remove(fieldId);
      _clearUrl(fieldId);
    });
  }

  void _clearUrl(String fieldId) {
    switch (fieldId) {
      case 'profile_pic':
        _documentUrls.profilePic = null;
        break;
      case 'aadhar_front':
        _documentUrls.aadharPicFront = null;
        break;
      case 'aadhar_back':
        _documentUrls.aadharPicBack = null;
        break;
      case 'pan':
        _documentUrls.panPics = null;
        break;
      case 'tool_photos':
        _documentUrls.toolPhoto = null;
        break;
      case 'address':
        _documentUrls.addressProof = null;
        break;
      case 'qualification_cert':
        _documentUrls.qualificationCert = null;
        break;
      case 'experience_cert':
        _documentUrls.experienceCert = null;
        break;
      case 'selfie':
        _documentUrls.selfie = null;
        break;
      case 'driving_license':
        _documentUrls.drivingLicense = null;
        break;
      case 'rc':
        _documentUrls.rc = null;
        break;
      case 'police_cert':
        _documentUrls.policeCert = null;
        break;
      case 'certificate':
        _documentUrls.certificate = null;
        break;
      case 'salon_cert':
        _documentUrls.salonCert = null;
        break;
      case 'work_photos':
        _documentUrls.workPhotos = (_uploads['work_photos'] ?? [])
            .where((f) => f.s3Url != null && f.s3Url!.isNotEmpty)
            .map((f) => f.s3Url!)
            .toList();
        break;
      case 'work_media':
        _documentUrls.workMedia = (_uploads['work_media'] ?? [])
            .where((f) => f.s3Url != null && f.s3Url!.isNotEmpty)
            .map((f) => f.s3Url!)
            .toList();
        break;
    }
  }

  bool _validateAndSubmit() {
    if (_uploadingFiles.isNotEmpty) {
      _showError(context.l10n.docUploadsInProgress);
      return false;
    }

    final required = _fields.where((f) => !f.isOptional);
    for (final field in required) {
      final files = _uploads[field.id] ?? [];
      if (files.isEmpty) {
        _showError(context.l10n.docPleaseUpload(_docText(field.label)));
        return false;
      }
      final failedUploads = files.where((f) => f.s3Url == null || f.s3Url!.isEmpty);
      if (failedUploads.isNotEmpty) {
        _showError(context.l10n.docReuploadFailed(_docText(field.label)));
        return false;
      }
    }
    return true;
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        )
    );
  }

  void _showPickerSheet(String fieldId, {bool isPhoto = false, bool allowMultiple = false}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: Colors.white,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.docUploadImage,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.docChooseOption,
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),
                _SheetTile(
                  svgAsset: icCamera,
                  title: context.l10n.docCamera,
                  subtitle: context.l10n.docTakePhotoNow,
                  onTap: () async {
                    Navigator.pop(context);
                    await Future.delayed(const Duration(milliseconds: 300));
                    _pickFromCamera(fieldId, allowMultiple: allowMultiple);
                  },
                ),
                const SizedBox(height: 12),
                _SheetTile(
                  svgAsset: icGallery,
                  title: context.l10n.docGallery,
                  subtitle: context.l10n.docChooseLibrary,
                  onTap: () async {
                    Navigator.pop(context);
                    await Future.delayed(const Duration(milliseconds: 300));
                    _pickFromGallery(fieldId, allowMultiple: allowMultiple);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitWithoutPayment(User currentUser) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profProfileStr = prefs.getString('professionalProfile');

      dynamic professionalProfileData;
      List skillsToPass = currentUser.skills;
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
        } catch (e) {
          log('upload_images: $e');
        }
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

      final outcome = await _controller.submitWithoutPayment(
        user: currentUser,
        documentUrls: _documentUrls,
        moduleId: extractedModuleId,
        moduleName: extractedModuleName,
        professionalProfileData: professionalProfileData,
        skills: skillsToPass,
      );

      if (!mounted) return;

      if (outcome != FreeSubmitResult.documentsFailed) {
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
          Avatar: _documentUrls.profilePic ?? currentUser.Avatar,
          UPI: currentUser.UPI,
          PaymentGateWay: currentUser.PaymentGateWay,
          Experience: currentUser.Experience,
          RefContactPerson: currentUser.RefContactPerson,
          RefContactNumber: currentUser.RefContactNumber,
          skills: skillsToPass,
          AadharPicFront: _documentUrls.aadharPicFront ?? currentUser.AadharPicFront,
          AadharPicBack: _documentUrls.aadharPicBack ?? currentUser.AadharPicBack,
          PanPics: _documentUrls.panPics ?? currentUser.PanPics,
          ToolPhoto: _documentUrls.toolPhoto ?? currentUser.ToolPhoto,
          AddressProof: _documentUrls.addressProof ?? currentUser.AddressProof,
          QualificationCertificate: _documentUrls.qualificationCert ?? currentUser.QualificationCertificate,
        );

        if (!mounted) return;
        await Provider.of<UserProvider>(context, listen: false).setAsCurrentUser(updatedUser);
        if (!mounted) return;
        setState(() => _isLoading = false);
        if (outcome == FreeSubmitResult.done) {
          context.go(AppRoutes.paymentSuccess, extra: {"RequestDataID": ""});
        } else {
          // 6 Nov app: documents are saved, only the ₹0 record failed.
          context.push(AppRoutes.paymentFailed);
        }
      } else {
        setState(() => _isLoading = false);
        AppSnackBar.showError(context, _controller.errorMessage ?? context.l10n.feeUpdateFailed);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        AppSnackBar.showError(context, context.l10n.feeUnexpectedError('$e'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final showGlobalLoading = _uploadingFiles.isNotEmpty || _isLoading;

    return CommonLoadingOverlay(
      isLoading: showGlobalLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppTopBar(title: context.l10n.docDocumentation),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.docUploadDocuments,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.docUploadDocumentsSub,
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    ..._fields.map((field) => _buildField(field, primary)),
                    ..._dropdowns.map((dd) => _buildDropdown(dd, primary)),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -4)),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: showGlobalLoading ? null : () async {
                    if (_validateAndSubmit()) {
                      final currentUser = await UserProvider.getCurrentUser();
                      if (currentUser == null) return;

                      setState(() => _isLoading = true);

                      final bool isMedicalCategory = _currentCategory == PartnerCategory.medical;

                      if (_registrationFee == 0 || isMedicalCategory) {
                        await _submitWithoutPayment(currentUser);
                      } else {
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
                          Avatar: _documentUrls.profilePic ?? currentUser.Avatar,
                          UPI: currentUser.UPI,
                          PaymentGateWay: currentUser.PaymentGateWay,
                          Experience: currentUser.Experience,
                          RefContactPerson: currentUser.RefContactPerson,
                          RefContactNumber: currentUser.RefContactNumber,
                          skills: currentUser.skills,
                          AadharPicFront: _documentUrls.aadharPicFront ?? currentUser.AadharPicFront,
                          AadharPicBack: _documentUrls.aadharPicBack ?? currentUser.AadharPicBack,
                          PanPics: _documentUrls.panPics ?? currentUser.PanPics,
                          ToolPhoto: _documentUrls.toolPhoto ?? currentUser.ToolPhoto,
                          AddressProof: _documentUrls.addressProof ?? currentUser.AddressProof,
                          QualificationCertificate: _documentUrls.qualificationCert ?? currentUser.QualificationCertificate,
                        );

                        if (!mounted || !context.mounted) return;
                        await Provider.of<UserProvider>(context, listen: false).setAsCurrentUser(updatedUser);

                        if (!mounted || !context.mounted) return;
                        setState(() => _isLoading = false);
                        context.push(AppRoutes.activationFee);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: onPrimary,
                    disabledBackgroundColor: primary.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _registrationFee == 0 ? context.l10n.commonSubmit : context.l10n.commonNext,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(_DocField field, Color primary) {
    final files = _uploads[field.id] ?? [];
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: Text(
                        _docText(field.label),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
                      )
                  ),
                  if (field.isOptional) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)),
                      child: Text(context.l10n.docOptional, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
                    )
                  ],
                ],
              ),
              if (field.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(_docText(field.subtitle!), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
              const SizedBox(height: 8),
              if (field.isPhoto) _buildPhotoTile(field, files, primary) else _buildDocInputRow(field, files, primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyUploadCard(_DocField field, Color primary) {
    return GestureDetector(
      onTap: () => _showPickerSheet(field.id, isPhoto: field.isPhoto, allowMultiple: field.allowMultiple),
      child: _DashedBorderContainer(
        borderColor: AppColors.borderStrong,
        borderRadius: 12,
        child: SizedBox(
          height: 150,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                field.isPhoto
                    ? icCamera.svg(width: 32, height: 32, color: AppColors.textDisabled)
                    : icFile.svg(width: 32, height: 32, color: AppColors.textDisabled),
                const SizedBox(height: 8),
                Text(
                  field.isPhoto ? context.l10n.docTapAddPhoto : context.l10n.docTapUploadFile,
                  style: const TextStyle(fontSize: 12, color: AppColors.textDisabled),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilledUploadCard(_DocField field, List<_PickedFile> files, Color primary) {
    return _DashedBorderContainer(
      borderColor: AppColors.borderStrong,
      borderRadius: 12,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: files.asMap().entries.map((e) {
                    final idx = e.key;
                    final file = e.value;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildThumbnail(file, idx, field.id, primary),
                    );
                  }).toList(),
                ),
              ),
            ),
            if (field.allowMultiple || files.isEmpty) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showPickerSheet(field.id, isPhoto: field.isPhoto, allowMultiple: field.allowMultiple),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 2),
                    Text(
                      context.l10n.addMore,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ✅ MEMORY FIX: Downsample thumbnail bitmaps to 300x300 instead of 4000x3000
  Widget _buildThumbnail(_PickedFile file, int idx, String fieldId, Color primary) {
    bool isNetwork = file.path.startsWith('http');
    ImageProvider imageProvider = isNetwork
        ? ResizeImage(NetworkImage(file.path), width: 300, height: 300)
        : ResizeImage(FileImage(File(file.path)), width: 300, height: 300);

    return Stack(
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColors.border,
            image: file.isImage
                ? DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            )
                : null,
          ),
          child: !file.isImage
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              file.s3Url != null && file.s3Url!.isEmpty
                  ? const Icon(Icons.error_outline, color: Colors.redAccent, size: 28)
                  : icFile.svg(width: 28, height: 28, color: primary),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  file.s3Url != null && file.s3Url!.isEmpty ? context.l10n.docUploadFailed : file.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    color: file.s3Url != null && file.s3Url!.isEmpty ? Colors.redAccent : primary,
                  ),
                ),
              ),
            ],
          )
              : file.s3Url != null && file.s3Url!.isEmpty
              ? Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
              child: Text(
                context.l10n.docUploadFailedRetry,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 9, color: Colors.white),
              ),
            ),
          )
              : file.s3Url != null
              ? Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.8),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
              child: Text(
                context.l10n.docUploaded,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 9, color: Colors.white),
              ),
            ),
          )
              : null,
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeFile(fieldId, idx),
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0x22000000), blurRadius: 4, offset: Offset(0, 1))
                ],
              ),
              child: const Icon(Icons.close, size: 12, color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoTile(_DocField field, List<_PickedFile> files, Color primary) {
    return files.isEmpty ? _buildEmptyUploadCard(field, primary) : _buildFilledUploadCard(field, files, primary);
  }

  Widget _buildDocInputRow(_DocField field, List<_PickedFile> files, Color primary) {
    return files.isEmpty ? _buildEmptyUploadCard(field, primary) : _buildFilledUploadCard(field, files, primary);
  }

  Widget _buildDropdown(_DropdownField dd, Color primary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _docText(dd.label),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
          ),
          const SizedBox(height: 8),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: dd.selected,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: primary, size: 22),
                style: const TextStyle(fontSize: 14, color: AppColors.ink, fontWeight: FontWeight.w500),
                onChanged: (val) {
                  if (val != null) setState(() => dd.selected = val);
                },
                items: dd.options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderContainer extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double borderRadius;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;

  const _DashedBorderContainer({
    required this.child,
    this.borderColor = AppColors.borderStrong,
    this.borderRadius = 12,
    this.strokeWidth = 1.5,
    this.dashLength = 6,
    this.dashGap = 4,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: borderColor,
        radius: borderRadius,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        dashGap: dashGap,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;

  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius || old.strokeWidth != strokeWidth;
}

class _SheetTile extends StatelessWidget {
  final SvgGenImage svgAsset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetTile({
    required this.svgAsset,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: svgAsset.svg(color: primary),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: primary.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
