import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/job_progress_entity.dart';
import '../../domain/usecases/cancel_job_usecase.dart';
import '../../domain/usecases/complete_job_usecase.dart';
import '../../domain/usecases/upload_work_image_usecase.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

class UploadItem {
  final XFile file;
  bool isUploading;
  String? serverPath;
  bool isError;

  UploadItem({
    required this.file,
    this.isUploading = true,
    this.serverPath,
    this.isError = false,
  });
}

typedef JobProgressController = JobProgressProvider;

class JobProgressProvider extends ChangeNotifier {
  final UploadWorkImageUseCase uploadWorkImageUseCase;
  final CancelJobUseCase cancelJobUseCase;
  final CompleteJobUseCase completeJobUseCase;

  JobProgressProvider({
    required this.uploadWorkImageUseCase,
    required this.cancelJobUseCase,
    required this.completeJobUseCase,
  });

  JobProgressStep _step = JobProgressStep.step1;
  String? _customerAvailability;
  bool _isSubmitting = false;
  String? _errorMessage;

  final List<UploadItem> _selfieImages = [];
  final List<UploadItem> _beforeImages = [];
  final List<UploadItem> _afterImages = [];

  JobProgressStep get step => _step;
  String? get customerAvailability => _customerAvailability;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  List<UploadItem> get selfieImages => _selfieImages;
  List<UploadItem> get beforeImages => _beforeImages;
  List<UploadItem> get afterImages => _afterImages;

  void setCustomerAvailability(String value) {
    _customerAvailability = value;
    notifyListeners();
  }

  void goToStep2() {
    _step = JobProgressStep.step2;
    notifyListeners();
  }

  void removeImage(List<UploadItem> list, int index) {
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> addImages(List<UploadItem> targetList, List<XFile> pickedFiles) async {
    for (var file in pickedFiles) {
      final item = UploadItem(file: file, isUploading: true);
      targetList.add(item);
      notifyListeners();

      _uploadFile(item);
    }
  }

  Future<void> _uploadFile(UploadItem item) async {
    try {
      final bytes = await item.file.readAsBytes();
      final base64Data = base64Encode(bytes);

      final result = await uploadWorkImageUseCase(
        filename: item.file.name,
        base64Data: base64Data,
      );

      result.when(
        success: (filePath) {
          item.serverPath = filePath;
          item.isUploading = false;
          item.isError = false;
          notifyListeners();
        },
        failure: (_) {
          item.isUploading = false;
          item.isError = true;
          notifyListeners();
        },
      );
    } catch (_) {
      item.isUploading = false;
      item.isError = true;
      notifyListeners();
    }
  }

  Future<bool> cancelJob({
    required String partnerId,
    required String jobId,
    required String reason,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await cancelJobUseCase(
      partnerId: partnerId,
      jobId: jobId,
      reason: reason,
    );

    bool isSuccess = false;
    result.when(
      success: (_) {
        _isSubmitting = false;
        isSuccess = true;
        notifyListeners();
      },
      failure: (message) {
        _errorMessage = message;
        _isSubmitting = false;
        isSuccess = false;
        notifyListeners();
      },
    );

    return isSuccess;
  }

  Future<bool> completeJob({
    required String partnerId,
    required String jobId,
    required String reason,
  }) async {
    final allItems = [..._selfieImages, ..._beforeImages, ..._afterImages];

    if (allItems.isEmpty) {
      _errorMessage = L10n.current.uploadAtLeastOne;
      notifyListeners();
      return false;
    }

    if (allItems.any((item) => item.isUploading)) {
      _errorMessage = L10n.current.waitForUploads;
      notifyListeners();
      return false;
    }

    if (allItems.any((item) => item.isError || item.serverPath == null)) {
      _errorMessage = L10n.current.someUploadsFailed;
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final workPicUrls = allItems.map((item) => item.serverPath!).toList();

    final result = await completeJobUseCase(
      partnerId: partnerId,
      jobId: jobId,
      workPicUrls: workPicUrls,
      reason: reason,
    );

    bool isSuccess = false;
    result.when(
      success: (_) {
        _isSubmitting = false;
        isSuccess = true;
        notifyListeners();
      },
      failure: (message) {
        _errorMessage = message;
        _isSubmitting = false;
        isSuccess = false;
        notifyListeners();
      },
    );

    return isSuccess;
  }
}
