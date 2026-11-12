import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:gotask_partner/core/design/app_top_bar.dart';
import 'package:gotask_partner/core/localization/server_labels.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../main.dart' show userID, userFirstName;
import '../../domain/entities/job_progress_entity.dart';
import '../providers/job_progress_provider.dart';
import '../widgets/job_upload_section_widget.dart';
import 'package:gotask_partner/core/design/app_colors.dart';
import 'package:gotask_partner/core/localization/locale_provider.dart';

class JobProgressScreen extends StatefulWidget {
  final String jobId;
  final String jobTitle;
  final double jobAmount;
  final String jobDateTime;
  final bool isInstant;
  final String etaLabel;
  final List<String> aboutPoints;

  const JobProgressScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
    required this.jobAmount,
    required this.jobDateTime,
    required this.isInstant,
    required this.etaLabel,
    required this.aboutPoints,
  });

  @override
  State<JobProgressScreen> createState() => _JobProgressScreenState();
}

class _JobProgressScreenState extends State<JobProgressScreen> {
  static const Color _blue = AppColors.primaryPressed;
  static const Color _orange = AppColors.warning;
  static const Color _reject = AppColors.accent;

  late final JobProgressProvider _provider;
  final TextEditingController _feedbackController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _provider = ServiceLocator.createJobProgressProvider();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _provider.dispose();
    super.dispose();
  }

  void _showImageSourceSheet(List<UploadItem> target) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.primaryPressed,
                ),
                title: Text(context.l10n.takePhoto),
                onTap: () async {
                  Navigator.pop(context);
                  final p = await _picker.pickImage(
                    source: ImageSource.camera,
                    // About 150-300 KB: clear enough for proof of work, quick on mobile data.
                    maxWidth: 1280,
                    maxHeight: 1280,
                    imageQuality: 70,
                  );
                  if (p != null && mounted) {
                    _provider.addImages(target, [p]);
                  }
                },
              ),
              // Camera only, as in the 6 Nov app (gallery removed so work photos are taken on site).
            ],
          ),
        ),
      ),
    );
  }

  void _onNext() {
    if (_provider.customerAvailability == null) {
      AppSnackBar.error(context.l10n.selectAvailability);
      return;
    }
    _provider.goToStep2();
  }

  Future<void> _onSubmit() async {
    final feedback = _feedbackController.text.trim();

    if (feedback.isEmpty) {
      AppSnackBar.error(context.l10n.enterFeedback);
      return;
    }

    if (_provider.customerAvailability == 'No') {
      await _showCancelConfirmation();
    } else {
      await _submitCompletedJob();
    }
  }

  Future<void> _showCancelConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          context.l10n.closeJob,
          style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
        ),
        content: Text(
          context.l10n.closeJobConfirm,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              context.l10n.commonNo,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _reject,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(context.l10n.commonYes, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _submitCancelledJob();
    }
  }

  Future<void> _submitCancelledJob() async {
    final success = await _provider.cancelJob(
      partnerId: userID,
      jobId: widget.jobId,
      reason: _feedbackController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      _navigateToSuccess();
    } else {
      AppSnackBar.error(
        _provider.errorMessage ?? context.l10n.cancelJobFailed,
      );
    }
  }

  Future<void> _submitCompletedJob() async {
    final success = await _provider.completeJob(
      partnerId: userID,
      jobId: widget.jobId,
      reason: _feedbackController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      _navigateToSuccess();
    } else {
      AppSnackBar.error(
        _provider.errorMessage ?? context.l10n.completeJobFailed,
      );
    }
  }

  void _navigateToSuccess() {
    context.pushReplacement(
      AppRoutes.workStatusSuccess,
      extra: userFirstName.isNotEmpty ? userFirstName : context.l10n.partnerFallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<JobProgressProvider>.value(
      value: _provider,
      child: Consumer<JobProgressProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
 top: false,
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildJobHeader(),
                          const SizedBox(height: 16),
                          _buildDivider(),
                          const SizedBox(height: 16),
                          _buildAbout(),
                          const SizedBox(height: 16),
                          _buildDivider(),
                          const SizedBox(height: 20),
                          _buildStartJobLabel(),
                          const SizedBox(height: 20),
                          _buildAvailabilityDropdown(provider),
                          const SizedBox(height: 24),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) => FadeTransition(
                              opacity: anim,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.04),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: anim,
                                  curve: Curves.easeOutCubic,
                                )),
                                child: child,
                              ),
                            ),
                            child: provider.step == JobProgressStep.step2
                                ? (provider.customerAvailability == 'Yes'
                                    ? _buildStep2Yes(provider,
                                        key: const ValueKey('yes'))
                                    : _buildStep2No(key: const ValueKey('no')))
                                : const SizedBox.shrink(key: ValueKey('empty')),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomButton(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return AppTopBar(title: context.l10n.jobProgressTitle);
  }

  Widget _buildJobHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.jobTitle,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ),
            Text(
              '₹${widget.jobAmount.toInt()}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.jobDateTime,
          style: const TextStyle(fontSize: 12, color: AppColors.textDisabled),
        ),
        if (widget.isInstant) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _orange.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 15, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.instantLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.etaLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAbout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.aboutService,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.jobTitle,
          style: const TextStyle(fontSize: 13, color: AppColors.textDisabled),
        ),
        const SizedBox(height: 10),
        ...widget.aboutPoints.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                Expanded(
                  child: Text(
                    p,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartJobLabel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.startJob,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.fillDetailsBeforeWork,
          style: const TextStyle(fontSize: 13, color: AppColors.textDisabled),
        ),
      ],
    );
  }

  Widget _buildAvailabilityDropdown(JobProgressProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.customerAvailable,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: provider.customerAvailability,
              hint: Text(
                context.l10n.selectHint,
                style: const TextStyle(fontSize: 14, color: AppColors.textDisabled),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textMuted,
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              isExpanded: true,
              onChanged: provider.step == JobProgressStep.step1
                  ? (val) {
                      if (val != null) {
                        provider.setCustomerAvailability(val);
                      }
                    }
                  : null,
              items: ['Yes', 'No']
                  .map((v) => DropdownMenuItem(value: v, child: Text(v == 'Yes' ? context.l10n.commonYes : context.l10n.commonNo)))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2Yes(JobProgressProvider provider, {Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JobUploadSectionWidget(
          title: context.l10n.selfieTitle,
          subtitle:
              context.l10n.selfieSubtitle,
          images: provider.selfieImages,
          onAdd: () => _showImageSourceSheet(provider.selfieImages),
          onRemove: (i) => provider.removeImage(provider.selfieImages, i),
        ),
        const SizedBox(height: 20),
        JobUploadSectionWidget(
          title: context.l10n.beforeRepairTitle,
          subtitle: context.l10n.beforeRepairSubtitle,
          images: provider.beforeImages,
          onAdd: () => _showImageSourceSheet(provider.beforeImages),
          onRemove: (i) => provider.removeImage(provider.beforeImages, i),
        ),
        const SizedBox(height: 20),
        JobUploadSectionWidget(
          title: context.l10n.afterRepairTitle,
          subtitle: context.l10n.afterRepairSubtitle,
          images: provider.afterImages,
          onAdd: () => _showImageSourceSheet(provider.afterImages),
          onRemove: (i) => provider.removeImage(provider.afterImages, i),
        ),
        const SizedBox(height: 24),
        _buildFeedbackField(provider),
      ],
    );
  }

  Widget _buildStep2No({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<JobProgressProvider>(
          builder: (context, provider, _) => _buildFeedbackField(provider),
        ),
      ],
    );
  }

  Widget _buildFeedbackField(JobProgressProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.feedbackReason,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: _feedbackController,
            maxLines: 5,
            style: const TextStyle(fontSize: 14, color: AppColors.text),
            decoration: InputDecoration(
              hintText: provider.customerAvailability == 'Yes'
                  ? context.l10n.feedbackHint
                  : context.l10n.closeReasonHint,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.textDisabled,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() =>
      Container(height: 1, color: AppColors.background);

  Widget _buildBottomButton(JobProgressProvider provider) {
    final String label;
    final VoidCallback? action;

    if (provider.step == JobProgressStep.step1) {
      label = context.l10n.commonNext;
      action = _onNext;
    } else if (provider.customerAvailability == 'No') {
      label = context.l10n.closeJob;
      action = _onSubmit;
    } else {
      label = context.l10n.workDone;
      action = _onSubmit;
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: provider.isSubmitting ? null : action,
          style: ElevatedButton.styleFrom(
            backgroundColor: _blue,
            disabledBackgroundColor: _blue.withOpacity(0.6),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
            elevation: 0,
          ),
          child: provider.isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}
